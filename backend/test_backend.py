"""
Complete backend testing script with sample data
Tests all major features and endpoints
"""

import requests
import json
from datetime import datetime, timedelta
import time

# Configuration
BASE_URL = "http://localhost:8000"
API_PREFIX = "/api/v1"

# Test users data
TEST_USERS = [
    {
        "email": "alice@example.com",
        "username": "alice_astro",
        "password": "TestPass123!",
        "full_name": "Alice Johnson",
        "birth_date": "1990-05-15",
        "birth_time": "14:30",
        "birth_place": "New York, USA",
        "gender": "Female"
    },
    {
        "email": "bob@example.com",
        "username": "bob_lucky",
        "password": "TestPass123!",
        "full_name": "Bob Smith",
        "birth_date": "1988-12-25",
        "birth_time": "09:00",
        "birth_place": "Los Angeles, USA",
        "gender": "Male"
    },
    {
        "email": "charlie@example.com",
        "username": "charlie_astro",
        "password": "TestPass123!",
        "full_name": "Charlie Brown",
        "birth_date": "1995-03-10",
        "birth_time": "18:45",
        "birth_place": "Chicago, USA",
        "gender": "Male"
    }
]

# Color codes for output
GREEN = '\033[92m'
RED = '\033[91m'
BLUE = '\033[94m'
YELLOW = '\033[93m'
RESET = '\033[0m'

def print_section(title):
    """Print section header"""
    print(f"\n{BLUE}{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}{RESET}\n")

def print_success(msg):
    """Print success message"""
    print(f"{GREEN}✓ {msg}{RESET}")

def print_error(msg):
    """Print error message"""
    print(f"{RED}✗ {msg}{RESET}")

def print_info(msg):
    """Print info message"""
    print(f"{YELLOW}ℹ {msg}{RESET}")

