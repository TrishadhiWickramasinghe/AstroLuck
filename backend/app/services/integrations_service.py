"""Integration Services for WhatsApp, Calendar, Payments, Notifications, and Lottery Results"""

from sqlalchemy.orm import Session
from app.models.integrations_models import (
    WhatsAppConnection, WhatsAppMessage, CalendarConnection, CalendarEvent,
    PaymentMethod, Payment, Subscription, NotificationPreference, NotificationLog,
    LotteryResults, UserTicket, TicketVerification, LotteryResultsSync
)
from app.models.models import User
from datetime import datetime, timedelta
from decimal import Decimal
import json
import uuid
import re
from typing import List, Dict, Optional, Tuple

# Third-party imports (to be added to requirements.txt)
# import stripe
# import paypalrestsdk
# from twilio.rest import Client as TwilioClient
# from sendgrid import SendGridAPIClient
# from sendgrid.helpers.mail import Mail
# from google.oauth2.credentials import Credentials
# from google_auth_oauthlib.flow import InstalledAppFlow
# from googleapiclient.discovery import build
# import requests


class WhatsAppService:
    """WhatsApp integration using Twilio"""
    
    def __init__(self, db: Session):
        self.db = db
        # self.twilio_client = TwilioClient(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
        # self.twilio_whatsapp_number = TWILIO_WHATSAPP_NUMBER
    
    def initiate_whatsapp_connection(self, user_id: str, whatsapp_phone: str) -> Dict:
        """Initiate WhatsApp connection for user"""
        # Check if already connected
        existing = self.db.query(WhatsAppConnection).filter(
            WhatsAppConnection.user_id == user_id
        ).first()
        
        if existing and existing.is_active:
            return {"success": False, "error": "WhatsApp already connected"}
        
        # Generate verification code
        verification_code = str(uuid.uuid4())[:6].upper()
        
        # Create connection record
        connection = WhatsAppConnection(
            id=str(uuid.uuid4()),
            user_id=user_id,
            whatsapp_phone=whatsapp_phone,
            verification_code=verification_code
        )
        self.db.add(connection)
        self.db.commit()
        
        # Send verification code via WhatsApp
        try:
            # message = self.twilio_client.messages.create(
            #     from_=f"whatsapp:{self.twilio_whatsapp_number}",
            #     to=f"whatsapp:{whatsapp_phone}",
            #     body=f"Your AstroLuck verification code is: {verification_code}"
            # )
            
            return {"success": True, "connection_id": connection.id}
        except Exception as e:
            self.db.delete(connection)
            self.db.commit()
            return {"success": False, "error": str(e)}
    
    def verify_whatsapp_code(self, connection_id: str, code: str) -> Dict:
        """Verify WhatsApp connection with code"""
        connection = self.db.query(WhatsAppConnection).filter(
            WhatsAppConnection.id == connection_id
        ).first()
        
        if not connection:
            return {"success": False, "error": "Connection not found"}
        
        if connection.verification_attempts >= 3:
            return {"success": False, "error": "Too many attempts"}
        
        if connection.verification_code != code:
            connection.verification_attempts += 1
            self.db.commit()
            return {"success": False, "error": "Invalid code"}
        
        # Mark as verified
        connection.is_verified = True
        connection.connected_at = datetime.utcnow()
        connection.verification_attempts = 0
        self.db.commit()
        
        return {"success": True, "message": "WhatsApp verified"}
    
    def send_daily_numbers(self, user_id: str, numbers: List[int], lucky_time: str) -> Dict:
        """Send daily lucky numbers to WhatsApp"""
        connection = self.db.query(WhatsAppConnection).filter(
            WhatsAppConnection.user_id == user_id,
            WhatsAppConnection.is_verified == True,
            WhatsAppConnection.is_active == True,
            WhatsAppConnection.receive_daily_numbers == True
        ).first()
        
        if not connection:
            return {"success": False, "error": "WhatsApp not connected"}
        
        # Format message
        numbers_str = ", ".join(map(str, numbers))
        message_text = f"🍀 Your Daily Lucky Numbers:\n{numbers_str}\n\n⏰ Lucky Time: {lucky_time}"
        
        try:
            # message = self.twilio_client.messages.create(
            #     from_=f"whatsapp:{self.twilio_whatsapp_number}",
            #     to=f"whatsapp:{connection.whatsapp_phone}",
            #     body=message_text
            # )
            
            # Log message
            msg_log = WhatsAppMessage(
                id=str(uuid.uuid4()),
                connection_id=connection.id,
                message_type="daily_numbers",
                message_content=message_text,
                status="sent"
            )
            self.db.add(msg_log)
            connection.last_message_sent = datetime.utcnow()
            connection.message_count += 1
            self.db.commit()
            
            return {"success": True, "message_id": msg_log.id}
        except Exception as e:
            msg_log = WhatsAppMessage(
                id=str(uuid.uuid4()),
                connection_id=connection.id,
                message_type="daily_numbers",
                message_content=message_text,
                status="failed",
                error_message=str(e)
            )
            self.db.add(msg_log)
            self.db.commit()
            return {"success": False, "error": str(e)}
    
    def disconnect_whatsapp(self, user_id: str) -> Dict:
        """Disconnect WhatsApp from user account"""
        connection = self.db.query(WhatsAppConnection).filter(
            WhatsAppConnection.user_id == user_id
        ).first()
        
        if not connection:
            return {"success": False, "error": "WhatsApp not connected"}
        
        connection.is_active = False
        connection.disconnected_at = datetime.utcnow()
        self.db.commit()
        
        return {"success": True, "message": "WhatsApp disconnected"}


