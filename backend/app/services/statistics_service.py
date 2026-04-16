"""
Statistics Dashboard Service Layer
Services for analyzing lottery statistics, trends, patterns, and user engagement.
"""

from datetime import datetime, timedelta
from typing import List, Dict, Optional, Tuple
import math
from collections import Counter, defaultdict
from sqlalchemy.orm import Session
from sqlalchemy import desc, asc

from app.models.statistics_models import (
    HotColdNumber, TrendData, WinningPattern, UserStatistics,
    NumberAnalysis, EngagementMetric, StatisticsDashboardConfig,
    NumberCategory, TrendDirection, PatternType, LotteryType
)
from app.models import User, LotteryDrawing, UserTicket


class NumberAnalysisService:
    """Service for analyzing hot/cold numbers and number frequency"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def calculate_hot_cold_numbers(self, lottery_type: str, period_days: int = 30):
        """
        Calculate hot and cold numbers for a lottery type.
        
        Args:
            lottery_type: Type of lottery (powerball, mega_millions, etc.)
            period_days: Analysis period in days
            
        Returns:
            Dictionary with hot, cold, warm, neutral numbers
        """
        cutoff_date = datetime.utcnow() - timedelta(days=period_days)
        
        # Get all drawings in period
        drawings = self.db.query(LotteryDrawing).filter(
            LotteryDrawing.lottery_type == lottery_type,
            LotteryDrawing.draw_date >= cutoff_date
        ).all()
        
        if not drawings:
            return {"hot": [], "cold": [], "warm": [], "neutral": []}
        
        # Count number appearances
        number_counts = Counter()
        all_numbers = set()
        
        for drawing in drawings:
            winning_numbers = drawing.winning_numbers or []
            for num in winning_numbers:
                number_counts[num] += 1
                all_numbers.add(num)
        
        # Add zero-count numbers (cold numbers)
        total_possible_numbers = self._get_max_number_for_lottery(lottery_type)
        for num in range(1, total_possible_numbers + 1):
            if num not in number_counts:
                all_numbers.add(num)
                number_counts[num] = 0
        
        # Calculate statistics
        appearance_counts = list(number_counts.values())
        mean_count = sum(appearance_counts) / len(appearance_counts)
        std_dev = math.sqrt(sum((x - mean_count) ** 2 for x in appearance_counts) / len(appearance_counts))
        
        # Categorize numbers
        categories = {"hot": [], "cold": [], "warm": [], "neutral": []}
        
        for number in all_numbers:
            count = number_counts[number]
            deviation = (count - mean_count) / std_dev if std_dev > 0 else 0
            
            # Calculate frequency score (0-100)
            if std_dev > 0:
                frequency_score = ((count - min(appearance_counts)) / (max(appearance_counts) - min(appearance_counts)) * 100) if max(appearance_counts) > min(appearance_counts) else 50
            else:
                frequency_score = 50
            
            # Last appearance tracking
            last_draw = None
            days_since = None
            for drawing in reversed(drawings):
                if number in (drawing.winning_numbers or []):
                    last_draw = drawing.draw_number
                    days_since = (datetime.utcnow() - drawing.draw_date).days
                    break
            
            # Categorize
            if deviation > 1.0:
                category = NumberCategory.HOT
            elif deviation < -1.0:
                category = NumberCategory.COLD
            elif -0.5 <= deviation <= 0.5:
                category = NumberCategory.NEUTRAL
            else:
                category = NumberCategory.WARM
            
            # Create or update record
            existing = self.db.query(HotColdNumber).filter(
                HotColdNumber.number == number,
                HotColdNumber.lottery_type == lottery_type
            ).first()
            
            if existing:
                existing.category = category
                existing.appearance_count = count
                existing.frequency_score = frequency_score
                existing.last_appeared_draw_number = last_draw
                existing.days_since_last_appearance = days_since
                existing.deviation_from_expected = ((count - mean_count) / mean_count * 100) if mean_count > 0 else 0
                existing.period_analyzed = f"{period_days}_days"
                existing.last_updated = datetime.utcnow()
            else:
                record = HotColdNumber(
                    number=number,
                    lottery_type=lottery_type,
                    category=category,
                    appearance_count=count,
                    frequency_score=frequency_score,
                    volatility_score=std_dev,
                    expected_frequency=mean_count,
                    last_appeared_draw_number=last_draw,
                    days_since_last_appearance=days_since,
                    deviation_from_expected=((count - mean_count) / mean_count * 100) if mean_count > 0 else 0,
                    period_analyzed=f"{period_days}_days"
                )
                self.db.add(record)
            
            categories[category.value].append(number)
        
        self.db.commit()
        return categories
    
    def get_hot_numbers(self, lottery_type: str, limit: int = 10) -> List[Dict]:
        """Get hottest numbers"""
        hot_numbers = self.db.query(HotColdNumber).filter(
            HotColdNumber.lottery_type == lottery_type,
            HotColdNumber.category == NumberCategory.HOT
        ).order_by(desc(HotColdNumber.frequency_score)).limit(limit).all()
        
        return [self._format_number_data(num) for num in hot_numbers]
    
    def get_cold_numbers(self, lottery_type: str, limit: int = 10) -> List[Dict]:
        """Get coldest numbers"""
        cold_numbers = self.db.query(HotColdNumber).filter(
            HotColdNumber.lottery_type == lottery_type,
            HotColdNumber.category == NumberCategory.COLD
        ).order_by(asc(HotColdNumber.frequency_score)).limit(limit).all()
        
        return [self._format_number_data(num) for num in cold_numbers]
    
    def analyze_individual_number(self, lottery_type: str, number: int) -> Dict:
        """Perform deep statistical analysis on individual number"""
        cutoff_date = datetime.utcnow() - timedelta(days=365)
        
        drawings = self.db.query(LotteryDrawing).filter(
            LotteryDrawing.lottery_type == lottery_type,
            LotteryDrawing.draw_date >= cutoff_date
        ).order_by(LotteryDrawing.draw_date).all()
        
        # Find occurrences
        occurrences = []
        for drawing in drawings:
            if number in (drawing.winning_numbers or []):
                occurrences.append(drawing)
        
        # Calculate gaps
        gaps = []
        for i in range(1, len(occurrences)):
            gap = (occurrences[i].draw_date - occurrences[i-1].draw_date).days
            gaps.append(gap)
        
        mean_gap = sum(gaps) / len(gaps) if gaps else 0
        median_gap = sorted(gaps)[len(gaps)//2] if gaps else 0
        max_gap = max(gaps) if gaps else 0
        
        # Calculate chi-squared
        expected = len(drawings) / self._get_max_number_for_lottery(lottery_type)
        chi_squared = ((len(occurrences) - expected) ** 2) / expected if expected > 0 else 0
        
        # Heat and cold scores
        heat_score = min(100, (len(occurrences) / expected * 50)) if expected > 0 else 50
        cold_score = 100 - heat_score
        
        # Create or update analysis
        analysis = self.db.query(NumberAnalysis).filter(
            NumberAnalysis.number == number,
            NumberAnalysis.lottery_type == lottery_type
        ).first()
        
        if analysis:
            analysis.update({
                'total_appearances': len(occurrences),
                'expected_appearances': int(expected),
                'chi_squared_statistic': chi_squared,
                'mean_gap': mean_gap,
                'median_gap': median_gap,
                'max_gap': max_gap,
                'heat_score': heat_score,
                'cold_score': cold_score,
                'recent_appearances_30d': len([o for o in occurrences if (datetime.utcnow() - o.draw_date).days <= 30]),
                'recent_appearances_90d': len([o for o in occurrences if (datetime.utcnow() - o.draw_date).days <= 90]),
                'recent_appearances_1y': len(occurrences),
                'analysis_date': datetime.utcnow(),
                'data_points_used': len(drawings),
            })
        else:
            analysis = NumberAnalysis(
                number=number,
                lottery_type=lottery_type,
                total_appearances=len(occurrences),
                expected_appearances=int(expected),
                chi_squared_statistic=chi_squared,
                mean_gap=mean_gap,
                median_gap=median_gap,
                max_gap=max_gap,
                heat_score=heat_score,
                cold_score=cold_score,
                recent_appearances_30d=len([o for o in occurrences if (datetime.utcnow() - o.draw_date).days <= 30]),
                recent_appearances_90d=len([o for o in occurrences if (datetime.utcnow() - o.draw_date).days <= 90]),
                recent_appearances_1y=len(occurrences),
                data_points_used=len(drawings)
            )
            self.db.add(analysis)
        
        self.db.commit()
        return self._format_analysis(analysis)
    
    def _format_number_data(self, num_record: HotColdNumber) -> Dict:
        """Format number data for API response"""
        return {
            "number": num_record.number,
            "category": num_record.category.value,
            "frequency_score": round(num_record.frequency_score, 2),
            "appearance_count": num_record.appearance_count,
            "days_since_last": num_record.days_since_last_appearance,
            "trend": num_record.trend_prediction,
        }
    
    def _format_analysis(self, analysis: NumberAnalysis) -> Dict:
        """Format analysis for API response"""
        return {
            "number": analysis.number,
            "total_appearances": analysis.total_appearances,
            "heat_score": round(analysis.heat_score, 2),
            "cold_score": round(analysis.cold_score, 2),
            "mean_gap_days": round(analysis.mean_gap, 1),
            "max_gap_days": analysis.max_gap,
            "recent_30d": analysis.recent_appearances_30d,
            "recommended": analysis.heat_score > 60,
        }
    
    def _get_max_number_for_lottery(self, lottery_type: str) -> int:
        """Get max number range for lottery type"""
        ranges = {
            "powerball": 69,
            "mega_millions": 70,
            "daily_4": 9,
            "pick_3": 9,
        }
        return ranges.get(lottery_type, 69)


class TrendAnalysisService:
    """Service for trend analysis and prediction"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def analyze_trends(self, lottery_type: str, number: Optional[int] = None, period_days: int = 90):
        """
        Analyze trends for lottery or specific number.
        
        Args:
            lottery_type: Type of lottery
            number: Optional specific number, None for overall lottery
            period_days: Analysis period
            
        Returns:
            Trend analysis data
        """
        cutoff_date = datetime.utcnow() - timedelta(days=period_days)
        cutoff_date_prev = cutoff_date - timedelta(days=period_days)
        
        # Get drawings in periods
        current_period = self.db.query(LotteryDrawing).filter(
            LotteryDrawing.lottery_type == lottery_type,
            LotteryDrawing.draw_date >= cutoff_date
        ).all()
        
        previous_period = self.db.query(LotteryDrawing).filter(
            LotteryDrawing.lottery_type == lottery_type,
            LotteryDrawing.draw_date >= cutoff_date_prev,
            LotteryDrawing.draw_date < cutoff_date
        ).all()
        
        if number:
            current_count = sum(1 for d in current_period if number in (d.winning_numbers or []))
            previous_count = sum(1 for d in previous_period if number in (d.winning_numbers or []))
        else:
            current_count = len(current_period)
            previous_count = len(previous_period)
        
        # Calculate trend
        if previous_count == 0:
            change_pct = 100 if current_count > 0 else 0
        else:
            change_pct = ((current_count - previous_count) / previous_count * 100)
        
        # Determine direction
        if change_pct > 10:
            direction = TrendDirection.INCREASING
            strength = min(1.0, change_pct / 100)
        elif change_pct < -10:
            direction = TrendDirection.DECREASING
            strength = min(1.0, abs(change_pct) / 100)
        else:
            direction = TrendDirection.STABLE
            strength = 0.5
        
        # Create trend record
        trend = TrendData(
            lottery_type=lottery_type,
            number=number,
            trend_date=datetime.utcnow(),
            trend_direction=direction,
            trend_strength=strength,
            trend_confidence=0.85,  # Simplified
            period_start=cutoff_date_prev,
            period_end=datetime.utcnow(),
            data_points_count=len(current_period) + len(previous_period),
            average_value=float(current_count),
            previous_average=float(previous_count),
            change_percentage=change_pct,
        )
        
        self.db.add(trend)
        self.db.commit()
        
        return self._format_trend(trend)
    
    def get_trending_numbers(self, lottery_type: str, limit: int = 10) -> List[Dict]:
        """Get numbers with strongest upward trends"""
        trends = self.db.query(TrendData).filter(
            TrendData.lottery_type == lottery_type,
            TrendData.number.isnot(None),
            TrendData.trend_direction == TrendDirection.INCREASING
        ).order_by(desc(TrendData.trend_strength)).limit(limit).all()
        
        return [self._format_trend(t) for t in trends]
    
    def get_trending_down_numbers(self, lottery_type: str, limit: int = 10) -> List[Dict]:
        """Get numbers with strongest downward trends"""
        trends = self.db.query(TrendData).filter(
            TrendData.lottery_type == lottery_type,
            TrendData.number.isnot(None),
            TrendData.trend_direction == TrendDirection.DECREASING
        ).order_by(desc(TrendData.trend_strength)).limit(limit).all()
        
        return [self._format_trend(t) for t in trends]
    
    def _format_trend(self, trend: TrendData) -> Dict:
        """Format trend data for API response"""
        return {
            "number": trend.number,
            "direction": trend.trend_direction.value,
            "strength": round(trend.trend_strength, 2),
            "change_percentage": round(trend.change_percentage, 1),
            "confidence": round(trend.trend_confidence, 2),
            "predicted_next_value": trend.predicted_next_value,
        }


