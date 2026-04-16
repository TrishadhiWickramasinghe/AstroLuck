# AstroLuck Integration API Reference

## Authentication

All endpoints require JWT authentication. Include the token in the Authorization header:

```
Authorization: Bearer {jwt_token}
```

---

## WhatsApp Integration Endpoints

### 1. Initiate WhatsApp Connection
**Endpoint**: `POST /api/v1/integrations/whatsapp/initiate`

**Description**: Initiate WhatsApp connection with phone number verification.

**Request**:
```json
{
  "whatsapp_phone": "+1 (234) 567-8900"
}
```

**Response (Success)**:
```json
{
  "success": true,
  "connection_id": "conn_abc123xyz",
  "message": "Verification code sent to WhatsApp"
}
```

**Response (Error)**:
```json
{
  "success": false,
  "error": "Invalid phone number format"
}
```

**Error Codes**:
- 400: Invalid phone number
- 429: Too many requests (rate limited)
- 500: Twilio API error

---

### 2. Verify WhatsApp Connection
**Endpoint**: `POST /api/v1/integrations/whatsapp/verify`

**Description**: Verify WhatsApp connection with 6-digit code.

**Request**:
```json
{
  "connection_id": "conn_abc123xyz",
  "code": "123456"
}
```

**Response (Success)**:
```json
{
  "success": true,
  "message": "WhatsApp connection verified successfully"
}
```

**Response (Error - Max Attempts)**:
```json
{
  "success": false,
  "error": "Maximum verification attempts exceeded. Please restart process."
}
```

**Error Codes**:
- 400: Invalid code
- 403: Max attempts exceeded
- 404: Connection not found
- 500: Verification error

---

### 3. Get WhatsApp Status
**Endpoint**: `GET /api/v1/integrations/whatsapp/status`

**Description**: Get current WhatsApp connection status.

**Response (Connected)**:
```json
{
  "connected": true,
  "phone": "+12345678900",
  "receive_daily_numbers": true,
  "receive_alerts": true,
  "notification_time": "08:00",
  "message_count": 127,
  "last_message": "2024-01-15T08:00:00Z"
}
```

**Response (Not Connected)**:
```json
{
  "connected": false
}
```

---

### 4. Update WhatsApp Preferences
**Endpoint**: `PATCH /api/v1/integrations/whatsapp/preferences`

**Description**: Update WhatsApp notification preferences.

**Request**:
```json
{
  "receive_daily_numbers": true,
  "receive_alerts": false,
  "notification_time": "09:00"
}
```

**Response**:
```json
{
  "success": true
}
```

---

### 5. Disconnect WhatsApp
**Endpoint**: `POST /api/v1/integrations/whatsapp/disconnect`

**Description**: Disconnect WhatsApp integration.

**Response**:
```json
{
  "success": true,
  "message": "WhatsApp disconnected"
}
```

---

## Calendar Integration Endpoints

### 1. Get Google Calendar Auth URL
**Endpoint**: `POST /api/v1/integrations/calendar/google/auth-url`

**Description**: Get OAuth authorization URL for Google Calendar.

**Response**:
```json
{
  "success": true,
  "connection_id": "cal_abc123xyz",
  "auth_url": "https://accounts.google.com/o/oauth2/auth?client_id=..."
}
```

---

### 2. Handle Google Calendar OAuth Callback
**Endpoint**: `POST /api/v1/integrations/calendar/google/callback`

**Description**: Handle OAuth callback from Google.

**Request**:
```json
{
  "connection_id": "cal_abc123xyz",
  "code": "4/0AXxx..."
}
```

**Response**:
```json
{
  "success": true,
  "message": "Google Calendar connected"
}
```

---

### 3. Get Connected Calendars
**Endpoint**: `GET /api/v1/integrations/calendar/connected`

**Description**: Get list of connected calendars.

**Response**:
```json
{
  "calendars": [
    {
      "id": "cal_abc123xyz",
      "type": "google",
      "email": "user@gmail.com",
      "sync_enabled": true,
      "last_sync": "2024-01-15T10:00:00Z"
    }
  ]
}
```

---

### 4. Update Calendar Sync Preferences
**Endpoint**: `PATCH /api/v1/integrations/calendar/{calendar_id}/preferences`

**Description**: Update which events to sync to calendar.

**Request**:
```json
{
  "sync_lucky_dates": true,
  "sync_lucky_times": true,
  "sync_lottery_drawings": true
}
```

**Response**:
```json
{
  "success": true
}
```

---

### 5. Disconnect Calendar
**Endpoint**: `POST /api/v1/integrations/calendar/disconnect/{calendar_id}`

**Description**: Disconnect calendar.

**Response**:
```json
{
  "success": true
}
```

---

## Payment Integration Endpoints

