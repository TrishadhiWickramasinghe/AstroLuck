"""Service for managing user badges and achievements"""
from datetime import datetime, timedelta
from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.models import UserBadge, User, LotteryHistory, UserAnalytics
import uuid


class BadgeService:
    """Handle badge unlocking, tracking, and achievements"""
    
    # Badge definitions
    BADGES = {
        "first_play": {
            "name": "First Draw",
            "icon": "🎰",
            "description": "Generated your first lucky numbers",
            "points": 10,
            "condition": "first_lottery_play"
        },
        "lucky_10": {
            "name": "Lucky Streak",
            "icon": "⭐",
            "description": "Played 10 lotteries",
            "points": 50,
            "condition": "play_count_10"
        },
        "lucky_50": {
            "name": "Dedicated Player",
            "icon": "🏆",
            "description": "Played 50 lotteries",
            "points": 200,
            "condition": "play_count_50"
        },
        "lucky_100": {
            "name": "Lottery Master",
            "icon": "👑",
            "description": "Played 100 lotteries",
            "points": 500,
            "condition": "play_count_100"
        },
        "first_win": {
            "name": "First Winner",
            "icon": "🎊",
            "description": "Won your first prize",
            "points": 100,
            "condition": "first_win"
        },
        "winning_streak_5": {
            "name": "Fortune's Favorite",
            "icon": "💎",
            "description": "Won 5 times",
            "points": 250,
            "condition": "win_count_5"
        },
        "winning_streak_10": {
            "name": "Millionaire Mindset",
            "icon": "💰",
            "description": "Won 10 times",
            "points": 500,
            "condition": "win_count_10"
        },
        "community_share": {
            "name": "Community Spirit",
            "icon": "🤝",
            "description": "Shared numbers with community",
            "points": 30,
            "condition": "community_share"
        },
        "social_butterfly": {
            "name": "Social Butterfly",
            "icon": "🦋",
            "description": "Followed 10 users",
            "points": 75,
            "condition": "followers_10"
        },
        "consistent_player": {
            "name": "Consistent Player",
            "icon": "📅",
            "description": "Played consecutively for 7 days",
            "points": 100,
            "condition": "consecutive_7_days"
        },
        "midnight_player": {
            "name": "Night Owl",
            "icon": "🌙",
            "description": "Generated lucky numbers after midnight",
            "points": 25,
            "condition": "midnight_play"
        },
        "zodiac_master": {
            "name": "Zodiac Master",
            "icon": "♈",
            "description": "Complete birth profile with all details",
            "points": 75,
            "condition": "complete_profile"
        },
        "insight_reader": {
            "name": "Insight Seeker",
            "icon": "📖",
            "description": "Read daily insights 10 times",
            "points": 50,
            "condition": "read_insights_10"
        },
        "premium_member": {
            "name": "Premium Believer",
            "icon": "✨",
            "description": "Upgraded to Premium",
            "points": 150,
            "condition": "premium_subscription"
        },
        "referral_master": {
            "name": "Referral King",
            "icon": "👥",
            "description": "Referred 3 friends",
            "points": 200,
            "condition": "referral_3"
        }
    }
    
    @staticmethod
    def check_and_unlock_badges(db: Session, user_id: str) -> List[UserBadge]:
        """Check all badge conditions and unlock new ones"""
        
        unlocked_badges = []
        user = db.query(User).filter(User.id == user_id).first()
        
        if not user:
            return unlocked_badges
        
        # Get all existing badges for user
        existing_badges = db.query(UserBadge).filter(
            UserBadge.user_id == user_id
        ).all()
        existing_badge_names = [b.badge_name for b in existing_badges]
        
        # Check each badge condition
        for badge_id, badge_info in BadgeService.BADGES.items():
            if badge_info["name"] in existing_badge_names:
                continue  # Already unlocked
            
            condition = badge_info["condition"]
            if BadgeService._check_condition(db, user_id, condition):
                # Unlock badge
                new_badge = UserBadge(
                    id=str(uuid.uuid4()),
                    user_id=user_id,
                    badge_name=badge_info["name"],
                    badge_icon=badge_info["icon"],
                    description=badge_info["description"],
                    points_earned=badge_info["points"]
                )
                db.add(new_badge)
                unlocked_badges.append(new_badge)
        
        if unlocked_badges:
            db.commit()
        
        return unlocked_badges
    
    @staticmethod
    def _check_condition(db: Session, user_id: str, condition: str) -> bool:
        """Check if a condition is met"""
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            return False
        
        # Get user's lottery history and analytics
        lottery_count = db.query(LotteryHistory).filter(
            LotteryHistory.user_id == user_id
        ).count()
        
        analytics = db.query(UserAnalytics).filter(
            UserAnalytics.user_id == user_id
        ).first()
        
        win_count = 0
        if analytics:
            win_count = analytics.total_winners
        
        conditions_map = {
            "first_lottery_play": lottery_count >= 1,
            "play_count_10": lottery_count >= 10,
            "play_count_50": lottery_count >= 50,
            "play_count_100": lottery_count >= 100,
            "first_win": win_count >= 1,
            "win_count_5": win_count >= 5,
            "win_count_10": win_count >= 10,
            "community_share": False,  # Check separately if needed
            "followers_10": len(user.followers) >= 10,
            "consecutive_7_days": BadgeService._check_consecutive_plays(db, user_id, 7),
            "midnight_play": False,  # Check separately
            "complete_profile": bool(user.birth_date and user.birth_time and user.birth_place),
            "read_insights_10": False,  # Track separately
            "premium_subscription": False,  # Check subscription table
            "referral_3": False  # Implement referral tracking
        }
        
        return conditions_map.get(condition, False)
    
    @staticmethod
    def _check_consecutive_plays(db: Session, user_id: str, days: int) -> bool:
        """Check if user played on consecutive days"""
        
        lottery_history = db.query(LotteryHistory).filter(
            LotteryHistory.user_id == user_id
        ).order_by(LotteryHistory.generated_at.desc()).all()
        
        if len(lottery_history) < days:
            return False
        
        # Check recent plays
        recent_plays = [h.generated_at.date() for h in lottery_history[:days]]
        expected_dates = [
            (datetime.now() - timedelta(days=i)).date() for i in range(days)
        ]
        
        return len(set(recent_plays) & set(expected_dates)) >= days - 1
    
    @staticmethod
    def get_user_badges(db: Session, user_id: str) -> List[UserBadge]:
        """Get all badges for user"""
        
        badges = db.query(UserBadge).filter(
            UserBadge.user_id == user_id
        ).order_by(UserBadge.unlocked_date.desc()).all()
        
        return badges
    
    @staticmethod
    def get_total_points(db: Session, user_id: str) -> int:
        """Calculate total achievement points"""
        
        badges = db.query(UserBadge).filter(
            UserBadge.user_id == user_id
        ).all()
        
        total = sum(b.points_earned for b in badges)
        return total
    
    @staticmethod
    def get_badge_progress(db: Session, user_id: str) -> dict:
        """Get progress towards locked badges"""
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            return {}
        
        # Get user stats
        lottery_count = db.query(LotteryHistory).filter(
            LotteryHistory.user_id == user_id
        ).count()
        
        analytics = db.query(UserAnalytics).filter(
            UserAnalytics.user_id == user_id
        ).first()
        
        win_count = analytics.total_winners if analytics else 0
        
        # Calculate progress for each badge
        progress = {
            "lucky_10": {
                "name": "Lucky Streak",
                "current": min(lottery_count, 10),
                "required": 10,
                "percentage": min(100, (lottery_count / 10) * 100)
            },
            "lucky_50": {
                "name": "Dedicated Player",
                "current": min(lottery_count, 50),
                "required": 50,
                "percentage": min(100, (lottery_count / 50) * 100)
            },
            "lucky_100": {
                "name": "Lottery Master",
                "current": min(lottery_count, 100),
                "required": 100,
                "percentage": min(100, (lottery_count / 100) * 100)
            },
            "winning_streak_5": {
                "name": "Fortune's Favorite",
                "current": min(win_count, 5),
                "required": 5,
                "percentage": min(100, (win_count / 5) * 100)
            },
            "winning_streak_10": {
                "name": "Millionaire Mindset",
                "current": min(win_count, 10),
                "required": 10,
                "percentage": min(100, (win_count / 10) * 100)
            },
            "followers": {
                "name": "Social Butterfly",
                "current": len(user.followers),
                "required": 10,
                "percentage": min(100, (len(user.followers) / 10) * 100)
            }
        }
        
        return progress
    
    @staticmethod
    def unlock_manual_badge(db: Session, user_id: str, badge_name: str) -> Optional[UserBadge]:
        """Manually unlock a badge (admin/special event)"""
        
        # Check if badge exists
        badge_info = None
        for badge_id, info in BadgeService.BADGES.items():
            if info["name"] == badge_name:
                badge_info = info
                break
        
        if not badge_info:
            return None
        
        # Check if already unlocked
        existing = db.query(UserBadge).filter(
            UserBadge.user_id == user_id,
            UserBadge.badge_name == badge_name
        ).first()
        
        if existing:
            return existing
        
        # Create badge
        new_badge = UserBadge(
            id=str(uuid.uuid4()),
            user_id=user_id,
            badge_name=badge_name,
            badge_icon=badge_info["icon"],
            description=badge_info["description"],
            points_earned=badge_info["points"]
        )
        
        db.add(new_badge)
        db.commit()
        db.refresh(new_badge)
        
        return new_badge
