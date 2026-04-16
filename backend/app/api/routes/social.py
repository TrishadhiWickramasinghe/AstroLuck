"""
Social Features API Routes
Endpoints for: Community Pools, Live Events, Astrologer Directory, Challenges, Badges
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from decimal import Decimal
from typing import List

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.social_models import (
    CommunityPool, LiveGenerationEvent, Astrologer, Challenge, UserBadge
)
from app.services.social_service import SocialService

router = APIRouter(
    prefix="/api/v1/social",
    tags=["social"]
)


# ============================================================================
# 1. COMMUNITY POOLS ENDPOINTS
# ============================================================================

@router.post("/pools/create")
def create_pool(
    pool_name: str,
    lottery_type: str,
    buy_in_amount: float,
    num_tickets: int,
    max_members: int,
    description: str = None,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new community lottery pool"""
    try:
        pool = SocialService.create_community_pool(
            db=db,
            creator_id=current_user.id,
            pool_name=pool_name,
            lottery_type=lottery_type,
            buy_in_amount=Decimal(str(buy_in_amount)),
            num_tickets=num_tickets,
            max_members=max_members,
            description=description
        )
        
        return {
            "success": True,
            "pool_id": pool.id,
            "pool_name": pool.pool_name,
            "status": pool.status,
            "members": len(pool.members)
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/pools/{pool_id}/join")
def join_pool(
    pool_id: int,
    contribution: float,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Join a community pool"""
    try:
        member = SocialService.join_pool(
            db=db,
            pool_id=pool_id,
            user_id=current_user.id,
            contribution=Decimal(str(contribution))
        )
        
        return {
            "success": True,
            "member_id": member.id,
            "pool_id": pool_id,
            "contribution": float(member.contribution),
            "joined_at": member.joined_at
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/pools/{pool_id}")
def get_pool_details(
    pool_id: int,
    db: Session = Depends(get_db)
):
    """Get community pool details"""
    pool = db.query(CommunityPool).filter(CommunityPool.id == pool_id).first()
    
    if not pool:
        raise HTTPException(status_code=404, detail="Pool not found")
    
    return {
        "pool_id": pool.id,
        "pool_name": pool.pool_name,
        "lottery_type": pool.lottery_type,
        "creator_id": pool.creator_id,
        "buy_in_amount": float(pool.buy_in_amount),
        "num_members": len(pool.members),
        "max_members": pool.max_members,
        "status": pool.status,
        "total_winnings": float(pool.total_winnings) if pool.total_winnings else 0,
        "draw_date": pool.draw_date,
        "members": [
            {
                "user_id": m.user_id,
                "contribution": float(m.contribution),
                "shares": m.num_shares,
                "winnings": float(m.winnings_received)
            }
            for m in pool.members
        ]
    }


@router.get("/pools")
def list_pools(
    lottery_type: str = None,
    status: str = "active",
    limit: int = Query(50, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """List community pools"""
    query = db.query(CommunityPool).filter(CommunityPool.status == status)
    
    if lottery_type:
        query = query.filter(CommunityPool.lottery_type == lottery_type)
    
    total = query.count()
    pools = query.offset(offset).limit(limit).all()
    
    return {
        "total": total,
        "limit": limit,
        "offset": offset,
        "pools": [
            {
                "pool_id": p.id,
                "pool_name": p.pool_name,
                "lottery_type": p.lottery_type,
                "members": len(p.members),
                "max_members": p.max_members,
                "buy_in": float(p.buy_in_amount),
                "status": p.status,
                "draw_date": p.draw_date
            }
            for p in pools
        ]
    }


# ============================================================================
# 2. LIVE EVENTS ENDPOINTS
# ============================================================================

@router.post("/events/create")
def create_event(
    event_name: str,
    lottery_type: str,
    target_numbers: int = 6,
    max_participants: int = 100,
    duration_minutes: int = 30,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new live generation event"""
    try:
        event = SocialService.create_live_event(
            db=db,
            creator_id=current_user.id,
            event_name=event_name,
            lottery_type=lottery_type,
            target_numbers=target_numbers,
            max_participants=max_participants,
            duration_minutes=duration_minutes
        )
        
        return {
            "success": True,
            "event_id": event.id,
            "event_name": event.event_name,
            "status": event.status,
            "start_time": event.start_time,
            "end_time": event.end_time
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/events/{event_id}/join")
def join_event(
    event_id: int,
    submitted_numbers: List[int],
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Join a live generation event and submit numbers"""
    try:
        participant = SocialService.join_live_event(
            db=db,
            event_id=event_id,
            user_id=current_user.id,
            submitted_numbers=submitted_numbers
        )
        
        return {
            "success": True,
            "participant_id": participant.id,
            "event_id": event_id,
            "numbers_submitted": participant.submitted_numbers,
            "submission_time": participant.submission_time
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/events/{event_id}/generate")
def generate_numbers(
    event_id: int,
    method: str = "frequency_based",
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Generate final numbers for event"""
    try:
        final_numbers = SocialService.generate_final_numbers(
            db=db,
            event_id=event_id,
            method=method
        )
        
        return {
            "success": True,
            "event_id": event_id,
            "final_numbers": final_numbers,
            "method": method
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/events/{event_id}")
def get_event_details(
    event_id: int,
    db: Session = Depends(get_db)
):
    """Get live event details"""
    event = db.query(LiveGenerationEvent).filter(
        LiveGenerationEvent.id == event_id
    ).first()
    
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    
    return {
        "event_id": event.id,
        "event_name": event.event_name,
        "lottery_type": event.lottery_type,
        "status": event.status,
        "participants": event.num_participants,
        "max_participants": event.max_participants,
        "collected_numbers": event.collected_numbers,
        "final_numbers": event.final_numbers,
        "start_time": event.start_time,
        "end_time": event.end_time
    }


@router.get("/events")
def list_events(
    status: str = "live",
    limit: int = Query(50, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """List live generation events"""
    query = db.query(LiveGenerationEvent)
    
    if status:
        query = query.filter(LiveGenerationEvent.status == status)
    
    total = query.count()
    events = query.offset(offset).limit(limit).all()
    
    return {
        "total": total,
        "limit": limit,
        "offset": offset,
        "events": [
            {
                "event_id": e.id,
                "event_name": e.event_name,
                "participants": e.num_participants,
                "status": e.status,
                "start_time": e.start_time,
                "end_time": e.end_time
            }
            for e in events
        ]
    }


# ============================================================================
# 3. ASTROLOGER DIRECTORY ENDPOINTS
# ============================================================================

@router.post("/astrologers/register")
def register_astrologer(
    professional_name: str,
    specializations: List[str],
    hourly_rate: float,
    experience_years: int,
    bio: str = None,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Register as an astrologer"""
    try:
        astrologer = SocialService.register_astrologer(
            db=db,
            user_id=current_user.id,
            professional_name=professional_name,
            specializations=specializations,
            hourly_rate=Decimal(str(hourly_rate)),
            experience_years=experience_years,
            bio=bio
        )
        
        return {
            "success": True,
            "astrologer_id": astrologer.id,
            "professional_name": astrologer.professional_name,
            "status": astrologer.status
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/astrologers")
def list_astrologers(
    specialization: str = None,
    min_rating: float = 0.0,
    limit: int = Query(50, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """List astrologers"""
    query = db.query(Astrologer).filter(
        Astrologer.is_verified == True,
        Astrologer.status == "active"
    )
    
    if min_rating > 0:
        query = query.filter(Astrologer.average_rating >= min_rating)
    
    total = query.count()
    astrologers = query.order_by(
        Astrologer.average_rating.desc()
    ).offset(offset).limit(limit).all()
    
    return {
        "total": total,
        "limit": limit,
        "offset": offset,
        "astrologers": [
            {
                "astrologer_id": a.id,
                "professional_name": a.professional_name,
                "specializations": a.specializations,
                "experience_years": a.experience_years,
                "hourly_rate": float(a.hourly_rate),
                "average_rating": a.average_rating,
                "total_reviews": a.total_reviews,
                "bio": a.bio
            }
            for a in astrologers
        ]
    }


@router.post("/astrologers/{astrologer_id}/book")
def book_consultation(
    astrologer_id: int,
    title: str,
    scheduled_time: datetime,
    consultation_type: str = "video_call",
    duration_minutes: int = 60,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Book a consultation with an astrologer"""
    try:
        consultation = SocialService.book_consultation(
            db=db,
            astrologer_id=astrologer_id,
            user_id=current_user.id,
            title=title,
            scheduled_time=scheduled_time,
            consultation_type=consultation_type,
            duration_minutes=duration_minutes
        )
        
        return {
            "success": True,
            "consultation_id": consultation.id,
            "scheduled_time": consultation.scheduled_time,
            "total_cost": float(consultation.total_cost),
            "status": consultation.status
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/astrologers/{astrologer_id}/review")
def review_astrologer(
    astrologer_id: int,
    rating: int,
    review_text: str = None,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Leave a review for an astrologer"""
    try:
        review = SocialService.review_astrologer(
            db=db,
            astrologer_id=astrologer_id,
            user_id=current_user.id,
            rating=rating,
            review_text=review_text
        )
        
        return {
            "success": True,
            "review_id": review.id,
            "rating": review.rating,
            "created_at": review.created_at
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


# ============================================================================
# 4. CHALLENGES & COMPETITIONS ENDPOINTS
# ============================================================================

@router.post("/challenges/create")
def create_challenge(
    challenge_name: str,
    challenge_type: str,
    lottery_type: str,
    correct_answer: List[int],
    start_date: datetime,
    end_date: datetime,
    prize_pool: float = 100.0,
    num_winners: int = 3,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new challenge"""
    try:
        challenge = SocialService.create_challenge(
            db=db,
            creator_id=current_user.id,
            challenge_name=challenge_name,
            challenge_type=challenge_type,
            lottery_type=lottery_type,
            correct_answer=correct_answer,
            start_date=start_date,
            end_date=end_date,
            prize_pool=Decimal(str(prize_pool)),
            num_winners=num_winners
        )
        
        return {
            "success": True,
            "challenge_id": challenge.id,
            "challenge_name": challenge.challenge_name,
            "status": challenge.status,
            "prize_pool": float(challenge.prize_pool)
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/challenges/{challenge_id}/submit")
def submit_challenge(
    challenge_id: int,
    submitted_answer: List[int],
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Submit answer to a challenge"""
    try:
        participant = SocialService.submit_challenge_answer(
            db=db,
            challenge_id=challenge_id,
            user_id=current_user.id,
            submitted_answer=submitted_answer
        )
        
        return {
            "success": True,
            "participant_id": participant.id,
            "is_correct": participant.is_correct,
            "score": participant.score,
            "submission_time": participant.submission_time
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/challenges/{challenge_id}")
def get_challenge_details(
    challenge_id: int,
    db: Session = Depends(get_db)
):
    """Get challenge details"""
    challenge = db.query(Challenge).filter(Challenge.id == challenge_id).first()
    
    if not challenge:
        raise HTTPException(status_code=404, detail="Challenge not found")
    
    return {
        "challenge_id": challenge.id,
        "challenge_name": challenge.challenge_name,
        "challenge_type": challenge.challenge_type,
        "status": challenge.status,
        "participants": challenge.total_participants,
        "prize_pool": float(challenge.prize_pool),
        "num_winners": challenge.num_winners,
        "start_date": challenge.start_date,
        "end_date": challenge.end_date
    }


@router.get("/challenges")
def list_challenges(
    status: str = "active",
    limit: int = Query(50, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """List challenges"""
    query = db.query(Challenge).filter(Challenge.status == status)
    
    total = query.count()
    challenges = query.order_by(
        Challenge.end_date
    ).offset(offset).limit(limit).all()
    
    return {
        "total": total,
        "limit": limit,
        "offset": offset,
        "challenges": [
            {
                "challenge_id": c.id,
                "challenge_name": c.challenge_name,
                "challenge_type": c.challenge_type,
                "participants": c.total_participants,
                "prize_pool": float(c.prize_pool),
                "end_date": c.end_date
            }
            for c in challenges
        ]
    }


# ============================================================================
# 5. BADGES & ACHIEVEMENTS ENDPOINTS
# ============================================================================

@router.get("/badges/{user_id}")
def get_user_badges(
    user_id: int,
    db: Session = Depends(get_db)
):
    """Get user's badges"""
    badges = db.query(UserBadge).filter(
        UserBadge.user_id == user_id,
        UserBadge.displayed == True
    ).all()
    
    return {
        "user_id": user_id,
        "total_badges": len(badges),
        "badges": [
            {
                "badge_id": b.badge_id,
                "is_unlocked": b.is_unlocked,
                "unlocked_at": b.unlocked_at,
                "progress": b.progress,
                "progress_percentage": b.progress_percentage
            }
            for b in badges
        ]
    }


@router.get("/leaderboard")
def get_global_leaderboard(
    limit: int = Query(100, le=500),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db)
):
    """Get global leaderboard"""
    from app.models.social_models import UserLeaderboard
    
    leaders = db.query(UserLeaderboard).order_by(
        UserLeaderboard.total_points.desc()
    ).offset(offset).limit(limit).all()
    
    return {
        "limit": limit,
        "offset": offset,
        "total_entries": db.query(UserLeaderboard).count(),
        "leaders": [
            {
                "rank": idx + offset + 1,
                "user_id": l.user_id,
                "total_points": l.total_points,
                "challenge_wins": l.challenge_wins,
                "badge_count": l.badge_count,
                "pool_winnings": float(l.pool_winnings)
            }
            for idx, l in enumerate(leaders)
        ]
    }


@router.get("/user/{user_id}/stats")
def get_user_social_stats(
    user_id: int,
    current_user = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's social stats"""
    from app.models.social_models import UserLeaderboard
    
    # Update leaderboard
    SocialService.update_leaderboard(db, user_id)
    
    leaderboard = db.query(UserLeaderboard).filter(
        UserLeaderboard.user_id == user_id
    ).first()
    
    if not leaderboard:
        return {
            "user_id": user_id,
            "total_points": 0,
            "challenge_wins": 0,
            "badge_count": 0,
            "pool_winnings": 0.0,
            "global_rank": None
        }
    
    return {
        "user_id": user_id,
        "total_points": leaderboard.total_points,
        "challenge_wins": leaderboard.challenge_wins,
        "badge_count": leaderboard.badge_count,
        "pool_winnings": float(leaderboard.pool_winnings),
        "global_rank": leaderboard.global_rank,
        "last_updated": leaderboard.last_updated
    }
