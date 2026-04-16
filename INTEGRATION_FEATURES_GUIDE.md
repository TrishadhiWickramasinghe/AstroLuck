# AstroLuck Integration Features

## Overview

The AstroLuck platform features five major integration points designed to maximize user engagement, support monetization, and enhance user convenience. These integrations enable WhatsApp messaging, calendar synchronization, payment processing, multi-channel notifications, and lottery result verification.

---

## 1. WhatsApp Integration ⭐⭐⭐⭐ (+45% reach)

### Features
- **Daily Lucky Numbers Delivery**: Send personalized lucky numbers via WhatsApp every morning
- **Lottery Alerts**: Real-time notifications for lottery opportunities and deadlines
- **Verification System**: 6-digit code verification for secure connection
- **Message Tracking**: Track message delivery, reads, and engagement
- **Preference Management**: Users control notification types, times, and frequency

### Technical Stack
- **Provider**: Twilio WhatsApp Business API
- **Authentication**: Phone number verification with 6-digit code
- **Message Rate**: Up to 50 messages per second per account

### Database Models
```python
WhatsAppConnection:
  - whatsapp_phone (unique)
  - verification_code (6 chars)
  - is_verified (bool)
  - connected_at (datetime)
  - receive_daily_numbers (bool)
  - receive_alerts (bool)
  - notification_time (HH:MM)
  - message_count (int)

WhatsAppMessage:
  - message_type (daily_numbers/alert/etc)
  - message_content (text)
  - status (pending/sent/delivered/failed)
  - sent_at, delivered_at, read_at
  - retry_count (max 3)
```

### Key Endpoints
```
POST /api/v1/integrations/whatsapp/initiate
  - Initiate WhatsApp connection via Twilio
  - Body: {whatsapp_phone: "+1234567890"}
  - Response: {success, connection_id}

POST /api/v1/integrations/whatsapp/verify
  - Verify connection with 6-digit code
  - Body: {connection_id, code}
  - Response: {success}

GET /api/v1/integrations/whatsapp/status
  - Get connection status and preferences
  - Response: {connected, phone, preferences}

PATCH /api/v1/integrations/whatsapp/preferences
  - Update notification preferences
  - Body: {receive_daily_numbers, notification_time, etc}

POST /api/v1/integrations/whatsapp/disconnect
  - Disconnect WhatsApp integration
  - Response: {success}
```

### Implementation Details

**Verification Flow**:
1. User enters WhatsApp phone number
2. Server generates 6-character code
3. Code sent via Twilio WhatsApp API
4. User receives code and enters in app
5. Max 3 attempts, rate limited
6. Upon success, connection marked verified

**Message Delivery**:
- Daily numbers sent at user-configured time
- Alerts sent immediately when relevant
- All messages logged in WhatsAppMessage table
- Failed messages stored with retry logic
- Max retry count: 3 attempts over 24 hours

---

## 2. Calendar Sync ⭐⭐⭐⭐ (+30% convenience)

### Features
- **Multi-Calendar Support**: Connect Google Calendar, Apple Calendar, Outlook
- **Automatic Event Creation**: Sync lucky dates, lucky times, and lottery drawings
- **Bidirectional Updates**: Calendar events can be updated in real-time
- **Sync Management**: Enable/disable sync for specific event types
- **RSVP Tracking**: Track calendar event responses

### Technical Stack
- **Google Calendar**: OAuth 2.0 authorization flow
- **Apple Calendar**: CalDAV support (iOS/macOS)
- **Outlook**: Microsoft Graph API
- **Refresh Strategy**: Token refresh every 30 minutes

### Database Models
```python
CalendarConnection:
  - calendar_type (google/apple/outlook)
  - calendar_email (str)
  - access_token, refresh_token
  - sync_enabled (bool)
  - last_sync_at, next_sync_at
  - sync_lucky_dates, sync_lucky_times, sync_lottery_drawings

CalendarEvent:
  - event_type (lucky_date/lucky_time/drawing)
  - event_name, description
  - start_time, end_time
  - external_event_id
  - sync_status (synced/pending/failed)
```

