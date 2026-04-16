"""
Statistics Dashboard Models
Models for tracking lottery statistics, hot/cold numbers, trends, and winning patterns.
"""

from datetime import datetime, timedelta
from sqlalchemy import Column, String, Integer, Float, DateTime, Boolean, ForeignKey, JSON, Index, Enum, Text
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.orm import relationship
import uuid
import enum

from app.core.config import Base


class NumberCategory(str, enum.Enum):
    """Category for number analysis"""
    HOT = "hot"
    COLD = "cold"
    WARM = "warm"
    NEUTRAL = "neutral"


class TrendDirection(str, enum.Enum):
    """Direction of trend"""
    INCREASING = "increasing"
    DECREASING = "decreasing"
    STABLE = "stable"
    VOLATILE = "volatile"


class PatternType(str, enum.Enum):
    """Type of winning pattern"""
    CONSECUTIVE = "consecutive"
    ARITHMETIC_SEQUENCE = "arithmetic_sequence"
    SYMMETRY = "symmetry"
    ODD_EVEN_RATIO = "odd_even_ratio"
    SUM_PATTERN = "sum_pattern"
    FREQUENCY_PATTERN = "frequency_pattern"
    CYCLICAL = "cyclical"
    CLUSTER = "cluster"


class LotteryType(str, enum.Enum):
    """Type of lottery game"""
    POWERBALL = "powerball"
    MEGA_MILLIONS = "mega_millions"
    DAILY_4 = "daily_4"
    PICK_3 = "pick_3"
    CUSTOM = "custom"


class HotColdNumber(Base):
    """Model for hot/cold number tracking
    
    Tracks which numbers appear frequently (hot) vs rarely (cold)
    Updated after each drawing and periodically
    """
    __tablename__ = "hot_cold_numbers"
    __table_args__ = (
        Index('idx_lottery_type_number', 'lottery_type', 'number'),
        Index('idx_category_lottery', 'category', 'lottery_type'),
        Index('idx_last_updated', 'last_updated'),
    )
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # Number identification
    number = Column(Integer, nullable=False)
    lottery_type = Column(String(50), nullable=False)  # powerball, mega_millions, etc.
    
    # Categorization
    category = Column(Enum(NumberCategory), nullable=False)  # hot, cold, warm, neutral
    
    # Frequency tracking
    appearance_count = Column(Integer, default=0)
    consecutive_draws_appeared = Column(Integer, default=0)
    last_appeared_draw_number = Column(Integer, nullable=True)
    days_since_last_appearance = Column(Integer, nullable=True)
    
    # Statistical metrics
    frequency_score = Column(Float, nullable=False, default=0.0)  # 0-100 scale
    volatility_score = Column(Float, nullable=False, default=0.0)  # How consistent
    expected_frequency = Column(Float, nullable=False, default=0.0)
    deviation_from_expected = Column(Float, nullable=False, default=0.0)  # % below/above expected
    
    # Analysis data
    avg_gap_between_appearances = Column(Integer, nullable=True)  # Days between draws
    trend_prediction = Column(String(50), nullable=True)  # Likely to increase/decrease
    
    # Time tracking
    created_at = Column(DateTime, default=datetime.utcnow)
    last_updated = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Metadata
    data_quality_score = Column(Float, default=0.95)  # Confidence in analysis
    period_analyzed = Column(String(50), default="30_days")  # 7_days, 30_days, 90_days, 1_year
    
    def __repr__(self):
        return f"<HotColdNumber(number={self.number}, category={self.category}, score={self.frequency_score})>"


