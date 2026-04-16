"""
AstroLuck Intelligence & Analytics Services
Numerology, Win Probability, Statistics, and AI Insights
"""

import math
from datetime import datetime, timedelta
from typing import List, Dict
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
import random
import json

from app.models.intelligence_models import (
    NumerologyProfile, WinProbabilityModel, LotteryStatistics,
    DailyAIInsight, AnalyticalDashboard
)
from app.models.models import User, LotteryHistory


class NumerologyService:
    """Generate and manage numerology readings"""
    
    @staticmethod
    def calculate_life_path_number(birth_date: str) -> int:
        """
        Calculate Life Path Number from birth date (YYYY-MM-DD)
        Reduces birth digits to single digit (except 11, 22, 33)
        """
        date_parts = birth_date.split('-')
        month = int(date_parts[1])
        day = int(date_parts[2])
        year = int(date_parts[0])
        
        # Sum all digits
        total = month + day + year
        
        # Reduce to single digit (keep master numbers)
        while total >= 10:
            if total in [11, 22, 33]:
                return total
            total = sum(int(digit) for digit in str(total))
        
        return total
    
    @staticmethod
    def calculate_destiny_number(full_name: str) -> int:
        """Calculate Destiny Number from full name"""
        # Convert letters to numbers (A=1, B=2, etc.)
        letter_values = {}
        for i, letter in enumerate('abcdefghijklmnopqrstuvwxyz'):
            letter_values[letter] = (i % 9) + 1
        
        total = 0
        for char in full_name.lower():
            if char.isalpha():
                total += letter_values[char]
        
        # Reduce to single digit
        while total >= 10:
            if total in [11, 22, 33]:
                return total
            total = sum(int(digit) for digit in str(total))
        
        return total
    
    @staticmethod
    def get_numerology_profile(db: Session, user_id: int) -> NumerologyProfile:
        """Get or create user's numerology profile"""
        user = db.query(User).filter(User.id == user_id).first()
        profile = db.query(NumerologyProfile).filter(
            NumerologyProfile.user_id == user_id
        ).first()
        
        if not profile:
            # Calculate numerology numbers
            life_path = NumerologyService.calculate_life_path_number(
                user.birth_date.strftime('%Y-%m-%d') if user.birth_date else '1990-01-01'
            )
            destiny = NumerologyService.calculate_destiny_number(user.full_name)
            
            profile = NumerologyProfile(
                user_id=user_id,
                life_path_number=life_path,
                destiny_number=destiny,
                soul_urge_number=random.randint(1, 9),
                personality_number=random.randint(1, 9),
                expression_number=random.randint(1, 9),
                birth_day_number=user.birth_date.day if user.birth_date else random.randint(1, 31),
                lucky_numbers=[life_path, destiny, (life_path + destiny) % 9 or 9],
                lucky_colors=['Gold', 'Purple', 'Silver'],
                lucky_days=['Monday', 'Wednesday', 'Friday'],
                lucky_hours=[8, 11, 14, 17, 20],
            )
            
            # Generate readings
            profile.life_path_reading = NumerologyService._generate_life_path_reading(life_path)
            profile.destiny_reading = NumerologyService._generate_destiny_reading(destiny)
            profile.soul_urge_reading = NumerologyService._generate_soul_urge_reading(
                profile.soul_urge_number
            )
            
            db.add(profile)
            db.commit()
            db.refresh(profile)
        
        return profile
    
    @staticmethod
    def _generate_life_path_reading(number: int) -> str:
        """Generate life path interpretation"""
        readings = {
            1: "You are a natural leader and pioneer. Your life path is about independence, creation, and bold action. You're meant to initiate new projects and inspire others.",
            2: "You are a peacemaker and mediator. Your path involves balance, partnerships, and diplomacy. You excel in collaboration and bringing harmony to conflict.",
            3: "You are a creative communicator. Your life path is about self-expression, joy, and inspiration. You're meant to bring happiness and creativity to the world.",
            4: "You are a builder and organizer. Your path involves creating stability, systems, and lasting foundations. You have strong work ethic and reliability.",
            5: "You are an adventurer and freedom-seeker. Your life path is about exploration, change, and adaptability. You're meant to experience life's variety.",
            6: "You are a nurturer and healer. Your path involves care, responsibility, and service. You're naturally inclined to help and support others.",
            7: "You are a seeker and mystic. Your life path is about spiritual wisdom, introspection, and truth. You're drawn to deeper understanding.",
            8: "You are a manifestor and power player. Your path involves abundance, success, and material accomplishment. You have natural authority.",
            9: "You are a humanitarian and visionary. Your life path is about completion, wisdom, and service to humanity. You see the bigger picture.",
            11: "You are an intuitive messenger (Master Number). Your path involves spiritual inspiration and enlightenment. You're meant to uplift others.",
            22: "You are a master builder (Master Number). Your path involves creating something of lasting value for humanity. You think big.",
            33: "You are a master teacher (Master Number). Your path involves compassion and teaching others wisdom. You're highly intuitive.",
        }
        return readings.get(number, "Your numerology reading is unique to your number.")
    
    @staticmethod
    def _generate_destiny_reading(number: int) -> str:
        """Generate destiny interpretation"""
        readings = {
            1: "Your destiny is to lead and innovate. You'll find success through courage and originality.",
            2: "Your destiny is peaceful collaboration. You'll create harmony and understanding.",
            3: "Your destiny is creative expression. You'll inspire others through your talents.",
            4: "Your destiny is building lasting foundations. You'll create security and stability.",
            5: "Your destiny is freedom and exploration. You'll embrace change and growth.",
            6: "Your destiny is healing and service. You'll make a difference through caring.",
            7: "Your destiny is wisdom and understanding. You'll seek truth and spiritual growth.",
            8: "Your destiny is material success. You'll build abundance and influence.",
            9: "Your destiny is humanitarian service. You'll make a global impact.",
        }
        return readings.get(number, "Your destiny awaits your unique talents.")
    
    @staticmethod
    def _generate_soul_urge_reading(number: int) -> str:
        """Generate soul urge interpretation"""
        return f"Your soul urges you toward growth and mastery in this incarnation. Number {number} drives you toward transformation and wisdom."


