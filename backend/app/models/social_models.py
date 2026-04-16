"""
Social Features Database Models
Handles: Community Pools, Live Events, Astrologer Directory, Challenges, Badges
"""

from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, JSON, Text, ForeignKey, Enum, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime
import enum

Base = declarative_base()


# ============================================================================
# 1. COMMUNITY LOTTERY POOLS
# ============================================================================

class CommunityPool(Base):
    """Lottery syndicate/pool created by users"""
    __tablename__ = "community_pools"
    
    id = Column(Integer, primary_key=True)
    creator_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    pool_name = Column(String(255), nullable=False)
    description = Column(Text)
    lottery_type = Column(String(50), nullable=False)  # astro, daily, weekly, etc
    buy_in_amount = Column(Numeric(10, 2), nullable=False)  # Cost per ticket
    num_tickets = Column(Integer, nullable=False)  # Number of tickets to buy
    max_members = Column(Integer, nullable=False)  # Max people in pool
    split_strategy = Column(String(50), default="equal")  # equal, contribution_based
    status = Column(String(20), default="active")  # active, filled, drawn, completed, closed
    
    # Winnings tracking
    total_winnings = Column(Numeric(15, 2), default=0)
    is_winner = Column(Boolean, default=False)
    winning_numbers = Column(JSON)  # [7, 14, 21, 28, 35, 42]
    drawn_date = Column(DateTime)
    
    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)
    draw_date = Column(DateTime)
    next_draw = Column(DateTime)
    
    # Relationships
    members = relationship("PoolMember", back_populates="pool", cascade="all, delete-orphan")
    transactions = relationship("PoolTransaction", back_populates="pool", cascade="all, delete-orphan")