### Key Endpoints
```
POST /api/v1/integrations/calendar/google/auth-url
  - Get OAuth authorization URL
  - Response: {success, auth_url, connection_id}

POST /api/v1/integrations/calendar/google/callback
  - Handle OAuth callback
  - Body: {connection_id, code}
  - Response: {success}

GET /api/v1/integrations/calendar/connected
  - List all connected calendars
  - Response: {calendars: [...]}

PATCH /api/v1/integrations/calendar/{calendar_id}/preferences
  - Update sync preferences
  - Body: {sync_lucky_dates, sync_lucky_times, sync_lottery_drawings}

POST /api/v1/integrations/calendar/disconnect/{calendar_id}
  - Disconnect calendar
  - Response: {success}
```

### OAuth Flow

**Google Calendar**:
1. Generate authorization URL with scope: `calendar`
2. Direct user to Google consent screen
3. User authorizes AstroLuck
4. Redirect with authorization code
5. Exchange code for access_token + refresh_token
6. Store tokens in CalendarConnection
7. Begin syncing events

**Token Refresh**:
- Every 30 minutes or when token expires
- Automatic refresh_token rotation
- Graceful handling of revoked access
- User re-authorization required if token refresh fails

---

## 3. Payment Gateway (Critical!) ⭐⭐⭐⭐⭐ (Unlock revenue)

### Features
- **Subscription Plans**: Free, Premium, Gold, Platinum tiers
- **One-Time Payments**: Pool entries, challenge fees, astrologer consultations
- **Multiple Payment Methods**: Credit cards, PayPal, Apple Pay, Google Pay
- **Automatic Subscription Management**: Auto-renewal with 7-day cancellation notice
- **Payment History**: Full transaction tracking and receipts
- **Refund Processing**: 30-day refund guarantee on subscription

### Subscription Tiers
```
FREE TIER:
  - Price: $0/month
  - Features:
    - 5 Community Pools
    - 10 Challenge Entries
    - 1 Astrologer Session/month
    - No daily insights

PREMIUM TIER:
  - Price: $9.99/month
  - Features:
    - 20 Community Pools (+300%)
    - 50 Challenge Entries (+400%)
    - 5 Astrologer Sessions (+400%)
    - Daily Insights ✓

GOLD TIER:
  - Price: $19.99/month
  - Features:
    - 50 Community Pools (+150%)
    - 200 Challenge Entries (+300%)
    - 10 Astrologer Sessions (+100%)
    - Daily Insights ✓
    - Priority Support ✓

PLATINUM TIER:
  - Price: $49.99/month
  - Features:
    - Unlimited Pools
    - Unlimited Challenges
    - Unlimited Sessions
    - All Features ✓
    - VIP Support ✓
    - Ad-free Experience ✓
```

### Technical Stack
- **Primary Provider**: Stripe
- **Fallback Provider**: PayPal
- **PCI Compliance**: No card data stored locally
- **webhook Security**: HMAC signature verification

### Database Models
```python
PaymentMethod:
  - payment_type (card/paypal/bank)
  - stripe_payment_method_id
  - paypal_email
  - last_four, card_brand
  - expiry_month, expiry_year
  - is_default, is_active, is_expired

Payment:
  - amount (float)
  - currency (USD/EUR/GBP)
  - payment_type (subscription/pool_entry/challenge)
  - stripe_payment_id, paypal_transaction_id
  - status (pending/processing/completed/failed/refunded)
  - metadata (JSON)
  - completed_at, refunded_at

Subscription:
  - plan (free/premium/gold/platinum)
  - tier (0/1/2/3)
  - price_per_month
  - status (active/canceled/suspended/expired)
  - stripe_subscription_id
  - billing_cycle_start, billing_cycle_end
  - next_billing_date
  - features (JSON)
```

