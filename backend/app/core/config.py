from pydantic_settings import BaseSettings
from typing import List
import os


class Settings(BaseSettings):
    """Application settings"""
    
    # App
    PROJECT_NAME: str = "AstroLuck Backend"
    API_V1_STR: str = "/api/v1"
    DEBUG: bool = False
    
    # Database
    # Use SQLite for development if no PostgreSQL URL provided
    DATABASE_URL: str = "sqlite:///./astroluck.db"
    
    # Security
    SECRET_KEY: str = "your-secret-key-here"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # CORS
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:8000",
        "http://localhost:19006",  # Flutter Web
    ]
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