class TrendData(Base):
    """Model for trend analysis and prediction
    
    Tracks statistical trends in number selection and popularity
    """
    __tablename__ = "trend_data"
    __table_args__ = (
        Index('idx_trend_lottery_date', 'lottery_type', 'trend_date'),
        Index('idx_trend_direction_type', 'trend_direction', 'lottery_type'),
        Index('idx_trend_date', 'trend_date'),
    )
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # Trend identification
    lottery_type = Column(String(50), nullable=False)
    number = Column(Integer, nullable=True)  # NULL for overall lottery trend
    trend_date = Column(DateTime, nullable=False)
    
    # Trend characteristics
    trend_direction = Column(Enum(TrendDirection), nullable=False)
    trend_strength = Column(Float, nullable=False)  # 0-1, higher = stronger trend
    trend_confidence = Column(Float, nullable=False)  # Statistical confidence %
    
    # Historical data
    period_start = Column(DateTime, nullable=False)
    period_end = Column(DateTime, nullable=False)
    data_points_count = Column(Integer, nullable=False)  # Number of observations
    
    # Trend metrics
    average_value = Column(Float, nullable=False)
    previous_average = Column(Float, nullable=False)
    change_percentage = Column(Float, nullable=False)  # % change from previous period
    
    # Extrapolation
    predicted_next_value = Column(Float, nullable=True)
    prediction_confidence = Column(Float, nullable=True)
    
    # Pattern information
    seasonality_detected = Column(Boolean, default=False)
    seasonality_pattern = Column(JSON, nullable=True)  # e.g., {"pattern": "monthly", "strength": 0.7}
    
    # Status
    is_active = Column(Boolean, default=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f"<TrendData(lottery={self.lottery_type}, direction={self.trend_direction}, strength={self.trend_strength})>"


class WinningPattern(Base):
    """Model for winning pattern identification
    
    Stores identified mathematical and statistical patterns in lottery results
    """
    __tablename__ = "winning_patterns"
    __table_args__ = (
        Index('idx_pattern_type_lottery', 'pattern_type', 'lottery_type'),
        Index('idx_pattern_frequency', 'pattern_frequency_percentage'),
        Index('idx_pattern_date', 'discovered_date'),
    )
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # Pattern identification
    lottery_type = Column(String(50), nullable=False)
    pattern_type = Column(Enum(PatternType), nullable=False)
    pattern_name = Column(String(200), nullable=False)  # e.g., "Consecutive Pairs in First 3"
    
    # Pattern description
    pattern_description = Column(Text, nullable=False)  # Detailed explanation
    pattern_formula = Column(String(500), nullable=True)  # Mathematical formula if applicable
    example_winning_set = Column(ARRAY(Integer), nullable=True)  # Example: [15, 16, 42, 43]
    
    # Statistical validation
    occurrences_found = Column(Integer, nullable=False)
    total_drawings_analyzed = Column(Integer, nullable=False)
    pattern_frequency_percentage = Column(Float, nullable=False)  # % of drawings with pattern
    
    # Performance metrics
    hit_rate = Column(Float, nullable=False)  # % of pattern occurrences that resulted in wins
    average_win_amount = Column(Float, nullable=True)  # When pattern hits, avg prize
    roi_estimate = Column(Float, nullable=True)  # Return on investment if betting on pattern
    
    # Analysis period
    analysis_period_days = Column(Integer, nullable=False)  # How many days analyzed
    confidence_score = Column(Float, nullable=False)  # 0-1, statistical significance
    
    # Historical performance
    last_occurred = Column(DateTime, nullable=True)
    last_occurred_draw_number = Column(Integer, nullable=True)
    days_since_last_occurrence = Column(Integer, nullable=True)
    
    # Predictive info
    expected_next_occurrence = Column(DateTime, nullable=True)
    next_occurrence_confidence = Column(Float, nullable=True)
    
    # Metadata
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)  # Verified by analysts
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f"<WinningPattern(type={self.pattern_type}, frequency={self.pattern_frequency_percentage}%)>"


