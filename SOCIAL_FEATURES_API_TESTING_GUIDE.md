# Social Features - API Testing Guide

## Overview

This guide provides detailed instructions for testing all 25+ social feature API endpoints, including request/response examples and edge cases.

---

## Setup

### Prerequisites
- Postman or similar API testing tool
- Valid JWT token (obtain from `/auth/login`)
- Test database with sample users
- Backend running locally or on staging

### Base URL
- Local: `http://localhost:8000/api/v1`
- Staging: `https://staging-api.astroluck.com/api/v1`

### Authentication
All endpoints (except create/list) require JWT token in header:
```
Authorization: Bearer {JWT_TOKEN}
```

---

## Community Pools Endpoints

### 1. Create Community Pool
```http
POST /social/pools/create
Content-Type: application/json

{
  "pool_name": "Friday Lucky Draw",
  "lottery_type": "mega_millions",
  "buy_in_amount": 10.00,
  "num_tickets": 5,
  "max_members": 10,
  "split_strategy": "equal"
}
```

**Expected Response** (200):
```json
{
  "success": true,
  "pool_id": "pool_001",
  "status": "active",
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Test Cases**:
- ✅ Valid pool creation
- ❌ Missing required fields → 400
- ❌ Invalid lottery_type → 400
- ❌ Negative buy_in_amount → 400
- ❌ max_members < 2 → 400
- ✅ Contribution-based split strategy

### 2. Join Community Pool
```http
POST /social/pools/{pool_id}/join
Content-Type: application/json

{
  "amount": 10.00
}
```

**Expected Response** (200):
```json
{
  "success": true,
  "member_id": "member_001",
  "pool_id": "pool_001",
  "contribution": 10.00,
  "num_shares": 1,
  "share_percentage": 10.0,
  "joined_at": "2024-01-15T10:35:00Z"
}
```

**Test Cases**:
- ✅ Valid join with exact buy-in amount
- ❌ Pool at max capacity → 400
- ❌ Already member of pool → 400
- ❌ Insufficient funds → 400
- ✅ Multiple joins from different users
- ✅ Contribution tracking

### 3. Get Pool Details
```http
GET /social/pools/{pool_id}
```

**Expected Response** (200):
```json
{
  "data": {
    "pool_id": "pool_001",
    "pool_name": "Friday Lucky Draw",
    "lottery_type": "mega_millions",
    "buy_in_amount": 10.00,
    "max_members": 10,
    "status": "active",
    "split_strategy": "equal",
    "total_winnings": 0,
    "members": [
      {
        "user_id": "user_001",
        "contribution": 10.00,
        "num_shares": 1,
        "share_percentage": 33.33
      }
    ]
  }
}
```

**Test Cases**:
- ✅ Valid pool ID
- ❌ Non-existent pool → 404
- ✅ Multiple members shown
- ✅ Correct percentage calculations

### 4. List Community Pools
```http
GET /social/pools?status=active&limit=50
```

**Expected Response** (200):
```json
{
  "data": [
    {
      "pool_id": "pool_001",
      "pool_name": "Friday Lucky Draw",
      "status": "active",
      "members_count": 3,
      "total_winnings": 150.00
    }
  ]
}
```

**Test Cases**:
- ✅ Filter by status (active/completed/cancelled)
- ✅ Pagination (limit, offset)
- ✅ Sort by creation date
- ✅ Empty list when no pools

---

## Live Generation Events

### 1. Create Live Event
```http
POST /social/events/create
Content-Type: application/json

{
  "event_name": "Monday Magic Numbers",
  "lottery_type": "powerball",
  "target_numbers": 6,
  "max_participants": 500,
  "generation_method": "frequency_based"
}
```

**Expected Response** (200):
```json
{
  "success": true,
  "event_id": "event_001",
  "status": "live",
  "created_at": "2024-01-15T15:00:00Z"
}
```

**Test Cases**:
- ✅ Valid event creation
- ✅ All generation methods (frequency_based, voting, blend, random)
- ❌ Invalid generation_method → 400
- ❌ target_numbers > 100 → 400
- ✅ Event created in "live" status

### 2. Join Live Event
```http
POST /social/events/{event_id}/join
Content-Type: application/json

