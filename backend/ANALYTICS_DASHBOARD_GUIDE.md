# AstroLuck Analytics Dashboard Guide

Complete guide for building an admin analytics dashboard to track user engagement, revenue, and platform metrics.

## Table of Contents

1. [Dashboard Overview](#dashboard-overview)
2. [Database Analytics Schema](#database-analytics-schema)
3. [Analytics Service](#analytics-service)
4. [API Endpoints](#api-endpoints)
5. [Frontend Implementation](#frontend-implementation)
6. [Real-Time Dashboards](#real-time-dashboards)
7. [Reports & Exports](#reports--exports)
8. [Data Visualization](#data-visualization)

---

## Dashboard Overview

### Key Metrics Overview
- **Total Users**: Active and inactive users
- **Revenue**: Subscription revenue, payment transactions
- **Engagement**: Daily active users, lottery plays, insights generated
- **User Lifetime Value**: Average revenue from each user
- **Churn Rate**: Users who cancelled subscriptions
- **Feature Adoption**: Usage of each premium feature

### Dashboard Sections

1. **Real-time Metrics** (Last 24 hours)
   - Active users currently on platform
   - Revenue generated today
   - Lottery plays today
   - New registrations today

2. **User Analytics**
   - User growth over time
   - User retention cohorts
   - Geographic distribution
   - Device/platform breakdown
   - Subscription plan distribution

3. **Revenue Analytics**
   - MRR (Monthly Recurring Revenue)
   - Annual Run Rate (ARR)
   - Subscription tiers breakdown
   - Payment method breakdown
   - Refund/churn analysis

4. **Feature Analytics**
   - Feature adoption rates
   - Daily insights generation
   - Badge unlocking trends
   - Consultation bookings
   - Pool/Challenge participation

5. **Engagement Analytics**
   - Daily/Weekly/Monthly Active Users
   - Session duration
   - Feature usage patterns
   - Lottery play frequency
   - Community shares volume

6. **System Health**
   - API response times
   - Error rates
   - Database query performance
   - Uptime percentage
   - Concurrent users

---

## Database Analytics Schema

### 1. Analytics Models

```python
# app/models/analytics.py

from sqlalchemy import Column, Integer, Float, String, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
from .base import Base

class DailyAnalytics(Base):
    """Daily snapshot of platform metrics"""
    __tablename__ = "daily_analytics"
    
    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.utcnow, unique=True)
    
    # User metrics
    total_users = Column(Integer, default=0)
    active_users_today = Column(Integer, default=0)
    active_users_week = Column(Integer, default=0)
    active_users_month = Column(Integer, default=0)
    new_users_today = Column(Integer, default=0)
    churned_users_today = Column(Integer, default=0)
    
    # Revenue metrics
    revenue_today = Column(Float, default=0.0)
    mrr = Column(Float, default=0.0)  # Monthly Recurring Revenue
    arr = Column(Float, default=0.0)  # Annual Run Rate
    subscription_count = Column(Integer, default=0)
    
    # Engagement metrics
    lottery_plays_today = Column(Integer, default=0)
    insights_generated_today = Column(Integer, default=0)
    badges_unlocked_today = Column(Integer, default=0)
    consultations_booked_today = Column(Integer, default=0)
    
    # Feature metrics
    pools_created_today = Column(Integer, default=0)
    challenges_created_today = Column(Integer, default=0)
    shares_created_today = Column(Integer, default=0)
    
    # System metrics
    api_avg_response_time = Column(Float, default=0.0)  # milliseconds
    error_rate = Column(Float, default=0.0)  # percentage
    uptime_percentage = Column(Float, default=100.0)

class UserCohort(Base):
    """Track user cohorts for retention analysis"""
    __tablename__ = "user_cohorts"
    
    id = Column(Integer, primary_key=True)
    cohort_date = Column(DateTime)  # Week/Month when user joined
    cohort_size = Column(Integer, default=0)
    
    # Retention by week/month
    retention_day_1 = Column(Float, default=0.0)
    retention_day_7 = Column(Float, default=0.0)
    retention_day_30 = Column(Float, default=0.0)
    retention_day_90 = Column(Float, default=0.0)

class FeatureAnalytics(Base):
    """Track feature usage"""
    __tablename__ = "feature_analytics"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    feature_name = Column(String(100))
    user_agent = Column(String(255))
    ip_address = Column(String(45))
    created_at = Column(DateTime, default=datetime.utcnow)
    
    user = relationship("User")

class RevenueMetric(Base):
    """Track revenue transactions"""
    __tablename__ = "revenue_metrics"
    
    id = Column(Integer, primary_key=True)
    date = Column(DateTime, default=datetime.utcnow)
    
    # Subscription revenue
    subscription_revenue = Column(Float, default=0.0)
    tier_free = Column(Integer, default=0)
    tier_premium = Column(Integer, default=0)
    tier_gold = Column(Integer, default=0)
    tier_platinum = Column(Integer, default=0)
    
    # Payment methods
    card_payments = Column(Float, default=0.0)
    wallet_payments = Column(Float, default=0.0)
    
    # Refunds and chargebacks
    refunds = Column(Float, default=0.0)
    chargebacks = Column(Float, default=0.0)
    
    # Retention metrics
    retained_subscriptions = Column(Integer, default=0)
    cancelled_subscriptions = Column(Integer, default=0)
```

### 2. Create Analytics Tables

```python
# migration_analytics.py

from sqlalchemy import create_engine
from app.models import DailyAnalytics, UserCohort, FeatureAnalytics, RevenueMetric, Base

def create_analytics_tables():
    """Create analytics schema"""
    engine = create_engine(DATABASE_URL)
    
    # Create tables
    Base.metadata.create_all(engine)
    
    # Create indexes for performance
    with engine.connect() as conn:
        indexes = """
        CREATE INDEX IF NOT EXISTS idx_daily_analytics_date 
            ON daily_analytics(date DESC);
        CREATE INDEX IF NOT EXISTS idx_feature_analytics_user_date 
            ON feature_analytics(user_id, created_at DESC);
        CREATE INDEX IF NOT EXISTS idx_revenue_metric_date 
            ON revenue_metrics(date DESC);
        CREATE INDEX IF NOT EXISTS idx_user_cohort_date 
            ON user_cohorts(cohort_date DESC);
        """
        for statement in indexes.split(';'):
            if statement.strip():
                conn.execute(statement)
        conn.commit()

if __name__ == '__main__':
    create_analytics_tables()
```

---

## Analytics Service

### 1. Analytics Service Implementation

```python
# app/services/analytics_service.py

from sqlalchemy.orm import Session
from sqlalchemy import func, and_, or_, desc
from datetime import datetime, timedelta
from app.models import (
    User, Subscription, LotteryHistory, DailyInsight, UserBadge,
    DailyAnalytics, UserCohort, FeatureAnalytics, RevenueMetric
)

class AnalyticsService:
    """Comprehensive analytics tracking and reporting"""
    
    @staticmethod
    def get_user_metrics(db: Session, days: int = 30) -> dict:
        """Get user growth and activity metrics"""
        
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Total users
        total_users = db.query(func.count(User.id)).scalar()
        
        # New users in period
        new_users = db.query(func.count(User.id)).filter(
            User.created_at >= start_date
        ).scalar()
        
        # Active users (played lottery in last 30 days)
        active_users = db.query(func.count(func.distinct(LotteryHistory.user_id)))\
            .filter(LotteryHistory.created_at >= start_date)\
            .scalar()
        
        # User retention cohort
        retention = AnalyticsService._calculate_retention(db)
        
        # Geographic distribution
        locations = db.query(
            User.birth_place,
            func.count(User.id).label('count')
        ).group_by(User.birth_place).all()
        
        return {
            'total_users': total_users,
            'new_users': new_users,
            'active_users': active_users,
            'retention': retention,
            'locations': [{'place': l[0], 'count': l[1]} for l in locations],
            'daily_growth': AnalyticsService._get_daily_growth(db, days)
        }
    
    @staticmethod
    def get_revenue_metrics(db: Session, days: int = 30) -> dict:
        """Get subscription and revenue metrics"""
        
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Get subscription data
        subscriptions = db.query(Subscription).filter(
            Subscription.created_at >= start_date
        ).all()
        
        # Calculate MRR
        active_subscriptions = db.query(Subscription).filter(
            Subscription.status == 'active'
        ).all()
        
        mrr = sum(sub.monthly_price for sub in active_subscriptions)
        arr = mrr * 12
        
        # Plan distribution
        tier_distribution = db.query(
            Subscription.tier,
            func.count(Subscription.id).label('count'),
            func.avg(Subscription.monthly_price).label('avg_price')
        ).filter(Subscription.status == 'active')\
         .group_by(Subscription.tier).all()
        
        # Churn rate
        churned = db.query(func.count(Subscription.id)).filter(
            and_(
                Subscription.status == 'cancelled',
                Subscription.cancelled_at >= start_date
            )
        ).scalar()
        
        churn_rate = (churned / len(active_subscriptions) * 100) if active_subscriptions else 0
        
        # Revenue by method
        revenue_methods = db.query(
            Subscription.payment_method,
            func.count(Subscription.id).label('count')
        ).filter(Subscription.status == 'active')\
         .group_by(Subscription.payment_method).all()
        
        return {
            'mrr': mrr,
            'arr': arr,
            'total_active_subscriptions': len(active_subscriptions),
            'churn_rate': churn_rate,
            'tier_distribution': [
                {
                    'tier': t[0],
                    'count': t[1],
                    'avg_price': t[2]
                } for t in tier_distribution
            ],
            'revenue_by_method': [
                {'method': m[0], 'count': m[1]} for m in revenue_methods
            ]
        }
    
    @staticmethod
    def get_engagement_metrics(db: Session, days: int = 30) -> dict:
        """Get feature engagement metrics"""
        
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=days)
        
        # Lottery plays
        lottery_plays = db.query(func.count(LotteryHistory.id)).filter(
            LotteryHistory.created_at >= start_date
        ).scalar()
        
        # Daily insights generated
        insights_generated = db.query(func.count(DailyInsight.id)).filter(
            DailyInsight.created_at >= start_date
        ).scalar()
        
        # Badges unlocked
        badges_unlocked = db.query(func.count(UserBadge.id)).filter(
            UserBadge.unlocked_at >= start_date
        ).scalar()
        
        # Feature adoption
        feature_usage = db.query(
            FeatureAnalytics.feature_name,
            func.count(FeatureAnalytics.id).label('usage_count'),
            func.count(func.distinct(FeatureAnalytics.user_id)).label('unique_users')
        ).filter(FeatureAnalytics.created_at >= start_date)\
         .group_by(FeatureAnalytics.feature_name).all()
        
        # DAU/WAU/MAU
        active_today = db.query(func.count(func.distinct(LotteryHistory.user_id))).filter(
            LotteryHistory.created_at >= end_date - timedelta(days=1)
        ).scalar()
        
        active_week = db.query(func.count(func.distinct(LotteryHistory.user_id))).filter(
            LotteryHistory.created_at >= end_date - timedelta(days=7)
        ).scalar()
        
        active_month = db.query(func.count(func.distinct(LotteryHistory.user_id))).filter(
            LotteryHistory.created_at >= end_date - timedelta(days=30)
        ).scalar()
        
        return {
            'lottery_plays': lottery_plays,
            'insights_generated': insights_generated,
            'badges_unlocked': badges_unlocked,
            'dau': active_today,
            'wau': active_week,
            'mau': active_month,
            'feature_adoption': [
                {
                    'feature': f[0],
                    'total_usage': f[1],
                    'unique_users': f[2]
                } for f in feature_usage
            ]
        }
    
    @staticmethod
    def _calculate_retention(db: Session) -> dict:
        """Calculate user retention cohorts"""
        
        # Get data for last 90 days
        retention_data = {}
        end_date = datetime.utcnow()
        
        for i in range(12):  # 12 weeks
            cohort_week = end_date - timedelta(weeks=i)
            cohort_start = cohort_week.replace(hour=0, minute=0, second=0, microsecond=0)
            cohort_end = cohort_start + timedelta(days=7)
            
            # Users created in this week
            cohort_users = db.query(func.count(User.id)).filter(
                and_(
                    User.created_at >= cohort_start,
                    User.created_at < cohort_end
                )
            ).scalar()
            
            if cohort_users > 0:
                # Check retention for each week after signup
                retention_data[f"week_{i}"] = {
                    'cohort_size': cohort_users,
                    'retention': {
                        'day_1': AnalyticsService._get_cohort_retention(
                            db, cohort_start, 1
                        ),
                        'day_7': AnalyticsService._get_cohort_retention(
                            db, cohort_start, 7
                        ),
                        'day_30': AnalyticsService._get_cohort_retention(
                            db, cohort_start, 30
                        ),
                    }
                }
        
        return retention_data
    
    @staticmethod
    def _get_daily_growth(db: Session, days: int) -> list:
        """Get daily user growth"""
        
        growth = []
        for i in range(days, 0, -1):
            date = datetime.utcnow().date() - timedelta(days=i)
            
            users_by_date = db.query(func.count(User.id)).filter(
                User.created_at <= datetime.combine(date, datetime.max.time())
            ).scalar()
            
            growth.append({
                'date': date.isoformat(),
                'total_users': users_by_date
            })
        
        return growth
    
    @staticmethod
    def _get_cohort_retention(db: Session, cohort_start: datetime, days: int) -> float:
        """Calculate cohort retention percentage"""
        
        cohort_end = cohort_start + timedelta(days=7)
        
        # Users in cohort
        cohort_users = db.query(User.id).filter(
            and_(
                User.created_at >= cohort_start,
                User.created_at < cohort_end
            )
        ).all()
        
        if not cohort_users:
            return 0.0
        
        cohort_user_ids = [u[0] for u in cohort_users]
        
        # Check if they played lottery within N days
        active_after = db.query(func.count(func.distinct(LotteryHistory.user_id))).filter(
            and_(
                LotteryHistory.user_id.in_(cohort_user_ids),
                LotteryHistory.created_at >= cohort_start,
                LotteryHistory.created_at <= cohort_start + timedelta(days=days)
            )
        ).scalar()
        
        return (active_after / len(cohort_users)) * 100
    
    @staticmethod
    def record_feature_usage(db: Session, user_id: int, feature_name: str, 
                           user_agent: str, ip_address: str):
        """Record feature usage for analytics"""
        
        feature_log = FeatureAnalytics(
            user_id=user_id,
            feature_name=feature_name,
            user_agent=user_agent,
            ip_address=ip_address
        )
        
        db.add(feature_log)
        db.commit()
    
    @staticmethod
    def generate_daily_snapshot(db: Session):
        """Generate daily analytics snapshot"""
        
        # Get all metrics
        user_metrics = AnalyticsService.get_user_metrics(db, days=1)
        revenue_metrics = AnalyticsService.get_revenue_metrics(db, days=1)
        engagement_metrics = AnalyticsService.get_engagement_metrics(db, days=1)
        
        # Create daily record
        daily = DailyAnalytics(
            total_users=user_metrics['total_users'],
            active_users_today=user_metrics['active_users'],
            new_users_today=user_metrics['new_users'],
            mrr=revenue_metrics['mrr'],
            arr=revenue_metrics['arr'],
            subscription_count=revenue_metrics['total_active_subscriptions'],
            lottery_plays_today=engagement_metrics['lottery_plays'],
            insights_generated_today=engagement_metrics['insights_generated'],
            badges_unlocked_today=engagement_metrics['badges_unlocked']
        )
        
        db.add(daily)
        db.commit()
        
        return daily
```

---

## API Endpoints

### 1. Analytics Routes

```python
# app/api/routes/analytics.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.services.analytics_service import AnalyticsService
from app.core.security import verify_admin_token
from app.database import get_db

router = APIRouter(prefix="/api/v1/analytics", tags=["analytics"])

@router.get("/overview")
async def get_analytics_overview(
    days: int = 30,
    db: Session = Depends(get_db),
    admin = Depends(verify_admin_token)
):
    """Get overall platform analytics"""
    
    try:
        user_metrics = AnalyticsService.get_user_metrics(db, days)
        revenue_metrics = AnalyticsService.get_revenue_metrics(db, days)
        engagement_metrics = AnalyticsService.get_engagement_metrics(db, days)
        
        return {
            'period_days': days,
            'users': user_metrics,
            'revenue': revenue_metrics,
            'engagement': engagement_metrics,
            'generated_at': datetime.utcnow().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/users")
async def get_user_analytics(
    days: int = 30,
    db: Session = Depends(get_db),
    admin = Depends(verify_admin_token)
):
    """Get detailed user analytics"""
    return AnalyticsService.get_user_metrics(db, days)

@router.get("/revenue")
async def get_revenue_analytics(
    days: int = 30,
    db: Session = Depends(get_db),
    admin = Depends(verify_admin_token)
):
    """Get detailed revenue analytics"""
    return AnalyticsService.get_revenue_metrics(db, days)

@router.get("/engagement")
async def get_engagement_analytics(
    days: int = 30,
    db: Session = Depends(get_db),
    admin = Depends(verify_admin_token)
):
    """Get detailed engagement analytics"""
    return AnalyticsService.get_engagement_analytics(db, days)

@router.post("/daily-snapshot")
async def create_daily_snapshot(
    db: Session = Depends(get_db),
    admin = Depends(verify_admin_token)
):
    """Create daily analytics snapshot"""
    return AnalyticsService.generate_daily_snapshot(db)

@router.get("/daily-history")
async def get_daily_history(
    days: int = 30,
    db: Session = Depends(get_db),
    admin = Depends(verify_admin_token)
):
    """Get daily analytics history"""
    
    end_date = datetime.utcnow()
    start_date = end_date - timedelta(days=days)
    
    history = db.query(DailyAnalytics).filter(
        DailyAnalytics.date.between(start_date, end_date)
    ).order_by(desc(DailyAnalytics.date)).all()
    
    return {
        'data': [
            {
                'date': h.date.isoformat(),
                'active_users': h.active_users_today,
                'revenue': h.mrr,
                'engagement': h.lottery_plays_today
            } for h in history
        ]
    }
```

---

## Frontend Implementation

### 1. Flutter Analytics Dashboard UI

```dart
// lib/features/admin/screens/analytics_dashboard.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/services/api_client.dart';

class AnalyticsDashboard extends StatefulWidget {
  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  final ApiClient _api = ApiClient();
  late Future<Map<String, dynamic>> _analyticsFuture;
  
  @override
  void initState() {
    super.initState();
    _analyticsFuture = _api.getAnalyticsOverview();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analytics Dashboard')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final data = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildMetricsCards(data),
                _buildUserGrowthChart(data),
                _buildRevenueChart(data),
                _buildEngagementChart(data),
                _buildFeatureAdoptionChart(data),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildMetricsCards(Map<String, dynamic> data) {
    final users = data['users'] as Map;
    final revenue = data['revenue'] as Map;
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Grid...
    );
  }
  
  // Chart methods...
}
```

---

## Real-Time Dashboards

### 1. WebSocket Real-Time Updates

```python
# app/api/websocket.py

from fastapi import WebSocket, WebSocketDisconnect
from app.services.analytics_service import AnalyticsService
from app.database import SessionLocal
import asyncio
import json

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []
    
    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
    
    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)
    
    async def broadcast(self, message: dict):
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except:
                pass

manager = ConnectionManager()

@app.websocket("/ws/analytics")
async def websocket_analytics(websocket: WebSocket):
    await manager.connect(websocket)
    
    db = SessionLocal()
    
    try:
        while True:
            # Send real-time metrics every 10 seconds
            metrics = {
                'engagement': AnalyticsService.get_engagement_metrics(db, days=1),
                'timestamp': datetime.utcnow().isoformat()
            }
            
            await manager.broadcast(metrics)
            await asyncio.sleep(10)
    except WebSocketDisconnect:
        manager.disconnect(websocket)
```

---

## Reports & Exports

### 1. Generate PDF Report

```python
# app/services/report_service.py

from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
from io import BytesIO
from datetime import datetime

class ReportService:
    @staticmethod
    def generate_monthly_report(db: Session, month: int, year: int) -> bytes:
        """Generate PDF report for specified month"""
        
        # Get analytics data
        user_metrics = AnalyticsService.get_user_metrics(db, days=30)
        revenue_metrics = AnalyticsService.get_revenue_metrics(db, days=30)
        engagement_metrics = AnalyticsService.get_engagement_metrics(db, days=30)
        
        # Create PDF
        buffer = BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter)
        elements = []
        
        # Title
        styles = getSampleStyleSheet()
        title = Paragraph(f"AstroLuck Monthly Report - {month}/{year}", styles['Title'])
        elements.append(title)
        elements.append(Spacer(1, 0.5*inch))
        
        # User Metrics Table
        user_data = [
            ['Metric', 'Value'],
            ['Total Users', str(user_metrics['total_users'])],
            ['New Users', str(user_metrics['new_users'])],
            ['Active Users', str(user_metrics['active_users'])],
        ]
        
        user_table = Table(user_data)
        user_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 14),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('GRID', (0, 0), (-1, -1), 1, colors.black)
        ]))
        
        elements.append(user_table)
        
        # Build PDF
        doc.build(elements)
        buffer.seek(0)
        return buffer.getvalue()
```

---

## Data Visualization

### 1. Chart Components Library

```dart
// lib/features/admin/widgets/analytics_charts.dart

class UserGrowthChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  
  const UserGrowthChart({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: _buildSpots(),
            isCurved: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
  
  List<FlSpot> _buildSpots() {
    return data.asMap().entries.map((e) {
      return FlSpot(
        e.key.toDouble(),
        (e.value['total_users'] as num).toDouble(),
      );
    }).toList();
  }
}

class RevenueChart extends StatelessWidget {
  final Map<String, dynamic> revenue;
  
  const RevenueChart({required this.revenue});
  
  @override
  Widget build(BuildContext context) {
    final tiers = revenue['tier_distribution'] as List;
    
    return PieChart(
      PieChartData(
        sections: tiers.map((t) {
          return PieChartSectionData(
            value: (t['count'] as num).toDouble(),
            title: t['tier'],
          );
        }).toList(),
      ),
    );
  }
}
```

---

## Scheduled Analytics

### 1. APScheduler Integration

```python
# app/services/scheduled_tasks.py

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from app.services.analytics_service import AnalyticsService
from app.database import SessionLocal

scheduler = BackgroundScheduler()

def daily_snapshot():
    """Generate daily analytics snapshot"""
    db = SessionLocal()
    try:
        AnalyticsService.generate_daily_snapshot(db)
        print("✓ Daily snapshot generated")
    finally:
        db.close()

def hourly_metrics():
    """Update hourly metrics"""
    db = SessionLocal()
    try:
        metrics = AnalyticsService.get_engagement_metrics(db, days=1)
        # Broadcast to WebSocket clients
        print(f"✓ Hourly metrics: {metrics['lottery_plays']}")
    finally:
        db.close()

def setup_scheduled_tasks():
    """Setup scheduled analytics tasks"""
    
    # Daily snapshot at 2 AM UTC
    scheduler.add_job(
        daily_snapshot,
        CronTrigger(hour=2, minute=0),
        id='daily_snapshot'
    )
    
    # Hourly metrics
    scheduler.add_job(
        hourly_metrics,
        CronTrigger(minute=0),
        id='hourly_metrics'
    )
    
    scheduler.start()
```

---

## Analytics Best Practices

1. **Data Collection**
   - Collect all user interactions
   - Track feature usage at every step
   - Log API performance metrics
   - Monitor system resource usage

2. **Data Storage**
   - Use separate analytics database
   - Implement data retention policies
   - Archive old data monthly
   - Use indexes for query performance

3. **Reporting**
   - Generate daily snapshots
   - Create weekly summary reports
   - Monthly detailed reports
   - Custom dashboards for different stakeholders

4. **Privacy**
   - Hash IP addresses
   - Anonymize user identifiers
   - Comply with GDPR/CCPA
   - Secure analytics API endpoints

5. **Performance**
   - Cache frequently accessed metrics
   - Use read replicas for analytics queries
   - Implement data aggregation
   - Monitor query performance

---

**Last Updated:** 2024-01-15
**Version:** 1.0
