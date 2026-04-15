@echo off
REM Setup script for AstroLuck Backend on Windows

echo ================================================
echo AstroLuck Backend Setup for Windows
echo ================================================
echo.

REM Check Python version
echo Checking Python version...
python --version
echo.

REM Create virtual environment
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Install dependencies
echo Installing dependencies...
python -m pip install --upgrade pip
pip install -r requirements.txt

REM Setup environment file
if not exist ".env" (
    echo Creating .env file from .env.example...
    copy .env.example .env
    echo [WARNING] Please update .env with your settings
)

REM Check database connection
echo.
echo Checking database connection...
python -c "from app.db import engine; engine.connect(); print('[OK] Database connection successful')" || (
    echo [WARNING] Could not connect to database. Make sure PostgreSQL is running and DATABASE_URL is correct.
)

echo.
echo ================================================
echo Setup Complete!
echo ================================================
echo.
echo To start the server, run:
echo   uvicorn app.main:app --reload
echo.
echo API Documentation will be at:
echo   http://localhost:8000/docs
echo.
pause
