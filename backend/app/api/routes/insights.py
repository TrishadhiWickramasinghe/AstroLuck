"""API routes for insights, badges, and achievements"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from app.core.security import get_current_user
from app.models.models import User
from app.services.insights_service import InsightsService
from app.services.badge_service import BadgeService
from pydantic import BaseModel
from typing import List, Dict

router = APIRouter(prefix="/api/v1", tags=["Insights & Achievements"])


# ============ Pydantic Models ============

class InsightResponse(BaseModel):
    date: str
    insight_text: str
    lucky_hours: str
    best_activities: str
    warning: str = None
    recommendations: List[str]


class BadgeResponse(BaseModel):
    badge_name: str
    badge_icon: str
    description: str
    points_earned: int
    unlocked_date: str


class AchievementsResponse(BaseModel):
    total_badges: int
    total_points: int
    badges: List[BadgeResponse]
    recent_unlocked: List[BadgeResponse]


# ============ Insight Routes ============

@router.post("/insights/generate")
def generate_daily_insight(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Generate today's daily insight"""
    
    insight = InsightsService.generate_daily_insight(db, current_user.id)
    
    if not insight:
        raise HTTPException(
            status_code=400,
            detail="Could not generate insight. Please ensure your birth date is set."
        )
    
    return {
        "status": "success",
        "insight": {
            "date": insight.date.isoformat() if insight.date else None,
            "insight_text": insight.insight_text,
            "lucky_hours": insight.lucky_hours,
            "best_activities": insight.best_activities,
            "warning": insight.warning,
            "recommendations": insight.recommendations or []
        }
    }


@router.get("/insights/today")
def get_today_insight(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get today's insight"""
    
    from datetime import date
    from app.models.models import DailyInsight
    
    insight = db.query(DailyInsight).filter(
        DailyInsight.user_id == current_user.id,
        DailyInsight.date == date.today()
    ).first()
    
    if not insight:
        # Generate if not exists
        insight = InsightsService.generate_daily_insight(db, current_user.id)
    
    if not insight:
        raise HTTPException(status_code=404, detail="No insight available")
    
    return {
        "status": "success",
        "insight": {
            "date": insight.date.isoformat() if insight.date else None,
            "insight_text": insight.insight_text,
            "lucky_hours": insight.lucky_hours,
            "best_activities": insight.best_activities,
            "warning": insight.warning,
            "recommendations": insight.recommendations or []
        }
    }


@router.get("/insights/weekly")
def get_weekly_insights(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get weekly insights summary"""
    
    summary = InsightsService.generate_weekly_summary(db, current_user.id)
    
    return {
        "status": "success",
        "weekly_summary": summary
    }


@router.get("/insights/history")
def get_insights_history(
    days: int = 7,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's insight history"""
    
    insights = InsightsService.get_user_insights(db, current_user.id, days)
    
    return {
        "status": "success",
        "total_insights": len(insights),
        "insights": [
            {
                "date": i.date.isoformat() if i.date else None,
                "insight_text": i.insight_text,
                "lucky_hours": i.lucky_hours,
                "recommendations": i.recommendations or []
            }
            for i in insights
        ]
    }


# ============ Badge & Achievement Routes ============

@router.get("/achievements")
def get_achievements(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's achievements and badges"""
    
    # Check for newly unlocked badges
    newly_unlocked = BadgeService.check_and_unlock_badges(db, current_user.id)
    
    # Get all badges
    badges = BadgeService.get_user_badges(db, current_user.id)
    total_points = BadgeService.get_total_points(db, current_user.id)
    
    return {
        "status": "success",
        "total_badges": len(badges),
        "total_points": total_points,
        "newly_unlocked": {
            "count": len(newly_unlocked),
            "badges": [
                {
                    "badge_name": b.badge_name,
                    "badge_icon": b.badge_icon,
                    "description": b.description,
                    "points_earned": b.points_earned
                }
                for b in newly_unlocked
            ]
        },
        "badges": [
            {
                "badge_name": b.badge_name,
                "badge_icon": b.badge_icon,
                "description": b.description,
                "points_earned": b.points_earned,
                "unlocked_date": b.unlocked_date.isoformat() if b.unlocked_date else None
            }
            for b in badges
        ]
    }


@router.get("/achievements/progress")
def get_achievement_progress(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get progress towards locked achievements"""
    
    progress = BadgeService.get_badge_progress(db, current_user.id)
    
    return {
        "status": "success",
        "progress": progress
    }


@router.post("/achievements/check-unlock")
def check_and_unlock_badges(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Manually check for unlockable badges"""
    
    unlocked = BadgeService.check_and_unlock_badges(db, current_user.id)
    
    return {
        "status": "success",
        "newly_unlocked": len(unlocked),
        "badges": [
            {
                "badge_name": b.badge_name,
                "badge_icon": b.badge_icon,
                "points_earned": b.points_earned
            }
            for b in unlocked
        ]
    }


@router.get("/leaderboard")
def get_community_leaderboard(
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get community leaderboard by achievement points"""
    
    from sqlalchemy import func
    from app.models.models import UserBadge
    
    # Get top users by achievement points
    top_users = db.query(
        UserBadge.user_id,
        func.sum(UserBadge.points_earned).label('total_points')
    ).group_by(UserBadge.user_id).order_by(
        func.sum(UserBadge.points_earned).desc()
    ).limit(limit).all()
    
    leaderboard = []
    for rank, (user_id, total_points) in enumerate(top_users, 1):
        user = db.query(User).filter(User.id == user_id).first()
        badges_count = db.query(UserBadge).filter(
            UserBadge.user_id == user_id
        ).count()
        
        leaderboard.append({
            "rank": rank,
            "username": user.username if user else "Unknown",
            "total_points": total_points or 0,
            "badges": badges_count
        })
    
    return {
        "status": "success",
        "leaderboard": leaderboard
    }


@router.get("/user/{user_id}/achievements")
def get_user_achievements(
    user_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get another user's public achievements"""
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    badges = BadgeService.get_user_badges(db, user_id)
    total_points = BadgeService.get_total_points(db, user_id)
    
    return {
        "status": "success",
        "user": user.username,
        "total_points": total_points,
        "total_badges": len(badges),
        "badges": [
            {
                "badge_name": b.badge_name,
                "badge_icon": b.badge_icon,
                "description": b.description
            }
            for b in badges
        ]
    }
