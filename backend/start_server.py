#!/usr/bin/env python
"""Start AstroLuck Backend Server"""

import uvicorn
import os
from pathlib import Path

def main():
    # Ensure we're in the right directory
    os.chdir(Path(__file__).parent)
    
    print("="*60)
    print("  🎰 Starting AstroLuck Backend")
    print("="*60)
    print("\nServer running at: http://localhost:8000")
    print("API Documentation: http://localhost:8000/docs")
    print("\nPress Ctrl+C to stop\n")
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )

if __name__ == "__main__":
    main()
