"""
Intelligence & Analytics API Routes
Numerology, Win Probability, Statistics, AI Insights, Dashboard
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import List

from app.api.dependencies import get_db, get_current_user
from app.services.intelligence_service import (
    NumerologyService, WinProbabilityService,
    StatisticalAnalysisService, AIInsightService,
    AnalyticsDashboardService
)

router = APIRouter(prefix="/api/v1", tags=["intelligence"])


# ============ NUMEROLOGY ENDPOINTS ============

@router.get("/numerology/profile")
async def get_numerology_profile(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get user's complete numerology profile"""
    try:
        profile = NumerologyService.get_numerology_profile(db, current_user.id)
        
        return {
            'life_path_number': profile.life_path_number,
            'destiny_number': profile.destiny_number,
            'soul_urge_number': profile.soul_urge_number,
            'personality_number': profile.personality_number,
            'expression_number': profile.expression_number,
            'birth_day_number': profile.birth_day_number,
            'life_path_reading': profile.life_path_reading,
            'destiny_reading': profile.destiny_reading,
            'soul_urge_reading': profile.soul_urge_reading,
            'lucky_numbers': profile.lucky_numbers,
            'lucky_colors': profile.lucky_colors,
            'lucky_days': profile.lucky_days,
            'lucky_hours': profile.lucky_hours,
            'zodiac_compatibility': profile.zodiac_compatibility,
            'challenges': profile.challenges,
            'strengths': profile.strengths,
            'personal_year_number': profile.personal_year_number,
            'personal_year_reading': profile.personal_year_reading,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/numerology/life-path/{number}")
async def get_life_path_details(
    number: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get detailed explanation of a life path number"""
    if not 1 <= number <= 33:
        raise HTTPException(status_code=400, detail="Invalid life path number")
    
    return {
        'number': number,
        'reading': NumerologyService._generate_life_path_reading(number),
        'compatibility': {
            'best_match': ((number + 1) % 9) or 9,
            'challenging': ((number + 5) % 9) or 9,
        }
    }


@router.get("/numerology/destiny/{number}")
async def get_destiny_details(
    number: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get detailed explanation of a destiny number"""
    if not 1 <= number <= 9:
        raise HTTPException(status_code=400, detail="Invalid destiny number")
    
    return {
        'number': number,
        'reading': NumerologyService._generate_destiny_reading(number),
    }


@router.get("/numerology/compatibility")
async def get_numerology_compatibility(
    other_number: int = Query(...),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get numerology compatibility with another person's number"""
    profile = NumerologyService.get_numerology_profile(db, current_user.id)
    
    # Calculate compatibility
    difference = abs(profile.life_path_number - other_number)
    compatibility = max(0, 100 - (difference * 10))
    
    return {
        'compatibility_score': compatibility,
        'your_number': profile.life_path_number,
        'other_number': other_number,
        'compatibility_level': 'Excellent' if compatibility > 80 else 'Good' if compatibility > 60 else 'Moderate',
    }


# ============ WIN PROBABILITY ENDPOINTS ============

@router.post("/probability/calculate")
async def calculate_win_probability(
    lottery_type: str = Query(...),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Calculate win probability for a specific lottery type"""
    valid_types = ['powerball', 'megamillions', 'lucky_seven', 'daily_pick']
    if lottery_type not in valid_types:
        raise HTTPException(status_code=400, detail=f"Invalid lottery type. Must be one of {valid_types}")
    
    try:
        probability = WinProbabilityService.calculate_probability(
            db, current_user.id, lottery_type
        )
        
        return {
            'lottery_type': lottery_type,
            'predicted_win_probability': probability.predicted_win_probability,
            'confidence_score': probability.confidence_score,
            'recommended_numbers': probability.recommended_numbers,
            'avoid_numbers': probability.avoid_numbers,
            'best_time_to_play': probability.best_time_to_play,
            'best_days_to_play': probability.best_days_to_play,
            'breakdown': {
                'base_probability': probability.base_probability,
                'numerology_boost': probability.numerology_boost,
                'astrological_influence': probability.astrological_influence,
                'historical_performance': probability.historical_performance,
                'lucky_day_bonus': probability.lucky_day_bonus,
                'lucky_hour_bonus': probability.lucky_hour_bonus,
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/probability/today")
async def get_probability_today(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get today's win probability for all lottery types"""
    try:
        probabilities = {}
        for lottery_type in ['powerball', 'megamillions', 'lucky_seven', 'daily_pick']:
            prob = WinProbabilityService.calculate_probability(db, current_user.id, lottery_type)
            probabilities[lottery_type] = {
                'probability': prob.predicted_win_probability,
                'recommendation': 'play' if prob.predicted_win_probability > 2 else 'wait',
                'best_numbers': prob.recommended_numbers,
            }
        
        return probabilities
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============ STATISTICS ENDPOINTS ============

@router.get("/statistics/dashboard")
async def get_statistics_dashboard(
    lottery_type: str = Query(default='powerball'),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get user's statistical dashboard"""
    try:
        stats = StatisticalAnalysisService.analyze_user_statistics(
            db, current_user.id, lottery_type
        )
        
        return {
            'total_plays': stats.total_plays,
            'win_rate': stats.win_rate,
            'hot_numbers': stats.hot_numbers,
            'cold_numbers': stats.cold_numbers,
            'most_active_day': stats.most_active_day,
            'most_active_hour': stats.most_active_hour,
            'hot_count': stats.hot_count,
            'cold_count': stats.cold_count,
            'even_odd_ratio': stats.even_odd_ratio,
            'prime_number_ratio': stats.prime_number_ratio,
            'current_losing_streak': stats.current_losing_streak,
            'last_play_date': stats.last_play_date,
            'days_since_last_play': stats.days_since_last_play,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/statistics/hot-numbers")
async def get_hot_numbers(
    lottery_type: str = Query(default='powerball'),
    limit: int = Query(10, ge=1, le=55),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get user's hot numbers (most frequently played/won)"""
    try:
        stats = StatisticalAnalysisService.analyze_user_statistics(
            db, current_user.id, lottery_type
        )
        
        return {
            'hot_numbers': stats.hot_numbers[:limit],
            'appearance_counts': stats.hot_count,
            'total_plays': stats.total_plays,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/statistics/cold-numbers")
async def get_cold_numbers(
    lottery_type: str = Query(default='powerball'),
    limit: int = Query(10, ge=1, le=55),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get user's cold numbers (rarely played/won)"""
    try:
        stats = StatisticalAnalysisService.analyze_user_statistics(
            db, current_user.id, lottery_type
        )
        
        return {
            'cold_numbers': stats.cold_numbers[:limit],
            'appearance_counts': stats.cold_count,
            'total_plays': stats.total_plays,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/statistics/patterns")
async def get_number_patterns(
    lottery_type: str = Query(default='powerball'),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get number patterns and trends"""
    try:
        stats = StatisticalAnalysisService.analyze_user_statistics(
            db, current_user.id, lottery_type
        )
        
        return {
            'even_odd_ratio': stats.even_odd_ratio,
            'prime_number_ratio': stats.prime_number_ratio,
            'numbers_due_to_appear': stats.numbers_due_to_appear,
            'number_sequences': stats.number_sequences,
            'gap_analysis': stats.gap_analysis,
            'trend_direction': stats.trend_direction,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/statistics/performance")
async def get_performance_metrics(
    lottery_type: str = Query(default='powerball'),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get performance metrics"""
    try:
        stats = StatisticalAnalysisService.analyze_user_statistics(
            db, current_user.id, lottery_type
        )
        
        return {
            'total_plays': stats.total_plays,
            'winning_plays': stats.total_wins,
            'losing_plays': stats.total_plays - stats.total_wins,
            'win_rate': stats.win_rate,
            'roi': stats.roi,
            'average_spend': stats.average_spend,
            'average_winnings': stats.average_winnings,
            'total_spent': stats.total_spent,
            'total_winnings': stats.total_winnings,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============ AI INSIGHTS ENDPOINTS ============

@router.post("/insights/generate-daily")
async def generate_daily_insight(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Generate or retrieve today's AI insight"""
    try:
        insight = AIInsightService.generate_daily_insight(db, current_user.id)
        
        return {
            'id': insight.id,
            'title': insight.title,
            'description': insight.description,
            'horoscope': insight.horoscope,
            'mood': insight.mood,
            'energy_level': insight.energy_level,
            'lottery_recommendation': insight.lottery_recommendation,
            'recommended_numbers': insight.recommended_numbers,
            'avoid_numbers': insight.avoid_numbers,
            'lucky_hours': insight.lucky_hours,
            'best_time_of_day': insight.best_time_of_day,
            'ruling_planet': insight.ruling_planet,
            'planetary_influence': insight.planetary_influence,
            'health_advice': insight.health_advice,
            'financial_advice': insight.financial_advice,
            'spending_forecast': insight.spending_forecast,
            'relationship_advice': insight.relationship_advice,
            'love_forecast': insight.love_forecast,
            'career_advice': insight.career_advice,
            'lucky_color_of_day': insight.lucky_color_of_day,
            'lucky_gemstone': insight.lucky_gemstone,
            'lucky_scent': insight.lucky_scent,
            'daily_challenge': insight.daily_challenge,
            'daily_opportunity': insight.daily_opportunity,
            'daily_affirmation': insight.daily_affirmation,
            'date': insight.date.isoformat(),
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/insights/today")
async def get_today_insight(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get today's AI insight (quick)"""
    try:
        insight = AIInsightService.generate_daily_insight(db, current_user.id)
        
        return {
            'title': insight.title,
            'description': insight.description,
            'mood': insight.mood,
            'energy_level': insight.energy_level,
            'lottery_recommendation': insight.lottery_recommendation,
            'recommended_numbers': insight.recommended_numbers[:5],
            'lucky_hours': insight.lucky_hours,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/insights/wellness")
async def get_wellness_advice(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get wellness and health advice"""
    try:
        insight = AIInsightService.generate_daily_insight(db, current_user.id)
        
        return {
            'health_advice': insight.health_advice,
            'meditation_recommendation': insight.meditation_recommendation,
            'breathing_exercise': insight.breathing_exercise,
            'lucky_gemstone': insight.lucky_gemstone,
            'lucky_scent': insight.lucky_scent,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ============ ANALYTICS DASHBOARD ENDPOINTS ============

@router.get("/dashboard/analytics")
async def get_analytics_dashboard(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get comprehensive analytics dashboard"""
    try:
        dashboard = AnalyticsDashboardService.build_dashboard(db, current_user.id)
        
        return {
            'total_plays_all_time': dashboard.total_plays_all_time,
            'total_played_month': dashboard.total_plays_month,
            'total_played_week': dashboard.total_plays_week,
            'total_winnings': dashboard.total_winnings,
            'total_spent': dashboard.total_spent,
            'net_profit_loss': dashboard.net_profit_loss,
            'overall_roi': dashboard.overall_roi,
            'biggest_win': dashboard.biggest_win,
            'biggest_loss': dashboard.biggest_loss,
            'user_rank_all_time': dashboard.user_rank_all_time,
            'percentile_rank': dashboard.percentile_rank,
            'play_frequency': dashboard.play_frequency,
            'favorite_lottery_type': dashboard.favorite_lottery_type,
            'personal_lucky_number': dashboard.personal_lucky_number,
            'numerology_compatibility': dashboard.numerology_compatibility_score,
            'primary_recommendation': dashboard.primary_recommendation,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/dashboard/summary")
async def get_dashboard_summary(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get dashboard summary (quick view)"""
    try:
        dashboard = AnalyticsDashboardService.build_dashboard(db, current_user.id)
        
        return {
            'total_plays': dashboard.total_plays_all_time,
            'total_winnings': dashboard.total_winnings,
            'roi': dashboard.overall_roi,
            'play_frequency': dashboard.play_frequency,
            'next_lucky_date': dashboard.next_predicted_lucky_date,
            'predicted_monthly_winnings': dashboard.predicted_monthly_winnings,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/dashboard/recommendations")
async def get_recommendations(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    """Get personalized recommendations"""
    try:
        dashboard = AnalyticsDashboardService.build_dashboard(db, current_user.id)
        
        return {
            'primary': dashboard.primary_recommendation,
            'secondary': dashboard.secondary_recommendations or [],
            'numerology_profile': {
                'lucky_number': dashboard.personal_lucky_number,
                'compatibility_score': dashboard.numerology_compatibility_score,
            },
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
