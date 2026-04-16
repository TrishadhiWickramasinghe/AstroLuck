"""AI Daily Insights Service - Business Logic for Personalized Astrological Intelligence"""

from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import List, Dict, Optional
import json
import hashlib
from app.models.ai_insights_models import (
    DailyInsight, DailyInsightPersonalized, InsightEngagementLog,
    UserInsightPreference, InsightHistory, InsightFeedback,
    InsightGenerationLog, InsightType, InsightMood, InsightStatus
)
from app.models import User


class AIInsightGeneratorService:
    """Generate daily astrological insights using AI"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def generate_daily_insights_batch(self) -> Dict:
        """
        Generate daily insights for all zodiac signs
        Called daily at 00:05 UTC
        """
        try:
            generation_start = datetime.utcnow()
            
            zodiac_signs = [
                "aries", "taurus", "gemini", "cancer", "leo", "virgo",
                "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces"
            ]
            
            generated_insights = []
            
            for zodiac_sign in zodiac_signs:
                # Get astrological data for today
                astrological_data = self._get_astrological_data()
                
                # Generate insight for zodiac sign
                insight = self._generate_zodiac_insight(zodiac_sign, astrological_data)
                generated_insights.append(insight)
            
            # Log generation process
            generation_time = (datetime.utcnow() - generation_start).total_seconds()
            self._log_generation(zodiac_signs, generation_time, len(generated_insights))
            
            return {
                "success": True,
                "insights_generated": len(generated_insights),
                "generation_time_seconds": generation_time
            }
        
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "error_type": type(e).__name__
            }
    
    def _get_astrological_data(self) -> Dict:
        """
        Fetch current astrological data
        In production, integrate with astronomy library or API
        """
        today = datetime.utcnow().date()
        
        return {
            "date": today.isoformat(),
            "moon_phase": self._calculate_moon_phase(today),
            "mercury_retrograde": False,  # Update based on calendar
            "planetary_positions": self._get_planetary_positions(),
            "aspects": self._get_current_aspects(),
            "sun_sign": "aries",  # Based on date
            "season": "spring"
        }
    
    def _calculate_moon_phase(self, date: datetime) -> str:
        """
        Calculate moon phase for given date
        Uses astronomical calculations
        """
        # Simplified - in production use ephem or astropy library
        day_of_year = date.timetuple().tm_yday
        lunar_cycle = 29.53  # days
        phase_position = (day_of_year % lunar_cycle) / lunar_cycle
        
        if phase_position < 0.25:
            return "new_moon"
        elif phase_position < 0.5:
            return "waxing_crescent"
        elif phase_position < 0.75:
            return "full_moon"
        else:
            return "waning_crescent"
    
    def _get_planetary_positions(self) -> Dict:
        """Get current planetary positions by zodiac sign"""
        return {
            "sun": "aries",
            "moon": "gemini",
            "mercury": "pisces",
            "venus": "taurus",
            "mars": "leo",
            "jupiter": "sagittarius",
            "saturn": "pisces"
        }
    
    def _get_current_aspects(self) -> Dict:
        """Get current astrological aspects"""
        return {
            "venus_aspects": ["trine_to_moon", "square_to_mars"],
            "mars_influences": ["in_fire_sign", "approaching_opposition"],
            "dominant_elements": ["fire", "air"]
        }
    
    def _generate_zodiac_insight(self, zodiac_sign: str, astrological_data: Dict) -> DailyInsight:
        """
        Generate insight for specific zodiac using AI
        Integrates with GPT-4 or Claude API
        """
        prompt = self._build_generation_prompt(zodiac_sign, astrological_data)
        prompt_hash = hashlib.sha256(prompt.encode()).hexdigest()
        
        # Call LLM (commented API calls - implement with actual credentials)
        # response = openai.ChatCompletion.create(
        #     model="gpt-4",
        #     messages=[{"role": "user", "content": prompt}],
        #     temperature=0.7,
        #     max_tokens=1500
        # )
        # content = response.choices[0].message.content
        
        # Mock response for demonstration
        content = {
            "title": f"Cosmic Alignment for {zodiac_sign.capitalize()} - Navigate Today's Energy",
            "short_summary": f"The stars align in {zodiac_sign}'s favor today. A day of growth and opportunity awaits.",
            "full_content": f"""
Today brings a powerful alignment of celestial energies for {zodiac_sign.capitalize()}. 
With the moon in {astrological_data['planetary_positions'].get('moon', 'gemini')}, 
your intuition runs strong. This is an excellent time to trust your inner voice.

