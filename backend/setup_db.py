import sqlite3
from pathlib import Path

# Create database file
db_path = Path(__file__).parent / "astroluck.db"

# SQL to create tables
sql_commands = [
    """
    CREATE TABLE IF NOT EXISTS "user" (
        id VARCHAR(36) PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        username VARCHAR(100) UNIQUE NOT NULL,
        hashed_password VARCHAR(255) NOT NULL,
        full_name VARCHAR(255),
        gender VARCHAR(20),
        birth_date DATETIME,
        birth_time VARCHAR(10),
        birth_place VARCHAR(255),
        latitude FLOAT,
        longitude FLOAT,
        is_active BOOLEAN DEFAULT 1,
        is_verified BOOLEAN DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS lottery_history (
        id VARCHAR(36) PRIMARY KEY,
        user_id VARCHAR(36) NOT NULL,
        lottery_type VARCHAR(50) NOT NULL,
        numbers VARCHAR(255) NOT NULL,
        generated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        play_date DATETIME,
        life_path_number INTEGER,
        daily_lucky_number INTEGER,
        lucky_color VARCHAR(50),
        energy_level VARCHAR(20),
        is_result_checked BOOLEAN DEFAULT 0,
        result_numbers VARCHAR(255),
        matched_count INTEGER DEFAULT 0,
        prize_amount FLOAT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES "user"(id)
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS user_analytics (
        id VARCHAR(36) PRIMARY KEY,
        user_id VARCHAR(36) UNIQUE NOT NULL,
        total_plays INTEGER DEFAULT 0,
        total_winners INTEGER DEFAULT 0,
        total_winnings FLOAT DEFAULT 0.0,
        favorite_lottery_type VARCHAR(50),
        most_used_numbers VARCHAR(255),
        lucky_day VARCHAR(20),
        winning_pattern TEXT,
        success_rate FLOAT DEFAULT 0.0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES "user"(id)
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS lucky_share (
        id VARCHAR(36) PRIMARY KEY,
        user_id VARCHAR(36) NOT NULL,
        numbers VARCHAR(255) NOT NULL,
        lottery_type VARCHAR(50) NOT NULL,
        description TEXT,
        likes_count INTEGER DEFAULT 0,
        comments_count INTEGER DEFAULT 0,
        is_public BOOLEAN DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES "user"(id)
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS user_followers (
        follower_id VARCHAR(36),
        following_id VARCHAR(36),
        PRIMARY KEY (follower_id, following_id),
        FOREIGN KEY(follower_id) REFERENCES "user"(id),
        FOREIGN KEY(following_id) REFERENCES "user"(id)
    )
    """,
]

try:
    print("Creating SQLite database...")
    conn = sqlite3.connect(str(db_path))
    cursor = conn.cursor()
    
    # Enable foreign keys
    cursor.execute("PRAGMA foreign_keys = ON")
    
    # Create tables
    for sql in sql_commands:
        cursor.execute(sql)
    
    conn.commit()
    conn.close()
    
    print(f"✓ Database created successfully!")
    print(f"✓ Location: {db_path}")
    print(f"✓ Tables created: user, lottery_history, user_analytics, lucky_share")
    
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