{
  "submitted_numbers": [5, 12, 23, 19, 7, 42]
}
```

**Expected Response** (200):
```json
{
  "success": true,
  "participant_id": "participant_001",
  "event_id": "event_001",
  "submission_time": "2024-01-15T15:05:30Z"
}
```

**Test Cases**:
- ✅ Valid number submission
- ❌ Wrong number count → 400
- ❌ Duplicate entries → 400
- ❌ Numbers out of range → 400
- ❌ User already participated → 400
- ✅ Max participants reached
- ✅ Concurrent submissions

### 3. Generate Final Numbers
```http
POST /social/events/{event_id}/generate?method=frequency_based
Content-Type: application/json

{}
```

**Expected Response** (200):
```json
{
  "success": true,
  "event_id": "event_001",
  "final_numbers": [23, 19, 12, 42, 7, 5],
  "generation_method": "frequency_based",
  "generated_at": "2024-01-15T15:30:00Z"
}
```

**Test Cases**:
- ✅ Frequency-based generation
- ✅ Voting-based generation
- ✅ Blend generation
- ✅ Random generation
- ❌ Already generated → 400
- ✅ Correct number count in result
- ✅ Numbers within valid range

### 4. Get Event Details
```http
GET /social/events/{event_id}
```

**Expected Response** (200):
```json
{
  "data": {
    "event_id": "event_001",
    "event_name": "Monday Magic Numbers",
    "status": "completed",
    "generated_at": "2024-01-15T15:30:00Z",
    "final_numbers": [23, 19, 12, 42, 7, 5],
    "num_participants": 150,
    "collected_numbers_count": 150
  }
}
```

**Test Cases**:
- ✅ Before generation (no final_numbers)
- ✅ After generation (has final_numbers)

---

## Astrologer Directory

### 1. Register as Astrologer
```http
POST /social/astrologers/register
Content-Type: application/json

{
  "professional_name": "Dr. Cosmic Stars",
  "specializations": ["birth_charts", "tarot"],
  "experience_years": 15,
  "hourly_rate": 75.00,
  "bio": "Expert in vedic astrology with 15 years experience",
  "certifications": ["Vedic Astrology Certificate", "Tarot Reading Professional"]
}
```

**Expected Response** (200):
```json
{
  "success": true,
  "astrologer_id": "astro_001",
  "is_verified": false,
  "created_at": "2024-01-15T11:00:00Z"
}
```

**Test Cases**:
- ✅ Valid registration
- ❌ Missing specializations → 400
- ❌ Invalid specializations → 400
- ❌ Negative experience_years → 400
- ❌ Negative hourly_rate → 400
- ✅ Created in unverified state

### 2. List Astrologers
```http
GET /social/astrologers?specialization=birth_charts&min_rating=4.0&limit=50
```

**Expected Response** (200):
```json
{
  "data": [
    {
      "astrologer_id": "astro_001",
      "professional_name": "Dr. Cosmic Stars",
      "specializations": ["birth_charts", "tarot"],
      "experience_years": 15,
      "hourly_rate": 75.00,
      "average_rating": 4.8,
      "total_reviews": 45,
      "is_verified": true
    }
  ]
}
```

**Test Cases**:
- ✅ No filters (all astrologers)
- ✅ Filter by specialization
- ✅ Filter by min_rating
- ✅ Combine filters
- ✅ Sorted by rating (highest first)
- ✅ Verified badge shown

### 3. Book Consultation
```http
POST /social/astrologers/{astrologer_id}/book
Content-Type: application/json

