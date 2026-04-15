from sqlalchemy import Column, String, Integer, Float, DateTime, Boolean, Text, ForeignKey, Table, JSON, Date
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import datetime
from app.db import Base

# Association table for user followers
user_follower_association = Table(
    'user_followers',
    Base.metadata,
    Column('follower_id', String(36), ForeignKey('user.id'), primary_key=True),
    Column('following_id', String(36), ForeignKey('user.id'), primary_key=True)
)

# Association table for pool members
pool_member_association = Table(
    'pool_members',
    Base.metadata,
    Column('pool_id', String(36), ForeignKey('lottery_pool.id'), primary_key=True),
    Column('user_id', String(36), ForeignKey('user.id'), primary_key=True)
)


class User(Base):
    """User model for authentication and profiles"""
    __tablename__ = "user"

    id = Column(String(36), primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    username = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    
    # Profile data
    full_name = Column(String(255))
    gender = Column(String(20))
    birth_date = Column(DateTime)
    birth_time = Column(String(10))  # HH:MM format
    birth_place = Column(String(255))
    latitude = Column(Float)
    longitude = Column(Float)
    
    # Contact for notifications
    phone_number = Column(String(20))
    
    # Payment info
    stripe_customer_id = Column(String(255))
    
    # Status
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    
    # Timestamps
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    # Relationships
    lottery_history = relationship("LotteryHistory", back_populates="user", cascade="all, delete-orphan")
    user_analytics = relationship("UserAnalytics", back_populates="user", cascade="all, delete-orphan")
    lucky_shares = relationship("LuckyShare", back_populates="user", cascade="all, delete-orphan")
    daily_insights = relationship("DailyInsight", back_populates="user", cascade="all, delete-orphan")
    user_badges = relationship("UserBadge", back_populates="user", cascade="all, delete-orphan")
    subscription = relationship("Subscription", back_populates="user", uselist=False, cascade="all, delete-orphan")
    astrologer_profile = relationship("AstrologerProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    created_pools = relationship("LotteryPool", back_populates="creator", foreign_keys="LotteryPool.creator_id")
    created_events = relationship("GenerationEvent", back_populates="creator", foreign_keys="GenerationEvent.creator_id")
    created_challenges = relationship("Challenge", back_populates="creator", foreign_keys="Challenge.creator_id")
    consultations_as_astrologer = relationship("ConsultationSession", back_populates="astrologer", foreign_keys="ConsultationSession.astrologer_id")
    consultations_as_user = relationship("ConsultationSession", back_populates="user", foreign_keys="ConsultationSession.user_id")
    
    followers = relationship(
        "User",
        secondary=user_follower_association,
        primaryjoin=(id == user_follower_association.c.follower_id),
        secondaryjoin=(id == user_follower_association.c.following_id),
        backref="following",
        foreign_keys=[user_follower_association.c.follower_id, user_follower_association.c.following_id]
    )


class LotteryHistory(Base):
    """Track user's lottery plays and results"""
    __tablename__ = "lottery_history"

    id = Column(String(36), primary_key=True, index=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, index=True)
    
    lottery_type = Column(String(50), nullable=False)
    numbers = Column(String(255), nullable=False)
    generated_at = Column(DateTime, server_default=func.now())
    play_date = Column(DateTime)
    
    # Astrology values at time of generation
    life_path_number = Column(Integer)
    daily_lucky_number = Column(Integer)
    lucky_color = Column(String(50))
    energy_level = Column(String(20))
    
    # Result tracking
    is_result_checked = Column(Boolean, default=False)
    result_numbers = Column(String(255))
    matched_count = Column(Integer, default=0)
    prize_amount = Column(Float)
    
    # Pool tracking (if part of pool)
    pool_id = Column(String(36), ForeignKey("lottery_pool.id"))
    
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="lottery_history")
    pool = relationship("LotteryPool", back_populates="tickets")


class UserAnalytics(Base):
    """Analytics and insights for users"""
    __tablename__ = "user_analytics"

    id = Column(String(36), primary_key=True, index=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, index=True, unique=True)
    
    # Statistics
    total_plays = Column(Integer, default=0)
    total_winners = Column(Integer, default=0)
    total_winnings = Column(Float, default=0.0)
    
    # Preferences
    favorite_lottery_type = Column(String(50))
    most_used_numbers = Column(String(255))
    lucky_day = Column(String(20))
    
    # Insights
    winning_pattern = Column(Text)
    success_rate = Column(Float, default=0.0)
    
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="user_analytics")


class LuckyShare(Base):
    """Community feature - users can share lucky numbers"""
    __tablename__ = "lucky_share"

    id = Column(String(36), primary_key=True, index=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, index=True)
    
    numbers = Column(String(255), nullable=False)
    lottery_type = Column(String(50), nullable=False)
    description = Column(Text)
    
    # Engagement
    likes_count = Column(Integer, default=0)
    comments_count = Column(Integer, default=0)
    is_public = Column(Boolean, default=True)
    
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="lucky_shares")


class DailyInsight(Base):
    """AI-generated daily insights for users"""
    __tablename__ = "daily_insight"
    
    id = Column(String(36), primary_key=True, index=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, index=True)
    
    date = Column(Date)
    insight_text = Column(Text)
    recommendations = Column(JSON)
    lucky_hours = Column(String(255))
    warning = Column(Text)
    best_activities = Column(String(500))
    
    created_at = Column(DateTime, server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="daily_insights")


class UserBadge(Base):
    """User badges and achievements"""
    __tablename__ = "user_badge"
    
    id = Column(String(36), primary_key=True, index=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, index=True)
    badge_name = Column(String(100))
    badge_icon = Column(String(500))
    description = Column(Text)
    points_earned = Column(Integer, default=10)
    
    unlocked_date = Column(DateTime, server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="user_badges")


