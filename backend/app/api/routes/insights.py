"""AI Daily Insights API Routes - FastAPI endpoints for personalized insights"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import List, Optional
import json

from app.api.dependencies import get_db, get_current_user
from app.models import User
from app.models.ai_insights_models import (
    DailyInsight, DailyInsightPersonalized, InsightEngagementLog,
    UserInsightPreference, InsightHistory, InsightFeedback,
    InsightGenerationLog
)
from app.services.ai_insights_service import (
    AIInsightGeneratorService,
    AIInsightPersonalizationService,
    AIInsightNotificationService,
    AIInsightEngagementService,
    AIInsightFeedbackService
)

router = APIRouter(prefix="/api/v1/insights", tags=["AI Insights"])


# ==================== Insight Retrieval ====================

@router.get("/daily")
async def get_daily_insight(
    zodiac_sign: Optional[str] = Query(None, description="Zodiac sign (e.g., 'aries')"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get today's daily insight
    If zodiac_sign not provided, uses user's zodiac sign from profile
    """
    try:
        # Use provided zodiac or user's zodiac
        sign = zodiac_sign or getattr(current_user, 'zodiac_sign', None)
        
        if not sign:
            raise HTTPException(
                status_code=400,
                detail="Zodiac sign required in query or user profile"
            )
        
        today = datetime.utcnow().date()
        
        # Get today's base insight
        insight = db.query(DailyInsight).filter(
            DailyInsight.zodiac_sign == sign.lower(),
            DailyInsight.date >= datetime.combine(today, datetime.min.time())
        ).first()
        
        if not insight:
            raise HTTPException(status_code=404, detail="Daily insight not available yet")
        
        # Log the view
        engagement_service = AIInsightEngagementService(db)
        engagement_service.log_insight_view(current_user.id, insight.id)
        
        return {
            "id": insight.id,
            "date": insight.date.isoformat(),
            "zodiac_sign": insight.zodiac_sign,
            "title": insight.title,
            "short_summary": insight.short_summary,
            "full_content": insight.full_content,
            "mood": insight.mood.value if insight.mood else None,
            "confidence_score": insight.confidence_score,
            "sections": json.loads(insight.sections or "{}"),
            "astrological_data": {
                "moon_phase": insight.moon_phase,
                "mercury_retrograde": insight.mercury_retrograde,
                "planetary_positions": json.loads(insight.current_planetary_positions or "{}")
            },
            "view_count": insight.view_count
        }
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/daily/personalized")
async def get_personalized_insight(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get today's personalized insight for current user
    Returns user-specific version with name and history context
    """
    try:
        today = datetime.utcnow().date()
        
        # Get personalized insight for today
        personalized = db.query(DailyInsightPersonalized).filter(
            DailyInsightPersonalized.user_id == current_user.id,
            DailyInsightPersonalized.created_at >= datetime.combine(today, datetime.min.time())
        ).first()
        
        if not personalized:
            # Try to generate/personalize if not exists
            user_zodiac = getattr(current_user, 'zodiac_sign', None)
            if not user_zodiac:
                raise HTTPException(
                    status_code=400,
                    detail="User zodiac sign not configured"
                )
            
            # Get base insight and personalize
            personalization_service = AIInsightPersonalizationService(db)
            result = personalization_service.personalize_insights_for_user(current_user.id)
            
            if not result.get("success"):
                raise HTTPException(status_code=400, detail=result.get("error", "Failed to personalize"))
            
            personalized = db.query(DailyInsightPersonalized).filter(
                DailyInsightPersonalized.id == result["personalized_insight_id"]
            ).first()
        
        # Log engagement
        engagement_service = AIInsightEngagementService(db)
        engagement_service.log_insight_view(current_user.id, personalized.id)
        
        return {
            "id": personalized.id,
            "base_insight_id": personalized.base_insight_id,
            "personalized_title": personalized.personalized_title,
            "personalized_content": personalized.personalized_content,
            "sections": json.loads(personalized.personalized_sections or "{}"),
            "scheduled_delivery_time": personalized.scheduled_delivery_time.isoformat() if personalized.scheduled_delivery_time else None,
            "delivered_at": personalized.delivered_at.isoformat() if personalized.delivered_at else None,
            "view_count": personalized.view_count,
            "user_history_context": personalized.user_history_context
        }
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/by-date")
async def get_insight_by_date(
    date: str = Query(..., description="Date in YYYY-MM-DD format"),
    zodiac_sign: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get insight for specific date
    """
    try:
        sign = zodiac_sign or getattr(current_user, 'zodiac_sign', None)
        if not sign:
            raise HTTPException(status_code=400, detail="Zodiac sign required")
        
        target_date = datetime.strptime(date, "%Y-%m-%d").date()
        
        insight = db.query(DailyInsight).filter(
            DailyInsight.zodiac_sign == sign.lower(),
            DailyInsight.date >= datetime.combine(target_date, datetime.min.time()),
            DailyInsight.date < datetime.combine(target_date + timedelta(days=1), datetime.min.time())
        ).first()
        
        if not insight:
            raise HTTPException(status_code=404, detail="Insight not found for this date")
        
        engagement_service = AIInsightEngagementService(db)
        engagement_service.log_insight_view(current_user.id, insight.id)
        
        return {
            "id": insight.id,
            "date": insight.date.isoformat(),
            "zodiac_sign": insight.zodiac_sign,
            "title": insight.title,
            "full_content": insight.full_content,
            "sections": json.loads(insight.sections or "{}")
        }
    
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid date format")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/by-zodiac/{zodiac_sign}")
async def get_insights_by_zodiac(
    zodiac_sign: str,
    days: int = Query(7, ge=1, le=30),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get last N days of insights for a zodiac sign
    """
    try:
        start_date = datetime.utcnow() - timedelta(days=days)
        
        insights = db.query(DailyInsight).filter(
            DailyInsight.zodiac_sign == zodiac_sign.lower(),
            DailyInsight.date >= start_date
        ).order_by(DailyInsight.date.desc()).all()
        
        if not insights:
            raise HTTPException(status_code=404, detail="No insights found")
        
        return {
            "zodiac_sign": zodiac_sign,
            "count": len(insights),
            "insights": [{
                "id": i.id,
                "date": i.date.isoformat(),
                "title": i.title,
                "mood": i.mood.value if i.mood else None,
                "short_summary": i.short_summary,
                "view_count": i.view_count
            } for i in insights]
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== History & Archive ====================

@router.get("/history")
async def get_insight_history(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get user's insight viewing history
    """
    try:
        history = db.query(InsightHistory).filter(
            InsightHistory.user_id == current_user.id
        ).order_by(InsightHistory.viewed_at.desc()).offset(offset).limit(limit).all()
        
        return {
            "count": len(history),
            "history": [{
                "id": h.id,
                "title": h.title,
                "zodiac_sign": h.zodiac_sign,
                "viewed_at": h.viewed_at.isoformat() if h.viewed_at else None,
                "time_spent_seconds": h.time_spent_seconds,
                "rating": h.rating,
                "is_favorite": h.is_favorite
            } for h in history]
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/favorites")
async def get_favorite_insights(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get user's favorited/saved insights
    """
    try:
        favorites = db.query(InsightHistory).filter(
            InsightHistory.user_id == current_user.id,
            InsightHistory.is_favorite == True
        ).order_by(InsightHistory.created_at.desc()).all()
        
        return {
            "count": len(favorites),
            "favorites": [{
                "id": f.id,
                "title": f.title,
                "zodiac_sign": f.zodiac_sign,
                "rating": f.rating,
                "saved_at": f.created_at.isoformat()
            } for f in favorites]
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/history/{insight_id}/favorite")
async def toggle_favorite(
    insight_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Add/remove insight to/from favorites
    """
    try:
        history = db.query(InsightHistory).filter(
            InsightHistory.user_id == current_user.id,
            InsightHistory.insight_id == insight_id
        ).first()
        
        if not history:
            raise HTTPException(status_code=404, detail="Insight not in history")
        
        history.is_favorite = not history.is_favorite
        db.commit()
        
        return {
            "success": True,
            "is_favorite": history.is_favorite
        }
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== Engagement Tracking ====================

@router.post("/engagement/{insight_id}/view")
async def log_view(
    insight_id: str,
    time_spent_seconds: Optional[int] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Log that user viewed an insight
    """
    try:
        engagement_service = AIInsightEngagementService(db)
        result = engagement_service.log_insight_view(current_user.id, insight_id)
        
        if time_spent_seconds:
            engagement_service.record_time_spent(current_user.id, insight_id, time_spent_seconds)
        
        if not result.get("success"):
            raise HTTPException(status_code=400, detail=result.get("error"))
        
        return {"success": True, "message": "View logged"}
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/engagement/{insight_id}/share")
async def log_share(
    insight_id: str,
    platform: str = Query(..., description="Platform: 'whatsapp' or 'social'"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Log share action
    """
    try:
        if platform not in ["whatsapp", "social"]:
            raise HTTPException(status_code=400, detail="Invalid platform")
        
        engagement_service = AIInsightEngagementService(db)
        interaction_type = "share_whatsapp" if platform == "whatsapp" else "share_social"
        
        result = engagement_service.log_insight_interaction(
            current_user.id, insight_id, interaction_type
        )
        
        if not result.get("success"):
            raise HTTPException(status_code=400, detail=result.get("error"))
        
        return {"success": True, "message": f"Shared to {platform}"}
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/engagement/{insight_id}/save")
async def log_save(
    insight_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Save insight for later reading
    """
    try:
        engagement_service = AIInsightEngagementService(db)
        result = engagement_service.log_insight_interaction(
            current_user.id, insight_id, "save"
        )
        
        if not result.get("success"):
            raise HTTPException(status_code=400, detail=result.get("error"))
        
        return {"success": True, "message": "Insight saved"}
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/engagement/stats")
async def get_engagement_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get user's overall engagement statistics
    """
    try:
        engagement_service = AIInsightEngagementService(db)
        stats = engagement_service.get_user_engagement_stats(current_user.id)
        
        return stats
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== User Preferences ====================

@router.get("/preferences")
async def get_preferences(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get user's insight preferences
    """
    try:
        prefs = db.query(UserInsightPreference).filter(
            UserInsightPreference.user_id == current_user.id
        ).first()
        
        if not prefs:
            # Create default preferences
            prefs = UserInsightPreference(user_id=current_user.id)
            db.add(prefs)
            db.commit()
        
        return {
            "id": prefs.id,
            "insights_enabled": prefs.insights_enabled,
            "delivery_time": prefs.delivery_time,
            "delivery_timezone": prefs.delivery_timezone,
            "delivery_frequency": prefs.delivery_frequency,
            "channels": {
                "email": prefs.send_via_email,
                "push": prefs.send_via_push,
                "whatsapp": prefs.send_via_whatsapp
            },
            "content_preferences": {
                "insight_types": json.loads(prefs.preferred_insight_types or "[]"),
                "mood": prefs.preferred_mood,
                "personalization_level": prefs.personalization_level,
                "include_birth_chart": prefs.include_birth_chart_insights,
                "include_transit_data": prefs.include_transit_data,
                "include_numerology": prefs.include_numerology,
                "include_tarot": prefs.include_tarot
            },
            "writing_style": prefs.writing_style,
            "content_length": prefs.content_length,
            "quiet_hours": {
                "enabled": prefs.quiet_hours_enabled,
                "start": prefs.quiet_hours_start,
                "end": prefs.quiet_hours_end
            },
            "auto_save_favorites": prefs.auto_save_favorites,
            "enable_weekly_digest": prefs.enable_weekly_digest
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/preferences")
async def update_preferences(
    preferences: dict,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Update user's insight preferences
    """
    try:
        prefs = db.query(UserInsightPreference).filter(
            UserInsightPreference.user_id == current_user.id
        ).first()
        
        if not prefs:
            prefs = UserInsightPreference(user_id=current_user.id)
        
        # Update fields
        if "insights_enabled" in preferences:
            prefs.insights_enabled = preferences["insights_enabled"]
        
        if "delivery_time" in preferences:
            prefs.delivery_time = preferences["delivery_time"]
        
        if "delivery_timezone" in preferences:
            prefs.delivery_timezone = preferences["delivery_timezone"]
        
        if "channels" in preferences:
            channels = preferences["channels"]
            prefs.send_via_email = channels.get("email", prefs.send_via_email)
            prefs.send_via_push = channels.get("push", prefs.send_via_push)
            prefs.send_via_whatsapp = channels.get("whatsapp", prefs.send_via_whatsapp)
        
        if "content_preferences" in preferences:
            content = preferences["content_preferences"]
            if "insight_types" in content:
                prefs.preferred_insight_types = json.dumps(content["insight_types"])
            if "mood" in content:
                prefs.preferred_mood = content["mood"]
        
        if "writing_style" in preferences:
            prefs.writing_style = preferences["writing_style"]
        
        if "quiet_hours" in preferences:
            quiet = preferences["quiet_hours"]
            prefs.quiet_hours_enabled = quiet.get("enabled", prefs.quiet_hours_enabled)
            prefs.quiet_hours_start = quiet.get("start", prefs.quiet_hours_start)
            prefs.quiet_hours_end = quiet.get("end", prefs.quiet_hours_end)
        
        db.add(prefs)
        db.commit()
        
        return {"success": True, "message": "Preferences updated"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/preferences/reset")
async def reset_preferences(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Reset preferences to defaults
    """
    try:
        prefs = db.query(UserInsightPreference).filter(
            UserInsightPreference.user_id == current_user.id
        ).first()
        
        if prefs:
            db.delete(prefs)
            db.commit()
        
        # Create new default
        new_prefs = UserInsightPreference(user_id=current_user.id)
        db.add(new_prefs)
        db.commit()
        
        return {"success": True, "message": "Preferences reset to defaults"}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== Feedback & Ratings ====================

@router.post("/feedback/{insight_id}")
async def submit_feedback(
    insight_id: str,
    rating: int = Query(..., ge=1, le=5),
    comment: Optional[str] = None,
    tags: Optional[List[str]] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Submit feedback/rating on an insight
    Used for AI model training and improvement
    """
    try:
        feedback_service = AIInsightFeedbackService(db)
        result = feedback_service.submit_feedback(
            current_user.id, insight_id, rating, comment, tags
        )
        
        if not result.get("success"):
            raise HTTPException(status_code=400, detail=result.get("error"))
        
        return {"success": True, "message": "Feedback recorded"}
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/feedback/{insight_id}/summary")
async def get_feedback_summary(
    insight_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get feedback summary for an insight
    """
    try:
        feedback_service = AIInsightFeedbackService(db)
        summary = feedback_service.get_feedback_summary(insight_id)
        
        return summary
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/feedback/my-feedback")
async def get_my_feedback(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get all feedback submitted by current user
    """
    try:
        feedback_list = db.query(InsightFeedback).filter(
            InsightFeedback.user_id == current_user.id
        ).order_by(InsightFeedback.created_at.desc()).offset(offset).limit(limit).all()
        
        return {
            "count": len(feedback_list),
            "feedback": [{
                "id": f.id,
                "insight_id": f.insight_id,
                "rating": f.overall_rating,
                "comment": f.comment,
                "tags": json.loads(f.feedback_tags or "[]"),
                "created_at": f.created_at.isoformat()
            } for f in feedback_list]
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== Admin/Generation Endpoints ====================

@router.post("/generate/batch")
async def trigger_batch_generation(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Manually trigger batch generation of daily insights
    Admin endpoint - requires admin role
    """
    try:
        # TODO: Add admin role check
        
        generator_service = AIInsightGeneratorService(db)
        result = generator_service.generate_daily_insights_batch()
        
        return result
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/generation-logs")
async def get_generation_logs(
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get generation process logs for monitoring
    """
    try:
        logs = db.query(InsightGenerationLog).order_by(
            InsightGenerationLog.generation_date.desc()
        ).offset(offset).limit(limit).all()
        
        return {
            "count": len(logs),
            "logs": [{
                "id": log.id,
                "generation_date": log.generation_date.isoformat(),
                "ai_model": log.ai_model_used,
                "generation_time_seconds": log.generation_time_seconds,
                "confidence_score": log.confidence_score,
                "status": log.status,
                "total_generated": log.total_generated
            } for log in logs]
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/quality-metrics")
async def get_quality_metrics(
    days: int = Query(7, ge=1, le=90),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get quality metrics for generated insights
    """
    try:
        start_date = datetime.utcnow() - timedelta(days=days)
        
        logs = db.query(InsightGenerationLog).filter(
            InsightGenerationLog.generation_date >= start_date
        ).all()
        
        if not logs:
            return {
                "period_days": days,
                "total_generations": 0
            }
        
        avg_confidence = sum([l.confidence_score for l in logs]) / len(logs)
        avg_diversity = sum([l.diversity_score for l in logs if l.diversity_score]) / max(len([l for l in logs if l.diversity_score]), 1)
        
        successful = len([l for l in logs if l.status == "success"])
        failed = len([l for l in logs if l.status == "failed"])
        
        return {
            "period_days": days,
            "total_generations": len(logs),
            "successful": successful,
            "failed": failed,
            "success_rate": f"{successful / len(logs) * 100:.1f}%",
            "average_confidence_score": f"{avg_confidence:.2f}",
            "average_diversity_score": f"{avg_diversity:.2f}",
            "average_generation_time_seconds": sum([l.generation_time_seconds for l in logs]) / len(logs)
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== Personalization ====================

@router.post("/personalize")
async def trigger_personalization(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Manually trigger personalization of insights for current user
    """
    try:
        personalization_service = AIInsightPersonalizationService(db)
        result = personalization_service.personalize_insights_for_user(current_user.id)
        
        if not result.get("success"):
            raise HTTPException(status_code=400, detail=result.get("error"))
        
        return result
    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/send-notifications")
async def trigger_send_notifications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Manually trigger sending notifications
    Admin endpoint
    """
    try:
        notification_service = AIInsightNotificationService(db)
        result = notification_service.send_personalized_insights()
        
        return result
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ==================== Search & Discovery ====================

@router.get("/search")
async def search_insights(
    query: str = Query(..., min_length=2),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Search insights by title or content
    """
    try:
        # Simple full-text search
        search_term = f"%{query}%"
        
        insights = db.query(DailyInsight).filter(
            (DailyInsight.title.ilike(search_term)) |
            (DailyInsight.short_summary.ilike(search_term))
        ).limit(limit).all()
        
        return {
            "query": query,
            "count": len(insights),
            "results": [{
                "id": i.id,
                "date": i.date.isoformat(),
                "zodiac_sign": i.zodiac_sign,
                "title": i.title,
                "short_summary": i.short_summary[:100] + "..."
            } for i in insights]
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/trending")
async def get_trending_insights(
    limit: int = Query(10, ge=1, le=50),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get most viewed/engaged insights
    """
    try:
        week_ago = datetime.utcnow() - timedelta(days=7)
        
        trending = db.query(DailyInsight).filter(
            DailyInsight.published_at >= week_ago
        ).order_by(
            (DailyInsight.view_count + DailyInsight.interaction_count).desc()
        ).limit(limit).all()
        
        return {
            "count": len(trending),
            "trending": [{
                "id": i.id,
                "title": i.title,
                "zodiac_sign": i.zodiac_sign,
                "view_count": i.view_count,
                "engagement_score": (i.view_count or 0) + (i.interaction_count or 0)
            } for i in trending]
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