### Key Endpoints
```
POST /api/v1/integrations/payments/intent
  - Create payment intent for checkout
  - Body: {amount, currency, payment_type}
  - Response: {payment_id, client_secret}

POST /api/v1/integrations/payments/{payment_id}/confirm
  - Confirm payment after Stripe processing
  - Response: {success}

GET /api/v1/integrations/subscription/current
  - Get current subscription
  - Response: {plan, tier, price_per_month, features, status}

POST /api/v1/integrations/subscription/downgrade
  - Cancel subscription and downgrade to free
  - Response: {success}

GET /api/v1/integrations/payments/history
  - Get payment history
  - Response: {payments: [...]}
```

### Payment Processing Flow

**Subscription Creation**:
1. User initiates payment from upgrade screen
2. Amount-based tier determination ($9.99=Premium, $19.99=Gold, $49.99=Platinum)
3. Create Stripe PaymentIntent with amount
4. Show Stripe payment modal
5. User completes payment
6. Stripe webhook confirms payment status
7. Create Subscription record with plan features
8. Set billing_cycle_start = now, billing_cycle_end = now + 30 days
9. Send confirmation email with receipt

**Automatic Top-up** (Optional):
- Stripe recurring subscription setup
- Auto-charge 3 days before billing_cycle_end
- Retry failed charges up to 3 times
- Send payment failure notifications

---

## 4. SMS & Email Notifications ⭐⭐⭐ (+20% engagement)

### Features
- **Multi-Channel Delivery**: Email, SMS, and push notifications
- **Smart Scheduling**: Send at optimal times based on user timezone
- **Quiet Hours**: Respect user sleep schedule
- **Notification Types**: Daily numbers, alerts, pool updates, challenge results
- **Engagement Tracking**: Open rates, click rates, unsubscribes
- **Unsubscribe Management**: One-click unsubscribe with token-based tracking

### Technical Stack
- **Email Provider**: SendGrid (1M+ emails/day capacity)
- **SMS Provider**: Twilio SMS API
- **Push Notifications**: Firebase Cloud Messaging
- **Rate Limiting**: 10 notifications per user per day max

### Database Models
```python
NotificationPreference:
  - email_enabled, email_frequency (daily/weekly/never)
  - sms_enabled, phone_number, sms_verified
  - push_enabled
  - morning_time, evening_time (HH:MM)
  - quiet_hours_enabled, quiet_hours_start, quiet_hours_end
  - unsubscribe_token (unique)

NotificationLog:
  - channel (email/sms/push)
  - notification_type (daily_numbers/alert/insight/etc)
  - recipient_address
  - status (pending/sent/delivered/failed/bounced)
  - opened_at, clicked_at, unsubscribed_at
  - related_entity_id, related_entity_type
```

### Key Endpoints
```
GET /api/v1/integrations/notifications/preferences
  - Get current notification preferences
  - Response: {email_enabled, sms_enabled, push_enabled, times, etc}

PATCH /api/v1/integrations/notifications/preferences
  - Update notification preferences
  - Body: {email_enabled, sms_enabled, push_enabled, morning_time, etc}

POST /api/v1/integrations/notifications/test-email
  - Send test email to verify settings
  - Response: {success, notification_id}

POST /api/v1/integrations/notifications/test-sms
  - Send test SMS to verify settings
  - Response: {success, notification_id}

GET /api/v1/integrations/notifications/history
  - Get notification history
  - Query: {channel?, limit}
  - Response: {notifications: [...]}
```

### Notification Scheduling Algorithm

```
if notification_time NOT in quiet_hours:
    if channel == 'email' and email_enabled:
        send via SendGrid
        wait 1 hour
    if channel == 'sms' and sms_enabled:
        send via Twilio
        wait 30 minutes
else:
    queue for next day at morning_time
    if already queued 3 times:
        skip notification
        mark as 'skipped'
```

