#!/usr/bin/env python
"""
Database initialization script
"""
import sys
from pathlib import Path

# Add backend to path
sys.path.insert(0, str(Path(__file__).parent))

try:
    print("Creating database tables...")
    from app.db import Base, engine
    Base.metadata.create_all(bind=engine)
    print("✓ Database created successfully!")
    print("✓ All tables initialized")
    print("\nDatabase location: astroluck.db")
except Exception as e:
    print(f"❌ Error creating database: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
