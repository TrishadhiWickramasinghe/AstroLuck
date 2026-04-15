"""Service for managing payments and subscriptions"""
import os
from typing import Optional, Dict
from sqlalchemy.orm import Session
from app.models.models import Subscription, User
import uuid
from datetime import datetime, timedelta

try:
    import stripe
    STRIPE_AVAILABLE = True
except ImportError:
    STRIPE_AVAILABLE = False


class PaymentService:
    """Handle Stripe payments and subscription management"""
    
    # Subscription plans
    PLANS = {
        "free": {
            "name": "Free",
            "price": 0,
            "features": ["Basic lottery generation", "Community sharing", "Limited insights"]
        },
        "premium": {
            "name": "Premium",
            "price": 4.99,
            "features": ["Daily lucky numbers", "Full astrology insights", "No ads", "Advanced analytics"]
        },
        "gold": {
            "name": "Gold",
            "price": 9.99,
            "features": ["Premium features", "Astrologer consultations", "Lottery pools", "24/7 support"]
        },
        "platinum": {
            "name": "Platinum",
            "price": 19.99,
            "features": ["All features", "Priority support", "VIP events", "Exclusive astrologers"]
        }
    }
    
    def __init__(self):
        """Initialize Stripe"""
        if STRIPE_AVAILABLE:
            stripe_key = os.getenv("STRIPE_SECRET_KEY")
            if stripe_key:
                stripe.api_key = stripe_key
    
    def create_subscription(
        self,
        db: Session,
        user_id: str,
        plan: str,
        payment_method_id: str
    ) -> Optional[Subscription]:
        """Create new subscription for user"""
        
        if plan not in self.PLANS or not STRIPE_AVAILABLE:
            return None
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            return None
        
        try:
            # Create or get Stripe customer
            if not user.stripe_customer_id:
                customer = stripe.Customer.create(
                    email=user.email,
                    name=user.full_name or user.username
                )
                user.stripe_customer_id = customer.id
                db.commit()
            
            plan_price = self.PLANS[plan]["price"]
            
            if plan_price == 0:
                # Free plan - no payment needed
                subscription = Subscription(
                    id=str(uuid.uuid4()),
                    user_id=user_id,
                    plan=plan,
                    status="active",
                    amount=0,
                    renews_at=None
                )
            else:
                # Create Stripe subscription
                stripe_subscription = stripe.Subscription.create(
                    customer=user.stripe_customer_id,
                    items=[{"price_data": {
                        "currency": "usd",
                        "unit_amount": int(plan_price * 100),
                        "recurring": {"interval": "month"},
                        "product_data": {
                            "name": self.PLANS[plan]["name"],
                            "description": ", ".join(self.PLANS[plan]["features"])
                        }
                    }}],
                    payment_method=payment_method_id,
                    off_session=True
                )
                
                # Create subscription record
                subscription = Subscription(
                    id=str(uuid.uuid4()),
                    user_id=user_id,
                    plan=plan,
                    status="active",
                    stripe_subscription_id=stripe_subscription.id,
                    amount=plan_price,
                    renews_at=datetime.fromtimestamp(
                        stripe_subscription.current_period_end
                    )
                )
            
            db.add(subscription)
            db.commit()
            db.refresh(subscription)
            
            return subscription
        except Exception as e:
            print(f"Subscription creation failed: {e}")
            return None
    
    def upgrade_plan(
        self,
        db: Session,
        user_id: str,
        new_plan: str
    ) -> Optional[Subscription]:
        """Upgrade user to new plan"""
        
        if new_plan not in self.PLANS:
            return None
        
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            return None
        
        current_subscription = db.query(Subscription).filter(
            Subscription.user_id == user_id
        ).first()
        
        if not current_subscription:
            # Create new subscription
            return self.create_subscription(db, user_id, new_plan, None)
        
        # Cancel old subscription if it exists
        if current_subscription.stripe_subscription_id:
            try:
                stripe.Subscription.delete(
                    current_subscription.stripe_subscription_id
                )
            except Exception as e:
                print(f"Failed to cancel old subscription: {e}")
        
        # Update subscription
        current_subscription.plan = new_plan
        current_subscription.amount = self.PLANS[new_plan]["price"]
        current_subscription.updated_at = datetime.now()
        
        db.commit()
        db.refresh(current_subscription)
        
        return current_subscription
    
    def cancel_subscription(
        self,
        db: Session,
        user_id: str
    ) -> bool:
        """Cancel user subscription"""
        
        subscription = db.query(Subscription).filter(
            Subscription.user_id == user_id
        ).first()
        
        if not subscription:
            return False
        
        try:
            if subscription.stripe_subscription_id:
                stripe.Subscription.delete(
                    subscription.stripe_subscription_id
                )
            
            subscription.status = "cancelled"
            subscription.updated_at = datetime.now()
            db.commit()
            
            return True
        except Exception as e:
            print(f"Subscription cancellation failed: {e}")
            return False
    
    def get_user_subscription(
        self,
        db: Session,
        user_id: str
    ) -> Optional[Subscription]:
        """Get user's active subscription"""
        
        subscription = db.query(Subscription).filter(
            Subscription.user_id == user_id,
            Subscription.status == "active"
        ).first()
        
        return subscription
    
    def check_subscription_expired(
        self,
        db: Session,
        user_id: str
    ) -> bool:
        """Check if subscription has expired"""
        
        subscription = db.query(Subscription).filter(
            Subscription.user_id == user_id
        ).first()
        
        if not subscription or subscription.status != "active":
            return True
        
        if subscription.renews_at and datetime.now() > subscription.renews_at:
            subscription.status = "expired"
            db.commit()
            return True
        
        return False
    
    def process_refund(
        self,
        db: Session,
        user_id: str,
        reason: str
    ) -> bool:
        """Process refund for subscription"""
        
        subscription = db.query(Subscription).filter(
            Subscription.user_id == user_id
        ).first()
        
        if not subscription or not subscription.stripe_subscription_id:
            return False
        
        try:
            # Find latest invoice and refund
            invoices = stripe.Invoice.list(
                subscription=subscription.stripe_subscription_id,
                limit=1
            )
            
            if invoices.data:
                invoice = invoices.data[0]
                if invoice.charge:
                    stripe.Refund.create(
                        charge=invoice.charge,
                        reason=reason
                    )
                    return True
            
            return False
        except Exception as e:
            print(f"Refund processing failed: {e}")
            return False
    
    def get_subscription_features(self, plan: str) -> Dict:
        """Get features for plan"""
        
        if plan not in self.PLANS:
            plan = "free"
        
        return self.PLANS[plan]
    
    def is_feature_available(
        self,
        db: Session,
        user_id: str,
        feature: str
    ) -> bool:
        """Check if feature is available for user"""
        
        subscription = self.get_user_subscription(db, user_id)
        
        # Define feature availability by plan
        feature_matrix = {
            "daily_lucky_numbers": ["premium", "gold", "platinum"],
            "full_astrology_insights": ["premium", "gold", "platinum"],
            "remove_ads": ["premium", "gold", "platinum"],
            "advanced_analytics": ["premium", "gold", "platinum"],
            "astrologer_consultations": ["gold", "platinum"],
            "lottery_pools": ["gold", "platinum"],
            "priority_support": ["platinum"],
            "vip_events": ["platinum"],
            "custom_reports": ["platinum"]
        }
        
        if not subscription:
            plan = "free"
        else:
            plan = subscription.plan
        
        available_plans = feature_matrix.get(feature, [])
        return plan in available_plans
