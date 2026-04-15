"""Service for managing lottery pools and community features"""
from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.models import LotteryPool, LotteryHistory, User
import uuid
from datetime import datetime, timedelta


class PoolService:
    """Handle community lottery pools and syndicates"""
    
    @staticmethod
    def create_pool(
        db: Session,
        creator_id: str,
        name: str,
        description: str,
        lottery_type: str,
        numbers: str,
        entry_fee: float,
        max_members: int = 10
    ) -> Optional[LotteryPool]:
        """Create new lottery pool"""
        
        creator = db.query(User).filter(User.id == creator_id).first()
        if not creator:
            return None
        
        pool = LotteryPool(
            id=str(uuid.uuid4()),
            creator_id=creator_id,
            name=name,
            description=description,
            lottery_type=lottery_type,
            numbers=numbers,
            entry_fee=entry_fee,
            max_members=max_members,
            current_members=1,
            status="active",
            pool_draw_date=datetime.now() + timedelta(days=7),
            total_pool_amount=entry_fee
        )
        
        db.add(pool)
        db.commit()
        db.refresh(pool)
        
        return pool
    
    @staticmethod
    def join_pool(
        db: Session,
        pool_id: str,
        user_id: str
    ) -> bool:
        """Add user to lottery pool"""
        
        pool = db.query(LotteryPool).filter(LotteryPool.id == pool_id).first()
        if not pool:
            return False
        
        if pool.current_members >= pool.max_members:
            return False
        
        if pool.status != "active":
            return False
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            return False
        
        # Check if already in pool
        existing = db.query(LotteryHistory).filter(
            LotteryHistory.pool_id == pool_id,
            LotteryHistory.user_id == user_id
        ).first()
        
        if existing:
            return False
        
        # Create lottery ticket for user in pool
        ticket = LotteryHistory(
            id=str(uuid.uuid4()),
            user_id=user_id,
            lottery_type=pool.lottery_type,
            numbers=pool.numbers,
            pool_id=pool_id,
            generated_at=datetime.now()
        )
        
        db.add(ticket)
        
        # Update pool
        pool.current_members += 1
        pool.total_pool_amount += pool.entry_fee
        
        db.commit()
        
        return True
    
    @staticmethod
    def get_pool_details(
        db: Session,
        pool_id: str
    ) -> Optional[dict]:
        """Get detailed pool information"""
        
        pool = db.query(LotteryPool).filter(LotteryPool.id == pool_id).first()
        if not pool:
            return None
        
        members = db.query(LotteryHistory).filter(
            LotteryHistory.pool_id == pool_id
        ).all()
        
        return {
            "id": pool.id,
            "name": pool.name,
            "description": pool.description,
            "lottery_type": pool.lottery_type,
            "numbers": pool.numbers,
            "entry_fee": pool.entry_fee,
            "max_members": pool.max_members,
            "current_members": pool.current_members,
            "total_pool_amount": pool.total_pool_amount,
            "status": pool.status,
            "pool_draw_date": pool.pool_draw_date.isoformat() if pool.pool_draw_date else None,
            "creator": pool.creator.username if pool.creator else None,
            "members_count": len(members),
            "created_at": pool.created_at.isoformat() if pool.created_at else None
        }
    
    @staticmethod
    def get_active_pools(db: Session, limit: int = 10) -> List[LotteryPool]:
        """Get list of active pools"""
        
        pools = db.query(LotteryPool).filter(
            LotteryPool.status == "active",
            LotteryPool.current_members < LotteryPool.max_members
        ).order_by(LotteryPool.created_at.desc()).limit(limit).all()
        
        return pools
    
    @staticmethod
    def get_user_pools(db: Session, user_id: str) -> List[LotteryPool]:
        """Get pools user is part of"""
        
        # Get user's pool memberships via lottery history
        pool_ids = db.query(LotteryHistory.pool_id).filter(
            LotteryHistory.user_id == user_id,
            LotteryHistory.pool_id.isnot(None)
        ).distinct().all()
        
        pool_id_list = [p[0] for p in pool_ids]
        
        if not pool_id_list:
            return []
        
        pools = db.query(LotteryPool).filter(
            LotteryPool.id.in_(pool_id_list)
        ).all()
        
        return pools
    
    @staticmethod
    def distribute_pool_winnings(
        db: Session,
        pool_id: str,
        total_winnings: float
    ) -> bool:
        """Distribute winnings to pool members"""
        
        pool = db.query(LotteryPool).filter(LotteryPool.id == pool_id).first()
        if not pool or pool.current_members == 0:
            return False
        
        # Calculate per-member winnings
        per_member_winnings = total_winnings / pool.current_members
        
        # Get all pool members
        members = db.query(LotteryHistory).filter(
            LotteryHistory.pool_id == pool_id
        ).all()
        
        # Record winnings for each member
        for member in members:
            member.prize_amount = per_member_winnings
            member.is_result_checked = True
        
        # Update pool record
        pool.total_winnings = total_winnings
        pool.status = "completed"
        
        db.commit()
        return True
    
    @staticmethod
    def leave_pool(
        db: Session,
        pool_id: str,
        user_id: str
    ) -> bool:
        """Remove user from pool"""
        
        ticket = db.query(LotteryHistory).filter(
            LotteryHistory.pool_id == pool_id,
            LotteryHistory.user_id == user_id
        ).first()
        
        if not ticket:
            return False
        
        pool = db.query(LotteryPool).filter(LotteryPool.id == pool_id).first()
        if not pool:
            return False
        
        # Remove ticket
        db.delete(ticket)
        
        # Update pool member count
        pool.current_members = max(0, pool.current_members - 1)
        pool.total_pool_amount = max(0, pool.total_pool_amount - pool.entry_fee)
        
        # Cancel pool if no members
        if pool.current_members == 0:
            pool.status = "cancelled"
        
        db.commit()
        return True