class WinProbabilityService:
    """Calculate win probabilities using multiple factors"""
    
    @staticmethod
    def calculate_probability(
        db: Session,
        user_id: int,
        lottery_type: str
    ) -> WinProbabilityModel:
        """
        Calculate comprehensive win probability
        Factors: Numerology, Astrology, Historical Performance, Lucky Days/Hours
        """
        user = db.query(User).filter(User.id == user_id).first()
        numerology = NumerologyService.get_numerology_profile(db, user_id)
        
        # Base mathematical probability (depends on lottery type)
        base_probs = {
            'powerball': 1/292_201_338 * 100,
            'megamillions': 1/302_575_350 * 100,
            'lucky_seven': 0.1,  # Higher odds
            'daily_pick': 0.01,
        }
        base_prob = base_probs.get(lottery_type, 0.001)
        
        # Numerology boost
        user_lucky_numbers = numerology.lucky_numbers or []
        numerology_boost = len(user_lucky_numbers) * 10  # +10% per lucky number
        
        # Historical performance
        user_stats = db.query(LotteryStatistics).filter(
            LotteryStatistics.user_id == user_id
        ).first()
        historical_boost = 0
        if user_stats:
            historical_boost = user_stats.win_rate if user_stats.win_rate else 0
        
        # Lucky day/hour bonus
        now = datetime.now()
        lucky_day_bonus = 5 if now.strftime('%A') in (numerology.lucky_days or []) else 0
        lucky_hour_bonus = 5 if now.hour in (numerology.lucky_hours or []) else 0
        
        # Astrological influence (based on current date)
        astrological_influence = WinProbabilityService._calculate_astrological_influence(user.birth_date)
        
        # Calculate final probability
        final_prob = base_prob + numerology_boost + historical_boost + lucky_day_bonus + lucky_hour_bonus + astrological_influence
        final_prob = min(final_prob, 99.9)  # Cap at 99.9%
        
        # Generate recommendations
        recommended_numbers = WinProbabilityService._generate_recommendations(
            user_lucky_numbers, user_stats
        )
        
        # Create probability model
        model = WinProbabilityModel(
            user_id=user_id,
            lottery_type=lottery_type,
            base_probability=base_prob,
            numerology_boost=numerology_boost,
            astrological_influence=astrological_influence,
            historical_performance=historical_boost,
            lucky_day_bonus=lucky_day_bonus,
            lucky_hour_bonus=lucky_hour_bonus,
            predicted_win_probability=final_prob,
            confidence_score=0.65,  # Model confidence
            recommended_numbers=recommended_numbers,
            avoid_numbers=WinProbabilityService._get_avoid_numbers(user_stats),
            best_time_to_play='morning' if lucky_hour_bonus > 0 else 'afternoon',
            best_days_to_play=numerology.lucky_days or ['Monday', 'Wednesday'],
            hot_numbers_influence=WinProbabilityService._calculate_hot_influence(user_stats),
            cold_numbers_influence=WinProbabilityService._calculate_cold_influence(user_stats),
            numerology_match=min(numerology_boost, 100),
        )
        
        db.add(model)
        db.commit()
        db.refresh(model)
        
        return model
    
    @staticmethod
    def _calculate_astrological_influence(birth_date):
        """Calculate astrological influence based on current planetary positions"""
        # Simplified: sun's position in zodiac
        today = datetime.now()
        day_of_year = today.timetuple().tm_yday
        
        # Ranges are approximate zodiac dates
        zodiac_dates = {
            'aries': (79, 109),
            'taurus': (109, 140),
            'gemini': (140, 172),
            'cancer': (172, 204),
            'leo': (204, 235),
            'virgo': (235, 266),
            'libra': (266, 298),
            'scorpio': (298, 329),
            'sagittarius': (329, 359),
            'capricorn': (359, 390),
            'aquarius': (390, 420),
            'pisces': (420, 450),
        }
        
        # Determine current zodiac
        for sign, (start, end) in zodiac_dates.items():
            if start <= day_of_year <= end:
                return random.uniform(2, 8)  # +2-8% astrological influence
        
        return random.uniform(1, 5)
    
    @staticmethod
    def _generate_recommendations(lucky_numbers, user_stats) -> List[int]:
        """Generate recommended numbers based on lucky numbers and patterns"""
        recommendations = lucky_numbers[:5] if lucky_numbers else []
        
        if user_stats and user_stats.hot_numbers:
            recommendations.extend(user_stats.hot_numbers[:2])
        
        # Add random numbers to reach 7
        while len(recommendations) < 7:
            num = random.randint(1, 55)
            if num not in recommendations:
                recommendations.append(num)
        
        return recommendations[:7]
    
    @staticmethod
    def _get_avoid_numbers(user_stats) -> List[int]:
        """Numbers to avoid based on historical performance"""
        if user_stats and user_stats.cold_numbers:
            return user_stats.cold_numbers[:5]
        return []
    
    @staticmethod
    def _calculate_hot_influence(user_stats) -> float:
        """Calculate influence of hot numbers"""
        if user_stats and user_stats.hot_numbers:
            return min(len(user_stats.hot_numbers) * 5, 50)
        return 0.0
    
    @staticmethod
    def _calculate_cold_influence(user_stats) -> float:
        """Calculate influence of cold numbers"""
        if user_stats and user_stats.cold_numbers:
            return min(len(user_stats.cold_numbers) * 3, 30)
        return 0.0


