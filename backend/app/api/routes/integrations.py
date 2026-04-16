"""Integration API Routes for WhatsApp, Calendar, Payments, Notifications, and Lottery Results"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.security import get_current_user
from app.db import get_db
from app.services.integrations_service import (
    WhatsAppService, CalendarSyncService, PaymentService,
    NotificationService, LotteryResultsService
)
from pydantic import BaseModel
from typing import List, Dict, Optional

# ============================================================================
# PYDANTIC MODELS FOR REQUEST/RESPONSE
# ============================================================================

# WhatsApp Models
class WhatsAppInitiateRequest(BaseModel):
    whatsapp_phone: str

class WhatsAppVerifyRequest(BaseModel):
    connection_id: str
    code: str

class WhatsAppResponse(BaseModel):
    success: bool
    message: Optional[str] = None

# Payment Models
class PaymentIntentRequest(BaseModel):
    amount: float
    currency: str = "USD"
    payment_type: str  # subscription, pool_entry, challenge, astrologer

class PaymentResponse(BaseModel):
    payment_id: str
    client_secret: str

class SubscriptionResponse(BaseModel):
    plan: str
    tier: int
    price_per_month: float
    status: str

# Notification Models
class NotificationPreferenceUpdate(BaseModel):
    email_enabled: Optional[bool] = None
    sms_enabled: Optional[bool] = None
    push_enabled: Optional[bool] = None
    morning_time: Optional[str] = None
    evening_time: Optional[str] = None
    phone_number: Optional[str] = None

# Lottery Models
class LotteryResultsRequest(BaseModel):
    lottery_type: str

class TicketVerificationResponse(BaseModel):
    ticket_id: str
    numbers_matched: int
    prize_won: Optional[float]
    verified_at: str


# ============================================================================
# API ROUTER
# ============================================================================

router = APIRouter(prefix="/api/v1/integrations", tags=["integrations"])


# ============================================================================
# 1. WHATSAPP INTEGRATION ENDPOINTS
# ============================================================================

@router.post("/whatsapp/initiate")
async def initiate_whatsapp(
    request: WhatsAppInitiateRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Initiate WhatsApp connection"""
    service = WhatsAppService(db)
    
    # Validate phone number
    phone = request.whatsapp_phone.replace(" ", "").replace("-", "")
    if not phone.startswith("+"):
        phone = "+" + phone
    
    result = service.initiate_whatsapp_connection(current_user["id"], phone)
    
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return {
        "success": True,
        "connection_id": result["connection_id"],
        "message": "Verification code sent to WhatsApp"
    }


