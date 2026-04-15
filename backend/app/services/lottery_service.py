from sqlalchemy.orm import Session
from datetime import datetime
from app.models import User, LotteryHistory, UserAnalytics, LuckyShare
from app.schemas import LotteryHistoryCreate, LotteryHistoryUpdate
from app.utils import generate_uuid, LotteryUtils, NumerologyUtils, DateUtils
from typing import List, Optional


class LotteryService:
    """Service for lottery-related operations"""

    @staticmethod
    def generate_lucky_numbers(
        user: User, lottery_type: str, current_date: datetime = None
    ) -> dict:
        """Generate lucky numbers for a user"""
        if current_date is None:
            current_date = datetime.now()

        # Get user's life path number
        if not user.birth_date:
            raise ValueError("User must have birth date to generate lucky numbers")

        life_path = NumerologyUtils.calculate_life_path_number(user.birth_date)
        daily_lucky = NumerologyUtils.calculate_daily_lucky_number(
            life_path, current_date
        )

        # Generate lottery numbers
        numbers = LotteryUtils.generate_lottery_numbers(
            daily_lucky, lottery_type, seed=user.birth_date.year
        )
        formatted_numbers = LotteryUtils.format_numbers_for_lottery(
            numbers, lottery_type
        )

        # Get additional info
        lucky_color = NumerologyUtils.get_lucky_color(daily_lucky)
        lucky_time = NumerologyUtils.calculate_lucky_time(life_path)
        moon_phase = DateUtils.get_moon_phase(current_date)
        energy_level, energy_value = NumerologyUtils.calculate_energy_level(
            daily_lucky, life_path, moon_phase
        )

        return {
            "numbers": formatted_numbers,
            "lottery_type": lottery_type,
            "daily_lucky_number": daily_lucky,
            "life_path_number": life_path,
            "lucky_color": lucky_color,
            "energy_level": energy_level,
            "energy_value": energy_value,
            "lucky_time": lucky_time,
            "timestamp": current_date,
        }

    @staticmethod
    def record_lottery_play(
        db: Session, user_id: str, play_data: LotteryHistoryCreate
    ) -> LotteryHistory:
        """Record a lottery play"""
        lottery = LotteryHistory(
            id=generate_uuid(),
            user_id=user_id,
            lottery_type=play_data.lottery_type,
            numbers=play_data.numbers,
            play_date=play_data.play_date or datetime.now(),
            life_path_number=play_data.life_path_number,
            daily_lucky_number=play_data.daily_lucky_number,
            lucky_color=play_data.lucky_color,
            energy_level=play_data.energy_level,
        )
        db.add(lottery)
        db.commit()
        db.refresh(lottery)
        return lottery

    @staticmethod
    def update_lottery_result(
        db: Session, lottery_id: str, update_data: LotteryHistoryUpdate
    ) -> Optional[LotteryHistory]:
        """Update lottery result"""
        lottery = db.query(LotteryHistory).filter(LotteryHistory.id == lottery_id).first()
        if not lottery:
            return None

        update_dict = update_data.dict(exclude_unset=True)
        for key, value in update_dict.items():
            setattr(lottery, key, value)

        db.commit()
        db.refresh(lottery)
        return lottery

    @staticmethod
    def get_user_lottery_history(
        db: Session, user_id: str, limit: int = 50, offset: int = 0
    ) -> List[LotteryHistory]:
        """Get user's lottery history"""
        return (
            db.query(LotteryHistory)
            .filter(LotteryHistory.user_id == user_id)
            .order_by(LotteryHistory.generated_at.desc())
            .limit(limit)
            .offset(offset)
            .all()
        )

    @staticmethod
    def update_user_analytics(db: Session, user_id: str) -> UserAnalytics:
        """Update user analytics based on lottery history"""
        analytics = (
            db.query(UserAnalytics)
            .filter(UserAnalytics.user_id == user_id)
            .first()
        )

        if not analytics:
            analytics = UserAnalytics(
                id=generate_uuid(),
                user_id=user_id,
                total_plays=0,
                total_winners=0,
                total_winnings=0.0,
            )
            db.add(analytics)

        # Recalculate statistics
        lottery_history = (
            db.query(LotteryHistory)
            .filter(LotteryHistory.user_id == user_id)
            .all()
        )

        total_plays = len(lottery_history)
        total_winners = sum(1 for l in lottery_history if l.prize_amount and l.prize_amount > 0)
        total_winnings = sum(l.prize_amount or 0 for l in lottery_history if l.prize_amount)

        analytics.total_plays = total_plays
        analytics.total_winners = total_winners
        analytics.total_winnings = total_winnings
        analytics.success_rate = (total_winners / total_plays * 100) if total_plays > 0 else 0.0

        db.commit()
        db.refresh(analytics)
        return analytics


class ShareService:
    """Service for lucky share/community features"""

    @staticmethod
    def create_share(
        db: Session, user_id: str, numbers: str, lottery_type: str, 
        description: Optional[str] = None, is_public: bool = True
    ) -> LuckyShare:
        """Create a lucky share"""
        share = LuckyShare(
            id=generate_uuid(),
            user_id=user_id,
            numbers=numbers,
            lottery_type=lottery_type,
            description=description,
            is_public=is_public,
        )
        db.add(share)
        db.commit()
        db.refresh(share)
        return share

    @staticmethod
    def get_public_shares(
        db: Session, limit: int = 50, offset: int = 0
    ) -> List[LuckyShare]:
        """Get public lucky shares (leaderboard)"""
        return (
            db.query(LuckyShare)
            .filter(LuckyShare.is_public == True)
            .order_by(LuckyShare.likes_count.desc())
            .limit(limit)
            .offset(offset)
            .all()
        )

    @staticmethod
    def like_share(db: Session, share_id: str) -> Optional[LuckyShare]:
        """Like a lucky share"""
        share = db.query(LuckyShare).filter(LuckyShare.id == share_id).first()
        if share:
            share.likes_count += 1
            db.commit()
            db.refresh(share)
        return share

    @staticmethod
    def get_leaderboard(db: Session, limit: int = 50) -> List[dict]:
        """Get community leaderboard"""
        from sqlalchemy import func
        
        leaderboard = (
            db.query(
                User.id,
                User.username,
                func.count(LotteryHistory.id).label("total_plays"),
                func.sum(LotteryHistory.prize_amount).label("total_winnings"),
            )
            .join(LotteryHistory, User.id == LotteryHistory.user_id)
            .filter(User.is_active == True)
            .group_by(User.id, User.username)
            .order_by(func.sum(LotteryHistory.prize_amount).desc())
            .limit(limit)
            .all()
        )

        results = []
        for rank, entry in enumerate(leaderboard, 1):
            total_plays = entry.total_plays or 0
            total_winnings = entry.total_winnings or 0.0
            success_rate = (total_winnings / total_plays * 100) if total_plays > 0 else 0.0
            
            results.append({
                "rank": rank,
                "user_id": entry.id,
                "username": entry.username,
                "total_plays": total_plays,
                "total_winnings": total_winnings,
                "success_rate": success_rate,
            })

        return results


__all__ = ["LotteryService", "ShareService"]