class UserStatistics(Base):
    """Model for user-specific lottery statistics
    
    One record per user, aggregated from their ticket history
    """
    __tablename__ = "user_statistics"
    __table_args__ = (
        Index('idx_user_id_lottery', 'user_id', 'lottery_type'),
        Index('idx_last_updated', 'last_updated'),
    )
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('user.id', ondelete='CASCADE'), nullable=False)
    
    # User identification
    lottery_type = Column(String(50), nullable=False)
    
    # Ticket history
    total_tickets_purchased = Column(Integer, default=0)
    total_winnings = Column(Float, default=0.0)
    total_spent = Column(Float, default=0.0)
    
    # Performance metrics
    win_rate = Column(Float, default=0.0)  # % of tickets that won
    roi_percentage = Column(Float, default=0.0)  # Return on investment
    average_winnings_per_ticket = Column(Float, default=0.0)
    largest_win = Column(Float, default=0.0)
    
    # Pattern usage
    lucky_numbers_used = Column(ARRAY(Integer), nullable=True)
    most_frequently_played_number = Column(Integer, nullable=True)
    preferred_patterns = Column(ARRAY(String), nullable=True)  # Pattern IDs
    
    # Behavioral stats
    play_frequency = Column(String(50), default="regular")  # daily, weekly, monthly, occasional
    avg_tickets_per_draw = Column(Float, default=0.0)
    days_playing = Column(Integer, default=0)  # Days since first ticket
    
    # Engagement
    dashboard_views = Column(Integer, default=0)
    pattern_insights_viewed = Column(Integer, default=0)
    hot_cold_numbers_viewed = Column(Integer, default=0)
    
    # Preferred features
    prefers_hot_numbers = Column(Boolean, nullable=True)
    prefers_patterns = Column(Boolean, nullable=True)
    prefers_lucky_numbers = Column(Boolean, nullable=True)
    
    # Time tracking
    created_at = Column(DateTime, default=datetime.utcnow)
    last_updated = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_viewed_dashboard = Column(DateTime, nullable=True)
    
    # Relationship
    user = relationship("User", back_populates="statistics")
    
    def __repr__(self):
        return f"<UserStatistics(user={self.user_id}, roi={self.roi_percentage}%)>"


class NumberAnalysis(Base):
    """Model for deep statistical analysis of individual numbers
    
    Contains comprehensive analysis of each number's behavior
    """
    __tablename__ = "number_analysis"
    __table_args__ = (
        Index('idx_number_lottery_type', 'number', 'lottery_type'),
        Index('idx_analysis_date_lottery', 'analysis_date', 'lottery_type'),
    )
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # Number identification
    number = Column(Integer, nullable=False)
    lottery_type = Column(String(50), nullable=False)
    
    # Historical appearance data
    total_appearances = Column(Integer, default=0)
    expected_appearances = Column(Integer, default=0)
    chi_squared_statistic = Column(Float, nullable=False, default=0.0)  # Goodness of fit
    
    # Distribution metrics
    mean_gap = Column(Float, nullable=False, default=0.0)  # Average gaps between draws
    median_gap = Column(Float, nullable=False, default=0.0)
    max_gap = Column(Integer, nullable=True)  # Longest drought
    consecutive_appearance_streaks = Column(Integer, default=0)  # Best streak
    
    # Periodicity analysis
    has_periodicity = Column(Boolean, default=False)
    period_length = Column(Integer, nullable=True)  # Every N draws
    periodicity_strength = Column(Float, nullable=True)  # 0-1
    
    # Clustering analysis
    draws_clusteringinto_weeks = Column(JSON, nullable=True)  # {"week": count, ...}
    draws_clustering_by_month = Column(JSON, nullable=True)
    
    # Predictive scoring
    heat_score = Column(Float, nullable=False)  # 0-100, higher = hotter
    cold_score = Column(Float, nullable=False)  # 0-100, higher = colder
    predictability_score = Column(Float, nullable=False)  # How predictable
    
    # Recent performance (last 30 draws)
    recent_appearances_30d = Column(Integer, default=0)
    recent_appearances_90d = Column(Integer, default=0)
    recent_appearances_1y = Column(Integer, default=0)
    
    # Pairing information
    frequently_paired_numbers = Column(ARRAY(Integer), nullable=True)  # Top 5 pairings
    rarely_paired_numbers = Column(ARRAY(Integer), nullable=True)  # Never paired with
    
    # Recommendation data
    recommendation_score = Column(Float, nullable=False, default=0.0)  # For player selection
    recommendation_reason = Column(String(200), nullable=True)
    
    # Analysis metadata
    analysis_date = Column(DateTime, nullable=False, default=datetime.utcnow)
    data_points_used = Column(Integer, nullable=False)
    confidence_level = Column(Float, nullable=False)  # 0-1
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    def __repr__(self):
        return f"<NumberAnalysis(number={self.number}, heat={self.heat_score}, cold={self.cold_score})>"


