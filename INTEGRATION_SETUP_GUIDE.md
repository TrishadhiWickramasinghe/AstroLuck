# AstroLuck Integration Setup Guide

## Quick Start Setup (30 minutes)

This guide will walk you through setting up all AstroLuck integration features end-to-end.

---

## Prerequisites

### Backend Requirements
- Python 3.10+
- FastAPI 0.95+
- SQLAlchemy 2.0+
- PostgreSQL 13+ or SQLite for development

### Frontend Requirements
- Flutter 3.7+
- Dart 3.0+
- Provider package 6.0+
- Dio package 5.0+

---

## Part 1: Backend Setup

### Step 1: Install Dependencies

```bash
cd backend

# Add integration dependencies to requirements.txt
pip install stripe==5.0.0
pip install twilio==8.1.0
pip install sendgrid==6.9.7
pip install google-auth-oauthlib==0.5.0
pip install google-auth-httplib2==0.2.0
pip install requests==2.31.0

# Install all requirements
pip install -r requirements.txt
```

### Step 2: Database Migration

Create migration file:
```bash
alembic revision --autogenerate -m "Add integration models"
alembic upgrade head
```

Or create tables directly:
```python
# In app/main.py
from app.models import Base
Base.metadata.create_all(bind=engine)
```

### Step 3: Configure Environment Variables

Copy `.env.example` to `.env` and fill in all credentials:

```bash
# Stripe
STRIPE_API_KEY=sk_live_xxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxx
STRIPE_PUBLISHABLE_KEY=pk_live_xxxxxxxxxxxxx

# Twilio
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_WHATSAPP_NUMBER=+1234567890
TWILIO_SMS_FROM=+1234567890

# SendGrid
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
SENDGRID_FROM_EMAIL=noreply@astroluck.com

# Google Calendar
GOOGLE_OAUTH_CLIENT_ID=xxxxx.apps.googleusercontent.com
GOOGLE_OAUTH_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxx
GOOGLE_OAUTH_REDIRECT_URL=https://astroluck.com/oauth/callback

# Lottery API
LOTTERY_API_KEY=your_lottery_api_key
LOTTERY_API_URL=https://api.lottery.com/v1

# JWT
SECRET_KEY=your_secret_key_for_jwt
JWT_ALGORITHM=HS256
```

### Step 4: Create Credential Files