The Venus-Moon trine creates harmony in relationships. Express your feelings authentically.
Mars energy supports bold action in your career - this is the time to pitch that idea or take initiative.

Take advantage of these favorable cosmic conditions. Your success today multiplies your opportunities ahead.
            """,
            "sections": {
                "lucky_times": {"start": "09:00", "end": "12:00", "secondary": "18:00-20:00"},
                "lucky_colors": ["gold", "emerald", "silver"],
                "lucky_numbers": [7, 14, 21, 28],
                "element_focus": "air",
                "power_affirmation": f"I embrace the cosmic support today and manifest my highest potential as a {zodiac_sign}.",
                "tarot_card": "The Magician",
                "numerology": {"day_number": 7, "message": "Spiritual insight and good fortune"},
                "career_focus": "Take initiative on a project you've been considering",
                "romance_insight": "Vulnerability leads to deeper connection",
                "health_tip": "Honor your body's need for rest and movement",
                "financial_guidance": "Conservative approach yields best results"
            }
        }
        
        # Create DailyInsight record
        insight = DailyInsight(
            date=datetime.utcnow(),
            zodiac_sign=zodiac_sign,
            title=content["title"],
            short_summary=content["short_summary"],
            full_content=content["full_content"],
            insight_type=InsightType.GENERAL,
            mood=InsightMood.POSITIVE,
            confidence_score=0.92,
            moon_phase=astrological_data.get("moon_phase"),
            current_planetary_positions=json.dumps(astrological_data["planetary_positions"]),
            mercury_retrograde=astrological_data.get("mercury_retrograde", False),
            sections=json.dumps(content["sections"]),
            ai_model_version="gpt-4-turbo",
            generation_prompt_hash=prompt_hash,
            generation_method="llm",
            status=InsightStatus.GENERATED,
            published_at=datetime.utcnow()
        )
        
        self.db.add(insight)
        self.db.commit()
        
        return insight
    
    def _build_generation_prompt(self, zodiac_sign: str, astrological_data: Dict) -> str:
        """Build AI prompt for insight generation"""
        return f"""
Generate a personalized, inspiring daily horoscope for {zodiac_sign.capitalize()} for today.

Current Astrological Data:
- Moon Phase: {astrological_data.get('moon_phase')}
- Planetary Positions: {astrological_data.get('planetary_positions')}
- Mercury Retrograde: {astrological_data.get('mercury_retrograde')}
- Aspects: {astrological_data.get('aspects')}

Requirements:
1. Title should be compelling and specific to today
2. Include lucky times (1-2 hour windows)
3. Suggest 3-4 lucky numbers (1-52)
4. Identify 2-3 lucky colors
5. Provide career, romance, and health guidance
6. Include a power affirmation specific to {zodiac_sign.capitalize()}
7. Suggest an element focus and tarot card
8. Numerology insight for the day
9. Tone: Inspiring, empowering, practical
10. Length: 2-3 paragraphs full content