class EngagementMetric(Base):
    """Model for tracking dashboard engagement
    
    Measures user interaction with statistics features
    """
    __tablename__ = "engagement_metrics"
    __table_args__ = (
        Index('idx_user_engagement_date', 'user_id', 'engagement_date'),
        Index('idx_engagement_type_date', 'engagement_type', 'engagement_date'),
    )
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # User identification
    user_id = Column(UUID(as_uuid=True), ForeignKey('user.id', ondelete='CASCADE'), nullable=False)
    
    # Engagement tracking
    engagement_type = Column(String(100), nullable=False)  # view_dashboard, view_hot_cold, view_trends, view_patterns
    engagement_date = Column(DateTime, default=datetime.utcnow)
    
    # Interaction details
    screen_viewed = Column(String(100), nullable=False)  # dashboard_home, hot_cold_detail, trends, patterns
    time_spent_seconds = Column(Integer, nullable=True)
    actions_performed = Column(Integer, default=0)  # Clicks, filters, etc.
    
    # Context
    lottery_type_viewed = Column(String(50), nullable=True)
    filters_applied = Column(JSON, nullable=True)  # {"category": "hot", "period": "30_days"}
    numbers_analyzed = Column(ARRAY(Integer), nullable=True)
    patterns_viewed = Column(ARRAY(UUID), nullable=True)
    
    # Outcome
    shared_stats = Column(Boolean, default=False)
    screenshot_taken = Column(Boolean, default=False)
    purchased_ticket_after = Column(Boolean, default=False)  # Did they buy a ticket?
    
    # Session info
    session_id = Column(String(100), nullable=True)
    device_type = Column(String(50), nullable=True)  # mobile, web, tablet
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationship
    user = relationship("User", foreign_keys=[user_id])
    
    def __repr__(self):
        return f"<EngagementMetric(type={self.engagement_type}, time={self.time_spent_seconds}s)>"


class StatisticsDashboardConfig(Base):
    """Model for dashboard configuration per user
    
    Stores user preferences for dashboard display and analytics
    """
    __tablename__ = "statistics_dashboard_configs"
    __table_args__ = (
        Index('idx_user_config_lottery', 'user_id', 'lottery_type'),
    )
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey('user.id', ondelete='CASCADE'), nullable=False)
    
    # Lottery selection
    lottery_type = Column(String(50), nullable=False)
    
    # Widget preferences
    show_hot_cold_numbers = Column(Boolean, default=True)
    show_trends = Column(Boolean, default=True)
    show_winning_patterns = Column(Boolean, default=True)
    show_personal_stats = Column(Boolean, default=True)
    
    # Analysis periods
    hot_cold_analysis_period = Column(String(50), default="30_days")  # 7_days, 30_days, 90_days, 1_year
    trends_analysis_period = Column(String(50), default="30_days")
    
    # Display preferences
    show_historical_data = Column(Boolean, default=False)
    show_predictions = Column(Boolean, default=True)
    show_confidence_scores = Column(Boolean, default=False)
    dark_mode = Column(Boolean, default=False)
    
    # Sorting preferences
    hot_cold_sort_by = Column(String(50), default="frequency_score")  # frequency, heat_score, days_since
    patterns_sort_by = Column(String(50), default="frequency_percentage")
    
    # Notification preferences
    notify_hot_numbers_change = Column(Boolean, default=True)
    notify_new_pattern_detected = Column(Boolean, default=True)
    notify_trend_reversal = Column(Boolean, default=False)
    
    # Advanced
    include_statistical_tests = Column(Boolean, default=False)
    show_advanced_metrics = Column(Boolean, default=False)
    enable_predictions = Column(Boolean, default=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship
    user = relationship("User", foreign_keys=[user_id])
    
    def __repr__(self):
        return f"<DashboardConfig(user={self.user_id}, lottery={self.lottery_type})>"