class StatisticalAnalysisService:
    """Analyze lottery patterns and statistics"""
    
    @staticmethod
    def analyze_user_statistics(
        db: Session,
        user_id: int,
        lottery_type: str
    ) -> LotteryStatistics:
        """Analyze user's lottery statistics and patterns"""
        
        # Get or create statistics record
        stats = db.query(LotteryStatistics).filter(
            and_(
                LotteryStatistics.user_id == user_id,
                LotteryStatistics.lottery_type == lottery_type
            )
        ).first()
        
        if not stats:
            stats = LotteryStatistics(
                user_id=user_id,
                lottery_type=lottery_type
            )
        
        # Get all plays for this user
        plays = db.query(LotteryHistory).filter(
            LotteryHistory.user_id == user_id
        ).order_by(LotteryHistory.created_at.desc()).all()
        
        if plays:
            # Extract numbers from all plays
            all_numbers = []
            for play in plays:
                numbers = [int(n) for n in play.numbers.split()]
                all_numbers.extend(numbers)
            
            # Calculate frequency
            from collections import Counter
            frequency = Counter(all_numbers)
            
            # Hot numbers (appeared 3+ times)
            hot = [num for num, count in frequency.items() if count >= 3]
            cold = [num for num, count in frequency.items() if count <= 1]
            
            stats.hot_numbers = hot[:10]
            stats.cold_numbers = cold[:10]
            stats.hot_count = {str(num): frequency[num] for num in hot[:10]}
            stats.cold_count = {str(num): frequency[num] for num in cold[:10]}
            
            # Calculate ratios
            even_numbers = sum(1 for n in all_numbers if n % 2 == 0)
            odd_numbers = sum(1 for n in all_numbers if n % 2 != 0)
            stats.even_odd_ratio = even_numbers / len(all_numbers) if all_numbers else 0.5
            
            # Prime numbers
            primes = [n for n in range(2, 60) if all(n % i != 0 for i in range(2, int(n**0.5) + 1))]
            prime_count = sum(1 for n in all_numbers if n in primes)
            stats.prime_number_ratio = prime_count / len(all_numbers) if all_numbers else 0
            
            # Personal stats
            stats.total_plays = len(plays)
            stats.most_active_day = StatisticalAnalysisService._get_most_active_day(plays)
            stats.most_active_hour = StatisticalAnalysisService._get_most_active_hour(plays)
            stats.last_play_date = plays[0].created_at
            stats.days_since_last_play = (datetime.now() - plays[0].created_at).days
            
            # Winning streaks
            stats.current_losing_streak = StatisticalAnalysisService._calculate_streak(plays)
        
        db.add(stats)
        db.commit()
        db.refresh(stats)
        
        return stats
    
    @staticmethod
    def _get_most_active_day(plays) -> str:
        """Find the day of week with most plays"""
        from collections import Counter
        days = [p.created_at.strftime('%A') for p in plays]
        if days:
            return Counter(days).most_common(1)[0][0]
        return 'Unknown'
    
    @staticmethod
    def _get_most_active_hour(plays) -> int:
        """Find the hour with most plays"""
        from collections import Counter
        hours = [p.created_at.hour for p in plays]
        if hours:
            return Counter(hours).most_common(1)[0][0]
        return 12
    
    @staticmethod
    def _calculate_streak(plays) -> int:
        """Calculate current losing streak"""
        streak = 0
        for play in plays:
            if not play.won:
                streak += 1
            else:
                break
        return streak


