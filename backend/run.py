#!/usr/bin/env python
"""
Quick development server starter script
"""
import os
import sys
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

def create_db():
    """Create database tables"""
    try:
        from app.db import engine, Base
        print("📦 Creating database tables...")
        Base.metadata.create_all(bind=engine)
        print("✓ Database tables created successfully")
        return True
    except Exception as e:
        print(f"❌ Error creating database: {e}")
        return False


def main():
    """Start the development server"""
    # Check if .env exists
    if not Path(".env").exists():
        print("⚠️  .env file not found. Creating from .env.local...")
        if Path(".env.local").exists():
            with open(".env.local") as f:
                env_content = f.read()
            with open(".env", "w") as f:
                f.write(env_content)
            print("✓ .env file created.")
        elif Path(".env.example").exists():
            with open(".env.example") as f:
                env_content = f.read()
            with open(".env", "w") as f:
                f.write(env_content)
            print("✓ .env file created from example.")
        else:
            print("❌ No .env configuration found!")
            return

    # Create database
    if not create_db():
        return

    try:
        import uvicorn
        print("\n" + "="*50)
        print("Starting AstroLuck Backend...")
        print("="*50)
        print("📖 API Docs: http://localhost:8000/docs")
        print("📚 ReDoc: http://localhost:8000/redoc")
        print("💾 Database: SQLite (astroluck.db)")
        print("="*50)
        print("Press Ctrl+C to stop\n")
        
        uvicorn.run(
            "app.main:app",
            host="0.0.0.0",
            port=8000,
            reload=True,
            log_level="info",
        )
    except KeyboardInterrupt:
        print("\n✓ Server stopped")
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