{
  "scheduled_time": "2024-01-20T14:00:00Z",
  "consultation_type": "video_call",
  "duration_hours": 1
}
```

**Expected Response** (200):
```json
{
  "success": true,
  "consultation_id": "consult_001",
  "astrologer_id": "astro_001",
  "scheduled_time": "2024-01-20T14:00:00Z",
  "total_cost": 75.00,
  "payment_status": "pending"
}
```

**Test Cases**:
- ✅ Video call booking
- ✅ Written report booking
- ✅ Email booking
- ❌ Invalid consultation_type → 400
- ❌ Past scheduled_time → 400
- ❌ Insufficient funds (if applicable) → 400
- ✅ Cost calculation (hourly_rate × duration)

### 4. Review Astrologer
```http
POST /social/astrologers/{astrologer_id}/review
Content-Type: application/json

{
  "rating": 5,
  "review_text": "Amazing insights, very professional",
  "pros": ["Knowledgeable", "Punctual"],
  "cons": ["Could provide more written details"]
}
```

**Expected Response** (200):
```json
{
  "success": true,
  "review_id": "review_001",
  "astrologer_id": "astro_001",
  "rating": 5,
  "average_rating_updated": 4.8
}
```

**Test Cases**:
- ✅ Valid 1-5 rating
- ❌ Rating > 5 or < 1 → 400
- ✅ Average rating updated after review
- ✅ Multiple reviews counted
- ✅ Empty pros/cons arrays allowed

---

## Challenges & Competitions

### 1. Create Challenge
```http
POST /social/challenges/create
Content-Type: application/json

{
  "challenge_name": "Mega Millions Prediction",
  "challenge_type": "prediction",
  "lottery_type": "mega_millions",
  "correct_answer": [15, 28, 42, 55, 67, 3],
  "participation_fee": 5.00,
  "prize_pool": 1000.00,
  "num_winners": 3
}
```

**Expected Response** (200):
```json
{
  "success": true,
  "challenge_id": "challenge_001",
  "status": "open",
  "created_at": "2024-01-15T12:00:00Z"
}
```

**Test Cases**:
- ✅ Valid challenge creation
- ❌ num_winners > 10 → 400
- ❌ participation_fee < 0 → 400
- ✅ Challenge starts in "open" status

### 2. Submit Challenge Answer
```http
POST /social/challenges/{challenge_id}/submit
Content-Type: application/json