class AIInsightService:
    """Generate personalized AI insights with recommendations"""
    
    @staticmethod
    def generate_daily_insight(db: Session, user_id: int) -> DailyAIInsight:
        """Generate complete daily insight with lottery recommendations"""
        
        user = db.query(User).filter(User.id == user_id).first()
        numerology = NumerologyService.get_numerology_profile(db, user_id)
        
        # Check if insight already exists for today
        today = datetime.now().date()
        existing = db.query(DailyAIInsight).filter(
            and_(
                DailyAIInsight.user_id == user_id,
                func.date(DailyAIInsight.date) == today
            )
        ).first()
        
        if existing:
            return existing
        
        # Generate new insight
        insight = DailyAIInsight(
            user_id=user_id,
            title=AIInsightService._generate_title(),
            description=AIInsightService._generate_horoscope(user.birth_date),
            horoscope=AIInsightService._generate_horoscope(user.birth_date),
            mood=random.choice(['Happy', 'Neutral', 'Cautious', 'Energetic', 'Reflective']),
            energy_level=random.randint(5, 10),
            lottery_recommendation=AIInsightService._get_lottery_recommendation(),
            recommended_numbers=numerology.lucky_numbers[:7],
            avoid_numbers=random.sample(range(1, 56), 3),
            lucky_hours=numerology.lucky_hours,
            best_time_of_day=random.choice(['morning', 'afternoon', 'evening']),
            ruling_planet=AIInsightService._get_ruling_planet(),
            planetary_influence=AIInsightService._generate_planetary_influence(),
            health_advice="Stay hydrated and get adequate rest for optimal well-being.",
            meditation_recommendation="Try 10 minutes of mindfulness meditation.",
            breathing_exercise="Practice 4-7-8 breathing: inhale for 4, hold for 7, exhale for 8.",
            financial_advice="A balanced approach to spending will serve you well today.",
            spending_forecast=random.choice(['cautious', 'moderate', 'favorable']),
            relationship_advice="Listen more than you speak today.",
            love_forecast=random.choice(['positive', 'neutral', 'challenging']),
            career_advice="Focus on one task to maximize productivity.",
            work_focus="Deep work and concentration are favored.",
            lucky_color_of_day=random.choice(['Gold', 'Purple', 'Blue', 'Green', 'Red']),
            lucky_gemstone=random.choice(['Amethyst', 'Rose Quartz', 'Citrine', 'Jade']),
            lucky_scent=random.choice(['Lavender', 'Sandalwood', 'Rose', 'Vanilla']),
            daily_challenge="Face one fear today with courage.",
            daily_opportunity="Be open to unexpected opportunities.",
            daily_affirmation="I am worthy of abundance and success today.",
        )
        
        db.add(insight)
        db.commit()
        db.refresh(insight)
        
        return insight
    
    @staticmethod
    def _generate_title() -> str:
        """Generate daily insight title"""
        titles = [
            "Today's Cosmic Alignment",
            "Your Daily Astral Reading",
            "Today's Luck Index",
            "Planetary Influences for Today",
            "Your Personal Horoscope",
            "Today's Fortune Guide",
            "Celestial Messages for You",
        ]
        return random.choice(titles)
    
    @staticmethod
    def _generate_horoscope(birth_date) -> str:
        """Generate personalized horoscope"""
        horoscopes = [
            "The stars align in your favor today. Seize the opportunities that come your way.",
            "A new beginning is approaching. Trust your instincts and move forward.",
            "Your intuition is heightened today. Listen to that inner voice.",
            "Changes are on the horizon. Embrace transformation with an open heart.",
            "Today brings clarity and insight. Your path becomes clearer.",
        ]
        return random.choice(horoscopes)
    
    @staticmethod
    def _get_lottery_recommendation() -> str:
        """Get today's lottery recommendation"""
        return random.choice(['play', 'wait', 'be_cautious'])
    
    @staticmethod
    def _get_ruling_planet() -> str:
        """Get today's ruling planet"""
        planets = ['Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Sun', 'Moon']
        return random.choice(planets)
    
    @staticmethod
    def _generate_planetary_influence() -> str:
        """Generate planetary influence description"""
        influences = [
            "Mars brings energy and motivation to your endeavors.",
            "Venus blesses you with charm and harmony.",
            "Mercury enhances your communication and thinking.",
            "Jupiter brings expansion and good fortune.",
            "Saturn teaches valuable lessons through discipline.",
        ]
        return random.choice(influences)