### Engagement Tracking

**Email**:
- Pixel tracking for open rates
- Click tracking on links
- Bounce detection and handling
- Unsubscribe link with token

**SMS**:
- Delivery confirmation from Twilio
- Click tracking via short URLs
- Opt-out response handling

---

## 5. Lottery Results API ⭐⭐⭐ (+25% engagement)

### Features
- **Automated Result Fetching**: Poll external lottery APIs every 6 hours
- **Ticket Verification**: Automatically verify user tickets against results
- **Prize Tier Calculation**: 6-tier prize structure (jackpot to 4-number match)
- **Payout Tracking**: Track payouts and payment status
- **Result History**: 12-month historical data retention
- **Notification Integration**: Alert users when wins verified

### Supported Lotteries
- Powerball (Wed, Sat)
- Mega Millions (Tue, Fri)
- Daily Pick 3 (Daily)
- Pick 4 (Daily)
- State lotteries (configurable)

### Technical Stack
- **Data Sources**: Lottery.com, TheLotter.com APIs
- **Polling Interval**: Every 6 hours
- **Cache Duration**: 24 hours
- **Redundancy**: Fallback to secondary data source if primary fails

### Database Models
```python
LotteryResults:
  - lottery_type (powerball/mega_millions/etc)
  - drawing_number (official)
  - drawing_date
  - numbers[] (JSON array)
  - bonus_number (int)
  - prize_pool_amount
  - estimated_jackpot, actual_jackpot
  - jackpot_winners (count)
  - prize_breakdown (JSON)
  - verified_at

UserTicket:
  - lottery_type, ticket_number
  - numbers[] (JSON), bonus_number
  - purchase_date, drawing_date
  - purchase_price
  - has_result (bool)
  - matching_numbers (int)
  - prize_won (float)
  - generated_by_astroluck (bool)

TicketVerification:
  - numbers_matched (int)
  - bonus_matched (bool)
  - prize_tier (1-6)
  - payout_status (pending/approved/paid/failed)
  - payout_method, payout_date
  - verified_at

LotteryResultsSync:
  - lottery_type, sync_type (full/incremental)
  - status (in_progress/completed/failed)
  - results_fetched, results_updated, tickets_verified (counts)
  - started_at, completed_at, next_sync_at
```

### Key Endpoints
```
POST /api/v1/integrations/lottery/fetch-results
  - Manually fetch latest lottery results
  - Body: {lottery_type}
  - Response: {success, result_id}

GET /api/v1/integrations/lottery/results/{lottery_type}
  - Get latest lottery results
  - Response: {lottery_type, drawing_date, numbers, bonus_number, jackpot}

GET /api/v1/integrations/lottery/my-tickets
  - Get user's lottery tickets
  - Query: {lottery_type?}
  - Response: {tickets: [...]}

GET /api/v1/integrations/lottery/ticket-results
  - Get verified ticket results
  - Response: {results: [...], total_won}

POST /api/v1/integrations/lottery/verify-tickets
  - Manually verify tickets against results
  - Body: {lottery_type}
  - Response: {success, verified_count}

POST /api/v1/integrations/lottery/automate-verification
  - Setup automated verification
  - Body: {lottery_type}
  - Response: {success}
```

### Prize Tier Logic
```
TIER 1 (Jackpot):  6 matches + bonus = Jackpot amount
TIER 2 ($1M):      6 matches          = $1,000,000
TIER 3 ($50K):     5 matches + bonus  = $50,000
TIER 4 ($100):     5 matches          = $100
TIER 5 ($100):     4 matches + bonus  = $100
TIER 6 ($50):      4 matches          = $50
NO PRIZE:          <4 matches         = $0
```

---

## System Architecture