class Subscription(Base):
    """User subscription plans"""
    __tablename__ = "subscription"
    
    id = Column(String(36), primary_key=True, index=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, unique=True)
    
    plan = Column(String(50))  # "free", "premium", "gold", "platinum"
    status = Column(String(20))  # "active", "expired", "cancelled"
    stripe_subscription_id = Column(String(255))
    
    amount = Column(Float)
    renews_at = Column(DateTime)
    
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="subscription")


class AstrologerProfile(Base):
    """Astrologer professional profiles"""
    __tablename__ = "astrologer_profile"
    
    id = Column(String(36), primary_key=True, index=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, unique=True)
    
    title = Column(String(255))
    bio = Column(Text)
    specialties = Column(String(500))
    hourly_rate = Column(Float)
    
    rating = Column(Float, default=0)
    reviews_count = Column(Integer, default=0)
    is_verified = Column(Boolean, default=False)
    experience_years = Column(Integer)
    certification = Column(String(500))
    
    availability = Column(JSON)
    
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="astrologer_profile")


class ConsultationSession(Base):
    """Consultation sessions with astrologers"""
    __tablename__ = "consultation_session"
    
    id = Column(String(36), primary_key=True, index=True)
    astrologer_id = Column(String(36), ForeignKey("user.id"), nullable=False)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False)
    
    topic = Column(String(255))
    status = Column(String(20))  # "booked", "active", "completed", "cancelled"
    
    scheduled_time = Column(DateTime)
    duration_minutes = Column(Integer)
    cost = Column(Float)
    
    meeting_link = Column(String(500))
    notes = Column(Text)
    
    rating = Column(Integer)  # 1-5
    review = Column(Text)
    
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    # Relationships
    astrologer = relationship("User", foreign_keys=[astrologer_id], back_populates="consultations_as_astrologer")
    user = relationship("User", foreign_keys=[user_id], back_populates="consultations_as_user")


class LotteryPool(Base):
    """Community lottery pools/syndicates"""
    __tablename__ = "lottery_pool"
    
    id = Column(String(36), primary_key=True, index=True)
    creator_id = Column(String(36), ForeignKey("user.id"), nullable=False)
    
    name = Column(String(255))
    description = Column(Text)
    
    lottery_type = Column(String(50))
    numbers = Column(String(255))
    
    entry_fee = Column(Float)
    max_members = Column(Integer)
    current_members = Column(Integer, default=1)
    
    status = Column(String(20))  # "active", "completed", "cancelled"
    pool_draw_date = Column(DateTime)
    
    total_pool_amount = Column(Float, default=0)
    total_winnings = Column(Float, default=0)
    
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    # Relationships
    creator = relationship("User", foreign_keys=[creator_id], back_populates="created_pools")
    tickets = relationship("LotteryHistory", back_populates="pool")


class GenerationEvent(Base):
    """Live lucky number generation events"""
    __tablename__ = "generation_event"
    
    id = Column(String(36), primary_key=True, index=True)
    creator_id = Column(String(36), ForeignKey("user.id"), nullable=False)
    
    event_name = Column(String(255))
    description = Column(Text)
    
    lottery_type = Column(String(50))
    scheduled_time = Column(DateTime)
    
    participants_count = Column(Integer, default=0)
    generated_numbers = Column(String(255))
    
    status = Column(String(20))  # "scheduled", "active", "completed"
    
    prize_pool = Column(Float, default=0)
    
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    
    # Relationships
    creator = relationship("User", foreign_keys=[creator_id], back_populates="created_events")


class Challenge(Base):
    """Weekly challenges and competitions"""
    __tablename__ = "challenge"
    
    id = Column(String(36), primary_key=True, index=True)
    creator_id = Column(String(36), ForeignKey("user.id"), nullable=False)
    
    title = Column(String(255))
    description = Column(Text)
    
    start_date = Column(DateTime)
    end_date = Column(DateTime)
    
    lottery_type = Column(String(50))
    max_participants = Column(Integer)
    
    prize_pool = Column(Float)
    rules = Column(Text)
    
    difficulty = Column(String(20))  # "easy", "medium", "hard"
    
    created_at = Column(DateTime, server_default=func.now())
    
    # Relationships
    creator = relationship("User", foreign_keys=[creator_id], back_populates="created_challenges")


class ChallengeParticipant(Base):
    """Challenge participants and scores"""
    __tablename__ = "challenge_participant"
    
    id = Column(String(36), primary_key=True, index=True)
    challenge_id = Column(String(36), ForeignKey("challenge.id"), nullable=False)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False)
    
    score = Column(Integer)
    rank = Column(Integer)
    status = Column(String(20))  # "active", "completed", "won"
    
    created_at = Column(DateTime, server_default=func.now())


class Notification(Base):
    """Notification history"""
    __tablename__ = "notification"
    
    id = Column(String(36), primary_key=True, index=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, index=True)
    
    type = Column(String(50))  # "email", "sms", "push", "whatsapp"
    title = Column(String(255))
    message = Column(Text)
    
    status = Column(String(20))  # "sent", "failed", "read"
    recipient = Column(String(255))
    
    created_at = Column(DateTime, server_default=func.now())


# Create all tables
__all__ = [
    "User",
    "LotteryHistory",
    "UserAnalytics",
    "LuckyShare",
    "DailyInsight",
    "UserBadge",
    "Subscription",
    "AstrologerProfile",
    "ConsultationSession",
    "LotteryPool",
    "GenerationEvent",
    "Challenge",
    "ChallengeParticipant",
    "Notification",
]
