# AstroLuck Firebase Backend Setup

## Overview
This document explains the Firebase backend infrastructure for the AstroLuck Flutter app, including database schema, Cloud Functions, and security rules.

## Database Schema

### Collections

#### 1. **users** - User Profiles
Stores user profile information and birth details.

```
users/{userId}
├── userId: string (Auth UID)
├── name: string
├── dateOfBirth: string (YYYY-MM-DD)
├── timeOfBirth: string (HH:MM, optional)
├── placeOfBirth: string (optional)
├── gender: string (Male/Female/Other)
├── createdAt: timestamp
└── updatedAt: timestamp
```

#### 2. **lotteryHistory** - Lottery Play Records
Immutable record of all lottery plays by users (audit trail).

```
lotteryHistory/{playId}
├── userId: string (reference to users)
├── lotteryType: string (6/49, 4-Digit, Powerball, etc.)
├── numbers: array<number> (winning numbers)
├── amount: number (bet amount, optional)
├── date: string (ISO date when played)
└── createdAt: timestamp
```

#### 3. **luckyNumbers** - Daily Lucky Numbers
Immutable record of generated lucky numbers with daily metadata.

```
luckyNumbers/{recordId}
├── userId: string (reference to users)
├── day: string (YYYY-MM-DD for the lucky day)
├── numbers: array<number> (lucky numbers 1-9)
├── color: string (lucky color)
├── energyLevel: string (High/Medium/Low)
├── luckyTime: string (HH:MM format)
└── createdAt: timestamp
```

#### 4. **preferences** - User Preferences
Stores user-specific app preferences and settings.

```
preferences/{userId}
├── userId: string (Auth UID)
├── notifications_enabled: boolean
├── daily_reminder_time: string (HH:MM)
├── preferred_lottery_types: array<string>
├── theme: string (dark/light)
├── language: string (en/es/fr/etc.)
└── updatedAt: timestamp
```

#### 5. **config** - App Configuration
Read-only configuration for all clients (e.g., lottery types, colors).

```
config/lotteries
├── types: array<{name, min, max, format}>
├── updatedAt: timestamp

config/lucky_colors
├── colors: object<number, hex>
└── updatedAt: timestamp
```

---

## Cloud Functions API

All functions are HTTP-callable and support CORS. Base URL: `https://[REGION]-[PROJECT_ID].cloudfunctions.net/`

### User Management

#### Create User Profile
- **Endpoint**: `POST /createUserProfile`
- **Auth**: Required (Firebase Auth token)
- **Request**:
  ```json
  {
    "userId": "user123",
    "name": "John Doe",
    "dateOfBirth": "1999-08-21",
    "timeOfBirth": "14:30",
    "placeOfBirth": "New York",
    "gender": "Male"
  }
  ```
- **Response**: `{ success: true, userId: "user123" }`

#### Get User Profile
- **Endpoint**: `GET /getUserProfile?userId=user123`
- **Auth**: Required
- **Response**: `{ success: true, data: { /* user profile */ } }`

### Lottery Management

#### Save Lottery Play
- **Endpoint**: `POST /saveLotteryPlay`
- **Auth**: Required
- **Request**:
  ```json
  {
    "userId": "user123",
    "lotteryType": "6/49",
    "numbers": [7, 14, 21, 28, 35, 42],
    "amount": 5.00,
    "date": "2024-04-05"
  }
  ```
- **Response**: `{ success: true, playId: "docId123" }`

#### Get Lottery History
- **Endpoint**: `GET /getLotteryHistory?userId=user123&limit=50`
- **Auth**: Required
- **Response**:
  ```json
  {
    "success": true,
    "data": [ /* array of lottery plays */ ],
    "count": 25
  }
  ```

### Lucky Numbers Management

#### Save Daily Lucky Numbers
- **Endpoint**: `POST /saveDailyLuckyNumbers`
- **Auth**: Required
- **Request**:
  ```json
  {
    "userId": "user123",
    "day": "2024-04-05",
    "numbers": [3, 6, 9],
    "color": "gold",
    "energyLevel": "High",
    "luckyTime": "14:00"
  }
  ```
- **Response**: `{ success: true, recordId: "docId123" }`