class CalendarSyncService:
    """Calendar sync with Google Calendar and Apple Calendar"""
    
    def __init__(self, db: Session):
        self.db = db
        # self.SCOPES = ['https://www.googleapis.com/auth/calendar']
    
    def initiate_google_calendar_auth(self, user_id: str, redirect_uri: str) -> Dict:
        """Start Google Calendar OAuth flow"""
        connection = CalendarConnection(
            id=str(uuid.uuid4()),
            user_id=user_id,
            calendar_type="google",
            calendar_email="pending",
            access_token="pending",
            sync_enabled=True
        )
        self.db.add(connection)
        self.db.commit()
        
        # Build authorization URL (in real implementation)
        auth_url = "https://accounts.google.com/o/oauth2/v2/auth?..."
        
        return {
            "success": True,
            "connection_id": connection.id,
            "auth_url": auth_url
        }
    
    def finalize_google_calendar(self, connection_id: str, auth_code: str) -> Dict:
        """Complete Google Calendar OAuth"""
        connection = self.db.query(CalendarConnection).filter(
            CalendarConnection.id == connection_id
        ).first()
        
        if not connection:
            return {"success": False, "error": "Connection not found"}
        
        try:
            # Exchange code for token
            # credentials = ...
            # connection.access_token = credentials.token
            # connection.refresh_token = credentials.refresh_token
            # connection.token_expires_at = credentials.expiry
            # connection.calendar_email = user_info['email']
            # connection.is_active = True
            
            self.db.commit()
            return {"success": True}
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def sync_lucky_dates_to_calendar(self, user_id: str, lucky_dates: List[Dict]) -> Dict:
        """Sync lucky dates to user's calendar"""
        connections = self.db.query(CalendarConnection).filter(
            CalendarConnection.user_id == user_id,
            CalendarConnection.is_active == True,
            CalendarConnection.sync_enabled == True,
            CalendarConnection.sync_lucky_dates == True
        ).all()
        
        if not connections:
            return {"success": False, "error": "No active calendar connections"}
        
        synced_count = 0
        
        for connection in connections:
            for date_obj in lucky_dates:
                try:
                    event_name = f"🍀 Lucky Date - {date_obj['description']}"
                    
                    event = CalendarEvent(
                        id=str(uuid.uuid4()),
                        connection_id=connection.id,
                        event_type="lucky_date",
                        event_name=event_name,
                        description=date_obj.get('details'),
                        start_time=date_obj['date'],
                        calendar_type=connection.calendar_type,
                        sync_status="synced"
                    )
                    self.db.add(event)
                    synced_count += 1
                except Exception as e:
                    continue
        
        self.db.commit()
        return {"success": True, "synced_count": synced_count}
    
    def get_synced_events(self, user_id: str, calendar_type: str = None) -> List[Dict]:
        """Get user's synced calendar events"""
        query = self.db.query(CalendarConnection).filter(
            CalendarConnection.user_id == user_id
        )
        
        if calendar_type:
            query = query.filter(CalendarConnection.calendar_type == calendar_type)
        
        connections = query.all()
        events = []
        
        for conn in connections:
            conn_events = self.db.query(CalendarEvent).filter(
                CalendarEvent.connection_id == conn.id
            ).all()
            events.extend([{
                "id": e.id,
                "name": e.event_name,
                "type": e.event_type,
                "start_time": e.start_time.isoformat(),
                "calendar": conn.calendar_type
            } for e in conn_events])
        
        return events


