"""Integration Models for WhatsApp, Calendar, Payments, Notifications, and Lottery Results"""

from sqlalchemy import Column, String, Integer, Float, DateTime, Boolean, Text, JSON, Enum, ForeignKey, Table
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime
from enum import Enum as PyEnum
from app.db import Base

# ============================================================================
# 1. WHATSAPP INTEGRATION MODELS
# ============================================================================

class WhatsAppConnection(Base):
    """Store WhatsApp user connections and preferences"""
    __tablename__ = "whatsapp_connections"
    
    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, unique=True)
    whatsapp_phone = Column(String(20), nullable=False, unique=True)
    whatsapp_id = Column(String(100), nullable=True)
    is_verified = Column(Boolean, default=False)
    verification_code = Column(String(6), nullable=True)
    verification_attempts = Column(Integer, default=0)
    connected_at = Column(DateTime, nullable=True)
    disconnected_at = Column(DateTime, nullable=True)
    is_active = Column(Boolean, default=True)
    
    # Preferences
    receive_daily_numbers = Column(Boolean, default=True)
    receive_alerts = Column(Boolean, default=True)
    receive_lucky_times = Column(Boolean, default=True)
    notification_time = Column(String(5), default="08:00")  # HH:MM format
    
    # Status tracking
    last_message_sent = Column(DateTime, nullable=True)
    message_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="whatsapp_connection")
    messages = relationship("WhatsAppMessage", back_populates="connection", cascade="all, delete-orphan")


class WhatsAppMessage(Base):
    """Log of WhatsApp messages sent"""
    __tablename__ = "whatsapp_messages"
    
    id = Column(String(36), primary_key=True)
    connection_id = Column(String(36), ForeignKey("whatsapp_connections.id"), nullable=False)
    message_type = Column(String(50), nullable=False)  # daily_numbers, alert, lucky_time, etc
    message_content = Column(Text, nullable=False)
    status = Column(String(20), default="pending")  # pending, sent, delivered, failed
    error_message = Column(Text, nullable=True)
    sent_at = Column(DateTime, nullable=True)
    delivered_at = Column(DateTime, nullable=True)
    read_at = Column(DateTime, nullable=True)
    retry_count = Column(Integer, default=0)
    max_retries = Column(Integer, default=3)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    connection = relationship("WhatsAppConnection", back_populates="messages")


# ============================================================================
# 2. CALENDAR SYNC MODELS
# ============================================================================

class CalendarConnection(Base):
    """Store connected calendar accounts"""
    __tablename__ = "calendar_connections"
    
    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False)
    calendar_type = Column(String(20), nullable=False)  # google, apple, outlook
    calendar_email = Column(String(255), nullable=False)
    access_token = Column(Text, nullable=False)
    refresh_token = Column(Text, nullable=True)
    token_expires_at = Column(DateTime, nullable=True)
    is_active = Column(Boolean, default=True)
    
    # Sync preferences
    sync_enabled = Column(Boolean, default=True)
    auto_sync_interval = Column(Integer, default=24)  # hours
    last_sync_at = Column(DateTime, nullable=True)
    next_sync_at = Column(DateTime, nullable=True)
    
    # What to sync
    sync_lucky_dates = Column(Boolean, default=True)
    sync_lucky_times = Column(Boolean, default=True)
    sync_lottery_drawings = Column(Boolean, default=True)
    calendar_color = Column(String(7), default="#4285F4")  # Color for events
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="calendar_connections")
    events = relationship("CalendarEvent", back_populates="connection", cascade="all, delete-orphan")


