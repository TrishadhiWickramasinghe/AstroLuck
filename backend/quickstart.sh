#!/bin/bash
# Quick Start Script for AstroLuck Backend - macOS/Linux
# This script sets up everything and starts the server

echo ""
echo "================================================"
echo "  AstroLuck Backend - Quick Start"
echo "================================================"
echo ""

# Check Python
echo "[1/4] Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    echo "Install with: brew install python3 (macOS) or apt-get install python3 (Linux)"
    exit 1
fi
PYTHON_VERSION=$(python3 --version)
echo "OK: $PYTHON_VERSION"
echo ""

# Create venv
if [ ! -d "venv" ]; then
    echo "[2/4] Creating virtual environment..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to create virtual environment"
        exit 1
    fi
    echo "OK: Virtual environment created"
else
    echo "[2/4] Virtual environment already exists"
fi
echo ""

# Activate venv and install deps
echo "[3/4] Installing dependencies..."
source venv/bin/activate
python -m pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install dependencies"
    exit 1
fi
echo "OK: Dependencies installed"
echo ""

# Create .env
if [ ! -f ".env" ]; then
    echo "[4/4] Creating configuration..."
    if [ -f ".env.local" ]; then
        cp .env.local .env
    elif [ -f ".env.example" ]; then
        cp .env.example .env
    fi
    echo "OK: Configuration created"
else
    echo "[4/4] Configuration already exists"
fi
echo ""

echo "================================================"
echo "  Setup Complete! Starting Server..."
echo "================================================"
echo ""
echo "Server will be available at:"
echo "  - API: http://localhost:8000"
echo "  - Docs: http://localhost:8000/docs"
echo "  - ReDoc: http://localhost:8000/redoc"
echo ""
echo "Database: SQLite (astroluck.db) - No external setup needed!"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start server
source venv/bin/activate
python run.py