class PaymentService:
    """Stripe and PayPal payment processing"""
    
    def __init__(self, db: Session):
        self.db = db
        # stripe.api_key = STRIPE_SECRET_KEY
        # self.stripe_public_key = STRIPE_PUBLIC_KEY
    
    def create_payment_intent(self, user_id: str, amount: float, currency: str = "USD",
                            payment_type: str = "subscription") -> Dict:
        """Create Stripe payment intent"""
        try:
            # intent = stripe.PaymentIntent.create(
            #     amount=int(amount * 100),  # Convert to cents
            #     currency=currency.lower(),
            #     metadata={
            #         "user_id": user_id,
            #         "payment_type": payment_type
            #     }
            # )
            
            # Create payment record
            payment = Payment(
                id=str(uuid.uuid4()),
                user_id=user_id,
                amount=Decimal(str(amount)),
                currency=currency,
                payment_type=payment_type,
                description=f"{payment_type} payment",
                # stripe_payment_id=intent.id,
                status="pending"
            )
            self.db.add(payment)
            self.db.commit()
            
            return {
                "success": True,
                "payment_id": payment.id,
                "client_secret": "intent.client_secret"  # intent.client_secret
            }
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def confirm_payment(self, payment_id: str) -> Dict:
        """Confirm a payment has been processed"""
        payment = self.db.query(Payment).filter(Payment.id == payment_id).first()
        
        if not payment:
            return {"success": False, "error": "Payment not found"}
        
        try:
            payment.status = "completed"
            payment.completed_at = datetime.utcnow()
            self.db.commit()
            
            # If subscription payment, create subscription
            if payment.payment_type == "subscription":
                self._create_subscription(payment.user_id, payment.amount)
            
            return {"success": True, "payment_id": payment_id}
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def _create_subscription(self, user_id: str, amount: float):
        """Create user subscription"""
        existing = self.db.query(Subscription).filter(
            Subscription.user_id == user_id
        ).first()
        
        # Determine plan based on amount
        if amount < 5:
            plan = "free"
            tier = 0
        elif amount < 10:
            plan = "premium"
            tier = 1
        elif amount < 20:
            plan = "gold"
            tier = 2
        else:
            plan = "platinum"
            tier = 3
        
        if existing:
            existing.plan = plan
            existing.tier = tier
            existing.price_per_month = amount
            existing.status = "active"
            existing.billing_cycle_start = datetime.utcnow()
            existing.billing_cycle_end = datetime.utcnow() + timedelta(days=30)
            existing.next_billing_date = datetime.utcnow() + timedelta(days=30)
        else:
            subscription = Subscription(
                id=str(uuid.uuid4()),
                user_id=user_id,
                plan=plan,
                tier=tier,
                price_per_month=amount,
                status="active",
                billing_cycle_start=datetime.utcnow(),
                billing_cycle_end=datetime.utcnow() + timedelta(days=30),
                next_billing_date=datetime.utcnow() + timedelta(days=30),
                features=self._get_plan_features(plan)
            )
            self.db.add(subscription)
        
        self.db.commit()
    
    def _get_plan_features(self, plan: str) -> Dict:
        """Get features for subscription plan"""
        features = {
            "free": {
                "astrologer_sessions": 0,
                "pool_limit": 5,
                "challenge_entries": 10,
                "daily_insights": False,
                "priority_support": False
            },
            "premium": {
                "astrologer_sessions": 5,
                "pool_limit": 20,
                "challenge_entries": 50,
                "daily_insights": True,
                "priority_support": False
            },
            "gold": {
                "astrologer_sessions": 10,
                "pool_limit": 50,
                "challenge_entries": 200,
                "daily_insights": True,
                "priority_support": True
            },
            "platinum": {
                "astrologer_sessions": "unlimited",
                "pool_limit": "unlimited",
                "challenge_entries": "unlimited",
                "daily_insights": True,
                "priority_support": True
            }
        }
        return features.get(plan, features["free"])
    
    def cancel_subscription(self, user_id: str) -> Dict:
        """Cancel user subscription"""
        subscription = self.db.query(Subscription).filter(
            Subscription.user_id == user_id
        ).first()
        
        if not subscription:
            return {"success": False, "error": "Subscription not found"}
        
        subscription.status = "canceled"
        subscription.canceled_at = datetime.utcnow()
        self.db.commit()
        
        return {"success": True, "message": "Subscription canceled"}
    
    def get_payment_methods(self, user_id: str) -> List[Dict]:
        """Get user's payment methods"""
        methods = self.db.query(PaymentMethod).filter(
            PaymentMethod.user_id == user_id,
            PaymentMethod.is_active == True
        ).all()
        
        return [{
            "id": m.id,
            "type": m.payment_type,
            "last_four": m.last_four,
            "brand": m.card_brand,
            "expiry": f"{m.expiry_month}/{m.expiry_year}",
            "is_default": m.is_default
        } for m in methods]


