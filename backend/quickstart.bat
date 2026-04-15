@echo off
REM Quick Start Script for AstroLuck Backend - Windows
REM This script sets up everything and starts the server

echo.
echo ================================================
echo   AstroLuck Backend - Quick Start
echo ================================================
echo.

REM Check Python
echo [1/4] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Download from: https://www.python.org/downloads/
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('python --version') do set PYTHON_VERSION=%%i
echo OK: %PYTHON_VERSION%
echo.

REM Create venv
if not exist "venv" (
    echo [2/4] Creating virtual environment...
    python -m venv venv
    if errorlevel 1 (
        echo ERROR: Failed to create virtual environment
        pause
        exit /b 1
    )
    echo OK: Virtual environment created
) else (
    echo [2/4] Virtual environment already exists
)
echo.

REM Activate venv
echo [3/4] Installing dependencies...
call venv\Scripts\activate.bat
python -m pip install --upgrade pip >nul 2>&1
pip install -r requirements.txt >nul 2>&1
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)
echo OK: Dependencies installed
echo.

REM Create .env
if not exist ".env" (
    echo [4/4] Creating configuration...
    if exist ".env.local" (
        copy .env.local .env >nul 2>&1
    ) else if exist ".env.example" (
        copy .env.example .env >nul 2>&1
    )
    echo OK: Configuration created
) else (
    echo [4/4] Configuration already exists
)
echo.

echo ================================================
echo   Setup Complete! Starting Server...
echo ================================================
echo.
echo Server will be available at:
echo   - API: http://localhost:8000
echo   - Docs: http://localhost:8000/docs
echo   - ReDoc: http://localhost:8000/redoc
echo.
echo Database: SQLite (astroluck.db) - No external setup needed!
echo.
echo Press Ctrl+C to stop the server
echo.

REM Start server
python run.py