def health_check():
    """Check if backend is running"""
    print_section("🏥 HEALTH CHECK")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        if response.status_code == 200:
            print_success("Backend is running")
            return True
        else:
            print_error(f"Backend returned status {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print_error("Cannot connect to backend. Is it running?")
        print_info("Start server with: python run.py")
        return False

def register_users():
    """Register test users"""
    print_section("👥 REGISTERING TEST USERS")
    users = {}
    
    for user_data in TEST_USERS:
        response = requests.post(
            f"{BASE_URL}{API_PREFIX}/auth/register",
            json={
                "email": user_data["email"],
                "username": user_data["username"],
                "password": user_data["password"],
                "full_name": user_data["full_name"]
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            users[user_data["username"]] = {
                "token": data["access_token"],
                "user_id": data["user_id"],
                "email": user_data["email"],
                **user_data
            }
            print_success(f"Registered {user_data['username']}")
        else:
            print_error(f"Failed to register {user_data['username']}: {response.text}")
    
    return users

def update_user_profiles(users):
    """Update user profiles with birth details"""
    print_section("👤 UPDATING USER PROFILES")
    
    for username, user_data in users.items():
        response = requests.put(
            f"{BASE_URL}{API_PREFIX}/users/me",
            headers={"Authorization": f"Bearer {user_data['token']}"},
            json={
                "full_name": user_data["full_name"],
                "birth_date": user_data["birth_date"],
                "birth_time": user_data["birth_time"],
                "birth_place": user_data["birth_place"],
                "gender": user_data["gender"],
                "latitude": 40.7128,
                "longitude": -74.0060
            }
        )
        
        if response.status_code == 200:
            print_success(f"Updated profile for {username}")
        else:
            print_error(f"Failed to update {username}: {response.text}")

def test_lottery_generation(users):
    """Test lottery number generation"""
    print_section("🎰 TESTING LOTTERY GENERATION")
    
    for username, user_data in users.items():
        response = requests.post(
            f"{BASE_URL}{API_PREFIX}/generate-lucky-numbers",
            headers={"Authorization": f"Bearer {user_data['token']}"},
            json={"lottery_type": "6/49"}
        )
        
        if response.status_code == 200:
            data = response.json()
            print_success(f"{username} generated: {data['numbers']}")
            print_info(f"  Life Path: {data.get('life_path')}, Daily Lucky: {data.get('daily_lucky')}")
        else:
            print_error(f"Failed for {username}: {response.text}")

def test_daily_insights(users):
    """Test daily insights generation"""
    print_section("✨ TESTING DAILY INSIGHTS")
    
    for username, user_data in users.items():
        response = requests.post(
            f"{BASE_URL}{API_PREFIX}/insights/generate",
            headers={"Authorization": f"Bearer {user_data['token']}"}
        )
        
        if response.status_code == 200:
            data = response.json()["insight"]
            print_success(f"{username} got insight")
            print_info(f"  {data['insight_text'][:60]}...")
            print_info(f"  Lucky Hours: {data['lucky_hours']}")
        else:
            print_error(f"Failed for {username}: {response.text}")

def test_badges(users):
    """Test badge system"""
    print_section("🏆 TESTING BADGE SYSTEM")
    
    for username, user_data in users.items():
        # Generate 10 lotteries to unlock "Lucky Streak" badge
        print_info(f"Generating 10 lotteries for {username}...")
        for i in range(10):
            requests.post(
                f"{BASE_URL}{API_PREFIX}/generate-lucky-numbers",
                headers={"Authorization": f"Bearer {user_data['token']}"},
                json={"lottery_type": "6/49"}
            )
        
        # Check achievements
        response = requests.get(
            f"{BASE_URL}{API_PREFIX}/achievements",
            headers={"Authorization": f"Bearer {user_data['token']}"}
        )
        
        if response.status_code == 200:
            data = response.json()
            print_success(f"{username} has {data['total_points']} points, {data['total_badges']} badge(s)")
            if data["newly_unlocked"]["badges"]:
                for badge in data["newly_unlocked"]["badges"]:
                    print_info(f"  🎉 Unlocked: {badge['badge_name']} (+{badge['points_earned']} pts)")
        else:
            print_error(f"Failed for {username}: {response.text}")

def test_leaderboard(users):
    """Test leaderboard"""
    print_section("📊 TESTING LEADERBOARD")
    
    # Use first user's token
    token = list(users.values())[0]["token"]
    
    response = requests.get(
        f"{BASE_URL}{API_PREFIX}/leaderboard?limit=10",
        headers={"Authorization": f"Bearer {token}"}
    )
    
    if response.status_code == 200:
        data = response.json()["leaderboard"]
        print_success(f"Retrieved leaderboard with {len(data)} users")
        for rank, user in enumerate(data[:3], 1):
            print_info(f"  #{rank} {user['username']}: {user['total_points']} pts, {user['badges']} badges")
    else:
        print_error(f"Failed: {response.text}")

def test_subscriptions(users):
    """Test subscription system"""
    print_section("💳 TESTING SUBSCRIPTIONS")
    
    # Get plans
    response = requests.get(f"{BASE_URL}{API_PREFIX}/subscriptions/plans")
    
    if response.status_code == 200:
        plans = response.json()["plans"]
        print_success(f"Retrieved {len(plans)} subscription plans")
        for plan in plans:
            print_info(f"  {plan['name']}: ${plan['price']}/mo - {', '.join(plan['features'][:2])}...")
    else:
        print_error(f"Failed to get plans: {response.text}")
    
    # Check current subscription
    token = list(users.values())[0]["token"]
    response = requests.get(
        f"{BASE_URL}{API_PREFIX}/subscriptions/current",
        headers={"Authorization": f"Bearer {token}"}
    )
    
    if response.status_code == 200:
        data = response.json()
        print_success(f"Current subscription: {data.get('plan', 'free')}")
    else:
        print_error(f"Failed: {response.text}")

def test_pools(users):
    """Test lottery pools"""
    print_section("🤝 TESTING LOTTERY POOLS")
    
    alice = users["alice_astro"]
    
    # Create pool
    response = requests.post(
        f"{BASE_URL}{API_PREFIX}/pools/create",
        headers={"Authorization": f"Bearer {alice['token']}"},
        json={
            "name": "Weekend Jackpot Syndicate",
            "description": "Join us for the weekend draw",
            "lottery_type": "6/49",
            "numbers": "7,14,21,28,35,42",
            "entry_fee": 5.00,
            "max_members": 5
        }
    )
    
    if response.status_code == 200:
        pool_data = response.json()
        pool_id = pool_data["pool_id"]
        print_success(f"Created pool: {pool_id}")
        
        # Other users join
        for username, user_data in list(users.items())[1:]:
            response = requests.post(
                f"{BASE_URL}{API_PREFIX}/pools/{pool_id}/join",
                headers={"Authorization": f"Bearer {user_data['token']}"}
            )
            
            if response.status_code == 200:
                print_success(f"  {username} joined pool")
            else:
                print_error(f"  {username} failed to join: {response.text}")
        
        # Get pool details
        response = requests.get(
            f"{BASE_URL}{API_PREFIX}/pools/{pool_id}",
            headers={"Authorization": f"Bearer {alice['token']}"}
        )
        
        if response.status_code == 200:
            pool = response.json()["pool"]
            print_success(f"Pool details: {pool['current_members']} members, ${pool['total_pool_amount']} total")
    else:
        print_error(f"Failed to create pool: {response.text}")

def test_challenges(users):
    """Test challenges"""
    print_section("🎯 TESTING CHALLENGES")
    
    alice = users["alice_astro"]
    
    # Create challenge
    start_date = datetime.now().isoformat()
    end_date = (datetime.now() + timedelta(days=7)).isoformat()
    
    response = requests.post(
        f"{BASE_URL}{API_PREFIX}/challenges/create",
        headers={"Authorization": f"Bearer {alice['token']}"},
        json={
            "title": "January Lucky Draw Challenge",
            "description": "Win the most this week!",
            "start_date": start_date,
            "end_date": end_date,
            "lottery_type": "6/49",
            "difficulty": "medium",
            "prize_pool": 500.00,
            "max_participants": 10
        }
    )
    
    if response.status_code == 200:
        challenge_data = response.json()["challenge"]
        challenge_id = challenge_data["id"]
        print_success(f"Created challenge: {challenge_id}")
        
        # Users join
        for username, user_data in users.items():
            response = requests.post(
                f"{BASE_URL}{API_PREFIX}/challenges/{challenge_id}/join",
                headers={"Authorization": f"Bearer {user_data['token']}"}
            )
            
            if response.status_code == 200:
                print_success(f"  {username} joined challenge")
            else:
                print_error(f"  {username} failed to join: {response.text}")
        
        # Get leaderboard
        response = requests.get(
            f"{BASE_URL}{API_PREFIX}/challenges/{challenge_id}/leaderboard",
            headers={"Authorization": f"Bearer {alice['token']}"}
        )
        
        if response.status_code == 200:
            leaderboard = response.json()["leaderboard"]
            print_success(f"Challenge leaderboard: {len(leaderboard)} participants")
    else:
        print_error(f"Failed to create challenge: {response.text}")

def test_astrologers(users):
    """Test astrologer directory"""
    print_section("👨‍🔬 TESTING ASTROLOGER DIRECTORY")
    
    bob = users["bob_lucky"]
    alice = users["alice_astro"]
    
    # Register as astrologer
    response = requests.post(
        f"{BASE_URL}{API_PREFIX}/astrologers/register",
        headers={"Authorization": f"Bearer {bob['token']}"},
        json={
            "title": "Master Vedic Astrologer",
            "bio": "15+ years of experience in Vedic astrology and numerology",
            "specialties": "Vedic Astrology, Numerology, Tarot",
            "hourly_rate": 50.00,
            "experience_years": 15,
            "certification": "International Astrology Association"
        }
    )
    
    if response.status_code == 200:
        print_success(f"Registered {bob['username']} as astrologer")
        
        # Search astrologers
        response = requests.get(
            f"{BASE_URL}{API_PREFIX}/astrologers/search?specialty=Vedic",
            headers={"Authorization": f"Bearer {alice['token']}"}
        )
        
        if response.status_code == 200:
            astrologers = response.json()["astrologers"]
            print_success(f"Found {len(astrologers)} astrologer(s)")
            if astrologers:
                print_info(f"  {astrologers[0]['name']}: ${astrologers[0]['hourly_rate']}/hr")
        else:
            print_error(f"Failed to search: {response.text}")
    else:
        print_error(f"Failed to register: {response.text}")

def test_consultations(users):
    """Test consultation booking"""
    print_section("📞 TESTING CONSULTATIONS")
    
    bob = users["bob_lucky"]
    alice = users["alice_astro"]
    
    # Book consultation
    scheduled_time = (datetime.now() + timedelta(days=1)).isoformat()
    
    response = requests.post(
        f"{BASE_URL}{API_PREFIX}/consultations/book",
        headers={"Authorization": f"Bearer {alice['token']}"},
        json={
            "astrologer_id": bob["user_id"],
            "topic": "Career and Life Path Guidance",
            "scheduled_time": scheduled_time,
            "duration_minutes": 60
        }
    )
    
    if response.status_code == 200:
        data = response.json()
        print_success(f"Consultation booked: ${data['cost']}")
        print_info(f"  Session ID: {data['session_id']}")
        print_info(f"  Scheduled: {data['scheduled_time']}")
    else:
        print_error(f"Failed to book: {response.text}")

def main():
    """Run all tests"""
    print(f"\n{BLUE}{'='*60}")
    print(f"  🎰 ASTROLUCK BACKEND TEST SUITE")
    print(f"  Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*60}{RESET}\n")
    
    # Health check
    if not health_check():
        return
    
    # Register users
    users = register_users()
    if not users:
        print_error("No users registered. Stopping tests.")
        return
    
    # Update profiles
    update_user_profiles(users)
    
    # Test features
    test_lottery_generation(users)
    test_daily_insights(users)
    test_badges(users)
    test_leaderboard(users)
    test_subscriptions(users)
    test_pools(users)
    test_challenges(users)
    test_astrologers(users)
    test_consultations(users)
    
    # Summary
    print_section("✅ TEST SUMMARY")
    print_success(f"All tests completed!")
    print_info(f"Test users registered: {', '.join([u['username'] for u in TEST_USERS])}")
    print_info(f"API URL: {BASE_URL}")
    print_info(f"Swagger UI: {BASE_URL}/docs")
    print_info(f"\nNext steps:")
    print_info(f"1. Review API documentation at: {BASE_URL}/docs")
    print_info(f"2. Login as: alice_astro / TestPass123!")
    print_info(f"3. Test more endpoints using Swagger UI")

if __name__ == "__main__":
    main()
