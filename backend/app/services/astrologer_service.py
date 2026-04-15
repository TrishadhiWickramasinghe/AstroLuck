"""Service for managing astrologer profiles and consultations"""
from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.models import AstrologerProfile, ConsultationSession, User
import uuid
from datetime import datetime, timedelta


class AstrologerService:
    """Handle astrologer directory and consultation bookings"""
    
    @staticmethod
    def create_astrologer_profile(
        db: Session,
        user_id: str,
        title: str,
        bio: str,
        specialties: str,
        hourly_rate: float,
        experience_years: int = 0,
        certification: str = None
    ) -> Optional[AstrologerProfile]:
        """Create astrologer profile"""
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            return None
        
        # Check if profile already exists
        existing = db.query(AstrologerProfile).filter(
            AstrologerProfile.user_id == user_id
        ).first()
        
        if existing:
            return existing
        
        profile = AstrologerProfile(
            id=str(uuid.uuid4()),
            user_id=user_id,
            title=title,
            bio=bio,
            specialties=specialties,
            hourly_rate=hourly_rate,
            experience_years=experience_years,
            certification=certification,
            rating=0,
            reviews_count=0,
            is_verified=False
        )
        
        db.add(profile)
        db.commit()
        db.refresh(profile)
        
        return profile
    
    @staticmethod
    def update_astrologer_profile(
        db: Session,
        user_id: str,
        **kwargs
    ) -> Optional[AstrologerProfile]:
        """Update astrologer profile"""
        
        profile = db.query(AstrologerProfile).filter(
            AstrologerProfile.user_id == user_id
        ).first()
        
        if not profile:
            return None
        
        # Update fields
        allowed_fields = {
            'title', 'bio', 'specialties', 'hourly_rate',
            'experience_years', 'certification', 'availability'
        }
        
        for field, value in kwargs.items():
            if field in allowed_fields:
                setattr(profile, field, value)
        
        db.commit()
        db.refresh(profile)
        
        return profile
    
    @staticmethod
    def verify_astrologer(
        db: Session,
        astrologer_id: str,
        verified: bool = True
    ) -> bool:
        """Verify astrologer (admin function)"""
        
        profile = db.query(AstrologerProfile).filter(
            AstrologerProfile.user_id == astrologer_id
        ).first()
        
        if not profile:
            return False
        
        profile.is_verified = verified
        db.commit()
        
        return True
    
    @staticmethod
    def get_astrologer_profile(
        db: Session,
        astrologer_id: str
    ) -> Optional[dict]:
        """Get astrologer profile details"""
        
        profile = db.query(AstrologerProfile).filter(
            AstrologerProfile.user_id == astrologer_id
        ).first()
        
        if not profile:
            return None
        
        user = db.query(User).filter(User.id == astrologer_id).first()
        
        # Get consultation stats
        total_sessions = db.query(ConsultationSession).filter(
            ConsultationSession.astrologer_id == astrologer_id,
            ConsultationSession.status == "completed"
        ).count()
        
        return {
            "id": profile.id,
            "user_id": astrologer_id,
            "name": user.full_name if user else profile.user.username,
            "title": profile.title,
            "bio": profile.bio,
            "specialties": profile.specialties.split(",") if profile.specialties else [],
            "hourly_rate": profile.hourly_rate,
            "rating": profile.rating,
            "reviews_count": profile.reviews_count,
            "is_verified": profile.is_verified,
            "experience_years": profile.experience_years,
            "certification": profile.certification,
            "total_sessions": total_sessions,
            "availability": profile.availability or {}
        }
    
    @staticmethod
    def search_astrologers(
        db: Session,
        specialty: str = None,
        min_rating: float = 0,
        limit: int = 10
    ) -> List[dict]:
        """Search for astrologers"""
        
        query = db.query(AstrologerProfile).filter(
            AstrologerProfile.is_verified == True,
            AstrologerProfile.rating >= min_rating
        )
        
        if specialty:
            query = query.filter(
                AstrologerProfile.specialties.contains(specialty)
            )
        
        profiles = query.order_by(
            AstrologerProfile.rating.desc()
        ).limit(limit).all()
        
        result = []
        for profile in profiles:
            user = db.query(User).filter(User.id == profile.user_id).first()
            result.append({
                "id": profile.user_id,
                "name": user.full_name if user else profile.user.username,
                "title": profile.title,
                "specialties": profile.specialties,
                "hourly_rate": profile.hourly_rate,
                "rating": profile.rating,
                "reviews_count": profile.reviews_count
            })
        
        return result
    
    @staticmethod
    def book_consultation(
        db: Session,
        astrologer_id: str,
        user_id: str,
        topic: str,
        scheduled_time: datetime,
        duration_minutes: int = 60
    ) -> Optional[ConsultationSession]:
        """Book consultation with astrologer"""
        
        astrologer = db.query(User).filter(User.id == astrologer_id).first()
        user = db.query(User).filter(User.id == user_id).first()
        
        if not astrologer or not user:
            return None
        
        # Calculate cost
        profile = db.query(AstrologerProfile).filter(
            AstrologerProfile.user_id == astrologer_id
        ).first()
        
        if not profile:
            return None
        
        cost = (profile.hourly_rate / 60) * duration_minutes
        
        session = ConsultationSession(
            id=str(uuid.uuid4()),
            astrologer_id=astrologer_id,
            user_id=user_id,
            topic=topic,
            status="booked",
            scheduled_time=scheduled_time,
            duration_minutes=duration_minutes,
            cost=cost
        )
        
        db.add(session)
        db.commit()
        db.refresh(session)
        
        return session
    
    @staticmethod
    def get_consultation_session(
        db: Session,
        session_id: str
    ) -> Optional[dict]:
        """Get consultation session details"""
        
        session = db.query(ConsultationSession).filter(
            ConsultationSession.id == session_id
        ).first()
        
        if not session:
            return None
        
        astrologer = db.query(User).filter(User.id == session.astrologer_id).first()
        user = db.query(User).filter(User.id == session.user_id).first()
        
        return {
            "id": session.id,
            "astrologer": astrologer.full_name if astrologer else None,
            "user": user.full_name if user else None,
            "topic": session.topic,
            "status": session.status,
            "scheduled_time": session.scheduled_time.isoformat() if session.scheduled_time else None,
            "duration_minutes": session.duration_minutes,
            "cost": session.cost,
            "meeting_link": session.meeting_link,
            "rating": session.rating,
            "review": session.review
        }
    
    @staticmethod
    def get_astrologer_sessions(
        db: Session,
        astrologer_id: str,
        status: str = None
    ) -> List[ConsultationSession]:
        """Get astrologer's consultation sessions"""
        
        query = db.query(ConsultationSession).filter(
            ConsultationSession.astrologer_id == astrologer_id
        )
        
        if status:
            query = query.filter(ConsultationSession.status == status)
        
        sessions = query.order_by(
            ConsultationSession.scheduled_time.desc()
        ).all()
        
        return sessions
    
    @staticmethod
    def get_user_sessions(
        db: Session,
        user_id: str,
        status: str = None
    ) -> List[ConsultationSession]:
        """Get user's consultation sessions"""
        
        query = db.query(ConsultationSession).filter(
            ConsultationSession.user_id == user_id
        )
        
        if status:
            query = query.filter(ConsultationSession.status == status)
        
        sessions = query.order_by(
            ConsultationSession.scheduled_time.desc()
        ).all()
        
        return sessions
    
    @staticmethod
    def start_session(
        db: Session,
        session_id: str,
        meeting_link: str = None
    ) -> bool:
        """Mark session as active"""
        
        session = db.query(ConsultationSession).filter(
            ConsultationSession.id == session_id
        ).first()
        
        if not session or session.status != "booked":
            return False
        
        session.status = "active"
        if meeting_link:
            session.meeting_link = meeting_link
        
        db.commit()
        return True
    
    @staticmethod
    def complete_session(
        db: Session,
        session_id: str,
        notes: str = None
    ) -> bool:
        """Complete consultation session"""
        
        session = db.query(ConsultationSession).filter(
            ConsultationSession.id == session_id
        ).first()
        
        if not session:
            return False
        
        session.status = "completed"
        if notes:
            session.notes = notes
        
        db.commit()
        return True
    
    @staticmethod
    def rate_and_review_session(
        db: Session,
        session_id: str,
        rating: int,
        review: str = None
    ) -> bool:
        """Add rating and review to consultation"""
        
        if rating < 1 or rating > 5:
            return False
        
        session = db.query(ConsultationSession).filter(
            ConsultationSession.id == session_id
        ).first()
        
        if not session or session.status != "completed":
            return False
        
        session.rating = rating
        if review:
            session.review = review
        
        # Update astrologer profile rating
        profile = db.query(AstrologerProfile).filter(
            AstrologerProfile.user_id == session.astrologer_id
        ).first()
        
        if profile:
            # Recalculate average rating
            all_sessions = db.query(ConsultationSession).filter(
                ConsultationSession.astrologer_id == session.astrologer_id,
                ConsultationSession.rating.isnot(None)
            ).all()
            
            if all_sessions:
                avg_rating = sum(s.rating for s in all_sessions) / len(all_sessions)
                profile.rating = avg_rating
                profile.reviews_count = len(all_sessions)
        
        db.commit()
        return True
    
    @staticmethod
    def cancel_session(
        db: Session,
        session_id: str
    ) -> bool:
        """Cancel consultation session"""
        
        session = db.query(ConsultationSession).filter(
            ConsultationSession.id == session_id
        ).first()
        
        if not session or session.status == "completed":
            return False
        
        session.status = "cancelled"
        db.commit()
        
        return True
