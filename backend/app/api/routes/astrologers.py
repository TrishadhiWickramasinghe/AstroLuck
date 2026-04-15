"""API routes for astrologer profiles and consultations"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from app.core.security import get_current_user
from app.models.models import User
from app.services.astrologer_service import AstrologerService
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

router = APIRouter(prefix="/api/v1", tags=["Astrologers & Consultations"])


# ============ Pydantic Models ============

class CreateAstrologerProfileRequest(BaseModel):
    title: str
    bio: str
    specialties: str
    hourly_rate: float
    experience_years: int = 0
    certification: Optional[str] = None


class UpdateAstrologerProfileRequest(BaseModel):
    title: Optional[str] = None
    bio: Optional[str] = None
    specialties: Optional[str] = None
    hourly_rate: Optional[float] = None
    experience_years: Optional[int] = None
    certification: Optional[str] = None


class BookConsultationRequest(BaseModel):
    astrologer_id: str
    topic: str
    scheduled_time: datetime
    duration_minutes: int = 60


class RateReviewRequest(BaseModel):
    rating: int
    review: Optional[str] = None


class CancelSessionRequest(BaseModel):
    reason: Optional[str] = None


# ============ Astrologer Directory Routes ============

@router.post("/astrologers/register")
def register_as_astrologer(
    request: CreateAstrologerProfileRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Register as an astrologer"""
    
    profile = AstrologerService.create_astrologer_profile(
        db=db,
        user_id=current_user.id,
        title=request.title,
        bio=request.bio,
        specialties=request.specialties,
        hourly_rate=request.hourly_rate,
        experience_years=request.experience_years,
        certification=request.certification
    )
    
    if not profile:
        raise HTTPException(status_code=400, detail="Failed to create astrologer profile")
    
    return {
        "status": "success",
        "message": "Astrologer profile created successfully",
        "profile_id": profile.id,
        "note": "Your profile is pending verification. An admin will review it shortly."
    }


@router.get("/astrologers/profile")
def get_my_astrologer_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get current user's astrologer profile"""
    
    profile = AstrologerService.get_astrologer_profile(db, current_user.id)
    
    if not profile:
        raise HTTPException(status_code=404, detail="Astrologer profile not found")
    
    return {
        "status": "success",
        "profile": profile
    }


@router.put("/astrologers/profile")
def update_astrologer_profile(
    request: UpdateAstrologerProfileRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update astrologer profile"""
    
    update_data = {k: v for k, v in request.dict().items() if v is not None}
    
    profile = AstrologerService.update_astrologer_profile(
        db=db,
        user_id=current_user.id,
        **update_data
    )
    
    if not profile:
        raise HTTPException(status_code=400, detail="Failed to update profile")
    
    return {
        "status": "success",
        "message": "Profile updated successfully"
    }


@router.get("/astrologers/search")
def search_astrologers(
    specialty: Optional[str] = None,
    min_rating: float = 0,
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Search for verified astrologers"""
    
    astrologers = AstrologerService.search_astrologers(
        db=db,
        specialty=specialty,
        min_rating=min_rating,
        limit=limit
    )
    
    return {
        "status": "success",
        "total": len(astrologers),
        "astrologers": astrologers
    }


@router.get("/astrologers/{astrologer_id}")
def get_astrologer_profile(
    astrologer_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get astrologer's public profile"""
    
    profile = AstrologerService.get_astrologer_profile(db, astrologer_id)
    
    if not profile:
        raise HTTPException(status_code=404, detail="Astrologer not found")
    
    return {
        "status": "success",
        "profile": profile
    }


# ============ Consultation Booking Routes ============

@router.post("/consultations/book")
def book_consultation(
    request: BookConsultationRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Book a consultation with an astrologer"""
    
    # Verify scheduled time is in future
    if request.scheduled_time <= datetime.now():
        raise HTTPException(status_code=400, detail="Scheduled time must be in the future")
    
    session = AstrologerService.book_consultation(
        db=db,
        astrologer_id=request.astrologer_id,
        user_id=current_user.id,
        topic=request.topic,
        scheduled_time=request.scheduled_time,
        duration_minutes=request.duration_minutes
    )
    
    if not session:
        raise HTTPException(status_code=400, detail="Failed to book consultation")
    
    return {
        "status": "success",
        "session_id": session.id,
        "message": "Consultation booked successfully",
        "cost": session.cost,
        "scheduled_time": session.scheduled_time.isoformat() if session.scheduled_time else None
    }


@router.get("/consultations")
def get_my_consultations(
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's consultations"""
    
    sessions = AstrologerService.get_user_sessions(db, current_user.id, status)
    
    return {
        "status": "success",
        "total": len(sessions),
        "consultations": [
            {
                "id": s.id,
                "astrologer_id": s.astrologer_id,
                "topic": s.topic,
                "status": s.status,
                "scheduled_time": s.scheduled_time.isoformat() if s.scheduled_time else None,
                "cost": s.cost,
                "rating": s.rating
            }
            for s in sessions
        ]
    }


@router.get("/consultations/{session_id}")
def get_consultation_details(
    session_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get consultation session details"""
    
    session_data = AstrologerService.get_consultation_session(db, session_id)
    
    if not session_data:
        raise HTTPException(status_code=404, detail="Consultation not found")
    
    return {
        "status": "success",
        "session": session_data
    }


@router.post("/consultations/{session_id}/start")
def start_consultation(
    session_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Start a consultation session"""
    
    success = AstrologerService.start_session(db, session_id)
    
    if not success:
        raise HTTPException(status_code=400, detail="Failed to start consultation")
    
    return {
        "status": "success",
        "message": "Consultation started"
    }


@router.post("/consultations/{session_id}/complete")
def complete_consultation(
    session_id: str,
    notes: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Complete a consultation session"""
    
    success = AstrologerService.complete_session(db, session_id, notes)
    
    if not success:
        raise HTTPException(status_code=400, detail="Failed to complete consultation")
    
    return {
        "status": "success",
        "message": "Consultation completed"
    }


@router.post("/consultations/{session_id}/rate")
def rate_consultation(
    session_id: str,
    request: RateReviewRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Rate and review a consultation"""
    
    if request.rating < 1 or request.rating > 5:
        raise HTTPException(status_code=400, detail="Rating must be between 1 and 5")
    
    success = AstrologerService.rate_and_review_session(
        db=db,
        session_id=session_id,
        rating=request.rating,
        review=request.review
    )
    
    if not success:
        raise HTTPException(status_code=400, detail="Failed to rate consultation")
    
    return {
        "status": "success",
        "message": "Consultation rated successfully"
    }


@router.post("/consultations/{session_id}/cancel")
def cancel_consultation(
    session_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Cancel a consultation"""
    
    success = AstrologerService.cancel_session(db, session_id)
    
    if not success:
        raise HTTPException(status_code=400, detail="Failed to cancel consultation")
    
    return {
        "status": "success",
        "message": "Consultation cancelled"
    }


# ============ Astrologer Session Routes ============

@router.get("/astrologers/{astrologer_id}/sessions")
def get_astrologer_sessions(
    astrologer_id: str,
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get sessions for an astrologer (astrologer only)"""
    
    if astrologer_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    sessions = AstrologerService.get_astrologer_sessions(db, astrologer_id, status)
    
    return {
        "status": "success",
        "total": len(sessions),
        "sessions": [
            {
                "id": s.id,
                "user_id": s.user_id,
                "topic": s.topic,
                "status": s.status,
                "scheduled_time": s.scheduled_time.isoformat() if s.scheduled_time else None,
                "cost": s.cost
            }
            for s in sessions
        ]
    }
