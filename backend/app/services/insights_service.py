"""Service for generating AI-powered daily insights"""
import json
from datetime import datetime, date, timedelta
from typing import Dict, List, Optional
from sqlalchemy.orm import Session
from app.models.models import DailyInsight, User, UserAnalytics
from app.utils.astrology_utils import DateUtils, NumerologyUtils
import uuid


class InsightsService:
    """Generate AI daily insights based on astrology and user data"""
    
    @staticmethod
    def generate_daily_insight(db: Session, user_id: str) -> Optional[DailyInsight]:
        """Generate daily insight for user based on birth info"""
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user or not user.birth_date:
            return None
        
        # Check if insight already exists for today
        today = date.today()
        existing = db.query(DailyInsight).filter(
            DailyInsight.user_id == user_id,
            DailyInsight.date == today
        ).first()
        
        if existing:
            return existing
        
        # Calculate astrological values
        zodiac_sign = DateUtils.get_zodiac_sign(user.birth_date)
        moon_phase = DateUtils.get_moon_phase(datetime.now())
        
        # Calculate lucky numbers
        life_path = NumerologyUtils.calculate_life_path(user.birth_date)
        daily_lucky = NumerologyUtils.calculate_daily_lucky_number(datetime.now())
        
        # Generate insight text based on zodiac and lunar phases
        insight_text = InsightsService._generate_insight_text(
            zodiac_sign, 
            moon_phase, 
            life_path,
            daily_lucky
        )
        
        # Determine lucky hours (Vedic astrology concept)
        lucky_hours = InsightsService._calculate_lucky_hours(zodiac_sign)
        
        # Get recommendations based on user's lottery history
        recommendations = InsightsService._generate_recommendations(db, user_id)
        
        # Warning/caution based on lunar phase
        warning = InsightsService._generate_warning(moon_phase, zodiac_sign)
        
        # Best activities recommendation
        best_activities = InsightsService._suggest_activities(moon_phase, zodiac_sign)
        
        # Create and save insight
        insight = DailyInsight(
            id=str(uuid.uuid4()),
            user_id=user_id,
            date=today,
            insight_text=insight_text,
            recommendations=recommendations,
            lucky_hours=lucky_hours,
            warning=warning,
            best_activities=best_activities
        )
        
        db.add(insight)
        db.commit()
        db.refresh(insight)
        
        return insight
    
    @staticmethod
    def _generate_insight_text(zodiac: str, moon_phase: str, life_path: int, daily_lucky: int) -> str:
        """Generate personalized insight text"""
        
        insights_map = {
            "Aries": f"Aries energy runs high today! With {moon_phase} moon and life path {life_path}, you're in a powerful position.",
            "Taurus": f"Steady Taurus vibes prevail. The {moon_phase} moon brings grounding energy. Lucky number: {daily_lucky}",
            "Gemini": f"Communication is your superpower today, Gemini. {moon_phase} moon enhances mental clarity.",
            "Cancer": f"Emotional intuition peaks with {moon_phase} moon. Trust your gut, Cancer. Life path {life_path} guides you.",
            "Leo": f"Leo shines bright today! Creative energy flows with {moon_phase} moon. Your lucky number is {daily_lucky}",
            "Virgo": f"Detail-oriented Virgo, organize and plan. {moon_phase} moon brings clarity to your path.",
            "Libra": f"Balance and harmony prevail for Libra today. {moon_phase} moon aligns with your nature.",
            "Scorpio": f"Intense Scorpio energy with {moon_phase} moon. Transformation awaits. Lucky: {daily_lucky}",
            "Sagittarius": f"Adventure calls, Sagittarius! {moon_phase} moon expands horizons. Life path {life_path} leads forward.",
            "Capricorn": f"Ambitious Capricorn, consolidate gains. {moon_phase} moon brings structure to success.",
            "Aquarius": f"Innovation flows through Aquarius today. {moon_phase} moon sparks brilliance.",
            "Pisces": f"Intuitive Pisces, dreams guide you. {moon_phase} moon deepens spiritual connection."
        }
        
        return insights_map.get(zodiac, f"Mystical {moon_phase} moon energy flows. Life path {life_path} guides your day.")
    
    @staticmethod
    def _calculate_lucky_hours(zodiac: str) -> str:
        """Calculate lucky hours based on zodiac"""
        
        # Simplified zodiac hour associations
        hour_map = {
            "Aries": "5am-7am, 1pm-3pm",
            "Taurus": "6am-8am, 2pm-4pm",
            "Gemini": "5am-7am, 3pm-5pm",
            "Cancer": "4am-6am, 12pm-2pm",
            "Leo": "7am-9am, 1pm-3pm",
            "Virgo": "5am-7am, 11am-1pm",
            "Libra": "7am-9am, 3pm-5pm",
            "Scorpio": "4am-6am, 2pm-4pm",
            "Sagittarius": "6am-8am, 12pm-2pm",
            "Capricorn": "5am-7am, 4pm-6pm",
            "Aquarius": "8am-10am, 3pm-5pm",
            "Pisces": "6am-8am, 11am-1pm"
        }
        
        return hour_map.get(zodiac, "6am-8am, 12pm-2pm")
    
    @staticmethod
    def _generate_recommendations(db: Session, user_id: str) -> List[str]:
        """Generate lottery recommendations based on user data"""
        
        analytics = db.query(UserAnalytics).filter(UserAnalytics.user_id == user_id).first()
        
        recommendations = [
            "Play your favorite lottery type today",
            "Mix even and odd numbers for balance"
        ]
        
        if analytics:
            if analytics.favorite_lottery_type:
                recommendations.append(f"Focus on {analytics.favorite_lottery_type} today")
            if analytics.success_rate > 0.3:
                recommendations.append("High success rate - trust your patterns")
            if analytics.total_plays > 50:
                recommendations.append("You're an experienced player - combine intuition with strategy")
        
        recommendations.append("Check the lucky hours section for optimal play times")
        
        return recommendations
    
    @staticmethod
    def _generate_warning(moon_phase: str, zodiac: str) -> Optional[str]:
        """Generate warning based on lunar phase"""
        
        warnings = {
            "New Moon": "Avoid major changes. Great for planning instead. Focus on intention-setting.",
            "Waxing Crescent": "Energy builds slowly. Start new ventures with patience.",
            "Full Moon": "High emotions and energy. Second-guess your decisions less, trust more.",
            "Waning Crescent": "Release period. Let go of losing streaks. Prepare for renewal."
        }
        
        return warnings.get(moon_phase, None)
    
    @staticmethod
    def _suggest_activities(moon_phase: str, zodiac: str) -> str:
        """Suggest activities aligned with day's energy"""
        
        if moon_phase == "Full Moon":
            return "Release rituals, gratitude practice, community activities, celebration"
        elif moon_phase == "New Moon":
            return "Meditation, goal-setting, journaling, personal reflection, intention ceremony"
        elif moon_phase == "Waxing":
            return "Launch projects, increase activity, networking, manifestation work"
        else:  # Waning
            return "Rest, healing, review results, declutter, introspection, quiet time"
    
    @staticmethod
    def get_user_insights(db: Session, user_id: str, days: int = 7) -> List[DailyInsight]:
        """Get user's recent insights"""
        
        start_date = date.today() - timedelta(days=days)
        
        insights = db.query(DailyInsight).filter(
            DailyInsight.user_id == user_id,
            DailyInsight.date >= start_date
        ).order_by(DailyInsight.date.desc()).all()
        
        return insights
    
    @staticmethod
    def generate_weekly_summary(db: Session, user_id: str) -> Dict:
        """Generate weekly insight summary"""
        
        end_date = date.today()
        start_date = end_date - timedelta(days=7)
        
        insights = db.query(DailyInsight).filter(
            DailyInsight.user_id == user_id,
            DailyInsight.date >= start_date,
            DailyInsight.date <= end_date
        ).all()
        
        if not insights:
            return {"status": "No insights available"}
        
        # Count recommendations distribution
        all_recommendations = []
        for insight in insights:
            if insight.recommendations:
                all_recommendations.extend(insight.recommendations)
        
        # Get most common recommendations
        from collections import Counter
        common_recs = Counter(all_recommendations).most_common(5)
        
        return {
            "period": f"{start_date} to {end_date}",
            "total_insights": len(insights),
            "top_recommendations": [rec[0] for rec in common_recs],
            "average_lucky_hours": f"Peak hours: Morning and Afternoon",
            "overall_energy": "Balanced" if len(insights) >= 7 else "Building"
        }