class PoolMember(Base):
    """User member in a community pool"""
    __tablename__ = "pool_members"
    
    id = Column(Integer, primary_key=True)
    pool_id = Column(Integer, ForeignKey("community_pools.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    contribution = Column(Numeric(10, 2), nullable=False)  # Amount paid
    num_shares = Column(Integer, default=1)  # Number of shares owned
    share_percentage = Column(Float)  # Calculated share %
    status = Column(String(20), default="active")  # active, inactive, left
    winnings_received = Column(Numeric(15, 2), default=0)
    joined_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    pool = relationship("CommunityPool", back_populates="members")


class PoolTransaction(Base):
    """Track pool transactions and payments"""
    __tablename__ = "pool_transactions"
    
    id = Column(Integer, primary_key=True)
    pool_id = Column(Integer, ForeignKey("community_pools.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    transaction_type = Column(String(20))  # buy_in, winning, refund, distribution
    amount = Column(Numeric(10, 2), nullable=False)
    status = Column(String(20), default="pending")  # pending, completed, failed
    description = Column(String(255))
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    pool = relationship("CommunityPool", back_populates="transactions")


# ============================================================================
# 2. LIVE LUCKY GENERATION EVENTS
# ============================================================================

class LiveGenerationEvent(Base):
    """Real-time collaborative number generation event"""
    __tablename__ = "live_generation_events"
    
    id = Column(Integer, primary_key=True)
    creator_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    event_name = Column(String(255), nullable=False)
    description = Column(Text)
    lottery_type = Column(String(50), nullable=False)  # Type of lottery
    status = Column(String(20), default="pending")  # pending, live, completed, cancelled
    
    # Event details
    target_numbers = Column(Integer, default=6)  # How many numbers to pick
    max_participants = Column(Integer, default=100)
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime)
    duration_minutes = Column(Integer, default=30)
    
    # Generated data
    collected_numbers = Column(JSON)  # List of all submitted numbers
    final_numbers = Column(JSON)  # [7, 14, 21, 28, 35, 42] - final picks
    generation_method = Column(String(50))  # frequency_based, random, voting, blend
    
    # Stats
    num_participants = Column(Integer, default=0)
    num_submissions = Column(Integer, default=0)
    participation_rate = Column(Float, default=0.0)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    participants = relationship("EventParticipant", back_populates="event", cascade="all, delete-orphan")


class EventParticipant(Base):
    """User participation in a live generation event"""
    __tablename__ = "event_participants"
    
    id = Column(Integer, primary_key=True)
    event_id = Column(Integer, ForeignKey("live_generation_events.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    submitted_numbers = Column(JSON)  # [1, 2, 3, 4, 5, 6]
    submission_time = Column(DateTime, default=datetime.utcnow)
    votes_received = Column(Integer, default=0)
    contribution_score = Column(Float, default=0.0)
    
    # Relationships
    event = relationship("LiveGenerationEvent", back_populates="participants")


# ============================================================================
# 3. EXPERT ASTROLOGER DIRECTORY
# ============================================================================

class Astrologer(Base):
    """Verified astrologers available for consultations"""
    __tablename__ = "astrologers"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    professional_name = Column(String(255), nullable=False)
    bio = Column(Text)
    specializations = Column(JSON)  # ["birth charts", "numerology", "tarot"]
    experience_years = Column(Integer)
    certifications = Column(JSON)  # Proof of qualifications
    
    # Ratings & Reviews
    average_rating = Column(Float, default=0.0)
    total_reviews = Column(Integer, default=0)
    total_consultations = Column(Integer, default=0)
    
    # Availability & Pricing
    hourly_rate = Column(Numeric(10, 2), nullable=False)
    currency = Column(String(3), default="USD")
    available_hours = Column(JSON)  # {"Monday": ["09:00-17:00"], ...}
    session_duration_minutes = Column(Integer, default=60)
    
    # Verification
    is_verified = Column(Boolean, default=False)
    verification_date = Column(DateTime)
    verification_documents = Column(JSON)
    
    # Status
    status = Column(String(20), default="active")  # active, inactive, suspended
    
    # Metadata
    profile_image_url = Column(String(500))
    languages = Column(JSON)  # ["English", "Spanish"]
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    consultations = relationship("AstrologerConsultation", back_populates="astrologer", cascade="all, delete-orphan")
    reviews = relationship("AstrologerReview", back_populates="astrologer", cascade="all, delete-orphan")


class AstrologerConsultation(Base):
    """Booking and consultation with astrologer"""
    __tablename__ = "astrologer_consultations"
    
    id = Column(Integer, primary_key=True)
    astrologer_id = Column(Integer, ForeignKey("astrologers.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Booking details
    title = Column(String(255), nullable=False)
    description = Column(Text)
    consultation_type = Column(String(50))  # video_call, written_report, email
    
    # Scheduling
    scheduled_time = Column(DateTime, nullable=False)
    duration_minutes = Column(Integer, default=60)
    status = Column(String(20), default="pending")  # pending, confirmed, completed, cancelled
    
    # Payment
    rate = Column(Numeric(10, 2), nullable=False)
    total_cost = Column(Numeric(10, 2), nullable=False)
    payment_status = Column(String(20), default="pending")  # pending, completed, refunded
    payment_id = Column(String(100))
    
    # Results
    notes_from_astrologer = Column(Text)
    recording_url = Column(String(500))  # For video consultations
    report_url = Column(String(500))  # For written reports
    
    # Rating
    user_rating = Column(Integer)  # 1-5 stars
    user_review = Column(Text)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime)
    
    # Relationships
    astrologer = relationship("Astrologer", back_populates="consultations")


class AstrologerReview(Base):
    """Reviews and ratings for astrologers"""
    __tablename__ = "astrologer_reviews"
    
    id = Column(Integer, primary_key=True)
    astrologer_id = Column(Integer, ForeignKey("astrologers.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    consultation_id = Column(Integer, ForeignKey("astrologer_consultations.id"))
    
    rating = Column(Integer, nullable=False)  # 1-5
    review_text = Column(Text)
    pros = Column(JSON)
    cons = Column(JSON)
    
    verified_consultation = Column(Boolean, default=False)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    astrologer = relationship("Astrologer", back_populates="reviews")


# ============================================================================
# 4. WEEKLY CHALLENGES & COMPETITIONS
# ============================================================================

class Challenge(Base):
    """Weekly gamified challenges for users"""
    __tablename__ = "challenges"
    
    id = Column(Integer, primary_key=True)
    creator_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    challenge_name = Column(String(255), nullable=False)
    description = Column(Text)
    challenge_type = Column(String(50))  # predict_numbers, guess_winner, lucky_pick, streak_challenge
    difficulty = Column(String(20), default="medium")  # easy, medium, hard
    
    # Challenge details
    lottery_type = Column(String(50))
    correct_answer = Column(JSON)  # The winning answer
    participation_fee = Column(Numeric(10, 2), default=0)
    
    # Prize pool
    prize_pool = Column(Numeric(15, 2), default=0)
    num_winners = Column(Integer, default=3)
    prize_distribution = Column(JSON)  # {"1st": 0.5, "2nd": 0.3, "3rd": 0.2}
    
    # Timing
    start_date = Column(DateTime, nullable=False)
    end_date = Column(DateTime, nullable=False)
    results_announced_at = Column(DateTime)
    status = Column(String(20), default="active")  # active, completed, cancelled
    
    # Stats
    total_participants = Column(Integer, default=0)
    total_submissions = Column(Integer, default=0)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    participants = relationship("ChallengeParticipant", back_populates="challenge", cascade="all, delete-orphan")
    winners = relationship("ChallengeWinner", back_populates="challenge", cascade="all, delete-orphan")


class ChallengeParticipant(Base):
    """User participation in a challenge"""
    __tablename__ = "challenge_participants"
    
    id = Column(Integer, primary_key=True)
    challenge_id = Column(Integer, ForeignKey("challenges.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Submission
    submitted_answer = Column(JSON)  # User's answer/guess
    submission_time = Column(DateTime, default=datetime.utcnow)
    is_correct = Column(Boolean, default=False)
    score = Column(Integer, default=0)
    
    # Payment (if applicable)
    participation_fee_paid = Column(Boolean, default=False)
    
    # Results
    rank = Column(Integer)
    prize_won = Column(Numeric(15, 2), default=0)
    
    # Relationships
    challenge = relationship("Challenge", back_populates="participants")


class ChallengeWinner(Base):
    """Prize winners from challenges"""
    __tablename__ = "challenge_winners"
    
    id = Column(Integer, primary_key=True)
    challenge_id = Column(Integer, ForeignKey("challenges.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    rank = Column(Integer, nullable=False)  # 1st, 2nd, 3rd, etc
    prize_amount = Column(Numeric(15, 2), nullable=False)
    payout_status = Column(String(20), default="pending")  # pending, completed
    payout_date = Column(DateTime)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    challenge = relationship("Challenge", back_populates="winners")


# ============================================================================
# 5. USER BADGES & ACHIEVEMENTS
# ============================================================================

class BadgeDefinition(Base):
    """Badge templates that users can unlock"""
    __tablename__ = "badge_definitions"
    
    id = Column(Integer, primary_key=True)
    badge_name = Column(String(255), nullable=False, unique=True)
    description = Column(Text)
    category = Column(String(50))  # milestone, achievement, social, lottery, astrology
    icon_url = Column(String(500))
    
    # Unlock requirements
    unlock_condition = Column(String(100))  # e.g., "win_5_times", "join_pool", "book_astrologer"
    threshold_value = Column(Integer)  # e.g., 5 for "win_5_times"
    
    # Metadata
    rarity = Column(String(20), default="common")  # common, rare, epic, legendary
    points_reward = Column(Integer, default=10)
    created_at = Column(DateTime, default=datetime.utcnow)


class UserBadge(Base):
    """Badges earned by users"""
    __tablename__ = "user_badges"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    badge_id = Column(Integer, ForeignKey("badge_definitions.id"), nullable=False)
    
    # Progress tracking
    progress = Column(Integer, default=0)  # Current progress toward badge
    progress_percentage = Column(Float, default=0.0)
    
    # Status
    is_unlocked = Column(Boolean, default=False)
    unlocked_at = Column(DateTime)
    
    # Display
    displayed = Column(Boolean, default=True)  # User can hide badges
    
    created_at = Column(DateTime, default=datetime.utcnow)


class UserAchievement(Base):
    """Track user achievements and milestones"""
    __tablename__ = "user_achievements"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    achievement_type = Column(String(50))  # first_win, hundred_plays, pool_creator, etc
    achievement_name = Column(String(255), nullable=False)
    description = Column(Text)
    
    # Progress
    progress = Column(Integer, default=0)
    target = Column(Integer)
    
    # Reward
    points_earned = Column(Integer, default=0)
    
    # Status
    completed = Column(Boolean, default=False)
    completed_at = Column(DateTime)
    
    created_at = Column(DateTime, default=datetime.utcnow)


class UserLeaderboard(Base):
    """User rankings and scores"""
    __tablename__ = "user_leaderboards"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Points and Scores
    total_points = Column(Integer, default=0)
    challenge_wins = Column(Integer, default=0)
    pool_winnings = Column(Numeric(15, 2), default=0)
    badge_count = Column(Integer, default=0)
    
    # Rankings
    global_rank = Column(Integer)
    weekly_rank = Column(Integer)
    monthly_rank = Column(Integer)
    
    # Stats
    total_participations = Column(Integer, default=0)
    accuracy_score = Column(Float, default=0.0)
    
    last_updated = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    created_at = Column(DateTime, default=datetime.utcnow)
