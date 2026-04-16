"""
Social Features Service
Handles: Community Pools, Live Events, Astrologer Directory, Challenges, Badges
"""

from datetime import datetime, timedelta
from typing import List, Dict, Optional, Tuple
from sqlalchemy.orm import Session
from decimal import Decimal
import json
import statistics
from collections import Counter

from app.models.social_models import (
    CommunityPool, PoolMember, PoolTransaction,
    LiveGenerationEvent, EventParticipant,
    Astrologer, AstrologerConsultation, AstrologerReview,
    Challenge, ChallengeParticipant, ChallengeWinner,
    BadgeDefinition, UserBadge, UserAchievement, UserLeaderboard
)


class SocialService:
    """Service for all social features"""
    
    # ========================================================================
    # 1. COMMUNITY POOL MANAGEMENT
    # ========================================================================
    
    @staticmethod
    def create_community_pool(
        db: Session,
        creator_id: int,
        pool_name: str,
        lottery_type: str,
        buy_in_amount: Decimal,
        num_tickets: int,
        max_members: int,
        description: str = None,
        split_strategy: str = "equal"
    ) -> CommunityPool:
        """Create a new community lottery pool"""
        
        pool = CommunityPool(
            creator_id=creator_id,
            pool_name=pool_name,
            description=description,
            lottery_type=lottery_type,
            buy_in_amount=buy_in_amount,
            num_tickets=num_tickets,
            max_members=max_members,
            split_strategy=split_strategy,
            draw_date=datetime.utcnow() + timedelta(days=7)  # Default: draw in 1 week
        )
        
        # Add creator as first member
        member = PoolMember(
            pool=pool,
            user_id=creator_id,
            contribution=buy_in_amount,
            num_shares=1
        )
        
        pool.members.append(member)
        
        db.add(pool)
        db.commit()
        db.refresh(pool)
        
        return pool
    
    @staticmethod
    def join_pool(
        db: Session,
        pool_id: int,
        user_id: int,
        contribution: Decimal
    ) -> PoolMember:
        """User joins a community pool"""
        
        pool = db.query(CommunityPool).filter(CommunityPool.id == pool_id).first()
        if not pool:
            raise ValueError(f"Pool {pool_id} not found")
        
        if len(pool.members) >= pool.max_members:
            raise ValueError("Pool is full")
        
        # Check if already member
        existing = db.query(PoolMember).filter(
            PoolMember.pool_id == pool_id,
            PoolMember.user_id == user_id
        ).first()
        if existing:
            raise ValueError("Already a member of this pool")
        
        # Create member
        member = PoolMember(
            pool_id=pool_id,
            user_id=user_id,
            contribution=contribution,
            num_shares=1
        )
        
        # Record transaction
        transaction = PoolTransaction(
            pool_id=pool_id,
            user_id=user_id,
            transaction_type="buy_in",
            amount=contribution,
            description=f"Joined pool: {pool.pool_name}"
        )
        
        db.add(member)
        db.add(transaction)
        db.commit()
        db.refresh(member)
        
        return member
    
    @staticmethod
    def calculate_pool_split(
        db: Session,
        pool_id: int,
        total_winnings: Decimal
    ) -> Dict[int, Decimal]:
        """Calculate winnings distribution for pool members"""
        
        pool = db.query(CommunityPool).filter(CommunityPool.id == pool_id).first()
        members = db.query(PoolMember).filter(PoolMember.pool_id == pool_id).all()
        
        distribution = {}
        
        if pool.split_strategy == "equal":
            # Equal split
            per_member = total_winnings / len(members)
            for member in members:
                distribution[member.user_id] = per_member
        
        elif pool.split_strategy == "contribution_based":
            # Based on contribution amount
            total_contribution = sum(m.contribution for m in members)
            for member in members:
                percentage = member.contribution / total_contribution
                distribution[member.user_id] = total_winnings * Decimal(str(percentage))
        
        return distribution
    
    @staticmethod
    def distribute_pool_winnings(
        db: Session,
        pool_id: int,
        winning_numbers: List[int],
        total_winnings: Decimal
    ) -> Dict[int, Decimal]:
        """Process pool winnings distribution"""
        
        pool = db.query(CommunityPool).filter(CommunityPool.id == pool_id).first()
        
        # Update pool
        pool.winning_numbers = winning_numbers
        pool.total_winnings = total_winnings
        pool.is_winner = True
        pool.status = "completed"
        pool.drawn_date = datetime.utcnow()
        
        # Calculate splits
        distribution = SocialService.calculate_pool_split(db, pool_id, total_winnings)
        
        # Record transactions
        for user_id, amount in distribution.items():
            member = db.query(PoolMember).filter(
                PoolMember.pool_id == pool_id,
                PoolMember.user_id == user_id
            ).first()
            
            if member:
                member.winnings_received = amount
            
            transaction = PoolTransaction(
                pool_id=pool_id,
                user_id=user_id,
                transaction_type="winning",
                amount=amount,
                status="completed",
                description=f"Prize from pool: {pool.pool_name}"
            )
            db.add(transaction)
        
        db.commit()
        return distribution
    
    # ========================================================================
    # 2. LIVE LUCKY GENERATION EVENTS
    # ========================================================================
    
    @staticmethod
    def create_live_event(
        db: Session,
        creator_id: int,
        event_name: str,
        lottery_type: str,
        target_numbers: int = 6,
        max_participants: int = 100,
        duration_minutes: int = 30
    ) -> LiveGenerationEvent:
        """Create a new live generation event"""
        
        now = datetime.utcnow()
        event = LiveGenerationEvent(
            creator_id=creator_id,
            event_name=event_name,
            lottery_type=lottery_type,
            target_numbers=target_numbers,
            max_participants=max_participants,
            duration_minutes=duration_minutes,
            start_time=now,
            end_time=now + timedelta(minutes=duration_minutes),
            status="live",
            collected_numbers=[]
        )
        
        db.add(event)
        db.commit()
        db.refresh(event)
        
        return event
    
    @staticmethod
    def join_live_event(
        db: Session,
        event_id: int,
        user_id: int,
        submitted_numbers: List[int]
    ) -> EventParticipant:
        """User submits numbers to live event"""
        
        event = db.query(LiveGenerationEvent).filter(
            LiveGenerationEvent.id == event_id
        ).first()
        
        if not event or event.status != "live":
            raise ValueError("Event not found or not live")
        
        if event.num_participants >= event.max_participants:
            raise ValueError("Event is full")
        
        # Create participation record
        participant = EventParticipant(
            event_id=event_id,
            user_id=user_id,
            submitted_numbers=submitted_numbers
        )
        
        # Add numbers to collected pool
        if event.collected_numbers is None:
            event.collected_numbers = []
        event.collected_numbers.extend(submitted_numbers)
        
        event.num_participants += 1
        event.num_submissions += 1
        
        db.add(participant)
        db.commit()
        db.refresh(participant)
        
        return participant
    
    @staticmethod
    def generate_final_numbers(
        db: Session,
        event_id: int,
        method: str = "frequency_based"
    ) -> List[int]:
        """Generate final numbers from collected submissions"""
        
        event = db.query(LiveGenerationEvent).filter(
            LiveGenerationEvent.id == event_id
        ).first()
        
        if not event:
            raise ValueError("Event not found")
        
        collected = event.collected_numbers or []
        target = event.target_numbers
        
        if method == "frequency_based":
            # Most frequently submitted numbers
            if collected:
                counter = Counter(collected)
                final = [num for num, _ in counter.most_common(target)]
            else:
                final = list(range(1, target + 1))
        
        elif method == "voting":
            # Democratic voting
            final = list(set(collected))[:target]
        
        elif method == "blend":
            # Mix of frequency and randomness
            counter = Counter(collected)
            top_half = [num for num, _ in counter.most_common(target // 2)]
            remaining = list(set(collected) - set(top_half))
            final = top_half + remaining[:target - len(top_half)]
        
        else:
            # Default: random
            final = list(set(collected))[:target]
        
        # Ensure exactly target_numbers
        while len(final) < target:
            final.append(max(final) + 1 if final else 1)
        
        event.final_numbers = final[:target]
        event.generation_method = method
        event.status = "completed"
        event.end_time = datetime.utcnow()
        
        db.commit()
        
        return final[:target]
    
    # ========================================================================
    # 3. ASTROLOGER DIRECTORY MANAGEMENT
    # ========================================================================
    
    @staticmethod
    def register_astrologer(
        db: Session,
        user_id: int,
        professional_name: str,
        specializations: List[str],
        hourly_rate: Decimal,
        experience_years: int,
        bio: str = None
    ) -> Astrologer:
        """Register a user as an astrologer"""
        
        astrologer = Astrologer(
            user_id=user_id,
            professional_name=professional_name,
            bio=bio,
            specializations=specializations,
            experience_years=experience_years,
            hourly_rate=hourly_rate,
            status="active"
        )
        
        db.add(astrologer)
        db.commit()
        db.refresh(astrologer)
        
        return astrologer
    
    @staticmethod
    def book_consultation(
        db: Session,
        astrologer_id: int,
        user_id: int,
        title: str,
        scheduled_time: datetime,
        consultation_type: str = "video_call",
        duration_minutes: int = 60
    ) -> AstrologerConsultation:
        """Book a consultation with an astrologer"""
        
        astrologer = db.query(Astrologer).filter(
            Astrologer.id == astrologer_id
        ).first()
        
        if not astrologer:
            raise ValueError("Astrologer not found")
        
        # Calculate cost
        hours = duration_minutes / 60
        total_cost = Decimal(str(hours)) * astrologer.hourly_rate
        
        consultation = AstrologerConsultation(
            astrologer_id=astrologer_id,
            user_id=user_id,
            title=title,
            scheduled_time=scheduled_time,
            consultation_type=consultation_type,
            duration_minutes=duration_minutes,
            rate=astrologer.hourly_rate,
            total_cost=total_cost,
            status="pending"
        )
        
        db.add(consultation)
        db.commit()
        db.refresh(consultation)
        
        return consultation
    
    @staticmethod
    def complete_consultation(
        db: Session,
        consultation_id: int,
        notes: str = None,
        recording_url: str = None
    ) -> AstrologerConsultation:
        """Mark consultation as completed"""
        
        consultation = db.query(AstrologerConsultation).filter(
            AstrologerConsultation.id == consultation_id
        ).first()
        
        if not consultation:
            raise ValueError("Consultation not found")
        
        consultation.status = "completed"
        consultation.completed_at = datetime.utcnow()
        consultation.notes_from_astrologer = notes
        consultation.recording_url = recording_url
        consultation.payment_status = "completed"
        
        db.commit()
        db.refresh(consultation)
        
        return consultation
    
    @staticmethod
    def review_astrologer(
        db: Session,
        astrologer_id: int,
        user_id: int,
        rating: int,
        review_text: str = None
    ) -> AstrologerReview:
        """Leave a review for an astrologer"""
        
        if rating < 1 or rating > 5:
            raise ValueError("Rating must be between 1 and 5")
        
        review = AstrologerReview(
            astrologer_id=astrologer_id,
            user_id=user_id,
            rating=rating,
            review_text=review_text
        )
        
        # Update astrologer rating
        astrologer = db.query(Astrologer).filter(
            Astrologer.id == astrologer_id
        ).first()
        
        all_reviews = db.query(AstrologerReview).filter(
            AstrologerReview.astrologer_id == astrologer_id
        ).all()
        
        ratings = [r.rating for r in all_reviews] + [rating]
        astrologer.average_rating = sum(ratings) / len(ratings)
        astrologer.total_reviews = len(ratings)
        
        db.add(review)
        db.commit()
        db.refresh(review)
        
        return review
    
    # ========================================================================
    # 4. CHALLENGES & COMPETITIONS
    # ========================================================================
    
    @staticmethod
    def create_challenge(
        db: Session,
        creator_id: int,
        challenge_name: str,
        challenge_type: str,
        lottery_type: str,
        correct_answer: List[int],
        start_date: datetime,
        end_date: datetime,
        prize_pool: Decimal = Decimal("100.00"),
        num_winners: int = 3
    ) -> Challenge:
        """Create a new challenge"""
        
        challenge = Challenge(
            creator_id=creator_id,
            challenge_name=challenge_name,
            challenge_type=challenge_type,
            lottery_type=lottery_type,
            correct_answer=correct_answer,
            start_date=start_date,
            end_date=end_date,
            prize_pool=prize_pool,
            num_winners=num_winners,
            status="active",
            prize_distribution={
                "1st": 0.5,
                "2nd": 0.3,
                "3rd": 0.2
            }
        )
        
        db.add(challenge)
        db.commit()
        db.refresh(challenge)
        
        return challenge
    
    @staticmethod
    def submit_challenge_answer(
        db: Session,
        challenge_id: int,
        user_id: int,
        submitted_answer: List[int]
    ) -> ChallengeParticipant:
        """Submit answer to a challenge"""
        
        challenge = db.query(Challenge).filter(
            Challenge.id == challenge_id
        ).first()
        
        if not challenge or challenge.status != "active":
            raise ValueError("Challenge not found or not active")
        
        # Check if already submitted
        existing = db.query(ChallengeParticipant).filter(
            ChallengeParticipant.challenge_id == challenge_id,
            ChallengeParticipant.user_id == user_id
        ).first()
        
        if existing:
            raise ValueError("Already submitted to this challenge")
        
        # Check if correct
        is_correct = set(submitted_answer) == set(challenge.correct_answer)
        score = 100 if is_correct else 0
        
        participant = ChallengeParticipant(
            challenge_id=challenge_id,
            user_id=user_id,
            submitted_answer=submitted_answer,
            is_correct=is_correct,
            score=score
        )
        
        challenge.total_participants += 1
        challenge.total_submissions += 1
        
        db.add(participant)
        db.commit()
        db.refresh(participant)
        
        return participant
    
    @staticmethod
    def determine_challenge_winners(
        db: Session,
        challenge_id: int
    ) -> List[ChallengeWinner]:
        """Determine and record challenge winners"""
        
        challenge = db.query(Challenge).filter(
            Challenge.id == challenge_id
        ).first()
        
        # Get correct submissions
        correct_submissions = db.query(ChallengeParticipant).filter(
            ChallengeParticipant.challenge_id == challenge_id,
            ChallengeParticipant.is_correct == True
        ).order_by(ChallengeParticipant.submission_time).all()
        
        winners = []
        distribution = challenge.prize_distribution or {"1st": 0.5, "2nd": 0.3, "3rd": 0.2}
        
        for rank, participant in enumerate(correct_submissions[:challenge.num_winners]):
            rank_name = {0: "1st", 1: "2nd", 2: "3rd"}.get(rank, f"{rank+1}th")
            percentage = distribution.get(rank_name, 0)
            prize_amount = challenge.prize_pool * Decimal(str(percentage))
            
            winner = ChallengeWinner(
                challenge_id=challenge_id,
                user_id=participant.user_id,
                rank=rank + 1,
                prize_amount=prize_amount,
                payout_status="pending"
            )
            
            participant.rank = rank + 1
            participant.prize_won = prize_amount
            
            db.add(winner)
            winners.append(winner)
        
        challenge.status = "completed"
        challenge.results_announced_at = datetime.utcnow()
        
        db.commit()
        
        return winners
    
    # ========================================================================
    # 5. BADGES & ACHIEVEMENTS
    # ========================================================================
    
    @staticmethod
    def unlock_badge(
        db: Session,
        user_id: int,
        badge_id: int
    ) -> UserBadge:
        """Unlock a badge for a user"""
        
        # Check if already unlocked
        existing = db.query(UserBadge).filter(
            UserBadge.user_id == user_id,
            UserBadge.badge_id == badge_id,
            UserBadge.is_unlocked == True
        ).first()
        
        if existing:
            return existing
        
        # Unlock badge
        badge = db.query(UserBadge).filter(
            UserBadge.user_id == user_id,
            UserBadge.badge_id == badge_id
        ).first()
        
        if not badge:
            badge = UserBadge(
                user_id=user_id,
                badge_id=badge_id
            )
        
        badge.is_unlocked = True
        badge.unlocked_at = datetime.utcnow()
        badge.progress_percentage = 100.0
        
        db.add(badge)
        db.commit()
        db.refresh(badge)
        
        return badge
    
    @staticmethod
    def update_badge_progress(
        db: Session,
        user_id: int,
        badge_id: int,
        progress: int
    ) -> UserBadge:
        """Update badge progress for a user"""
        
        badge = db.query(UserBadge).filter(
            UserBadge.user_id == user_id,
            UserBadge.badge_id == badge_id
        ).first()
        
        if not badge:
            badge = UserBadge(
                user_id=user_id,
                badge_id=badge_id,
                progress=0
            )
            db.add(badge)
        
        badge_def = db.query(BadgeDefinition).filter(
            BadgeDefinition.id == badge_id
        ).first()
        
        badge.progress = progress
        if badge_def:
            badge.progress_percentage = (progress / badge_def.threshold_value) * 100
        
        db.commit()
        db.refresh(badge)
        
        return badge
    
    @staticmethod
    def add_achievement(
        db: Session,
        user_id: int,
        achievement_type: str,
        achievement_name: str,
        target: int = 1
    ) -> UserAchievement:
        """Add a new achievement for tracking"""
        
        achievement = UserAchievement(
            user_id=user_id,
            achievement_type=achievement_type,
            achievement_name=achievement_name,
            target=target,
            progress=0
        )
        
        db.add(achievement)
        db.commit()
        db.refresh(achievement)
        
        return achievement
    
    @staticmethod
    def update_leaderboard(
        db: Session,
        user_id: int
    ) -> UserLeaderboard:
        """Update user leaderboard position"""
        
        leaderboard = db.query(UserLeaderboard).filter(
            UserLeaderboard.user_id == user_id
        ).first()
        
        if not leaderboard:
            leaderboard = UserLeaderboard(user_id=user_id)
            db.add(leaderboard)
        
        # Calculate badges
        badges_count = db.query(UserBadge).filter(
            UserBadge.user_id == user_id,
            UserBadge.is_unlocked == True
        ).count()
        
        # Calculate challenge wins
        challenge_wins = db.query(ChallengeWinner).filter(
            ChallengeWinner.user_id == user_id
        ).count()
        
        # Calculate pool winnings
        pool_winnings = db.query(PoolTransaction).filter(
            PoolTransaction.user_id == user_id,
            PoolTransaction.transaction_type == "winning"
        ).with_entities(
            db.func.sum(PoolTransaction.amount)
        ).scalar() or 0
        
        leaderboard.badge_count = badges_count
        leaderboard.challenge_wins = challenge_wins
        leaderboard.pool_winnings = pool_winnings
        leaderboard.total_points = (badges_count * 10) + (challenge_wins * 50)
        leaderboard.last_updated = datetime.utcnow()
        
        db.commit()
        db.refresh(leaderboard)
        
        return leaderboard
    
    @staticmethod
    def get_global_leaderboard(
        db: Session,
        limit: int = 100
    ) -> List[UserLeaderboard]:
        """Get global leaderboard"""
        
        leaderboard = db.query(UserLeaderboard).order_by(
            UserLeaderboard.total_points.desc(),
            UserLeaderboard.challenge_wins.desc()
        ).limit(limit).all()
        
        # Assign ranks
        for rank, entry in enumerate(leaderboard, 1):
            entry.global_rank = rank
        
        return leaderboard
    
    @staticmethod
    def get_astrologer_recommendations(
        db: Session,
        specialization: str = None,
        min_rating: float = 4.0,
        limit: int = 10
    ) -> List[Astrologer]:
        """Get recommended astrologers"""
        
        query = db.query(Astrologer).filter(
            Astrologer.is_verified == True,
            Astrologer.status == "active",
            Astrologer.average_rating >= min_rating
        )
        
        if specialization:
            query = query.filter(
                Astrologer.specializations.contains([specialization])
            )
        
        return query.order_by(
            Astrologer.average_rating.desc()
        ).limit(limit).all()
