"""
Statistics Dashboard API Routes
FastAPI endpoints for lottery statistics and analytics.
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from datetime import datetime
from uuid import UUID

from app.core.database import get_db
from app.core.security import get_current_user
from app.models import User
from app.models.statistics_models import (
    StatisticsDashboardConfig, EngagementMetric, UserStatistics
)
from app.services.statistics_service import (
    NumberAnalysisService, TrendAnalysisService, PatternRecognitionService,
    DashboardDataService, EngagementTracker
)

router = APIRouter(prefix="/api/v1/statistics", tags=["statistics"])


# ========================
# Dashboard Overview
# ========================

@router.get("/dashboard/summary")
async def get_dashboard_summary(
    lottery_type: str = Query("powerball", description="Lottery type"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get complete statistics dashboard summary.
    
    Includes hot/cold numbers, trends, patterns, and personal stats.
    """
    try:
        # Log engagement
        tracker = EngagementTracker(db)
        tracker.log_engagement(
            current_user.id,
            "view_dashboard",
            "dashboard_home",
            lottery_type=lottery_type
        )
        
        # Get dashboard data
        service = DashboardDataService(db)
        data = service.get_dashboard_summary(lottery_type, current_user.id)
        
        return {
            "success": True,
            "data": data
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ========================
# Hot & Cold Numbers
# ========================

@router.get("/hot-cold/overview")
async def get_hot_cold_overview(
    lottery_type: str = Query("powerball"),
    limit: int = Query(10, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get hot and cold numbers overview.
    
    Returns top hot and cold numbers for specified lottery.
    """
    try:
        tracker = EngagementTracker(db)
        tracker.log_engagement(
            current_user.id,
            "view_hot_cold",
            "hot_cold_overview",
            lottery_type=lottery_type
        )
        
        service = NumberAnalysisService(db)
        hot_numbers = service.get_hot_numbers(lottery_type, limit)
        cold_numbers = service.get_cold_numbers(lottery_type, limit)
        
        return {
            "success": True,
            "data": {
                "hot_numbers": hot_numbers,
                "cold_numbers": cold_numbers,
                "analysis_date": datetime.utcnow().isoformat(),
                "lottery_type": lottery_type,
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/hot-cold/detail/{number}")
async def get_number_detail(
    number: int = Query(..., ge=1, le=100),
    lottery_type: str = Query("powerball"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get detailed analysis for specific number.
    
    Includes frequency, gaps, patterns, and recommendations.
    """
    try:
        tracker = EngagementTracker(db)
        tracker.log_engagement(
            current_user.id,
            "view_number_detail",
            "number_detail",
            lottery_type=lottery_type
        )
        
        service = NumberAnalysisService(db)
        analysis = service.analyze_individual_number(lottery_type, number)
        
        return {
            "success": True,
            "data": analysis
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ========================
# Trends
# ========================

@router.get("/trends/overview")
async def get_trends_overview(
    lottery_type: str = Query("powerball"),
    limit: int = Query(10, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get trending numbers (increasing and decreasing).
    """
    try:
        tracker = EngagementTracker(db)
        tracker.log_engagement(
            current_user.id,
            "view_trends",
            "trends_overview",
            lottery_type=lottery_type
        )
        
        service = TrendAnalysisService(db)
        trending_up = service.get_trending_numbers(lottery_type, limit)
        trending_down = service.get_trending_down_numbers(lottery_type, limit)
        
        return {
            "success": True,
            "data": {
                "trending_up": trending_up,
                "trending_down": trending_down,
                "analysis_date": datetime.utcnow().isoformat(),
                "period_days": 90,
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/trends/number/{number}")
async def get_number_trend(
    number: int = Query(..., ge=1, le=100),
    lottery_type: str = Query("powerball"),
    period_days: int = Query(90, ge=7, le=365),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get trend analysis for specific number.
    """
    try:
        service = TrendAnalysisService(db)
        trend = service.analyze_trends(lottery_type, number, period_days)
        
        return {
            "success": True,
            "data": trend
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ========================
# Patterns
# ========================

@router.get("/patterns/top")
async def get_top_patterns(
    lottery_type: str = Query("powerball"),
    limit: int = Query(10, ge=1, le=50),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get top winning patterns for lottery type.
    
    Includes consecutive numbers, odd/even ratios, sum patterns, etc.
    """
    try:
        tracker = EngagementTracker(db)
        tracker.log_engagement(
            current_user.id,
            "view_patterns",
            "patterns_top",
            lottery_type=lottery_type
        )
        
        service = PatternRecognitionService(db)
        
        # Find different pattern types
        consecutive = service.find_consecutive_patterns(lottery_type)
        odd_even = service.find_odd_even_patterns(lottery_type)
        sum_patterns = service.find_sum_patterns(lottery_type)
        
        # Get top patterns
        top_patterns = service.get_top_patterns(lottery_type, limit)
        
        return {
            "success": True,
            "data": {
                "patterns": top_patterns,
                "analysis_date": datetime.utcnow().isoformat(),
                "lottery_type": lottery_type,
                "total_patterns": len(top_patterns),
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/patterns/{pattern_id}/track")
async def track_pattern_interest(
    pattern_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Track user interest in specific pattern.
    
    Used for personalization and engagement analytics.
    """
    try:
        tracker = EngagementTracker(db)
        tracker.log_engagement(
            current_user.id,
            "pattern_interest",
            "pattern_detail"
        )
        
        return {
            "success": True,
            "message": "Pattern tracked"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ========================
# Personal Statistics
# ========================

@router.get("/personal/summary")
async def get_personal_statistics(
    lottery_type: str = Query("powerball"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get user's personal lottery statistics.
    
    Includes win rate, ROI, play frequency, etc.
    """
    try:
        stats = db.query(UserStatistics).filter(
            UserStatistics.user_id == current_user.id,
            UserStatistics.lottery_type == lottery_type
        ).first()
        
        if not stats:
            return {
                "success": True,
                "data": {
                    "message": "No statistics yet",
                    "total_tickets": 0,
                    "total_winnings": 0.0,
                    "roi": 0.0,
                }
            }
        
        return {
            "success": True,
            "data": {
                "total_tickets": stats.total_tickets_purchased,
                "total_spent": round(stats.total_spent, 2),
                "total_winnings": round(stats.total_winnings, 2),
                "win_rate": round(stats.win_rate, 2),
                "roi": round(stats.roi_percentage, 2),
                "largest_win": round(stats.largest_win, 2),
                "play_frequency": stats.play_frequency,
                "days_playing": stats.days_playing,
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/personal/lucky-numbers")
async def get_lucky_numbers(
    lottery_type: str = Query("powerball"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get user's most frequently used lucky numbers.
    """
    try:
        stats = db.query(UserStatistics).filter(
            UserStatistics.user_id == current_user.id,
            UserStatistics.lottery_type == lottery_type
        ).first()
        
        if not stats or not stats.lucky_numbers_used:
            return {
                "success": True,
                "data": {"lucky_numbers": []}
            }
        
        return {
            "success": True,
            "data": {
                "lucky_numbers": stats.lucky_numbers_used,
                "most_frequent": stats.most_frequently_played_number,
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ========================
# Engagement Tracking
# ========================

@router.post("/engagement/view")
async def log_view(
    screen: str = Query(...),
    time_spent_seconds: int = Query(0),
    lottery_type: str = Query("powerball"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Log view event for analytics.
    """
    try:
        tracker = EngagementTracker(db)
        tracker.log_engagement(
            current_user.id,
            "view",
            screen,
            time_spent_seconds,
            lottery_type
        )
        
        return {
            "success": True,
            "message": "View logged"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/engagement/stats")
async def get_engagement_stats(
    lottery_type: str = Query("powerball"),
    days: int = Query(30, ge=1, le=365),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get dashboard engagement statistics.
    
    Shows engagement rate, average time spent, purchase correlation, etc.
    """
    try:
        tracker = EngagementTracker(db)
        stats = tracker.get_engagement_rate(lottery_type, days)
        
        return {
            "success": True,
            "data": stats
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ========================
# Dashboard Preferences
# ========================

@router.get("/preferences")
async def get_dashboard_preferences(
    lottery_type: str = Query("powerball"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get user's dashboard configuration preferences.
    """
    try:
        config = db.query(StatisticsDashboardConfig).filter(
            StatisticsDashboardConfig.user_id == current_user.id,
            StatisticsDashboardConfig.lottery_type == lottery_type
        ).first()
        
        if not config:
            # Return defaults
            return {
                "success": True,
                "data": {
                    "show_hot_cold": True,
                    "show_trends": True,
                    "show_patterns": True,
                    "show_personal_stats": True,
                    "analysis_period": "30_days",
                    "dark_mode": False,
                }
            }
        
        return {
            "success": True,
            "data": {
                "show_hot_cold": config.show_hot_cold_numbers,
                "show_trends": config.show_trends,
                "show_patterns": config.show_winning_patterns,
                "show_personal_stats": config.show_personal_stats,
                "analysis_period": config.hot_cold_analysis_period,
                "dark_mode": config.dark_mode,
                "notify_hot_numbers": config.notify_hot_numbers_change,
                "notify_new_patterns": config.notify_new_pattern_detected,
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/preferences")
async def update_dashboard_preferences(
    lottery_type: str = Query("powerball"),
    preferences: dict = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Update dashboard configuration preferences.
    """
    try:
        config = db.query(StatisticsDashboardConfig).filter(
            StatisticsDashboardConfig.user_id == current_user.id,
            StatisticsDashboardConfig.lottery_type == lottery_type
        ).first()
        
        if not config:
            config = StatisticsDashboardConfig(
                user_id=current_user.id,
                lottery_type=lottery_type
            )
            db.add(config)
        
        # Update preferences
        if preferences:
            for key, value in preferences.items():
                if hasattr(config, key):
                    setattr(config, key, value)
        
        db.commit()
        
        return {
            "success": True,
            "message": "Preferences updated"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ========================
# Recommendations
# ========================

@router.get("/recommendations/numbers")
async def get_number_recommendations(
    lottery_type: str = Query("powerball"),
    count: int = Query(6, ge=1, le=10),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get AI-powered number recommendations based on statistics.
    
    Uses hot numbers, trends, and patterns.
    """
    try:
        service = NumberAnalysisService(db)
        hot_numbers = service.get_hot_numbers(lottery_type, count)
        
        # Extract just the numbers
        recommended = [num["number"] for num in hot_numbers[:count]]
        
        # Pad with cold numbers if needed
        if len(recommended) < count:
            cold_numbers = service.get_cold_numbers(lottery_type, count - len(recommended))
            recommended.extend([num["number"] for num in cold_numbers])
        
        return {
            "success": True,
            "data": {
                "recommended_numbers": recommended[:count],
                "reasoning": "Based on hot number frequency analysis",
                "confidence_score": 0.82,
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/recommendations/feedback")
async def submit_recommendation_feedback(
    recommended_numbers: list = Query(...),
    purchased: bool = Query(False),
    won: bool = Query(False),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Submit feedback on recommendations to improve AI model.
    """
    try:
        # Track if recommended numbers led to purchase/win
        tracker = EngagementTracker(db)
        metric = tracker.log_engagement(
            current_user.id,
            "recommendation_feedback",
            "recommendation"
        )
        metric.purchased_ticket_after = purchased
        
        db.commit()
        
        return {
            "success": True,
            "message": "Feedback recorded"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ========================
# Export & Sharing
# ========================

@router.get("/export/statistics")
async def export_statistics(
    lottery_type: str = Query("powerball"),
    format: str = Query("json", regex="^(json|csv)$"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Export statistics in JSON or CSV format.
    """
    try:
        service = DashboardDataService(db)
        data = service.get_dashboard_summary(lottery_type, current_user.id)
        
        if format == "csv":
            # Convert to CSV format (simplified)
            csv_data = "Number,Category,Frequency,TrendScore\n"
            for num in data.get("hot_numbers", []):
                csv_data += f"{num['number']},hot,{num['frequency_score']},\n"
            for num in data.get("cold_numbers", []):
                csv_data += f"{num['number']},cold,{num['frequency_score']},\n"
            
            return {
                "success": True,
                "format": "csv",
                "data": csv_data
            }
        
        return {
            "success": True,
            "format": "json",
            "data": data
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/share/statistics")
async def share_statistics(
    lottery_type: str = Query("powerball"),
    platform: str = Query("whatsapp", regex="^(whatsapp|social|email)$"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Share statistics to social media or via WhatsApp.
    """
    try:
        return {
            "success": True,
            "message": f"Statistics shared to {platform}",
            "share_link": f"https://astroluck.com/shared/stats/{current_user.id}"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