### 1. Create Payment Intent
**Endpoint**: `POST /api/v1/integrations/payments/intent`

**Description**: Create Stripe payment intent for checkout.

**Request**:
```json
{
  "amount": 9.99,
  "currency": "USD",
  "payment_type": "subscription"
}
```

**Response**:
```json
{
  "success": true,
  "payment_id": "pay_abc123xyz",
  "client_secret": "pi_xxx_secret_xxx"
}
```

---

### 2. Confirm Payment
**Endpoint**: `POST /api/v1/integrations/payments/{payment_id}/confirm`

**Description**: Confirm payment after Stripe processing.

**Response**:
```json
{
  "success": true,
  "subscription_id": "sub_abc123xyz",
  "plan": "premium",
  "next_billing_date": "2024-02-15"
}
```

---

### 3. Get Current Subscription
**Endpoint**: `GET /api/v1/integrations/subscription/current`

**Description**: Get user's current subscription.

**Response (Subscriber)**:
```json
{
  "plan": "premium",
  "tier": 1,
  "price_per_month": 9.99,
  "status": "active",
  "next_billing_date": "2024-02-15T00:00:00Z",
  "features": {
    "astrologer_sessions": 5,
    "pool_limit": 20,
    "challenge_entries": 50,
    "daily_insights": true
  }
}
```

**Response (Free)**:
```json
{
  "plan": "free",
  "tier": 0,
  "price_per_month": 0,
  "status": "active"
}
```

---

### 4. Cancel Subscription
**Endpoint**: `POST /api/v1/integrations/subscription/downgrade`

**Description**: Cancel subscription and downgrade to free plan.

**Response**:
```json
{
  "success": true,
  "message": "Subscription cancelled. Downgraded to free plan."
}
```

---

### 5. Get Payment History
**Endpoint**: `GET /api/v1/integrations/payments/history`

**Description**: Get user's payment history.

**Query Parameters**:
- `limit`: Number of results (default: 20)

**Response**:
```json
{
  "payments": [
    {
      "id": "pay_abc123xyz",
      "amount": 9.99,
      "currency": "USD",
      "type": "subscription",
      "status": "completed",
      "date": "2024-01-15T10:00:00Z"
    }
  ]
}
```

---

## Notification Integration Endpoints

### 1. Get Notification Preferences
**Endpoint**: `GET /api/v1/integrations/notifications/preferences`

**Description**: Get current notification preferences.

**Response**:
```json
{
  "email_enabled": true,
  "email_frequency": "daily",
  "sms_enabled": false,
  "phone_number": null,
  "push_enabled": true,
  "morning_time": "08:00",
  "evening_time": "18:00",
  "quiet_hours_enabled": true,
  "quiet_hours_start": "23:00",
  "quiet_hours_end": "07:00"
}
```

---

### 2. Update Notification Preferences
**Endpoint**: `PATCH /api/v1/integrations/notifications/preferences`

**Description**: Update notification preferences.

**Request**:
```json
{
  "email_enabled": true,
  "sms_enabled": true,
  "phone_number": "+1234567890",
  "morning_time": "09:00",
  "quiet_hours_enabled": true,
  "quiet_hours_start": "22:00"
}
```

**Response**:
```json
{
  "success": true
}
```

---

### 3. Send Test Email
**Endpoint**: `POST /api/v1/integrations/notifications/test-email`

**Description**: Send test email notification.

**Response**:
```json
{
  "success": true,
  "message": "Test email sent"
}
```

---

### 4. Send Test SMS
**Endpoint**: `POST /api/v1/integrations/notifications/test-sms`

**Description**: Send test SMS notification.

**Response**:
```json
{
  "success": true,
  "message": "Test SMS sent"
}
```

---

### 5. Get Notification History
**Endpoint**: `GET /api/v1/integrations/notifications/history`

**Description**: Get notification history.

**Query Parameters**:
- `channel`: Filter by channel (email, sms, push)
- `limit`: Number of results (default: 20)

**Response**:
```json
{
  "notifications": [
    {
      "id": "notif_abc123xyz",
      "channel": "email",
      "type": "daily_numbers",
      "status": "delivered",
      "sent_at": "2024-01-15T08:00:00Z"
    }
  ]
}
```

---

## Lottery Integration Endpoints

### 1. Fetch Lottery Results
**Endpoint**: `POST /api/v1/integrations/lottery/fetch-results`

**Description**: Fetch latest lottery results from external source.

**Request**:
```json
{
  "lottery_type": "powerball"
}
```

**Response**:
```json
{
  "success": true,
  "result_id": "res_abc123xyz"
}
```

---

### 2. Get Latest Lottery Results
**Endpoint**: `GET /api/v1/integrations/lottery/results/{lottery_type}`

