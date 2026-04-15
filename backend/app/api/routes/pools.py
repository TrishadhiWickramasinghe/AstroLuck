"""API routes for lottery pools and challenges"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from app.core.security import get_current_user
from app.models.models import User
from app.services.pool_service import PoolService, ChallengeService
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

router = APIRouter(prefix="/api/v1", tags=["Pools & Challenges"])


# ============ Pydantic Models ============

class CreatePoolRequest(BaseModel):
    name: str
    description: str
    lottery_type: str
    numbers: str
    entry_fee: float
    max_members: int = 10


class JoinPoolRequest(BaseModel):
    pool_id: str


class CreateChallengeRequest(BaseModel):
    title: str
    description: str
    start_date: datetime
    end_date: datetime
    lottery_type: str
    max_participants: int = 100
    prize_pool: float = 0
    difficulty: str = "medium"


class JoinChallengeRequest(BaseModel):
    challenge_id: str


# ============ Lottery Pool Routes ============

@router.post("/pools/create")
def create_lottery_pool(
    request: CreatePoolRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new lottery pool"""
    
    pool = PoolService.create_pool(
        db=db,
        creator_id=current_user.id,
        name=request.name,
        description=request.description,
        lottery_type=request.lottery_type,
        numbers=request.numbers,
        entry_fee=request.entry_fee,
        max_members=request.max_members
    )
    
    if not pool:
        raise HTTPException(status_code=400, detail="Failed to create pool")
    
    return {
        "status": "success",
        "pool_id": pool.id,
        "message": "Pool created successfully"
    }


@router.post("/pools/{pool_id}/join")
def join_lottery_pool(
    pool_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Join an existing lottery pool"""
    
    success = PoolService.join_pool(db, pool_id, current_user.id)
    
    if not success:
        raise HTTPException(status_code=400, detail="Failed to join pool")
    
    return {
        "status": "success",
        "message": "Successfully joined pool"
    }


@router.get("/pools/{pool_id}")
def get_pool_details(
    pool_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get pool details"""
    
    pool_data = PoolService.get_pool_details(db, pool_id)
    
    if not pool_data:
        raise HTTPException(status_code=404, detail="Pool not found")
    
    return {
        "status": "success",
        "pool": pool_data
    }


@router.get("/pools")
def get_active_pools(
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get list of active pools"""
    
    pools = PoolService.get_active_pools(db, limit)
    
    return {
        "status": "success",
        "total": len(pools),
        "pools": [
            {
                "id": pool.id,
                "name": pool.name,
                "lottery_type": pool.lottery_type,
                "entry_fee": pool.entry_fee,
                "current_members": pool.current_members,
                "max_members": pool.max_members,
                "creator": pool.creator.username if pool.creator else None,
                "pool_draw_date": pool.pool_draw_date.isoformat() if pool.pool_draw_date else None
            }
            for pool in pools
        ]
    }


@router.get("/pools/user/my-pools")
def get_user_pools(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's pools"""
    
    pools = PoolService.get_user_pools(db, current_user.id)
    
    return {
        "status": "success",
        "total": len(pools),
        "pools": [
            {
                "id": pool.id,
                "name": pool.name,
                "status": pool.status,
                "lottery_type": pool.lottery_type,
                "entry_fee": pool.entry_fee,
                "members": pool.current_members,
                "total_pool": pool.total_pool_amount
            }
            for pool in pools
        ]
    }


@router.post("/pools/{pool_id}/leave")
def leave_lottery_pool(
    pool_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Leave a lottery pool"""
    
    success = PoolService.leave_pool(db, pool_id, current_user.id)
    
    if not success:
        raise HTTPException(status_code=400, detail="Failed to leave pool")
    
    return {
        "status": "success",
        "message": "Successfully left pool"
    }


# ============ Challenge Routes ============

@router.post("/challenges/create")
def create_challenge(
    request: CreateChallengeRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new challenge"""
    
    challenge = ChallengeService.create_challenge(
        db=db,
        creator_id=current_user.id,
        title=request.title,
        description=request.description,
        start_date=request.start_date,
        end_date=request.end_date,
        lottery_type=request.lottery_type,
        max_participants=request.max_participants,
        prize_pool=request.prize_pool,
        difficulty=request.difficulty
    )
    
    if not challenge:
        raise HTTPException(status_code=400, detail="Failed to create challenge")
    
    return {
        "status": "success",
        "challenge": challenge,
        "message": "Challenge created successfully"
    }


@router.post("/challenges/{challenge_id}/join")
def join_challenge(
    challenge_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Join a challenge"""
    
    success = ChallengeService.join_challenge(db, challenge_id, current_user.id)
    
    if not success:
        raise HTTPException(status_code=400, detail="Failed to join challenge")
    
    return {
        "status": "success",
        "message": "Successfully joined challenge"
    }


@router.get("/challenges")
def get_active_challenges(
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get active challenges"""
    
    challenges = ChallengeService.get_active_challenges(db, limit)
    
    return {
        "status": "success",
        "total": len(challenges),
        "challenges": challenges
    }


@router.get("/challenges/{challenge_id}/leaderboard")
def get_challenge_leaderboard(
    challenge_id: str,
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get challenge leaderboard"""
    
    leaderboard = ChallengeService.get_challenge_leaderboard(db, challenge_id, limit)
    
    if not leaderboard:
        raise HTTPException(status_code=404, detail="Challenge not found")
    
    return {
        "status": "success",
        "leaderboard": leaderboard
    }


@router.post("/challenges/{challenge_id}/end")
def end_challenge(
    challenge_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """End a challenge (creator only)"""
    
    from app.models.models import Challenge
    
    challenge = db.query(Challenge).filter(Challenge.id == challenge_id).first()
    if not challenge or challenge.creator_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="Only challenge creator can end the challenge"
        )
    
    success = ChallengeService.end_challenge(db, challenge_id)
    
    if not success:
        raise HTTPException(status_code=400, detail="Failed to end challenge")
    
    return {
        "status": "success",
        "message": "Challenge ended successfully"
    }


@router.post("/challenges/{challenge_id}/update-score")
def update_user_score(
    challenge_id: str,
    score_increment: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update user's score in challenge"""
    
    success = ChallengeService.update_challenge_score(
        db, challenge_id, current_user.id, score_increment
    )
    
    if not success:
        raise HTTPException(status_code=400, detail="Failed to update score")
    
    return {
        "status": "success",
        "message": "Score updated successfully"
    }
