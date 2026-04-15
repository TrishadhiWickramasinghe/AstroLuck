"""Service for managing user notifications via email and SMS"""
import os
from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.models import Notification, User, DailyInsight
import uuid
from datetime import datetime

# Import notification providers
try:
    from sendgrid import SendGridAPIClient
    from sendgrid.helpers.mail import Mail
    SENDGRID_AVAILABLE = True
except ImportError:
    SENDGRID_AVAILABLE = False

try:
    from twilio.rest import Client
    TWILIO_AVAILABLE = True
except ImportError:
    TWILIO_AVAILABLE = False


class NotificationService:
    """Handle email, SMS, and push notifications"""
    
    def __init__(self):
        """Initialize notification service with API credentials"""
        self.sendgrid_client = None
        self.twilio_client = None
        
        # Initialize SendGrid
        if SENDGRID_AVAILABLE:
            api_key = os.getenv("SENDGRID_API_KEY")
            if api_key:
                self.sendgrid_client = SendGridAPIClient(api_key)
        
        # Initialize Twilio
        if TWILIO_AVAILABLE:
            account_sid = os.getenv("TWILIO_ACCOUNT_SID")
            auth_token = os.getenv("TWILIO_AUTH_TOKEN")
            if account_sid and auth_token:
                self.twilio_client = Client(account_sid, auth_token)
    
    def send_daily_lucky_numbers_email(
        self,
        db: Session,
        user_id: str,
        numbers: str,
        lottery_type: str
    ) -> bool:
        """Send daily lucky numbers via email"""
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user or not user.email:
            return False
        
        # Get user's today insight
        from datetime import date
        insight = db.query(DailyInsight).filter(
            DailyInsight.user_id == user_id,
            DailyInsight.date == date.today()
        ).first()
        
        subject = f"🎰 Your Daily Lucky Numbers - {lottery_type}"
        
        html_content = f"""
        <html>
            <body style="font-family: Arial, sans-serif;">
                <div style="max-width: 600px; margin: 0 auto;">
                    <h2 style="color: #6366f1;">🌟 Your Daily Lucky Numbers 🌟</h2>
                    
                    <p>Hi {user.full_name or user.username},</p>
                    
                    <div style="background: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0;">
                        <h3 style="color: #1f2937;">Today's Lucky Numbers</h3>
                        <div style="font-size: 28px; font-weight: bold; color: #6366f1; letter-spacing: 4px;">
                            {numbers}
                        </div>
                        <p style="color: #6b7280;">Lottery Type: {lottery_type}</p>
                    </div>
                    
                    {f'''<div style="background: #f0fdf4; padding: 15px; border-left: 4px solid #22c55e; margin: 20px 0;">
                        <h4>✨ Daily Insight</h4>
                        <p>{insight.insight_text if insight else 'Check back for your personalized insight.'}</p>
                        {f'<p><strong>Lucky Hours:</strong> {insight.lucky_hours}</p>' if insight else ''}
                    </div>''' if insight else ''}
                    
                    <p>Generated on: {datetime.now().strftime('%B %d, %Y at %I:%M %p')}</p>
                    
                    <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 30px 0;">
                    
                    <p style="color: #6b7280; font-size: 12px;">
                        This is an automated message. Please don't reply to this email.
                        <br>
                        <a href="#settings">Manage notification preferences</a>
                    </p>
                </div>
            </body>
        </html>
        """
        
        return self.send_email(
            to_email=user.email,
            subject=subject,
            html_content=html_content,
            notification_type="lucky_numbers"
        )
    
    def send_daily_insights_email(self, db: Session, user_id: str) -> bool:
        """Send daily insight email"""
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user or not user.email:
            return False
        
        from datetime import date
        insight = db.query(DailyInsight).filter(
            DailyInsight.user_id == user_id,
            DailyInsight.date == date.today()
        ).first()
        
        if not insight:
            return False
        
        subject = "✨ Your Daily Astrology Insight"
        
        html_content = f"""
        <html>
            <body style="font-family: Arial, sans-serif;">
                <div style="max-width: 600px; margin: 0 auto;">
                    <h2 style="color: #9333ea;">✨ Daily Astrology Insight ✨</h2>
                    
                    <p>Hi {user.full_name or user.username},</p>
                    
                    <div style="background: #faf5ff; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #9333ea;">
                        <h3>Today's Energy</h3>
                        <p style="font-size: 16px; line-height: 1.6;">{insight.insight_text}</p>
                    </div>
                    
                    <h3>🕐 Lucky Hours</h3>
                    <p style="background: #fef3c7; padding: 10px; border-radius: 4px;">
                        {insight.lucky_hours}
                    </p>
                    
                    <h3>📋 Recommendations</h3>
                    <ul>
                        {''.join([f'<li>{rec}</li>' for rec in (insight.recommendations or [])])}
                    </ul>
                    
                    {f'<div style="background: #fee2e2; padding: 10px; border-radius: 4px; margin: 20px 0;"><strong>⚠️ Note:</strong> {insight.warning}</div>' if insight.warning else ''}
                    
                    <h3>🌙 Best Activities Today</h3>
                    <p>{insight.best_activities}</p>
                    
                    <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 30px 0;">
                    
                    <p style="color: #6b7280; font-size: 12px;">
                        Open the AstroLuck app for more detailed insights and lottery recommendations.
                    </p>
                </div>
            </body>
        </html>
        """
        
        return self.send_email(
            to_email=user.email,
            subject=subject,
            html_content=html_content,
            notification_type="daily_insight"
        )
    
    def send_lottery_result_email(
        self,
        db: Session,
        user_id: str,
        generated_numbers: str,
        winning_numbers: str,
        matched_count: int
    ) -> bool:
        """Send lottery result notification"""
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user or not user.email:
            return False
        
        subject = "🎊 Your Lottery Result" if matched_count > 0 else "Lottery Draw Result"
        
        status_color = "#22c55e" if matched_count > 0 else "#f3f4f6"
        status_bg = "#dcfce7" if matched_count > 0 else "#f9fafb"
        
        html_content = f"""
        <html>
            <body style="font-family: Arial, sans-serif;">
                <div style="max-width: 600px; margin: 0 auto;">
                    <h2>Your Lottery Results</h2>
                    
                    <div style="background: {status_bg}; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid {status_color};">
                        <p>Your Numbers: <strong>{generated_numbers}</strong></p>
                        <p>Winning Numbers: <strong>{winning_numbers}</strong></p>
                        <p style="font-size: 18px;"><strong>Matches: {matched_count}</strong></p>
                    </div>
                    
                    <p>Generated on: {datetime.now().strftime('%B %d, %Y')}</p>
                </div>
            </body>
        </html>
        """
        
        return self.send_email(
            to_email=user.email,
            subject=subject,
            html_content=html_content,
            notification_type="lottery_result"
        )
    
    def send_badge_unlocked_email(
        self,
        db: Session,
        user_id: str,
        badge_name: str,
        badge_icon: str,
        points_earned: int
    ) -> bool:
        """Send email when badge is unlocked"""
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user or not user.email:
            return False
        
        subject = f"🏆 Badge Unlocked: {badge_name}"
        
        html_content = f"""
        <html>
            <body style="font-family: Arial, sans-serif;">
                <div style="max-width: 600px; margin: 0 auto;">
                    <h2 style="color: #f59e0b;">Congratulations! 🎉</h2>
                    
                    <div style="background: #fef3c7; padding: 30px; border-radius: 8px; text-align: center; margin: 20px 0;">
                        <div style="font-size: 48px; margin-bottom: 10px;">{badge_icon}</div>
                        <h3 style="color: #92400e;">{badge_name}</h3>
                        <p style="color: #b45309;">You earned {points_earned} points!</p>
                    </div>
                    
                    <p>You've reached a new milestone in your AstroLuck journey!</p>
                    <p>Check your profile to see all your badges and achievements.</p>
                </div>
            </body>
        </html>
        """
        
        return self.send_email(
            to_email=user.email,
            subject=subject,
            html_content=html_content,
            notification_type="badge_unlocked"
        )
    
    def send_sms(
        self,
        db: Session,
        user_id: str,
        message: str,
        notification_type: str = "sms"
    ) -> bool:
        """Send SMS notification"""
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user or not user.phone_number or not self.twilio_client:
            return False
        
        try:
            # Send SMS via Twilio
            twilio_number = os.getenv("TWILIO_PHONE_NUMBER")
            if not twilio_number:
                return False
            
            self.twilio_client.messages.create(
                body=message,
                from_=twilio_number,
                to=user.phone_number
            )
            
            # Log notification
            notification = Notification(
                id=str(uuid.uuid4()),
                user_id=user_id,
                type="sms",
                title="SMS",
                message=message,
                status="sent",
                recipient=user.phone_number
            )
            db.add(notification)
            db.commit()
            
            return True
        except Exception as e:
            print(f"SMS sending failed: {e}")
            return False
    
    def send_whatsapp_message(
        self,
        db: Session,
        user_id: str,
        message: str
    ) -> bool:
        """Send WhatsApp message via Twilio"""
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user or not user.phone_number or not self.twilio_client:
            return False
        
        try:
            twilio_whatsapp = os.getenv("TWILIO_WHATSAPP_NUMBER")
            if not twilio_whatsapp:
                return False
            
            # WhatsApp format: whatsapp:+1234567890
            self.twilio_client.messages.create(
                body=message,
                from_=f"whatsapp:{twilio_whatsapp}",
                to=f"whatsapp:{user.phone_number}"
            )
            
            # Log notification
            notification = Notification(
                id=str(uuid.uuid4()),
                user_id=user_id,
                type="whatsapp",
                title="WhatsApp",
                message=message,
                status="sent",
                recipient=user.phone_number
            )
            db.add(notification)
            db.commit()
            
            return True
        except Exception as e:
            print(f"WhatsApp sending failed: {e}")
            return False
    
    def send_email(
        self,
        to_email: str,
        subject: str,
        html_content: str,
        notification_type: str = "email"
    ) -> bool:
        """Send email via SendGrid"""
        
        if not self.sendgrid_client or not to_email:
            return False
        
        try:
            from_email = os.getenv("SENDGRID_FROM_EMAIL", "noreply@astroluck.com")
            
            message = Mail(
                from_email=from_email,
                to_emails=to_email,
                subject=subject,
                html_content=html_content
            )
            
            self.sendgrid_client.send(message)
            return True
        except Exception as e:
            print(f"Email sending failed: {e}")
            return False
    
    def get_notification_history(
        self,
        db: Session,
        user_id: str,
        limit: int = 20
    ) -> List[Notification]:
        """Get user's notification history"""
        
        notifications = db.query(Notification).filter(
            Notification.user_id == user_id
        ).order_by(Notification.created_at.desc()).limit(limit).all()
        
        return notifications
    
    def mark_notification_as_read(
        self,
        db: Session,
        notification_id: str
    ) -> bool:
        """Mark notification as read"""
        
        notification = db.query(Notification).filter(
            Notification.id == notification_id
        ).first()
        
        if notification:
            notification.status = "read"
            db.commit()
            return True
        
        return False
