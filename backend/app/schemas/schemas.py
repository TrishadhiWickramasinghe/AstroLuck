from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime


# ============ Auth Schemas ============
class UserRegister(BaseModel):
    """User registration request"""
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=50)
    password: str = Field(..., min_length=8)
    full_name: Optional[str] = None


class UserLogin(BaseModel):
    """User login request"""
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    """Token response"""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


# ============ Profile Schemas ============
class UserProfileUpdate(BaseModel):
    """Update user profile"""
    full_name: Optional[str] = None
    gender: Optional[str] = None
    birth_date: Optional[datetime] = None
    birth_time: Optional[str] = None
    birth_place: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None


class UserProfileResponse(BaseModel):
    """User profile response"""
    id: str
    email: str
    username: str
    full_name: Optional[str]
    gender: Optional[str]
    birth_date: Optional[datetime]
    birth_time: Optional[str]
    birth_place: Optional[str]
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


# ============ Lottery History Schemas ============
class LotteryHistoryCreate(BaseModel):
    """Create lottery history entry"""
    lottery_type: str
    numbers: str  # Comma-separated
    play_date: Optional[datetime] = None
    life_path_number: Optional[int] = None
    daily_lucky_number: Optional[int] = None
    lucky_color: Optional[str] = None
    energy_level: Optional[str] = None


class LotteryHistoryUpdate(BaseModel):
    """Update lottery history"""
    result_numbers: Optional[str] = None
    matched_count: Optional[int] = None
    prize_amount: Optional[float] = None
    is_result_checked: Optional[bool] = None


class LotteryHistoryResponse(BaseModel):
    """Lottery history response"""
    id: str
    lottery_type: str
    numbers: str
    generated_at: datetime
    life_path_number: Optional[int]
    daily_lucky_number: Optional[int]
    lucky_color: Optional[str]
    energy_level: Optional[str]
    matched_count: int
    prize_amount: Optional[float]

    class Config:
        from_attributes = True


# ============ Analytics Schemas ============
class UserAnalyticsResponse(BaseModel):
    """User analytics response"""
    total_plays: int
    total_winners: int
    total_winnings: float
    favorite_lottery_type: Optional[str]
    most_used_numbers: Optional[str]
    success_rate: float

    class Config:
        from_attributes = True


# ============ Lucky Share Schemas ============
class LuckyShareCreate(BaseModel):
    """Create lucky share"""
    numbers: str
    lottery_type: str
    description: Optional[str] = None
    is_public: bool = True


class LuckyShareResponse(BaseModel):
    """Lucky share response"""
    id: str
    numbers: str
    lottery_type: str
    description: Optional[str]
    likes_count: int
    comments_count: int
    created_at: datetime
    user: UserProfileResponse

    class Config:
        from_attributes = True


class LuckyLeaderboardEntry(BaseModel):
    """Leaderboard entry"""
    user_id: str
    username: str
    total_plays: int
    total_winnings: float
    success_rate: float
    rank: int


# ============ Lucky Number Generation Schemas ============
class LuckyNumberRequest(BaseModel):
    """Request for lucky number generation"""
    lottery_type: str = Field(..., description="Lottery type: 6/49, Powerball, 4-Digit, etc.")


class LuckyNumberResponse(BaseModel):
    """Lucky number generation response"""
    numbers: str
    lottery_type: str
    daily_lucky_number: int
    life_path_number: int
    lucky_color: str
    energy_level: str
    energy_value: int
    lucky_time: str
    timestamp: datetime