@router.post("/whatsapp/verify")
async def verify_whatsapp(
    request: WhatsAppVerifyRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Verify WhatsApp connection with code"""
    service = WhatsAppService(db)
    result = service.verify_whatsapp_code(request.connection_id, request.code)
    
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return {"success": True, "message": result["message"]}


@router.get("/whatsapp/status")
async def get_whatsapp_status(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get WhatsApp connection status"""
    from app.models.integrations_models import WhatsAppConnection
    
    connection = db.query(WhatsAppConnection).filter(
        WhatsAppConnection.user_id == current_user["id"]
    ).first()
    
    if not connection:
        return {"connected": False}
    
    return {
        "connected": connection.is_verified and connection.is_active,
        "phone": connection.whatsapp_phone,
        "receive_daily_numbers": connection.receive_daily_numbers,
        "receive_alerts": connection.receive_alerts,
        "notification_time": connection.notification_time,
        "last_message": connection.last_message_sent.isoformat() if connection.last_message_sent else None
    }


@router.post("/whatsapp/disconnect")
async def disconnect_whatsapp(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Disconnect WhatsApp"""
    service = WhatsAppService(db)
    result = service.disconnect_whatsapp(current_user["id"])
    
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return {"success": True, "message": "WhatsApp disconnected"}


@router.patch("/whatsapp/preferences")
async def update_whatsapp_preferences(
    preferences: Dict,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update WhatsApp preferences"""
    from app.models.integrations_models import WhatsAppConnection
    
    connection = db.query(WhatsAppConnection).filter(
        WhatsAppConnection.user_id == current_user["id"]
    ).first()
    
    if not connection:
        raise HTTPException(status_code=404, detail="WhatsApp not connected")
    
    # Update fields
    for key, value in preferences.items():
        if hasattr(connection, key):
            setattr(connection, key, value)
    
    db.commit()
    return {"success": True}


# ============================================================================
# 2. CALENDAR SYNC ENDPOINTS
# ============================================================================

@router.post("/calendar/google/auth-url")
async def get_google_calendar_auth_url(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get Google Calendar OAuth URL"""
    service = CalendarSyncService(db)
    result = service.initiate_google_calendar_auth(
        current_user["id"],
        redirect_uri="https://astroluck.com/callback"
    )
    
    return {
        "success": True,
        "connection_id": result["connection_id"],
        "auth_url": result["auth_url"]
    }


@router.post("/calendar/google/callback")
async def handle_google_calendar_callback(
    connection_id: str,
    code: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Handle Google Calendar OAuth callback"""
    service = CalendarSyncService(db)
    result = service.finalize_google_calendar(connection_id, code)
    
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return {"success": True, "message": "Google Calendar connected"}


@router.get("/calendar/connected")
async def get_connected_calendars(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's connected calendars"""
    from app.models.integrations_models import CalendarConnection
    
    connections = db.query(CalendarConnection).filter(
        CalendarConnection.user_id == current_user["id"],
        CalendarConnection.is_active == True
    ).all()
    
    return {
        "calendars": [{
            "id": c.id,
            "type": c.calendar_type,
            "email": c.calendar_email,
            "sync_enabled": c.sync_enabled,
            "last_sync": c.last_sync_at.isoformat() if c.last_sync_at else None
        } for c in connections]
    }


@router.post("/calendar/disconnect/{calendar_id}")
async def disconnect_calendar(
    calendar_id: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Disconnect calendar"""
    from app.models.integrations_models import CalendarConnection
    
    connection = db.query(CalendarConnection).filter(
        CalendarConnection.id == calendar_id,
        CalendarConnection.user_id == current_user["id"]
    ).first()
    
    if not connection:
        raise HTTPException(status_code=404, detail="Calendar not found")
    
    connection.is_active = False
    db.commit()
    
    return {"success": True}


@router.patch("/calendar/{calendar_id}/preferences")
async def update_calendar_preferences(
    calendar_id: str,
    preferences: Dict,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update calendar sync preferences"""
    from app.models.integrations_models import CalendarConnection
    
    connection = db.query(CalendarConnection).filter(
        CalendarConnection.id == calendar_id,
        CalendarConnection.user_id == current_user["id"]
    ).first()
    
    if not connection:
        raise HTTPException(status_code=404, detail="Calendar not found")
    
    for key, value in preferences.items():
        if hasattr(connection, key):
            setattr(connection, key, value)
    
    db.commit()
    return {"success": True}


# ============================================================================
# 3. PAYMENT GATEWAY ENDPOINTS
# ============================================================================

@router.post("/payments/intent")
async def create_payment_intent(
    request: PaymentIntentRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create payment intent"""
    service = PaymentService(db)
    result = service.create_payment_intent(
        current_user["id"],
        request.amount,
        request.currency,
        request.payment_type
    )
    
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return result


@router.post("/payments/{payment_id}/confirm")
async def confirm_payment(
    payment_id: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Confirm payment completion"""
    service = PaymentService(db)
    result = service.confirm_payment(payment_id)
    
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return result


@router.get("/subscription/current")
async def get_current_subscription(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get current subscription"""
    from app.models.integrations_models import Subscription
    
    subscription = db.query(Subscription).filter(
        Subscription.user_id == current_user["id"]
    ).first()
    
    if not subscription:
        return {
            "plan": "free",
            "tier": 0,
            "price_per_month": 0,
            "status": "active"
        }
    
    return {
        "plan": subscription.plan,
        "tier": subscription.tier,
        "price_per_month": subscription.price_per_month,
        "status": subscription.status,
        "next_billing_date": subscription.next_billing_date.isoformat() if subscription.next_billing_date else None,
        "features": subscription.features
    }


@router.post("/subscription/downgrade")
async def downgrade_subscription(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Downgrade to free plan"""
    service = PaymentService(db)
    result = service.cancel_subscription(current_user["id"])
    
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return result


@router.get("/payments/history")
async def get_payment_history(
    limit: int = 20,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user payment history"""
    from app.models.integrations_models import Payment
    
    payments = db.query(Payment).filter(
        Payment.user_id == current_user["id"]
    ).order_by(Payment.created_at.desc()).limit(limit).all()
    
    return {
        "payments": [{
            "id": p.id,
            "amount": p.amount,
            "currency": p.currency,
            "type": p.payment_type,
            "status": p.status,
            "date": p.created_at.isoformat()
        } for p in payments]
    }


# ============================================================================
# 4. NOTIFICATION ENDPOINTS
# ============================================================================

@router.get("/notifications/preferences")
async def get_notification_preferences(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get notification preferences"""
    from app.models.integrations_models import NotificationPreference
    
    pref = db.query(NotificationPreference).filter(
        NotificationPreference.user_id == current_user["id"]
    ).first()
    
    if not pref:
        return {
            "email_enabled": True,
            "sms_enabled": False,
            "push_enabled": True,
            "morning_time": "08:00",
            "evening_time": "18:00"
        }
    
    return {
        "email_enabled": pref.email_enabled,
        "email_frequency": pref.email_frequency,
        "sms_enabled": pref.sms_enabled,
        "phone_number": pref.phone_number if pref.sms_verified else None,
        "push_enabled": pref.push_enabled,
        "morning_time": pref.morning_time,
        "evening_time": pref.evening_time,
        "quiet_hours_enabled": pref.quiet_hours_enabled,
        "quiet_hours_start": pref.quiet_hours_start,
        "quiet_hours_end": pref.quiet_hours_end
    }


@router.patch("/notifications/preferences")
async def update_notification_preferences(
    preferences: NotificationPreferenceUpdate,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update notification preferences"""
    service = NotificationService(db)
    
    result = service.update_preferences(
        current_user["id"],
        preferences.dict(exclude_unset=True)
    )
    
    return result


@router.post("/notifications/test-email")
async def send_test_email(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Send test email notification"""
    service = NotificationService(db)
    
    result = service.send_email(
        current_user["id"],
        "Test Email from AstroLuck",
        "<h1>Your Test Email</h1><p>If you received this, email notifications are working!</p>",
        "test"
    )
    
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return {"success": True, "message": "Test email sent"}


@router.get("/notifications/history")
async def get_notification_history(
    channel: Optional[str] = None,
    limit: int = 20,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get notification history"""
    from app.models.integrations_models import NotificationLog
    
    query = db.query(NotificationLog).filter(
        NotificationLog.user_id == current_user["id"]
    )
    
    if channel:
        query = query.filter(NotificationLog.channel == channel)
    
    logs = query.order_by(NotificationLog.created_at.desc()).limit(limit).all()
    
    return {
        "notifications": [{
            "id": n.id,
            "channel": n.channel,
            "type": n.notification_type,
            "status": n.status,
            "sent_at": n.sent_at.isoformat() if n.sent_at else None
        } for n in logs]
    }


# ============================================================================
# 5. LOTTERY RESULTS ENDPOINTS
# ============================================================================

@router.post("/lottery/fetch-results")
async def fetch_lottery_results(
    request: LotteryResultsRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Fetch latest lottery results"""
    service = LotteryResultsService(db)
    result = service.fetch_lottery_results(request.lottery_type)
    
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return {"success": True, "result_id": result["result_id"]}


@router.get("/lottery/results/{lottery_type}")
async def get_latest_results(
    lottery_type: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get latest lottery results"""
    from app.models.integrations_models import LotteryResults
    
    result = db.query(LotteryResults).filter(
        LotteryResults.lottery_type == lottery_type
    ).order_by(LotteryResults.drawing_date.desc()).first()
    
    if not result:
        raise HTTPException(status_code=404, detail="No results found")
    
    return {
        "lottery_type": result.lottery_type,
        "drawing_date": result.drawing_date.isoformat(),
        "numbers": result.numbers,
        "bonus_number": result.bonus_number,
        "jackpot": result.actual_jackpot or result.estimated_jackpot
    }


@router.get("/lottery/my-tickets")
async def get_my_tickets(
    lottery_type: Optional[str] = None,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's lottery tickets"""
    from app.models.integrations_models import UserTicket
    
    query = db.query(UserTicket).filter(
        UserTicket.user_id == current_user["id"]
    )
    
    if lottery_type:
        query = query.filter(UserTicket.lottery_type == lottery_type)
    
    tickets = query.order_by(UserTicket.created_at.desc()).all()
    
    return {
        "tickets": [{
            "id": t.id,
            "lottery_type": t.lottery_type,
            "numbers": t.numbers,
            "drawing_date": t.drawing_date.isoformat(),
            "has_result": t.has_result,
            "prize_won": t.prize_won
        } for t in tickets]
    }


@router.get("/lottery/ticket-results")
async def get_ticket_results(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get verified ticket results"""
    service = LotteryResultsService(db)
    results = service.get_user_ticket_results(current_user["id"])
    
    return {
        "results": results,
        "total_won": sum([r["prize_won"] or 0 for r in results])
    }


@router.post("/lottery/verify-tickets")
async def verify_user_tickets(
    lottery_type: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Manually trigger ticket verification"""
    service = LotteryResultsService(db)
    
    # Get latest result
    from app.models.integrations_models import LotteryResults
    result = db.query(LotteryResults).filter(
        LotteryResults.lottery_type == lottery_type
    ).order_by(LotteryResults.drawing_date.desc()).first()
    
    if not result:
        raise HTTPException(status_code=404, detail="No lottery results found")
    
    verification_result = service.verify_tickets_against_result(result.id)
    
    return verification_result


@router.post("/lottery/automate-verification")
async def automate_verification(
    request: LotteryResultsRequest,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Set up automated ticket verification"""
    service = LotteryResultsService(db)
    
    result = service.schedule_result_verification(
        request.lottery_type,
        "daily_after_drawing"
    )
    
    return result