class CalendarEvent(Base):
    """Track synced calendar events"""
    __tablename__ = "calendar_events"
    
    id = Column(String(36), primary_key=True)
    connection_id = Column(String(36), ForeignKey("calendar_connections.id"), nullable=False)
    event_type = Column(String(30), nullable=False)  # lucky_date, lucky_time, drawing
    event_name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    start_time = Column(DateTime, nullable=False)
    end_time = Column(DateTime, nullable=True)
    
    # Calendar IDs for tracking
    external_event_id = Column(String(255), nullable=True)
    calendar_type = Column(String(20), nullable=False)
    
    # Status
    sync_status = Column(String(20), default="synced")  # synced, pending, failed
    last_sync_at = Column(DateTime, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    connection = relationship("CalendarConnection", back_populates="events")


# ============================================================================
# 3. PAYMENT GATEWAY MODELS
# ============================================================================

class PaymentMethod(Base):
    """Store user payment methods"""
    __tablename__ = "payment_methods"
    
    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False)
    payment_type = Column(String(20), nullable=False)  # card, paypal, bank
    
    # Stripe / PayPal info
    stripe_payment_method_id = Column(String(100), nullable=True)
    paypal_email = Column(String(255), nullable=True)
    
    # Card details (tokenized, never store full card)
    last_four = Column(String(4), nullable=True)
    card_brand = Column(String(20), nullable=True)  # visa, mastercard, amex
    expiry_month = Column(Integer, nullable=True)
    expiry_year = Column(Integer, nullable=True)
    
    # Status
    is_default = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    is_expired = Column(Boolean, default=False)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="payment_methods")
    payments = relationship("Payment", back_populates="payment_method")


class Payment(Base):
    """Track all payments"""
    __tablename__ = "payments"
    
    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False)
    payment_method_id = Column(String(36), ForeignKey("payment_methods.id"), nullable=True)
    
    # Transaction details
    amount = Column(Float, nullable=False)
    currency = Column(String(3), default="USD")  # USD, EUR, GBP
    payment_type = Column(String(30), nullable=False)  # subscription, pool_entry, challenge, astrologer
    description = Column(String(255), nullable=False)
    
    # Gateway references
    stripe_payment_id = Column(String(100), nullable=True)
    paypal_transaction_id = Column(String(100), nullable=True)
    
    # Status tracking
    status = Column(String(20), default="pending")  # pending, processing, completed, failed, refunded
    failure_reason = Column(Text, nullable=True)
    retry_count = Column(Integer, default=0)
    
    # Metadata
    metadata = Column(JSON, nullable=True)  # Additional data (subscription_id, pool_id, etc)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)
    refunded_at = Column(DateTime, nullable=True)
    
    # Relationships
    user = relationship("User", back_populates="payments")
    payment_method = relationship("PaymentMethod", back_populates="payments")
    subscription = relationship("Subscription", back_populates="payment", uselist=False)


class Subscription(Base):
    """Track user subscriptions"""
    __tablename__ = "subscriptions"
    
    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, unique=True)
    payment_id = Column(String(36), ForeignKey("payments.id"), nullable=True)
    
    # Subscription details
    plan = Column(String(20), nullable=False)  # free, premium, gold, platinum
    tier = Column(Integer, default=0)  # 0=free, 1=premium, 2=gold, 3=platinum
    price_per_month = Column(Float, nullable=False, default=0)
    
    # Status
    status = Column(String(20), default="active")  # active, canceled, suspended, expired
    
    # Recurring billing
    stripe_subscription_id = Column(String(100), nullable=True)
    paypal_subscription_id = Column(String(100), nullable=True)
    billing_cycle_start = Column(DateTime, nullable=True)
    billing_cycle_end = Column(DateTime, nullable=True)
    next_billing_date = Column(DateTime, nullable=True)
    
    # Features unlocked
    features = Column(JSON, default={})  # {astrologer_sessions: 10, pool_limit: 50, etc}
    
    created_at = Column(DateTime, default=datetime.utcnow)
    canceled_at = Column(DateTime, nullable=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="subscription")
    payment = relationship("Payment", back_populates="subscription")


# ============================================================================
# 4. NOTIFICATION MODELS
# ============================================================================