#### Option A: Get Stripe Test Credentials
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/register)
2. Create account and verify email
3. Go to Developers → API Keys
4. Copy Publishable Key and Secret Key
5. Generate Webhook Signing Secret (add Endpoint for http://localhost:8000/webhooks/stripe)

#### Option B: Get Twilio Credentials
1. Go to [Twilio Console](https://console.twilio.com/)
2. Create account
3. From Dashboard, copy Account SID and Auth Token
4. Go to Resources → Messaging → Try it out → Get Twilio phone number
5. Send phone number to +1 415-639-2020: "join ASTROLUCK" (WhatsApp Beta signup)

#### Option C: Get SendGrid Credentials
1. Go to [SendGrid Web API](https://app.sendgrid.com/settings/api_keys)
2. Create new API key
3. Copy key to `.env`
4. Verify sender email in Settings → Sender Authentication

#### Option D: Get Google OAuth Credentials
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project
3. Enable Google Calendar API
4. Create OAuth 2.0 Client (Web Application)
5. Add authorized redirect URI: `https://astroluck.com/oauth/callback`
6. Download credentials JSON

### Step 5: Verify Installation

```bash
# Test Stripe
python -c "import stripe; stripe.api_key = 'sk_test_xxx'; print('✓ Stripe')"

# Test Twilio
python -c "from twilio.rest import Client; Client('sid', 'token').api.accounts.get(); print('✓ Twilio')"

# Test SendGrid
python -c "import sendgrid; sg = sendgrid.SendGridAPIClient('SG.xxx'); print('✓ SendGrid')"

# Test Google Auth
python -c "from google.oauth2 import credentials; print('✓ Google Auth')"
```

### Step 6: Create Integration Routes Integration

The integration routes are already created in `app/api/routes/integrations.py`.

Update `app/main.py`:
```python
from app.api.routes import integrations

# Include the integrations router
app.include_router(integrations.router)
```

### Step 7: Create Webhook Handlers

Add webhook endpoints to your main FastAPI app:

```python
@app.post("/webhooks/stripe")
async def handle_stripe_webhook(request: Request, db: Session = Depends(get_db)):
    """Handle Stripe webhook events"""
    payload = await request.body()
    sig_header = request.headers.get('stripe-signature')
    
    from stripe.error import SignatureVerificationError
    import stripe
    
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except SignatureVerificationError:
        raise HTTPException(status_code=400, detail="Invalid signature")
    
    # Handle specific event types
    if event['type'] == 'payment_intent.succeeded':
        payment_id = event['data']['object']['id']
        # Update payment status in database
        from app.models import Payment
        payment = db.query(Payment).filter(
            Payment.stripe_payment_id == payment_id
        ).first()
        if payment:
            payment.status = 'completed'
            db.commit()
    
    return {"status": "success"}
```

### Step 8: Test Backend Integration

```bash
# Start development server
uvicorn app.main:app --reload --port 8000

# Test WhatsApp endpoint
curl -X POST http://localhost:8000/api/v1/integrations/whatsapp/initiate \
  -H "Authorization: Bearer your_jwt_token" \
  -H "Content-Type: application/json" \
  -d '{"whatsapp_phone": "+1234567890"}'

# Test payment endpoint
curl -X POST http://localhost:8000/api/v1/integrations/payments/intent \
  -H "Authorization: Bearer your_jwt_token" \
  -H "Content-Type: application/json" \
  -d '{"amount": 9.99, "currency": "USD", "payment_type": "subscription"}'
```

---

## Part 2: Frontend Setup (Flutter)

### Step 1: Add Dependencies to pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.0.0
  
  # HTTP Requests
  dio: ^5.0.0
  
  # Payment
  flutter_stripe: ^3.0.0
  
  # OAuth & Calendar
  url_launcher: ^6.0.0
  google_sign_in: ^6.0.0
  
  # Utilities
  intl: ^0.19.0
  timeago: ^3.5.0
```

### Step 2: Run Pub Get

```bash
cd flutter_app
flutter pub get
```

### Step 3: Configure Stripe (iOS)

**iOS/Podfile**:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'Stripe'
      target.build_configurations.each do |config|
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
          '$(inherited)',
          'STRIPE_VERSION=@"23.0.0"'
        ]
      end
    end
  end
end
```

### Step 4: Configure Stripe (Android)

**android/app/build.gradle**:
```gradle
android {
  ...
  buildTypes {
    release {
      // Release signing config
    }
  }
}

dependencies {
  implementation 'com.stripe:stripe-android:20.0.0'
}
```

### Step 5: Setup Flutter Constants

Create `lib/core/constants/app_constants.dart`:
```dart
class AppConstants {
  static const String apiUrl = 'https://api.astroluck.com/api/v1';
  static const String stripePublishableKey = 'pk_live_xxx';
  static const String googleOAuthClientId = 'xxx.apps.googleusercontent.com';
  
  static String? authToken; // Set after login
  
  // Update during initialization
  static void initializeFromConfig(Map<String, dynamic> config) {
    // Load from remote config or secure storage
  }
}
```

### Step 6: Create Integration Providers

Providers are already created in `lib/features/integrations/providers/integrations_providers.dart`.

### Step 7: Register Providers in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe
  await Stripe.instance.publishableKey = AppConstants.stripePublishableKey;
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WhatsAppProvider()),
        ChangeNotifierProvider(create: (_) => CalendarSyncProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LotteryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
```

### Step 8: Add Integration Screens to Navigation

Update your app router:
```dart
// In your router or navigation logic
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/integrations/whatsapp':
      return MaterialPageRoute(builder: (_) => const WhatsAppSettingsScreen());
    case '/integrations/calendar':
      return MaterialPageRoute(builder: (_) => const CalendarSyncScreen());
    case '/integrations/payment':
      return MaterialPageRoute(builder: (_) => const PaymentSettingsScreen());
    case '/integrations/notifications':
      return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());
    case '/integrations/lottery':
      return MaterialPageRoute(builder: (_) => const LotteryTicketsScreen());
    default:
      return null;
  }
}
```

### Step 9: Update App Navigation

Add integration menu items:
```dart
// In your settings or menu screen
ListTile(
  title: const Text('WhatsApp Integration'),
  leading: Icon(Icons.whatsapp),
  onTap: () => Navigator.pushNamed(context, '/integrations/whatsapp'),
),
ListTile(
  title: const Text('Calendar Sync'),
  leading: Icon(Icons.calendar_today),
  onTap: () => Navigator.pushNamed(context, '/integrations/calendar'),
),
ListTile(
  title: const Text('Payment Settings'),
  leading: Icon(Icons.credit_card),
  onTap: () => Navigator.pushNamed(context, '/integrations/payment'),
),
ListTile(
  title: const Text('Notifications'),
  leading: Icon(Icons.notifications),
  onTap: () => Navigator.pushNamed(context, '/integrations/notifications'),
),
ListTile(
  title: const Text('Lottery Tickets'),
  leading: Icon(Icons.sport_score),
  onTap: () => Navigator.pushNamed(context, '/integrations/lottery'),
),
```

---

## Testing Integration Features

### Test WhatsApp Integration

```bash
# 1. Get your test phone number
# 2. Send verification code
curl -X POST http://localhost:8000/api/v1/integrations/whatsapp/initiate \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"whatsapp_phone": "+91xxxxxxxxxx"}'

# 3. Wait for WhatsApp message with code

# 4. Verify code
curl -X POST http://localhost:8000/api/v1/integrations/whatsapp/verify \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"connection_id": "conn_xxx", "code": "123456"}'

# 5. Check status
curl -X GET http://localhost:8000/api/v1/integrations/whatsapp/status \
  -H "Authorization: Bearer $TOKEN"