class AnalyticsDashboardService:
    """Build comprehensive analytics dashboard for users"""
    
    @staticmethod
    def build_dashboard(db: Session, user_id: int) -> AnalyticalDashboard:
        """Build complete analytics dashboard"""
        
        dashboard = db.query(AnalyticalDashboard).filter(
            AnalyticalDashboard.user_id == user_id
        ).first()
        
        if not dashboard:
            dashboard = AnalyticalDashboard(user_id=user_id)
        
        # Get user's lottery history
        plays = db.query(LotteryHistory).filter(
            LotteryHistory.user_id == user_id
        ).all()
        
        # Calculate statistics
        if plays:
            dashboard.total_plays_all_time = len(plays)
            dashboard.total_spent = sum(p.amount for p in plays if p.amount)
            dashboard.total_winnings = sum(p.winnings for p in plays if p.winnings)
            dashboard.net_profit_loss = dashboard.total_winnings - dashboard.total_spent
            dashboard.overall_roi = (dashboard.net_profit_loss / dashboard.total_spent * 100) if dashboard.total_spent > 0 else 0
            
            # Biggest win/loss
            if dashboard.total_winnings > 0:
                dashboard.biggest_win = max(p.winnings for p in plays if p.winnings)
            if dashboard.total_spent > 0:
                dashboard.biggest_loss = max(p.amount for p in plays if p.amount)
            
            # Play frequency
            days_between = (datetime.now() - plays[0].created_at).days
            if days_between > 0:
                plays_per_day = len(plays) / days_between
                if plays_per_day >= 1:
                    dashboard.play_frequency = 'daily'
                elif plays_per_day >= 0.14:  # ~2 per week
                    dashboard.play_frequency = 'weekly'
                elif plays_per_day >= 0.03:
                    dashboard.play_frequency = 'monthly'
                else:
                    dashboard.play_frequency = 'occasional'
        
        # Get numerology
        numerology = NumerologyService.get_numerology_profile(db, user_id)
        if numerology and numerology.lucky_numbers:
            dashboard.personal_lucky_number = numerology.lucky_numbers[0]
        
        # Get insights
        prob_model = WinProbabilityService.calculate_probability(db, user_id, 'powerball')
        dashboard.predicted_monthly_winnings = prob_model.predicted_win_probability * 100
        
        # Primary recommendation
        dashboard.primary_recommendation = (
            f"Based on your {dashboard.play_frequency} playing pattern and numerology profile, "
            f"your next lucky day is {random.choice(['Monday', 'Wednesday', 'Friday'])}. "
            f"Your predicted win probability is {prob_model.predicted_win_probability:.2f}%"
        )
        
        db.add(dashboard)
        db.commit()
        db.refresh(dashboard)
        
        return dashboard
