@echo off
REM Simple startup script - installs FastAPI if needed and starts server

echo.
echo Starting AstroLuck Backend...
echo.

REM Try to import fastapi to check if installed
python -c "import fastapi" >nul 2>&1
if errorlevel 1 (
    echo Installing FastAPI and dependencies...
    pip install -q fastapi uvicorn sqlalchemy pydantic pydantic-settings python-jose[cryptography] passlib[bcrypt] python-multipart email-validator python-dotenv
    if errorlevel 1 (
        echo.
        echo ERROR: Failed to install dependencies
        pause
        exit /b 1
    )
    echo Installed successfully!
)

echo.
echo ================================================
echo   AstroLuck Backend Server
echo ================================================
echo.
echo Server starting at: http://localhost:8000
echo API Documentation: http://localhost:8000/docs  
echo Database: SQLite (astroluck.db)
echo.
echo Press Ctrl+C to stop
echo.

python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