{
  "submitted_answer": [15, 28, 42, 55, 67, 3]
}
```

**Expected Response** (200):
```json
{
  "success": true,
  "challenge_id": "challenge_001",
  "is_correct": true,
  "score": 100,
  "submission_time": "2024-01-15T14:30:45Z"
}
```

**Expected Response** (200 - Incorrect):
```json
{
  "success": true,
  "is_correct": false,
  "score": 0
}
```

**Test Cases**:
- ✅ Correct answer submission
- ✅ Incorrect answer submission
- ❌ Duplicate submission → 400
- ❌ Challenge closed/expired → 400
- ✅ Submission time recorded
- ✅ Score calculated

### 3. Get Challenge Details
```http
GET /social/challenges/{challenge_id}
```

**Expected Response** (200):
```json
{
  "data": {
    "challenge_id": "challenge_001",
    "challenge_name": "Mega Millions Prediction",
    "status": "completed",
    "participation_fee": 5.00,
    "prize_pool": 1000.00,
    "num_winners": 3,
    "num_participants": 250,
    "winners": [
      {
        "rank": 1,
        "user_id": "user_001",
        "prize_amount": 500.00
      }
    ]
  }
}
```

**Test Cases**:
- ✅ Active challenge (no winners yet)
- ✅ Completed challenge (with winners)

---

## Badges & Leaderboard

### 1. Get User Badges
```http
GET /social/badges/{user_id}
```

**Expected Response** (200):
```json
{
  "data": [
    {
      "badge_id": "badge_001",
      "badge_name": "First Win",
      "emoji": "🎯",
      "progress": 1,
      "progress_percentage": 100,
      "is_unlocked": true,
      "unlocked_at": "2024-01-10T15:00:00Z"
    },
    {
      "badge_id": "badge_002",
      "badge_name": "Pool Legend",
      "emoji": "💰",
      "progress": 250,
      "progress_percentage": 25,
      "is_unlocked": false
    }
  ]
}
```

**Test Cases**:
- ✅ Unlocked badges shown
- ✅ Locked badges with progress
- ✅ Progress percentage calculated
- ✅ Empty array if no badges

### 2. Get Global Leaderboard
```http
GET /social/leaderboard?limit=100
```

**Expected Response** (200):
```json
{
  "data": [
    {
      "rank": 1,
      "username": "LuckyPlayer",
      "user_id": "user_001",
      "total_points": 5000,
      "challenge_wins": 50,
      "badges_count": 12,
      "accuracy_score": 92.5
    },
    {
      "rank": 2,
      "username": "AstroEnthusiast",
      "user_id": "user_002",
      "total_points": 4800,
      "challenge_wins": 45,
      "badges_count": 10
    }
  ]
}
```

**Test Cases**:
- ✅ Top 100 users returned
- ✅ Ranked by total_points descending
- ✅ All metrics calculated correctly
- ✅ Pagination works (limit, offset)

### 3. Get User Stats
```http
GET /social/user/{user_id}/stats
```

**Expected Response** (200):
```json
{
  "data": {
    "user_id": "user_001",
    "total_points": 5000,
    "challenge_wins": 50,
    "challenge_losses": 8,
    "pool_winnings": 2500.00,
    "badges_count": 12,
    "global_rank": 1,
    "weekly_rank": 3,
    "monthly_rank": 2,
    "accuracy_score": 92.5
  }
}
```

**Test Cases**:
- ✅ Valid user stats
- ❌ Non-existent user → 404
- ✅ Calculations match other endpoints

---

## Error Handling Tests

### Common Error Scenarios

**400 Bad Request**:
```json
{
  "success": false,
  "error": "Invalid request",
  "details": "missing required field: pool_name"
}
```

**401 Unauthorized**:
```json
{
  "success": false,
  "error": "Unauthorized",
  "details": "Invalid or missing JWT token"
}
```

**404 Not Found**:
```json
{
  "success": false,
  "error": "Not found",
  "details": "Pool with id 'pool_xyz' not found"
}
```

**429 Rate Limited**:
```json
{
  "success": false,
  "error": "Rate limited",
  "details": "Too many requests. Please try again in 60 seconds"
}
```

---

## Performance Tests

### Load Testing
```bash
# Test with 100 concurrent requests
wrk -t4 -c100 -d30s http://localhost:8000/api/v1/social/leaderboard

# Test pool creation under load
wrk -t4 -c50 -d60s -s pool_creation.lua http://localhost:8000/api/v1/social/pools/create
```

### Acceptable Metrics
- Response time: < 200ms (p95)
- Throughput: > 1,000 requests/second
- Error rate: < 0.1%

---

## Test Data

### Sample Users
```json
{
  "user_1": {
    "user_id": "user_001",
    "username": "LuckyPlayer",
    "email": "lucky@astroluck.com"
  },
  "user_2": {
    "user_id": "user_002",
    "username": "AstroEnthusiast",
    "email": "astro@astroluck.com"
  }
}
```

### Sample Lottery Types
- `powerball`
- `mega_millions`
- `daily_pick_3`
- `daily_pick_4`

---

## Automation Scripts

### Postman Collection
Use the provided Postman collection: `social_features_tests.postman_collection.json`

### Manual Test Checklist
- [ ] All 25+ endpoints responding
- [ ] Authentication working
- [ ] Validation working
- [ ] Error handling working
- [ ] Data persistence working
- [ ] Calculations accurate

---

**Last Updated**: 2024
**Version**: 1.0.0
