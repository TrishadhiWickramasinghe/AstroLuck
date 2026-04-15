"""API routes for payments and subscriptions"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import get_db
from app.core.security import get_current_user
from app.models.models import User
from app.services.payment_service import PaymentService
from pydantic import BaseModel
from typing import List, Dict, Optional

router = APIRouter(prefix="/api/v1", tags=["Payments & Subscriptions"])

payment_service = PaymentService()


# ============ Pydantic Models ============

class SubscriptionPlan(BaseModel):
    plan: str


class PaymentMethodRequest(BaseModel):
    stripe_payment_method_id: str


class CancelSubscriptionRequest(BaseModel):
    reason: Optional[str] = None


class RefundRequest(BaseModel):
    reason: str


# ============ Subscription Routes ============

@router.get("/subscriptions/plans")
def get_all_plans():
    """Get all available subscription plans"""
    
    plans_list = []
    for plan_name, plan_info in PaymentService.PLANS.items():
        plans_list.append({
            "plan": plan_name,
            "name": plan_info["name"],
            "price": plan_info["price"],
            "features": plan_info["features"]
        })
    
    return {
        "status": "success",
        "plans": plans_list
    }


@router.get("/subscriptions/current")
def get_current_subscription(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's current subscription"""
    
    subscription = payment_service.get_user_subscription(db, current_user.id)
    
    if not subscription:
        return {
            "status": "success",
            "subscription": None,
            "plan": "free"
        }
    
    return {
        "status": "success",
        "subscription": {
            "plan": subscription.plan,
            "status": subscription.status,
            "amount": subscription.amount,
            "renews_at": subscription.renews_at.isoformat() if subscription.renews_at else None,
            "created_at": subscription.created_at.isoformat() if subscription.created_at else None
        }
    }


@router.post("/subscriptions/upgrade")
def upgrade_subscription(
    request: SubscriptionPlan,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Upgrade to a new subscription plan"""
    
    # If plan is premium or higher, stripe is required
    if request.plan != "free":
        raise HTTPException(
            status_code=400,
            detail="Stripe integration required for paid plans. Configure STRIPE_SECRET_KEY."
        )
    
    subscription = payment_service.upgrade_plan(db, current_user.id, request.plan)
    
    if not subscription:
        raise HTTPException(
            status_code=400,
            detail="Failed to upgrade subscription"
        )
    
    return {
        "status": "success",
        "message": f"Upgraded to {request.plan} plan",
        "subscription": {
            "plan": subscription.plan,
            "status": subscription.status,
            "amount": subscription.amount
        }
    }


@router.post("/subscriptions/cancel")
def cancel_subscription(
    request: CancelSubscriptionRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Cancel subscription"""
    
    success = payment_service.cancel_subscription(db, current_user.id)
    
    if not success:
        raise HTTPException(
            status_code=400,
            detail="Subscription cancellation failed"
        )
    
    return {
        "status": "success",
        "message": "Subscription cancelled successfully"
    }


@router.get("/subscriptions/features/{feature}")
def check_feature_availability(
    feature: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Check if feature is available for user"""
    
    is_available = payment_service.is_feature_available(db, current_user.id, feature)
    
    return {
        "status": "success",
        "feature": feature,
        "available": is_available
    }


@router.get("/subscriptions/available-features")
def get_available_features(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all available features for user's current plan"""
    
    subscription = payment_service.get_user_subscription(db, current_user.id)
    plan = subscription.plan if subscription else "free"
    
    features = payment_service.get_subscription_features(plan)
    
    return {
        "status": "success",
        "current_plan": plan,
        "features": features.get("features", [])
    }


@router.post("/subscriptions/request-refund")
def request_refund(
    request: RefundRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Request refund for subscription"""
    
    success = payment_service.process_refund(db, current_user.id, request.reason)
    
    if not success:
        raise HTTPException(
            status_code=400,
            detail="Refund processing failed"
        )
    
    return {
        "status": "success",
        "message": "Refund request processed"
    }


# ============ Payment Info Routes ============

@router.get("/billing-info")
def get_billing_info(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's billing information"""
    
    subscription = payment_service.get_user_subscription(db, current_user.id)
    
    return {
        "status": "success",
        "billing": {
            "email": current_user.email,
            "current_plan": subscription.plan if subscription else "free",
            "plan_status": subscription.status if subscription else "inactive",
            "next_billing_date": subscription.renews_at.isoformat() if subscription and subscription.renews_at else None,
            "stripe_customer_id": current_user.stripe_customer_id
        }
    }


@router.post("/validate-plan")
def validate_plan(
    plan: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Validate if plan exists and get details"""
    
    if plan not in PaymentService.PLANS:
        raise HTTPException(status_code=404, detail="Plan not found")
    
    features = payment_service.get_subscription_features(plan)
    
    return {
        "status": "success",
        "valid": True,
        "plan": {
            "plan_id": plan,
            "name": features["name"],
            "price": features["price"],
            "features": features["features"]
        }
    }
