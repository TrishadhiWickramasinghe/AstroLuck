#!/bin/bash

# Setup script for AstroLuck Backend

set -e

echo "================================================"
echo "AstroLuck Backend Setup"
echo "================================================"
echo ""

# Check Python version
echo "Checking Python version..."
python --version
echo ""

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Setup environment file
if [ ! -f ".env" ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
    echo "⚠️  Please update .env with your settings"
fi

# Check database connection
echo ""
echo "Checking database connection..."
python -c "from app.db import engine; engine.connect(); print('✓ Database connection successful')" || {
    echo "⚠️  Could not connect to database. Make sure PostgreSQL is running and DATABASE_URL is correct."
}

echo ""
echo "================================================"
echo "Setup Complete!"
echo "================================================"
echo ""
echo "To start the server, run:"
echo "  uvicorn app.main:app --reload"
echo ""
echo "API Documentation will be at:"
echo "  http://localhost:8000/docs"
echo ""