#### Get Lucky Numbers
- **Endpoint**: `GET /getLuckyNumbers?userId=user123&days=30`
- **Auth**: Required
- **Response**: `{ success: true, data: [ /* lucky numbers */ ], count: 15 }`

### Analytics

#### Get User Statistics
- **Endpoint**: `GET /getUserStatistics?userId=user123`
- **Auth**: Required
- **Response**:
  ```json
  {
    "success": true,
    "data": {
      "totalLotteryPlays": 42,
      "totalLuckyNumbersGenerated": 180,
      "mostUsedLotteryType": "6/49",
      "lotteryTypeCounts": { "6/49": 25, "4-Digit": 17 }
    }
  }
  ```

---

## Security Rules

The Firestore security rules enforce the following:

1. **Authentication Required**: All collection access requires Firebase Authentication
2. **Ownership**: Users can only read/write their own data (enforced by `userId` field)
3. **Immutability**: Lottery history and lucky numbers are write-once (no updates/deletes)
4. **Read-only Config**: App configuration is readable but not writable by clients

---

## Setup Instructions

### Prerequisites
- Firebase Project set up (https://console.firebase.google.com)
- Firebase CLI installed: `npm install -g firebase-tools`
- Node.js 20+ installed

### 1. Initialize Firebase
```bash
firebase login
firebase init
```

### 2. Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### 3. Deploy Firestore Indexes
```bash
firebase deploy --only firestore:indexes
```

### 4. Deploy Cloud Functions
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

### 5. Configure Flutter App
Create `lib/firebase_options.dart` (generate via FlutterFire CLI):
```bash
flutterfire configure
```

### 6. Test with Emulators (Local Development)
```bash
firebase emulators:start
```
This starts the Firestore, Functions, and Auth emulators on localhost.

---

## Firebase Configuration File (google-services.json)

The Flutter app requires a `google-services.json` file in the `android/app/src` directory. Generate it from Firebase Console:
1. Go to Firebase Console > Project Settings
2. Download `google-services.json`
3. Place in `android/app/src/google-services.json`

For iOS, download `GoogleService-Info.plist` and place in `ios/Runner/`.

---

## Scheduled Maintenance

### Daily Cleanup (2 AM UTC)
- Deletes lottery history records older than 1 year
- Prevents database bloat
- Can be modified in `cleanupOldRecords` Cloud Function

---

## Performance Optimization

### Indexes Created
1. **lotteryHistory** by `userId` + `createdAt` (for user history queries)
2. **lotteryHistory** by `userId` + `lotteryType` + `createdAt` (for filtered history)
3. **luckyNumbers** by `userId` + `createdAt` (for daily numbers)
4. **luckyNumbers** by `userId` + `day` (for specific day lookup)

---

## Monitoring & Debugging

### View Cloud Function Logs
```bash
firebase functions:log
```

### Enable Firestore Monitoring
- Firebase Console > Firestore > Monitoring
- Track read/write operations, storage usage

### Error Handling
All functions return standardized error responses:
```json
{
  "success": false,
  "error": "Error message describing what went wrong"
}
```

---

## Cost Optimization Tips

1. **Use Firestore quotas**: Free tier includes 50K reads/day
2. **Enable offline persistence**: Reduces read operations
3. **Batch writes**: Use bulk operations when possible
4. **Cache data**: Store frequently accessed data locally
5. **Delete old records**: The scheduled cleanup function handles this

---

## Backup & Recovery

### Enable Backups
1. Firestore > Backups > Create scheduled backup
2. Set retention period (30+ days recommended)

### Manual Backup
```bash
firebase firestore:backups:list
firebase firestore:backups:create
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Permission Denied | Check Firestore rules and authentication status |
| Indexes not working | Wait for indexes to be created (can take 10+ mins) |
| Functions timeout | Increase timeout in firebase.json or optimize code |
| High costs | Review Firestore usage in console, enable caching |

---

## Next Steps

1. ✅ Deploy backend infrastructure
2. Implement Firebase Auth in Flutter app
3. Create FirestoreService wrapper for API calls
4. Add offline support via Firestore offline persistence
5. Implement analytics tracking
6. Set up error logging with Crashlytics