Return JSON with: title, short_summary, full_content, and sections object
        """
    
    def _log_generation(self, zodiac_signs: List[str], generation_time: float, count: int):
        """Log the generation process"""
        log = InsightGenerationLog(
            generation_date=datetime.utcnow(),
            ai_model_used="gpt-4-turbo",
            generation_method="llm",
            generation_time_seconds=generation_time,
            confidence_score=0.90,
            diversity_score=0.85,
            status="success",
            total_generated=count
        )
        self.db.add(log)
        self.db.commit()


class AIInsightPersonalizationService:
    """Personalize insights for individual users"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def personalize_insights_for_user(self, user_id: str) -> Dict:
        """
        Generate personalized insight for user based on their profile
        Called when insight is delivered to user
        """
        try:
            user = self.db.query(User).filter(User.id == user_id).first()
            if not user:
                return {"success": False, "error": "User not found"}
            
            # Get user's zodiac sign from profile
            user_zodiac = getattr(user, 'zodiac_sign', None)
            if not user_zodiac:
                return {"success": False, "error": "User zodiac sign not configured"}
            
            # Get today's base insight for user's zodiac
            today = datetime.utcnow().date()
            base_insight = self.db.query(DailyInsight).filter(
                DailyInsight.zodiac_sign == user_zodiac.lower(),
                DailyInsight.date >= datetime.combine(today, datetime.min.time()),
                DailyInsight.status == InsightStatus.GENERATED
            ).first()
            
            if not base_insight:
                return {"success": False, "error": "No base insight available"}
            
            # Personalize the insight
            personalized = self._create_personalized_version(user, base_insight)
            
            return {
                "success": True,
                "personalized_insight_id": personalized.id,
                "user_id": user_id
            }
        
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def _create_personalized_version(self, user: User, base_insight: DailyInsight) -> DailyInsightPersonalized:
        """Create personalized version of insight for user"""
        
        # Get user preferences
        prefs = self.db.query(UserInsightPreference).filter(
            UserInsightPreference.user_id == user.id
        ).first()
        
        if not prefs:
            prefs = UserInsightPreference(user_id=user.id)
            self.db.add(prefs)
            self.db.commit()
        
        # Build personalized content
        user_name = user.first_name or "there"
        personalized_title = f"{base_insight.title}"
        
        base_content = base_insight.full_content or ""
        personalized_content = f"""
Hi {user_name}!

{base_content}

Based on your profile and preferences, here's what I recommend focusing on today:
- Your strength areas align with today's energy
- Perfect timing for activities you've been planning
- Trust your instincts in key decisions

Make the most of these favorable cosmic conditions! ✨
        """
        
        # Get user's past insights for context
        user_history_context = self._get_user_history_summary(user.id)
        
        # Create personalized record
        personalized = DailyInsightPersonalized(
            base_insight_id=base_insight.id,
            user_id=user.id,
            personalized_title=personalized_title,
            personalized_content=personalized_content,
            personalization_factors={
                "used_birth_time": bool(getattr(user, 'birth_time', None)),
                "considered_user_history": True,
                "incorporated_preferences": prefs.preferred_insight_types or [],
                "personalization_level": 0.95
            },
            personalized_sections=json.dumps(self._personalize_sections(
                json.loads(base_insight.sections or "{}"),
                user
            )),
            user_history_context=user_history_context,
            scheduled_delivery_time=self._calculate_delivery_time(prefs)
        )
        
        self.db.add(personalized)
        self.db.commit()
        
        return personalized
    
    def _personalize_sections(self, sections: Dict, user: User) -> Dict:
        """Personalize the insight sections based on user profile"""
        personalized = sections.copy()
        
        # Add user-specific data
        if "power_affirmation" in personalized:
            user_zodiac = getattr(user, 'zodiac_sign', 'friend')
            personalized["power_affirmation"] = personalized["power_affirmation"].replace(
                "as a", f"as a {user_zodiac.lower()}"
            )
        
        # Adjust recommendations based on user's interests
        prefs = self.db.query(UserInsightPreference).filter(
            UserInsightPreference.user_id == user.id
        ).first()
        
        if prefs and prefs.preferred_insight_types:
            if "career" in prefs.preferred_insight_types:
                personalized["career_focus_priority"] = "high"
            if "romance" in prefs.preferred_insight_types:
                personalized["romance_insight_priority"] = "high"
        
        return personalized
    
    def _get_user_history_summary(self, user_id: str) -> str:
        """Get summary of user's past insights and patterns"""
        # Get last 7 days of insights
        week_ago = datetime.utcnow() - timedelta(days=7)
        history = self.db.query(InsightHistory).filter(
            InsightHistory.user_id == user_id,
            InsightHistory.created_at >= week_ago
        ).all()
        
        if not history:
            return "First week of insights - building your pattern"
        
        avg_rating = sum([h.rating for h in history if h.rating]) / len([h for h in history if h.rating]) if history else 0
        viewed_count = len([h for h in history if h.viewed])
        
        return f"Based on your recent pattern: {viewed_count} insights viewed, avg rating {avg_rating:.1f}⭐"
    
    def _calculate_delivery_time(self, prefs: UserInsightPreference) -> datetime:
        """Calculate when to deliver personalized insight to user"""
        if not prefs.delivery_time:
            delivery_time = "08:00"
        else:
            delivery_time = prefs.delivery_time
        
        hour, minute = map(int, delivery_time.split(':'))
        
        deliver_at = datetime.utcnow().replace(hour=hour, minute=minute, second=0)
        
        # If time has passed, schedule for tomorrow
        if deliver_at < datetime.utcnow():
            deliver_at += timedelta(days=1)
        
        return deliver_at


