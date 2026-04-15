from sqlalchemy.orm import Session
from datetime import datetime
from app.models import User
from app.schemas import UserProfileUpdate
from app.core.security import get_password_hash, verify_password
from app.utils import generate_uuid
from typing import Optional


class UserService:
    """Service for user-related operations"""

    @staticmethod
    def create_user(
        db: Session, email: str, username: str, password: str, full_name: Optional[str] = None
    ) -> User:
        """Create a new user"""
        hashed_password = get_password_hash(password)
        user = User(
            id=generate_uuid(),
            email=email,
            username=username,
            hashed_password=hashed_password,
            full_name=full_name,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def get_user_by_email(db: Session, email: str) -> Optional[User]:
        """Get user by email"""
        return db.query(User).filter(User.email == email).first()

    @staticmethod
    def get_user_by_username(db: Session, username: str) -> Optional[User]:
        """Get user by username"""
        return db.query(User).filter(User.username == username).first()

    @staticmethod
    def get_user_by_id(db: Session, user_id: str) -> Optional[User]:
        """Get user by ID"""
        return db.query(User).filter(User.id == user_id).first()

    @staticmethod
    def authenticate_user(db: Session, email: str, password: str) -> Optional[User]:
        """Authenticate user by email and password"""
        user = UserService.get_user_by_email(db, email)
        if not user or not verify_password(password, user.hashed_password):
            return None
        return user

    @staticmethod
    def update_user_profile(
        db: Session, user_id: str, profile_data: UserProfileUpdate
    ) -> Optional[User]:
        """Update user profile"""
        user = UserService.get_user_by_id(db, user_id)
        if not user:
            return None

        update_dict = profile_data.dict(exclude_unset=True)
        for key, value in update_dict.items():
            setattr(user, key, value)

        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def deactivate_user(db: Session, user_id: str) -> Optional[User]:
        """Deactivate a user account"""
        user = UserService.get_user_by_id(db, user_id)
        if user:
            user.is_active = False
            db.commit()
            db.refresh(user)
        return user


__all__ = ["UserService"]