class ChallengeService:
    """Handle lottery challenges and competitions"""
    
    @staticmethod
    def create_challenge(
        db: Session,
        creator_id: str,
        title: str,
        description: str,
        start_date: datetime,
        end_date: datetime,
        lottery_type: str,
        max_participants: int = 100,
        prize_pool: float = 0,
        difficulty: str = "medium"
    ) -> Optional[dict]:
        """Create new challenge"""
        
        from app.models.models import Challenge
        
        creator = db.query(User).filter(User.id == creator_id).first()
        if not creator:
            return None
        
        challenge = Challenge(
            id=str(uuid.uuid4()),
            creator_id=creator_id,
            title=title,
            description=description,
            start_date=start_date,
            end_date=end_date,
            lottery_type=lottery_type,
            max_participants=max_participants,
            prize_pool=prize_pool,
            difficulty=difficulty
        )
        
        db.add(challenge)
        db.commit()
        db.refresh(challenge)
        
        return {
            "id": challenge.id,
            "title": challenge.title,
            "description": challenge.description,
            "difficulty": challenge.difficulty,
            "created_at": challenge.created_at.isoformat() if challenge.created_at else None
        }
    
    @staticmethod
    def join_challenge(
        db: Session,
        challenge_id: str,
        user_id: str
    ) -> bool:
        """User joins challenge"""
        
        from app.models.models import Challenge, ChallengeParticipant
        
        challenge = db.query(Challenge).filter(Challenge.id == challenge_id).first()
        if not challenge:
            return False
        
        # Check if already participant
        existing = db.query(ChallengeParticipant).filter(
            ChallengeParticipant.challenge_id == challenge_id,
            ChallengeParticipant.user_id == user_id
        ).first()
        
        if existing:
            return False
        
        # Add participant
        participant = ChallengeParticipant(
            id=str(uuid.uuid4()),
            challenge_id=challenge_id,
            user_id=user_id,
            score=0,
            status="active"
        )
        
        db.add(participant)
        db.commit()
        
        return True
    
    @staticmethod
    def update_challenge_score(
        db: Session,
        challenge_id: str,
        user_id: str,
        score_increment: int
    ) -> bool:
        """Update participant score"""
        
        from app.models.models import ChallengeParticipant
        
        participant = db.query(ChallengeParticipant).filter(
            ChallengeParticipant.challenge_id == challenge_id,
            ChallengeParticipant.user_id == user_id
        ).first()
        
        if not participant:
            return False
        
        participant.score = (participant.score or 0) + score_increment
        db.commit()
        
        return True
    
    @staticmethod
    def get_challenge_leaderboard(
        db: Session,
        challenge_id: str,
        limit: int = 10
    ) -> List[dict]:
        """Get challenge leaderboard"""
        
        from app.models.models import Challenge, ChallengeParticipant
        
        participants = db.query(ChallengeParticipant).filter(
            ChallengeParticipant.challenge_id == challenge_id
        ).order_by(ChallengeParticipant.score.desc()).limit(limit).all()
        
        leaderboard = []
        for rank, participant in enumerate(participants, 1):
            user = db.query(User).filter(User.id == participant.user_id).first()
            leaderboard.append({
                "rank": rank,
                "username": user.username if user else None,
                "score": participant.score,
                "status": participant.status
            })
        
        return leaderboard
    
    @staticmethod
    def end_challenge(
        db: Session,
        challenge_id: str
    ) -> bool:
        """End challenge and finalize results"""
        
        from app.models.models import Challenge, ChallengeParticipant
        
        challenge = db.query(Challenge).filter(Challenge.id == challenge_id).first()
        if not challenge:
            return False
        
        # Get winner
        winner = db.query(ChallengeParticipant).filter(
            ChallengeParticipant.challenge_id == challenge_id
        ).order_by(ChallengeParticipant.score.desc()).first()
        
        if winner:
            winner.status = "won"
            winner.rank = 1
        
        # Mark all as completed
        participants = db.query(ChallengeParticipant).filter(
            ChallengeParticipant.challenge_id == challenge_id
        ).all()
        
        for participant in participants:
            if participant.status != "won":
                participant.status = "completed"
        
        db.commit()
        return True
    
    @staticmethod
    def get_active_challenges(db: Session, limit: int = 10) -> List[dict]:
        """Get active challenges"""
        
        from app.models.models import Challenge
        
        now = datetime.now()
        challenges = db.query(Challenge).filter(
            Challenge.start_date <= now,
            Challenge.end_date >= now
        ).order_by(Challenge.start_date).limit(limit).all()
        
        result = []
        for challenge in challenges:
            result.append({
                "id": challenge.id,
                "title": challenge.title,
                "difficulty": challenge.difficulty,
                "participants": db.query(lambda: None).select_from(lambda: None).count(),  # Placeholder
                "prize_pool": challenge.prize_pool,
                "ends_at": challenge.end_date.isoformat() if challenge.end_date else None
            })
        
        return result