class AIInsightNotificationService:
    """Send insight notifications via multiple channels"""
    
    def __init__(self, db: Session):
        self.db = db
        # Initialize external services
        # self.email_service = EmailService()
        # self.sms_service = SMSService()
        # self.push_service = PushNotificationService()
    
    def send_personalized_insights(self) -> Dict:
        """
        Send personalized insights to all users
        Called periodically (e.g., every 6 hours or based on user preferences)
        """
        try:
            # Get all users with insights enabled
            users_enabled = self.db.query(UserInsightPreference).filter(
                UserInsightPreference.insights_enabled == True
            ).all()
            
            sent_count = 0
            failed_count = 0
            
            for user_pref in users_enabled:
                # Check if within delivery window
                if not self._is_delivery_time(user_pref):
                    continue
                
                user = user_pref.user
                
                # Get personalized insight
                personalized = self.db.query(DailyInsightPersonalized).filter(
                    DailyInsightPersonalized.user_id == user.id,
                    DailyInsightPersonalized.delivered_at == None
                ).first()
                
                if not personalized:
                    continue
                
                # Send via configured channels
                try:
                    self._send_insight_notifications(user, user_pref, personalized)
                    personalized.delivered_at = datetime.utcnow()
                    sent_count += 1
                except Exception as e:
                    print(f"Failed to send insight to {user.id}: {str(e)}")
                    failed_count += 1
            
            self.db.commit()
            
            return {
                "success": True,
                "sent": sent_count,
                "failed": failed_count
            }
        
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def _is_delivery_time(self, user_pref: UserInsightPreference) -> bool:
        """Check if current time matches user's delivery preference"""
        if not user_pref.delivery_time:
            return False
        
        # Get user's current time (use timezone if available)
        # For now, simplified UTC check
        now = datetime.utcnow()
        delivery_hour = int(user_pref.delivery_time.split(':')[0])
        
        # Check if within 1-hour window
        return now.hour == delivery_hour
    
    def _send_insight_notifications(self, user: User, prefs: UserInsightPreference, 
                                   personalized: DailyInsightPersonalized):
        """Send notification via all enabled channels"""
        
        # Email
        if prefs.send_via_email:
            self._send_email_notification(user, personalized)
        
        # SMS / WhatsApp
        if prefs.send_via_whatsapp:
            self._send_whatsapp_notification(user, personalized)
        
        # Push notification
        if prefs.send_via_push:
            self._send_push_notification(user, personalized)
    
    def _send_email_notification(self, user: User, personalized: DailyInsightPersonalized):
        """Send insight via email"""
        # self.email_service.send(
        #     to=user.email,
        #     subject=personalized.personalized_title,
        #     body=personalized.personalized_content,
        #     html_template="daily_insight_email.html"
        # )
        print(f"[EMAIL] Sent daily insight to {user.email}")
    
    def _send_whatsapp_notification(self, user: User, personalized: DailyInsightPersonalized):
        """Send insight via WhatsApp"""
        # Get WhatsApp connection
        from app.models.integrations_models import WhatsAppConnection
        whatsapp = self.db.query(WhatsAppConnection).filter(
            WhatsAppConnection.user_id == user.id,
            WhatsAppConnection.is_verified == True
        ).first()
        
        if whatsapp:
            # self.sms_service.send_whatsapp(
            #     to=whatsapp.whatsapp_phone,
            #     message=personalized.personalized_content
            # )
            print(f"[WHATSAPP] Sent daily insight to {whatsapp.whatsapp_phone}")
    
    def _send_push_notification(self, user: User, personalized: DailyInsightPersonalized):
        """Send push notification"""
        # self.push_service.send(
        #     user_id=user.id,
        #     title=personalized.personalized_title,
        #     body=personalized.personalized_content,
        #     data={"insight_id": personalized.id}
        # )
        print(f"[PUSH] Sent daily insight to user {user.id}")