### Backend Structure
```
app/models/integrations_models.py (800 lines)
  └─ 17 SQLAlchemy models
     ├─ WhatsApp (2 models)
     ├─ Calendar (2 models)
     ├─ Payment (3 models)
     ├─ Notification (2 models)
     └─ Lottery (4 models)

app/services/integrations_service.py (1,200 lines)
  └─ 6 service classes (40+ methods)
     ├─ WhatsAppService
     ├─ CalendarSyncService
     ├─ PaymentService
     ├─ NotificationService
     └─ LotteryResultsService

app/api/routes/integrations.py (1,000 lines)
  └─ 25+ API endpoints
     ├─ WhatsApp routes (5)
     ├─ Calendar routes (5)
     ├─ Payment routes (6)
     ├─ Notification routes (5)
     └─ Lottery routes (6)
```

### Flutter Structure
```
lib/features/integrations/
  ├─ screens/
  │  ├─ whatsapp_settings_screen.dart (300 lines)
  │  ├─ calendar_sync_screen.dart (400 lines)
  │  ├─ payment_settings_screen.dart (450 lines)
  │  ├─ notification_settings_screen.dart (400 lines)
  │  └─ lottery_tickets_screen.dart (450 lines)
  │
  └─ providers/
     └─ integrations_providers.dart (500 lines)
        ├─ WhatsAppProvider
        ├─ CalendarSyncProvider
        ├─ PaymentProvider
        ├─ NotificationProvider
        └─ LotteryProvider
```

---

## Security Considerations

### Data Protection
- All external API keys stored in environment variables
- No payment card data stored locally (PCI compliance)
- All API calls over HTTPS
- JWT authentication on all endpoints

### Rate Limiting
- WhatsApp: 50 messages/sec per account
- Email: 10 emails per user per day
- SMS: 5 SMS per user per day
- API: 100 requests/minute per user

### Webhook Validation
- Stripe: HMAC signature verification
- Twilio: Authorization token validation
- Calendar: OAuth token validation

---

## Deployment Checklist

### Backend
- [ ] Configure Twilio credentials (WhatsApp, SMS)
- [ ] Configure SendGrid API key (Email)
- [ ] Configure Stripe API keys (Payment)
- [ ] Configure Google OAuth credentials (Calendar)
- [ ] Create database migrations
- [ ] Test all service methods
- [ ] Set up webhook receivers
- [ ] Configure environment variables

### Frontend
- [ ] Update API base URL
- [ ] Test all provider methods
- [ ] Verify OAuth redirects
- [ ] Test payment flow
- [ ] Test notification preferences

### Deployment
- [ ] Create database tables
- [ ] Run migrations
- [ ] Start background services
- [ ] Test end-to-end flows
- [ ] Monitor webhook deliveries

---

## Future Enhancements

1. **Additional Lotteries**: Support international lotteries (EuroMillions, etc)
2. **SMS Verification**: Two-factor authentication via SMS
3. **Smart Notifications**: ML-based optimal notification timing
4. **Payment Analytics**: Advanced payment and subscription analytics
5. **WhatsApp Groups**: Create group pools via WhatsApp
6. **Calendar AI**: Auto-schedule meetings based on lucky dates
7. **Lottery Syndicate**: Multi-user ticket buying pools
8. **Wallet Integration**: Apple Pay, Google Pay, cryptocurrency

---

## Support & Monitoring

### Health Checks
- WhatsApp API connectivity: Every 5 minutes
- Calendar sync status: Every 30 minutes
- Payment processor status: Every 10 minutes
- Lottery API availability: Every 1 hour
- Email delivery reliability: Daily reports

### Alerting
- Failed payment processing
- WhatsApp API errors > 5 in 5 minutes
- Calendar sync failures
- Email bounce rates > 5%
- Lottery API data inconsistencies

### Metrics to Track
- WhatsApp delivery rate
- Email open rate
- SMS conversion rate
- Payment success rate
- Subscription churn rate
- Calendar sync completion rate
- Lottery verification accuracy