```

### Test Payment Integration

```bash
# 1. Create payment intent
RESPONSE=$(curl -X POST http://localhost:8000/api/v1/integrations/payments/intent \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"amount": 9.99, "currency": "USD", "payment_type": "subscription"}')

PAYMENT_ID=$(echo $RESPONSE | jq -r '.payment_id')

# 2. Test with Stripe test card 4242 4242 4242 4242

# 3. Confirm payment
curl -X POST http://localhost:8000/api/v1/integrations/payments/$PAYMENT_ID/confirm \
  -H "Authorization: Bearer $TOKEN"

# 4. Check subscription
curl -X GET http://localhost:8000/api/v1/integrations/subscription/current \
  -H "Authorization: Bearer $TOKEN"
```

### Test Calendar Integration

```bash
# 1. Get auth URL
RESPONSE=$(curl -X POST http://localhost:8000/api/v1/integrations/calendar/google/auth-url \
  -H "Authorization: Bearer $TOKEN")

AUTH_URL=$(echo $RESPONSE | jq -r '.auth_url')
CONNECTION_ID=$(echo $RESPONSE | jq -r '.connection_id')

# 2. Open auth URL in browser, authorize app

# 3. Handle callback (should be done automatically in Flutter)
curl -X POST http://localhost:8000/api/v1/integrations/calendar/google/callback \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"connection_id": "'$CONNECTION_ID'", "code": "4/0AXxxx"}'

# 4. Verify connection
curl -X GET http://localhost:8000/api/v1/integrations/calendar/connected \
  -H "Authorization: Bearer $TOKEN"
```

---

## Troubleshooting

### Issue: "Twilio API Error: 401 Unauthorized"
**Solution**: Verify TWILIO_ACCOUNT_SID and TWILIO_AUTH_TOKEN in `.env`

### Issue: "Stripe API key not valid"
**Solution**: Use `sk_test_` for development, ensure key is valid in Stripe dashboard

### Issue: "SendGrid 403 Forbidden"
**Solution**: Verify SendGrid API key and ensure sender email is verified

### Issue: "Google OAuth redirect_uri mismatch"
**Solution**: Ensure GOOGLE_OAUTH_REDIRECT_URL matches registered URI in Google Cloud Console

### Issue: "Lottery API connection timeout"
**Solution**: Check LOTTERY_API_URL is accessible, may need VPN or IP whitelisting

### Issue: "Flutter provider not updating"
**Solution**: Ensure Provider package is in MultiProvider, use `notifyListeners()` after state change

---

## Monitoring & Logging

### Backend Logging

Add to `app/core/config.py`:
```python
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
```

### Monitor External APIs

```python
# Log all external API calls
@app.middleware("http")
async def log_external_calls(request: Request, call_next):
    response = await call_next(request)
    if '/integrations/' in request.url.path:
        logger.info(f"{request.method} {request.url.path} - {response.status_code}")
    return response
```

### Health Check Endpoint

```python
@app.get("/health/integrations")
async def integration_health() -> dict:
    return {
        "stripe": check_stripe_api(),
        "twilio": check_twilio_api(),
        "sendgrid": check_sendgrid_api(),
        "google": check_google_api(),
        "lottery": check_lottery_api(),
        "timestamp": datetime.now().isoformat()
    }
```

---

## Production Deployment

### Pre-Deployment Checklist

- [ ] Test all integration endpoints with production credentials
- [ ] Configure HTTPS/SSL certificates
- [ ] Setup webhook servers for Stripe (add to Stripe Dashboard)
- [ ] Enable rate limiting and DDoS protection
- [ ] Setup database backups
- [ ] Configure error logging (Sentry or similar)
- [ ] Setup monitoring alerts
- [ ] Test payment processing end-to-end
- [ ] Verify all external API credentials
- [ ] Load test critical endpoints
- [ ] Test failover scenarios

### Deploy Backend

```bash
# Using Docker
docker build -t astroluck-backend .
docker run -e STRIPE_API_KEY=$STRIPE_API_KEY ... astroluck-backend

# Or using traditional deployment
gunicorn -w 4 -b 0.0.0.0:8000 app.main:app
```

### Deploy Flutter

```bash
# Build APK for Android
flutter build apk --release

# Build IPA for iOS
flutter build ios --release

# Build Web
flutter build web --release
```

---

## Support & Resources

- **Stripe Documentation**: https://stripe.com/docs
- **Twilio WhatsApp**: https://www.twilio.com/docs/whatsapp
- **SendGrid Email**: https://docs.sendgrid.com
- **Google Calendar API**: https://developers.google.com/calendar
- **Flutter Documentation**: https://flutter.dev/docs
- **Provider Package**: https://pub.dev/packages/provider

---

## Next Steps

1. Complete all setup steps above
2. Test each integration individually
3. Run end-to-end tests
4. Setup monitoring and alerts
5. Deploy to staging environment
6. Perform load testing
7. Deploy to production
8. Monitor metrics and adjust as needed

Congratulations! Your integration features are now live! 🚀