class AIInsightEngagementService:
    """Track and analyze user engagement with insights"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def log_insight_view(self, user_id: str, insight_id: str) -> Dict:
        """Log when user views an insight"""
        try:
            engagement = self.db.query(InsightEngagementLog).filter(
                InsightEngagementLog.user_id == user_id,
                InsightEngagementLog.insight_id == insight_id
            ).first()
            
            if not engagement:
                engagement = InsightEngagementLog(
                    user_id=user_id,
                    insight_id=insight_id,
                    view_count=1,
                    opened_at=datetime.utcnow()
                )
            else:
                engagement.view_count += 1
                engagement.opened_at = datetime.utcnow()
            
            self.db.add(engagement)
            
            # Update insight view count
            insight = self.db.query(DailyInsight).filter(DailyInsight.id == insight_id).first()
            if insight:
                insight.view_count += 1
            
            self.db.commit()
            
            return {"success": True, "engagement_recorded": True}
        
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def log_insight_interaction(self, user_id: str, insight_id: str, 
                               interaction_type: str) -> Dict:
        """Log user interaction with insight (share, save, etc)"""
        try:
            engagement = self.db.query(InsightEngagementLog).filter(
                InsightEngagementLog.user_id == user_id,
                InsightEngagementLog.insight_id == insight_id
            ).first()
            
            if not engagement:
                engagement = InsightEngagementLog(
                    user_id=user_id,
                    insight_id=insight_id
                )
            
            # Log specific interaction
            if interaction_type == "share_whatsapp":
                engagement.shared_to_whatsapp = True
                engagement.interaction_count = (engagement.interaction_count or 0) + 1
            elif interaction_type == "share_social":
                engagement.shared_to_social = True
                engagement.interaction_count = (engagement.interaction_count or 0) + 1
            elif interaction_type == "save":
                engagement.is_saved = True
                engagement.saved_at = datetime.utcnow()
            elif interaction_type == "bookmark":
                engagement.is_bookmarked = True
                engagement.bookmarked_at = datetime.utcnow()
            
            self.db.add(engagement)
            
            # Update insight interaction count
            insight = self.db.query(DailyInsight).filter(DailyInsight.id == insight_id).first()
            if insight:
                insight.interaction_count = (insight.interaction_count or 0) + 1
            
            self.db.commit()
            
            return {"success": True, "interaction_logged": True}
        
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def get_user_engagement_stats(self, user_id: str) -> Dict:
        """Get engagement statistics for user"""
        try:
            total_views = self.db.query(InsightEngagementLog).filter(
                InsightEngagementLog.user_id == user_id,
                InsightEngagementLog.view_count > 0
            ).count()
            
            saved_insights = self.db.query(InsightEngagementLog).filter(
                InsightEngagementLog.user_id == user_id,
                InsightEngagementLog.is_saved == True
            ).count()
            
            shared_insights = self.db.query(InsightEngagementLog).filter(
                InsightEngagementLog.user_id == user_id
            ).filter(
                (InsightEngagementLog.shared_to_whatsapp == True) |
                (InsightEngagementLog.shared_to_social == True)
            ).count()
            
            # Calculate engagement rate
            engagement_rate = (saved_insights + shared_insights) / max(total_views, 1) * 100
            
            return {
                "success": True,
                "total_views": total_views,
                "saved_count": saved_insights,
                "shared_count": shared_insights,
                "engagement_rate": f"{engagement_rate:.1f}%"
            }
        
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def record_time_spent(self, user_id: str, insight_id: str, seconds: int) -> Dict:
        """Record how long user spent reading insight"""
        try:
            engagement = self.db.query(InsightEngagementLog).filter(
                InsightEngagementLog.user_id == user_id,
                InsightEngagementLog.insight_id == insight_id
            ).first()
            
            if engagement:
                engagement.time_spent_seconds = (engagement.time_spent_seconds or 0) + seconds
            
            self.db.commit()
            
            return {"success": True}
        
        except Exception as e:
            return {"success": False, "error": str(e)}


class AIInsightFeedbackService:
    """Manage user feedback for AI training and improvement"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def submit_feedback(self, user_id: str, insight_id: str, 
                       rating: int, comment: str = None, tags: List[str] = None) -> Dict:
        """Submit feedback on insight for AI training"""
        try:
            if not 1 <= rating <= 5:
                return {"success": False, "error": "Rating must be between 1 and 5"}
            
            feedback = InsightFeedback(
                user_id=user_id,
                insight_id=insight_id,
                overall_rating=rating,
                comment=comment,
                feedback_tags=json.dumps(tags or []),
                sentiment="positive" if rating >= 4 else ("neutral" if rating == 3 else "negative"),
                helpful_for_training=True
            )
            
            self.db.add(feedback)
            
            # Update insight with feedback data
            insight = self.db.query(DailyInsight).filter(DailyInsight.id == insight_id).first()
            if insight:
                # Could track average rating here
                pass
            
            self.db.commit()
            
            return {"success": True, "feedback_recorded": True}
        
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def get_feedback_summary(self, insight_id: str) -> Dict:
        """Get feedback summary for an insight"""
        try:
            feedback_list = self.db.query(InsightFeedback).filter(
                InsightFeedback.insight_id == insight_id
            ).all()
            
            if not feedback_list:
                return {"success": True, "total_feedback": 0, "average_rating": 0}
            
            ratings = [f.overall_rating for f in feedback_list]
            avg_rating = sum(ratings) / len(ratings)
            
            positive_count = len([f for f in feedback_list if f.sentiment == "positive"])
            
            return {
                "success": True,
                "total_feedback": len(feedback_list),
                "average_rating": f"{avg_rating:.1f}",
                "positive_sentiment": f"{positive_count / len(feedback_list) * 100:.0f}%"
            }
        
        except Exception as e:
            return {"success": False, "error": str(e)}