class NotificationService:
    """SMS and Email notifications via SendGrid and Twilio"""
    
    def __init__(self, db: Session):
        self.db = db
        # self.sg = SendGridAPIClient(SENDGRID_API_KEY)
        # self.twilio_client = TwilioClient(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
    
    def send_email(self, user_id: str, subject: str, message: str, 
                   notification_type: str = "daily_numbers") -> Dict:
        """Send email notification"""
        notification_pref = self.db.query(NotificationPreference).filter(
            NotificationPreference.user_id == user_id
        ).first()
        
        if not notification_pref or not notification_pref.email_enabled:
            return {"success": False, "error": "Email notifications disabled"}
        
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            return {"success": False, "error": "User not found"}
        
        try:
            # email = Mail(
            #     from_email='noreply@astroluck.com',
            #     to_emails=user.email,
            #     subject=subject,
            #     html_content=message
            # )
            # self.sg.send(email)
            
            # Log notification
            log = NotificationLog(
                id=str(uuid.uuid4()),
                user_id=user_id,
                preference_id=notification_pref.id,
                channel="email",
                notification_type=notification_type,
                subject=subject,
                message=message,
                recipient_address=user.email,
                status="sent"
            )
            self.db.add(log)
            self.db.commit()
            
            return {"success": True, "notification_id": log.id}
        except Exception as e:
            log = NotificationLog(
                id=str(uuid.uuid4()),
                user_id=user_id,
                preference_id=notification_pref.id,
                channel="email",
                notification_type=notification_type,
                subject=subject,
                message=message,
                recipient_address=user.email,
                status="failed",
                error_message=str(e)
            )
            self.db.add(log)
            self.db.commit()
            return {"success": False, "error": str(e)}
    
    def send_sms(self, user_id: str, message: str, notification_type: str = "alert") -> Dict:
        """Send SMS notification"""
        notification_pref = self.db.query(NotificationPreference).filter(
            NotificationPreference.user_id == user_id
        ).first()
        
        if not notification_pref or not notification_pref.sms_enabled:
            return {"success": False, "error": "SMS notifications disabled"}
        
        if not notification_pref.phone_number:
            return {"success": False, "error": "Phone number not configured"}
        
        try:
            # sms = self.twilio_client.messages.create(
            #     body=message,
            #     from_=TWILIO_PHONE_NUMBER,
            #     to=notification_pref.phone_number
            # )
            
            log = NotificationLog(
                id=str(uuid.uuid4()),
                user_id=user_id,
                preference_id=notification_pref.id,
                channel="sms",
                notification_type=notification_type,
                message=message,
                recipient_address=notification_pref.phone_number,
                status="sent"
            )
            self.db.add(log)
            self.db.commit()
            
            return {"success": True, "notification_id": log.id}
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def update_preferences(self, user_id: str, preferences: Dict) -> Dict:
        """Update user notification preferences"""
        notification_pref = self.db.query(NotificationPreference).filter(
            NotificationPreference.user_id == user_id
        ).first()
        
        if not notification_pref:
            notification_pref = NotificationPreference(
                id=str(uuid.uuid4()),
                user_id=user_id
            )
            self.db.add(notification_pref)
        
        # Update fields
        for key, value in preferences.items():
            if hasattr(notification_pref, key):
                setattr(notification_pref, key, value)
        
        self.db.commit()
        return {"success": True}