**Description**: Get latest results for specific lottery type.

**Response**:
```json
{
  "lottery_type": "powerball",
  "drawing_date": "2024-01-15T22:59:00Z",
  "numbers": [7, 24, 32, 41, 52],
  "bonus_number": 15,
  "jackpot": 950000000
}
```

---

### 3. Get User's Lottery Tickets
**Endpoint**: `GET /api/v1/integrations/lottery/my-tickets`

**Description**: Get user's lottery tickets.

**Query Parameters**:
- `lottery_type`: Filter by lottery type

**Response**:
```json
{
  "tickets": [
    {
      "id": "ticket_abc123xyz",
      "lottery_type": "powerball",
      "numbers": [7, 24, 32, 41, 52],
      "drawing_date": "2024-01-15T00:00:00Z",
      "has_result": true,
      "prize_won": 100.00
    }
  ]
}
```

---

### 4. Get Ticket Results
**Endpoint**: `GET /api/v1/integrations/lottery/ticket-results`

**Description**: Get verified ticket results and total winnings.

**Response**:
```json
{
  "results": [
    {
      "ticket_id": "ticket_abc123xyz",
      "numbers_matched": 5,
      "bonus_matched": false,
      "prize_tier": 4,
      "prize_won": 100.00,
      "verified_at": "2024-01-16T01:00:00Z"
    }
  ],
  "total_won": 1250.00
}
```

---

### 5. Verify Tickets
**Endpoint**: `POST /api/v1/integrations/lottery/verify-tickets`

**Description**: Manually verify all user tickets against lottery results.

**Request**:
```json
{
  "lottery_type": "powerball"
}
```

**Response**:
```json
{
  "success": true,
  "verified_count": 12,
  "total_prizes": 3450.00
}
```

---

### 6. Setup Automated Verification
**Endpoint**: `POST /api/v1/integrations/lottery/automate-verification`

**Description**: Setup automated ticket verification for lottery.

**Request**:
```json
{
  "lottery_type": "powerball"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Automated verification enabled for Powerball"
}
```

---

## Error Handling

### Standard Error Response
```json
{
  "success": false,
  "error": "Error message description",
  "error_code": "SPECIFIC_ERROR_CODE"
}
```

### Common Error Codes
- `INVALID_INPUT`: Validation error
- `AUTHENTICATION_FAILED`: JWT invalid or expired
- `AUTHORIZATION_FAILED`: User not authorized
- `RESOURCE_NOT_FOUND`: Resource doesn't exist
- `RATE_LIMITED`: Too many requests
- `EXTERNAL_API_ERROR`: Third-party API error
- `DATABASE_ERROR`: Database query error
- `INTERNAL_ERROR`: Unexpected server error

---

## Rate Limiting

All endpoints are rate limited:
- **Default**: 100 requests per minute per user
- **Payment endpoints**: 10 requests per minute per user
- **WhatsApp**: 5 initiate requests per minute per user

Rate limit headers included in response:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642254060
```

---

## Webhook Events

### Stripe Webhooks
Endpoint: `POST /webhooks/stripe`

**Event Types**:
- `payment_intent.succeeded`
- `payment_intent.payment_failed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`

---

## Testing

### Use Stripe Test Cards
```
Card: 4242 4242 4242 4242
Exp: 12/25
CVC: 123
```

### Use Twilio Test Credentials
```
Account SID: ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Auth Token: your_auth_token
```

---

## Environment Variables

```bash
# Stripe
STRIPE_API_KEY=sk_live_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx

# Twilio
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_WHATSAPP_NUMBER=+1234567890
TWILIO_SMS_FROM=+1234567890

# SendGrid
SENDGRID_API_KEY=SG.xxx

# Google Calendar
GOOGLE_OAUTH_CLIENT_ID=xxx.apps.googleusercontent.com
GOOGLE_OAUTH_CLIENT_SECRET=xxx

# Lottery APIs
LOTTERY_API_KEY=xxx
LOTTERY_API_URL=https://api.lottery.com/v1
```

---

## SDKs & Libraries

### Backend (Python)
```python
stripe==5.0.0
twilio==8.1.0
sendgrid==6.9.7
google-auth-oauthlib==0.5.0
```

### Frontend (Flutter)
```yaml
dio: ^5.0.0
provider: ^6.0.0
stripe_flutter: ^3.0.0
url_launcher: ^6.0.0
```

---

## Documentation Links

- [Twilio WhatsApp API](https://www.twilio.com/docs/whatsapp/quickstart/python)
- [Stripe Payment Intents](https://stripe.com/docs/payments/payment-intents)
- [SendGrid Email API](https://docs.sendgrid.com/api-reference/mail-send/mail-send)
- [Google Calendar API](https://developers.google.com/calendar/api/guides/overview)
