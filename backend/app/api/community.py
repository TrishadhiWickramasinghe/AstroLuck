from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.db import get_db
from app.models import User
from app.schemas import (
    LuckyShareCreate,
    LuckyShareResponse,
    LuckyLeaderboardEntry,
)
from app.services import ShareService
from app.api.auth import get_current_user

router = APIRouter(prefix="/community", tags=["community"])


@router.post("/shares", response_model=LuckyShareResponse)
def create_share(
    share_data: LuckyShareCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Share lucky numbers with community"""
    share = ShareService.create_share(
        db,
        user_id=current_user.id,
        numbers=share_data.numbers,
        lottery_type=share_data.lottery_type,
        description=share_data.description,
        is_public=share_data.is_public,
    )
    return share


@router.get("/shares/public", response_model=List[LuckyShareResponse])
def get_public_shares(
    limit: int = 50,
    offset: int = 0,
    db: Session = Depends(get_db),
):
    """Get public lucky shares"""
    shares = ShareService.get_public_shares(db, limit, offset)
    return shares


@router.post("/shares/{share_id}/like")
def like_share(
    share_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Like a lucky share"""
    share = ShareService.like_share(db, share_id)
    
    if not share:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Share not found",
        )
    
    return {"message": "Liked successfully", "likes_count": share.likes_count}


@router.get("/leaderboard", response_model=List[LuckyLeaderboardEntry])
def get_leaderboard(
    limit: int = 50,
    db: Session = Depends(get_db),
):
    """Get community leaderboard"""
    leaderboard = ShareService.get_leaderboard(db, limit)
    return [
        LuckyLeaderboardEntry(
            user_id=entry["user_id"],
            username=entry["username"],
            total_plays=entry["total_plays"],
            total_winnings=entry["total_winnings"],
            success_rate=entry["success_rate"],
            rank=entry["rank"],
        )
        for entry in leaderboard
    ]


__all__ = ["router"]