class LotteryResultsService:
    """Fetch lottery results and verify tickets"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def fetch_lottery_results(self, lottery_type: str) -> Dict:
        """Fetch latest lottery results from external API"""
        try:
            # This would call an actual lottery results API
            # Example: https://www.powerball.com/api/v1/powerball/latest
            
            # results = requests.get(
            #     f"https://lottery-api.example.com/{lottery_type}/latest"
            # ).json()
            
            result = LotteryResults(
                id=str(uuid.uuid4()),
                lottery_type=lottery_type,
                drawing_date=datetime.utcnow(),
                numbers=[12, 25, 38, 41, 52, 3],  # Example
                bonus_number=5,
                prize_pool_amount=50000000,
                estimated_jackpot=50000000,
                verified_at=datetime.utcnow()
            )
            self.db.add(result)
            self.db.commit()
            
            # Auto-verify tickets
            self.verify_tickets_against_result(result.id)
            
            return {"success": True, "result_id": result.id}
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def verify_tickets_against_result(self, lottery_result_id: str) -> Dict:
        """Verify user tickets against lottery result"""
        lottery_result = self.db.query(LotteryResults).filter(
            LotteryResults.id == lottery_result_id
        ).first()
        
        if not lottery_result:
            return {"success": False, "error": "Result not found"}
        
        # Find tickets for this lottery type and drawing date
        tickets = self.db.query(UserTicket).filter(
            UserTicket.lottery_type == lottery_result.lottery_type,
            UserTicket.drawing_date.date() == lottery_result.drawing_date.date()
        ).all()
        
        verified_count = 0
        total_prizes = Decimal('0.00')
        
        for ticket in tickets:
            verification = self._verify_single_ticket(ticket, lottery_result)
            verified_count += 1
            if verification['prize_won']:
                total_prizes += Decimal(str(verification['prize_won']))
        
        return {
            "success": True,
            "verified_count": verified_count,
            "total_prizes": float(total_prizes)
        }
    
    def _verify_single_ticket(self, ticket: UserTicket, result: LotteryResults) -> Dict:
        """Verify single ticket against result"""
        matched = 0
        bonus_matched = False
        
        # Count matching numbers
        for num in ticket.numbers:
            if num in result.numbers:
                matched += 1
        
        # Check bonus number
        if ticket.bonus_number and ticket.bonus_number == result.bonus_number:
            bonus_matched = True
        
        # Determine prize tier
        prize_tier = None
        prize_amount = 0
        
        if matched == 6 and bonus_matched:
            prize_tier = 1
            prize_amount = result.actual_jackpot or result.estimated_jackpot
        elif matched == 6:
            prize_tier = 2
            prize_amount = 1000000
        elif matched == 5 and bonus_matched:
            prize_tier = 3
            prize_amount = 50000
        elif matched == 5:
            prize_tier = 4
            prize_amount = 100
        elif matched == 4 and bonus_matched:
            prize_tier = 5
            prize_amount = 100
        elif matched == 4:
            prize_tier = 6
            prize_amount = 50
        
        # Create or update verification
        verification = self.db.query(TicketVerification).filter(
            TicketVerification.ticket_id == ticket.id
        ).first()
        
        if not verification:
            verification = TicketVerification(
                id=str(uuid.uuid4()),
                ticket_id=ticket.id,
                lottery_result_id=result.id
            )
            self.db.add(verification)
        
        verification.numbers_matched = matched
        verification.bonus_matched = bonus_matched
        verification.prize_tier = prize_tier
        verification.prize_amount = prize_amount if prize_amount > 0 else None
        verification.verification_status = "verified"
        verification.verified_at = datetime.utcnow()
        
        # Update ticket
        ticket.has_result = True
        ticket.result_checked_at = datetime.utcnow()
        ticket.matching_numbers = matched
        ticket.prize_won = prize_amount if prize_amount > 0 else None
        
        self.db.commit()
        
        return {
            "ticket_id": ticket.id,
            "numbers_matched": matched,
            "bonus_matched": bonus_matched,
            "prize_tier": prize_tier,
            "prize_won": prize_amount
        }
    
    def get_user_ticket_results(self, user_id: str) -> List[Dict]:
        """Get all verified ticket results for user"""
        verifications = self.db.query(TicketVerification).join(
            UserTicket
        ).filter(
            UserTicket.user_id == user_id,
            TicketVerification.verification_status == "verified"
        ).all()
        
        return [{
            "ticket_id": v.ticket_id,
            "numbers_matched": v.numbers_matched,
            "prize_won": v.prize_amount,
            "verified_at": v.verified_at.isoformat()
        } for v in verifications]
    
    def schedule_result_verification(self, lottery_type: str, check_time: str) -> Dict:
        """Schedule automatic result verification"""
        sync = LotteryResultsSync(
            id=str(uuid.uuid4()),
            lottery_type=lottery_type,
            sync_type="incremental",
            status="in_progress"
        )
        self.db.add(sync)
        self.db.commit()
        
        return {
            "success": True,
            "sync_id": sync.id,
            "message": f"Verification scheduled for {check_time}"
        }