class NotificationPreference(Base):
    """User notification preferences"""
    __tablename__ = "notification_preferences"
    
    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False, unique=True)
    
    # Email preferences
    email_enabled = Column(Boolean, default=True)
    email_daily_numbers = Column(Boolean, default=True)
    email_insights = Column(Boolean, default=True)
    email_alerts = Column(Boolean, default=True)
    email_promotions = Column(Boolean, default=False)
    email_frequency = Column(String(20), default="daily")  # daily, weekly, never
    
    # SMS preferences
    sms_enabled = Column(Boolean, default=False)
    phone_number = Column(String(20), nullable=True)
    sms_verified = Column(Boolean, default=False)
    sms_daily_numbers = Column(Boolean, default=True)
    sms_alerts = Column(Boolean, default=True)
    sms_frequency = Column(String(20), default="daily")
    
    # Push preferences
    push_enabled = Column(Boolean, default=True)
    push_daily_numbers = Column(Boolean, default=True)
    push_insights = Column(Boolean, default=True)
    push_alerts = Column(Boolean, default=True)
    push_challenges = Column(Boolean, default=True)
    
    # Notification times
    morning_time = Column(String(5), default="08:00")  # HH:MM
    evening_time = Column(String(5), default="18:00")
    
    # Quiet hours
    quiet_hours_enabled = Column(Boolean, default=False)
    quiet_hours_start = Column(String(5), default="22:00")
    quiet_hours_end = Column(String(5), default="07:00")
    
    # Unsubscribe token
    unsubscribe_token = Column(String(100), nullable=True, unique=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="notification_preferences")
    notifications = relationship("NotificationLog", back_populates="preference")


class NotificationLog(Base):
    """Track all notifications sent"""
    __tablename__ = "notification_logs"
    
    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False)
    preference_id = Column(String(36), ForeignKey("notification_preferences.id"), nullable=False)
    
    # Notification details
    channel = Column(String(20), nullable=False)  # email, sms, push
    notification_type = Column(String(50), nullable=False)  # daily_numbers, alert, insight, etc
    subject = Column(String(255), nullable=True)
    message = Column(Text, nullable=False)
    
    # Recipient info
    recipient_address = Column(String(255), nullable=False)  # email or phone
    
    # Status
    status = Column(String(20), default="pending")  # pending, sent, delivered, failed, bounced
    error_message = Column(Text, nullable=True)
    retry_count = Column(Integer, default=0)
    
    # Engagement tracking
    opened_at = Column(DateTime, nullable=True)
    clicked_at = Column(DateTime, nullable=True)
    unsubscribed_at = Column(DateTime, nullable=True)
    
    # Reference
    related_entity_id = Column(String(36), nullable=True)  # lucky_number_id, insight_id, etc
    related_entity_type = Column(String(50), nullable=True)  # lucky_number, insight, etc
    
    created_at = Column(DateTime, default=datetime.utcnow)
    sent_at = Column(DateTime, nullable=True)
    
    # Relationships
    user = relationship("User")
    preference = relationship("NotificationPreference", back_populates="notifications")


# ============================================================================
# 5. LOTTERY RESULTS MODELS
# ============================================================================

