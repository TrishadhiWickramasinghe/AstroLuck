from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.db import get_db
from app.models import User
from app.schemas import (
    UserProfileResponse,
    UserProfileUpdate,
    LotteryHistoryCreate,
    LotteryHistoryResponse,
    LuckyNumberRequest,
    LuckyNumberResponse,
)
from app.services import UserService, LotteryService
from app.api.auth import get_current_user

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserProfileResponse)
def get_profile(current_user: User = Depends(get_current_user)):
    """Get current user's profile"""
    return current_user


@router.put("/me", response_model=UserProfileResponse)
def update_profile(
    profile_data: UserProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update current user's profile"""
    updated_user = UserService.update_user_profile(db, current_user.id, profile_data)
    
    if not updated_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    
    return updated_user


@router.post("/generate-lucky-numbers", response_model=LuckyNumberResponse)
def generate_lucky_numbers(
    request: LuckyNumberRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Generate lucky numbers for user"""
    if not current_user.birth_date:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Birth date is required to generate lucky numbers",
        )

    lucky_data = LotteryService.generate_lucky_numbers(
        current_user, request.lottery_type
    )
    
    return {
        **lucky_data,
    }


@router.post("/record-lottery", response_model=LotteryHistoryResponse)
def record_lottery(
    lottery_data: LotteryHistoryCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Record a lottery play"""
    lottery = LotteryService.record_lottery_play(db, current_user.id, lottery_data)
    return lottery


@router.get("/lottery-history", response_model=List[LotteryHistoryResponse])
def get_lottery_history(
    limit: int = 50,
    offset: int = 0,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get user's lottery history"""
    history = LotteryService.get_user_lottery_history(
        db, current_user.id, limit, offset
    )
    return history


@router.delete("/deactivate")
def deactivate_account(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Deactivate user account"""
    UserService.deactivate_user(db, current_user.id)
    return {"message": "Account deactivated successfully"}


__all__ = ["router"]