class PatternRecognitionService:
    """Service for identifying winning patterns"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def find_consecutive_patterns(self, lottery_type: str, period_days: int = 365) -> List[WinningPattern]:
        """Find consecutive number patterns in winning sets"""
        cutoff_date = datetime.utcnow() - timedelta(days=period_days)
        
        drawings = self.db.query(LotteryDrawing).filter(
            LotteryDrawing.lottery_type == lottery_type,
            LotteryDrawing.draw_date >= cutoff_date
        ).all()
        
        consecutive_count = 0
        
        for drawing in drawings:
            numbers = sorted(drawing.winning_numbers or [])
            for i in range(len(numbers) - 1):
                if numbers[i+1] - numbers[i] == 1:
                    consecutive_count += 1
        
        frequency = (consecutive_count / len(drawings) * 100) if drawings else 0
        
        pattern = WinningPattern(
            lottery_type=lottery_type,
            pattern_type=PatternType.CONSECUTIVE,
            pattern_name="Consecutive Numbers Pattern",
            pattern_description="Two or more consecutive numbers in winning set",
            occurrences_found=consecutive_count,
            total_drawings_analyzed=len(drawings),
            pattern_frequency_percentage=frequency,
            hit_rate=0.65,  # Estimated
            analysis_period_days=period_days,
            confidence_score=0.78,
        )
        
        return [pattern]
    
    def find_odd_even_patterns(self, lottery_type: str, period_days: int = 365) -> List[WinningPattern]:
        """Find odd/even ratio patterns"""
        cutoff_date = datetime.utcnow() - timedelta(days=period_days)
        
        drawings = self.db.query(LotteryDrawing).filter(
            LotteryDrawing.lottery_type == lottery_type,
            LotteryDrawing.draw_date >= cutoff_date
        ).all()
        
        ratio_3_2_count = 0  # 3 odd, 2 even or 3 even, 2 odd
        
        for drawing in drawings:
            numbers = drawing.winning_numbers or []
            odd_count = sum(1 for n in numbers if n % 2 == 1)
            even_count = len(numbers) - odd_count
            
            if (odd_count == 3 and even_count == 2) or (odd_count == 2 and even_count == 3):
                ratio_3_2_count += 1
        
        frequency = (ratio_3_2_count / len(drawings) * 100) if drawings else 0
        
        pattern = WinningPattern(
            lottery_type=lottery_type,
            pattern_type=PatternType.ODD_EVEN_RATIO,
            pattern_name="3:2 Odd:Even Ratio",
            pattern_description="Winning sets with 3 odd and 2 even numbers (or reverse)",
            occurrences_found=ratio_3_2_count,
            total_drawings_analyzed=len(drawings),
            pattern_frequency_percentage=frequency,
            hit_rate=0.58,
            analysis_period_days=period_days,
            confidence_score=0.82,
        )
        
        return [pattern]
    
    def find_sum_patterns(self, lottery_type: str, period_days: int = 365) -> List[WinningPattern]:
        """Find sum-based patterns"""
        cutoff_date = datetime.utcnow() - timedelta(days=period_days)
        
        drawings = self.db.query(LotteryDrawing).filter(
            LotteryDrawing.lottery_type == lottery_type,
            LotteryDrawing.draw_date >= cutoff_date
        ).all()
        
        sum_ranges = defaultdict(int)
        
        for drawing in drawings:
            numbers = drawing.winning_numbers or []
            total_sum = sum(numbers)
            
            if 100 <= total_sum <= 150:
                sum_ranges["100_150"] += 1
            elif 150 < total_sum <= 200:
                sum_ranges["150_200"] += 1
        
        highest_range = max(sum_ranges, key=sum_ranges.get) if sum_ranges else "100_150"
        frequency = (sum_ranges[highest_range] / len(drawings) * 100) if drawings else 0
        
        pattern = WinningPattern(
            lottery_type=lottery_type,
            pattern_type=PatternType.SUM_PATTERN,
            pattern_name=f"Sum Range {highest_range} Pattern",
            pattern_description=f"Winning sets with sum in {highest_range} range",
            occurrences_found=sum_ranges[highest_range],
            total_drawings_analyzed=len(drawings),
            pattern_frequency_percentage=frequency,
            hit_rate=0.62,
            analysis_period_days=period_days,
            confidence_score=0.80,
        )
        
        return [pattern]
    
    def get_top_patterns(self, lottery_type: str, limit: int = 10) -> List[Dict]:
        """Get highest frequency patterns"""
        patterns = self.db.query(WinningPattern).filter(
            WinningPattern.lottery_type == lottery_type,
            WinningPattern.is_active == True
        ).order_by(desc(WinningPattern.pattern_frequency_percentage)).limit(limit).all()
        
        return [self._format_pattern(p) for p in patterns]
    
    def _format_pattern(self, pattern: WinningPattern) -> Dict:
        """Format pattern data for API response"""
        return {
            "id": str(pattern.id),
            "name": pattern.pattern_name,
            "type": pattern.pattern_type.value,
            "frequency": round(pattern.pattern_frequency_percentage, 2),
            "hit_rate": round(pattern.hit_rate, 2) if pattern.hit_rate else None,
            "confidence": round(pattern.confidence_score, 2),
            "occurrences": pattern.occurrences_found,
        }


class DashboardDataService:
    """Service for aggregating dashboard data"""
    
    def __init__(self, db: Session):
        self.db = db
        self.number_service = NumberAnalysisService(db)
        self.trend_service = TrendAnalysisService(db)
        self.pattern_service = PatternRecognitionService(db)
    
    def get_dashboard_summary(self, lottery_type: str, user_id: str) -> Dict:
        """Get complete dashboard summary"""
        # Calculate hot/cold numbers
        self.number_service.calculate_hot_cold_numbers(lottery_type, period_days=30)
        
        # Get top data
        hot_numbers = self.number_service.get_hot_numbers(lottery_type, limit=5)
        cold_numbers = self.number_service.get_cold_numbers(lottery_type, limit=5)
        trends = self.trend_service.get_trending_numbers(lottery_type, limit=5)
        patterns = self.pattern_service.get_top_patterns(lottery_type, limit=5)
        
        # Get user statistics
        user_stats = self.db.query(UserStatistics).filter(
            UserStatistics.user_id == user_id,
            UserStatistics.lottery_type == lottery_type
        ).first()
        
        return {
            "hot_numbers": hot_numbers,
            "cold_numbers": cold_numbers,
            "trending": trends,
            "patterns": patterns,
            "user_stats": self._format_user_stats(user_stats) if user_stats else None,
            "generated_at": datetime.utcnow().isoformat(),
        }
    
    def _format_user_stats(self, stats: UserStatistics) -> Dict:
        """Format user statistics for display"""
        return {
            "total_tickets": stats.total_tickets_purchased,
            "total_winnings": round(stats.total_winnings, 2),
            "roi": round(stats.roi_percentage, 2),
            "win_rate": round(stats.win_rate, 2),
            "play_frequency": stats.play_frequency,
        }


class EngagementTracker:
    """Service for tracking user engagement with dashboard"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def log_engagement(self, user_id: str, engagement_type: str, screen: str,
                      time_spent: int = None, lottery_type: str = None) -> EngagementMetric:
        """Log user engagement event"""
        metric = EngagementMetric(
            user_id=user_id,
            engagement_type=engagement_type,
            screen_viewed=screen,
            time_spent_seconds=time_spent,
            lottery_type_viewed=lottery_type,
        )
        self.db.add(metric)
        self.db.commit()
        return metric
    
    def get_engagement_rate(self, lottery_type: str, days: int = 30) -> Dict:
        """Calculate engagement statistics"""
        cutoff_date = datetime.utcnow() - timedelta(days=days)
        
        metrics = self.db.query(EngagementMetric).filter(
            EngagementMetric.lottery_type_viewed == lottery_type,
            EngagementMetric.created_at >= cutoff_date
        ).all()
        
        total_views = len(metrics)
        total_time = sum(m.time_spent_seconds or 0 for m in metrics)
        avg_time = total_time / total_views if total_views > 0 else 0
        
        users = set(m.user_id for m in metrics)
        
        # Check purchase correlation
        purchases = sum(1 for m in metrics if m.purchased_ticket_after)
        purchase_rate = (purchases / total_views * 100) if total_views > 0 else 0
        
        return {
            "total_views": total_views,
            "unique_users": len(users),
            "avg_time_spent": round(avg_time, 1),
            "purchase_rate": round(purchase_rate, 2),
        }