class LotteryResults(Base):
    """Store official lottery drawing results"""
    __tablename__ = "lottery_results"
    
    id = Column(String(36), primary_key=True)
    lottery_type = Column(String(50), nullable=False)  # powerball, mega_millions, daily_pick_3, etc
    drawing_number = Column(String(50), nullable=True)  # Official drawing number
    
    # Drawing details
    drawing_date = Column(DateTime, nullable=False)
    numbers = Column(JSON, nullable=False)  # List of winning numbers
    bonus_number = Column(Integer, nullable=True)  # Powerball, mega_millions bonus
    
    # Prize pool
    prize_pool_amount = Column(Float, nullable=True)
    estimated_jackpot = Column(Float, nullable=True)
    actual_jackpot = Column(Float, nullable=True)
    
    # Winners
    total_tickets_sold = Column(Integer, nullable=True)
    jackpot_winners = Column(Integer, default=0)
    prize_breakdown = Column(JSON, nullable=True)  # {1_correct: count, 2_correct: count, etc}
    
    # Official source
    source_url = Column(String(512), nullable=True)
    source_name = Column(String(255), nullable=True)
    verified_at = Column(DateTime, nullable=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    ticket_verifications = relationship("TicketVerification", back_populates="lottery_result")


class UserTicket(Base):
    """Store user's lottery tickets"""
    __tablename__ = "user_tickets"
    
    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), ForeignKey("user.id"), nullable=False)
    
    # Ticket details
    lottery_type = Column(String(50), nullable=False)
    ticket_number = Column(String(50), nullable=False, unique=True)
    numbers = Column(JSON, nullable=False)  # Array of numbers on ticket
    bonus_number = Column(Integer, nullable=True)
    
    # Purchase details
    purchase_date = Column(DateTime, nullable=False)
    purchase_price = Column(Float, nullable=False)
    
    # Drawing info
    drawing_date = Column(DateTime, nullable=False)
    is_for_upcoming = Column(Boolean, default=True)
    
    # Result status
    has_result = Column(Boolean, default=False)
    result_checked_at = Column(DateTime, nullable=True)
    matching_numbers = Column(Integer, default=0)
    prize_won = Column(Float, nullable=True)
    
    # Generated by AstroLuck
    generated_by_astroluck = Column(Boolean, default=False)
    generation_method = Column(String(50), nullable=True)  # lucky_numbers, pool, challenge, etc
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="tickets")
    verification = relationship("TicketVerification", back_populates="ticket", uselist=False)


class TicketVerification(Base):
    """Track ticket win verification against official results"""
    __tablename__ = "ticket_verifications"
    
    id = Column(String(36), primary_key=True)
    ticket_id = Column(String(36), ForeignKey("user_tickets.id"), nullable=False, unique=True)
    lottery_result_id = Column(String(36), ForeignKey("lottery_results.id"), nullable=True)
    
    # Verification details
    verification_status = Column(String(20), default="pending")  # pending, verified, no_match, error
    
    # Match results
    numbers_matched = Column(Integer, default=0)
    bonus_matched = Column(Boolean, default=False)
    prize_tier = Column(Integer, nullable=True)  # 1st, 2nd, 3rd tier, etc
    prize_amount = Column(Float, nullable=True)
    
    # Payout tracking
    payout_status = Column(String(20), default="pending")  # pending, approved, paid, failed
    payout_method = Column(String(50), nullable=True)  # original_payment_method, manual_transfer
    payout_date = Column(DateTime, nullable=True)
    
    # Verification timestamp
    verified_at = Column(DateTime, nullable=True)
    
    # Error tracking
    verification_error = Column(Text, nullable=True)
    retry_count = Column(Integer, default=0)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    ticket = relationship("UserTicket", back_populates="verification")
    lottery_result = relationship("LotteryResults", back_populates="ticket_verifications")


class LotteryResultsSync(Base):
    """Track lottery results API syncs"""
    __tablename__ = "lottery_results_sync"
    
    id = Column(String(36), primary_key=True)
    
    # Sync details
    lottery_type = Column(String(50), nullable=False)
    sync_type = Column(String(20), nullable=False)  # full, incremental
    
    # Status
    status = Column(String(20), default="in_progress")  # in_progress, completed, failed
    error_message = Column(Text, nullable=True)
    
    # Results
    results_fetched = Column(Integer, default=0)
    results_updated = Column(Integer, default=0)
    results_skipped = Column(Integer, default=0)
    tickets_verified = Column(Integer, default=0)
    
    # Timestamps
    started_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime, nullable=True)
    next_sync_at = Column(DateTime, nullable=True)


# ============================================================================
# UPDATE TO USER MODEL - ADD RELATIONSHIPS
# ============================================================================
# Note: These relationships should be added to the User model:
# whatsapp_connection = relationship("WhatsAppConnection", back_populates="user", uselist=False)
# calendar_connections = relationship("CalendarConnection", back_populates="user")
# payment_methods = relationship("PaymentMethod", back_populates="user")
# payments = relationship("Payment", back_populates="user")
# subscription = relationship("Subscription", back_populates="user", uselist=False)
# notification_preferences = relationship("NotificationPreference", back_populates="user", uselist=False)
# tickets = relationship("UserTicket", back_populates="user")
