# AstroLuck Firebase Backend - Deployment Guide

## Quick Start

### Step 1: Set Up Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named "astroluck"
3. Enable Firestore Database (Start in production mode)
4. Enable Firebase Authentication (Email/Password)
5. Note your project ID and region

### Step 2: Install Firebase CLI
```bash
npm install -g firebase-tools
```

### Step 3: Authenticate Firebase
```bash
firebase login
```

### Step 4: Initialize Firebase in Project
```bash
firebase init
```
Select:
- ✅ Firestore
- ✅ Functions
- ✅ Emulators

### Step 5: Deploy Backend

**Deploy Firestore Rules:**
```bash
firebase deploy --only firestore:rules
```

**Deploy Firestore Indexes:**
```bash
firebase deploy --only firestore:indexes
```

**Deploy Cloud Functions:**
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

### Step 6: Configure Flutter App

**Get your Cloud Functions base URL:**
After deployment, check the functions console for your URLs. They follow this pattern:
```
https://<REGION>-<PROJECT_ID>.cloudfunctions.net
```

**Update CloudFunctionsService:**
Edit `lib/core/services/cloud_functions_service.dart` and replace:
```dart
static const String BASE_URL = 'https://your-region-your-project-id.cloudfunctions.net';
```

**Generate Firebase options:**
```bash
flutter pub add firebase_core
flutter pub add cloud_firestore
flutter pub add firebase_auth

flutterfire configure
```

### Step 7: Get Google Services Files

**For Android:**
1. Firebase Console > Project Settings > General
2. Under "Your apps" section, click Android icon
3. Download `google-services.json`
4. Place in `android/app/src/google-services.json`

**For iOS:**
1. Click iOS icon
2. Download `GoogleService-Info.plist`
3. Place in `ios/Runner/GoogleService-Info.plist`
4. Add to Xcode (right-click Runner > Add Files to Runner)

### Step 8: Initialize Firebase in App
Update `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await FirebaseService.instance.initialize();
  
  runApp(const MyApp());
}
```

### Step 9: Test Locally with Emulators

```bash
firebase emulators:start
```

In your Flutter app during development, connect to emulators:
```dart
// In firebase_service.dart, add (only for development):
Future<void> connectToEmulators() async {
  final host = defaultTargetPlatform == TargetPlatform.android 
    ? '10.0.2.2' 
    : 'localhost';
  
  await _firestore.useFirestoreEmulator(host, 8080);
  await _auth.useAuthEmulator(host, 9099);
}
```

---

## File Structure After Setup

```
astroluck/
├── functions/
│   ├── node_modules/
│   ├── index.js (Cloud Functions)
│   └── package.json
├── lib/
│   ├── core/
│   │   └── services/
│   │       ├── firebase_service.dart ✅
│   │       ├── cloud_functions_service.dart ✅
│   │       └── firestore_service.dart ✅
│   ├── firebase_options.dart (auto-generated)
│   └── main.dart (updated)
├── android/
│   └── app/src/
│       └── google-services.json ✅
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist ✅
├── firebase.json ✅
├── firestore.rules ✅
├── firestore.indexes.json ✅
└── pubspec.yaml (updated with Firebase packages)
```

---

## Database Initialization

### Create App Configuration Collection
Run this command in Firestore Console or via Firebase CLI:

```bash
# Create config/lotteries document
firebase firestore:import ./config-backup.json

# Or manually create in Firebase Console:
# Collection: config
#   Document: lotteries
#     fields:
#       - types: array
#       - updatedAt: timestamp
#   Document: lucky_colors
#     fields:
#       - colors: map
#       - updatedAt: timestamp
```

---

## Verification Checklist

- [ ] Firebase project created
- [ ] Firestore Database enabled (production mode)
- [ ] Authentication enabled (Email/Password)
- [ ] Cloud Functions deployed
- [ ] Firestore rules deployed
- [ ] Firestore indexes deployed
- [ ] google-services.json in Android
- [ ] GoogleService-Info.plist in iOS
- [ ] Cloud Functions base URL updated in code
- [ ] Firebase initialized in main.dart
- [ ] Flutter app can connect to Firebase

---

## Testing the Backend

### Test with cURL (after deployment)

**Create User Profile:**
```bash
curl -X POST https://your-region-your-project-id.cloudfunctions.net/createUserProfile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ID_TOKEN" \
  -d '{
    "userId": "test-user-123",
    "name": "Test User",
    "dateOfBirth": "1990-01-15",
    "timeOfBirth": "14:30",
    "placeOfBirth": "Test City",
    "gender": "Male"
  }'
```

**Get User Profile:**
```bash
curl -X GET "https://your-region-your-project-id.cloudfunctions.net/getUserProfile?userId=test-user-123" \
  -H "Authorization: Bearer YOUR_ID_TOKEN"
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Deployment fails | Run `firebase login` again, check quota |
| Permission Denied | Check Firestore rules, ensure auth token is valid |
| Functions not working | Check Cloud Functions logs: `firebase functions:log` |
| Emulator won't start | Kill port 8080/5001: `lsof -i :8080` then `kill -9 <PID>` |
| Slow queries | Check if indexes need to be created |

---

## Production Checklist

Before deploying to production:

- [ ] Test all Cloud Functions with real data
- [ ] Enable Firebase security rules (not in test mode)
- [ ] Set up billing alerts
- [ ] Enable Firestore backups
- [ ] Configure Cloud Function memory/timeout appropriately
- [ ] Add monitoring and logging
- [ ] Test authentication flow
- [ ] Verify CORS configuration
- [ ] Set up error tracking (Crashlytics)
- [ ] Review database structure for optimization

---

## Next Steps

1. **Implement Authentication UI**: Login/Signup screens
2. **Sync Local Data**: Connect app to Firebase
3. **Set Up Analytics**: Track user behavior
4. **Enable Push Notifications**: Use Cloud Messaging
5. **Add Backup**: Enable Firestore automatic backups

---

## Support & Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Plugin](https://firebase.flutter.dev)
- [Cloud Functions Guide](https://firebase.google.com/docs/functions)
- [Firestore Security Rules](https://firebase.google.com/docs/rules)
