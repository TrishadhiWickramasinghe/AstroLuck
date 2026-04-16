from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api import auth_router, users_router, community_router
from app.api.routes import insights, payments, pools, astrologers, intelligence, social, integrations, statistics
from app.db import engine
from app.models import Base

# Create tables
Base.metadata.create_all(bind=engine)

# Create FastAPI app
app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Backend API for AstroLuck Flutter App",
    version="1.0.0",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers - Core features
app.include_router(auth_router, prefix=settings.API_V1_STR)
app.include_router(users_router, prefix=settings.API_V1_STR)
app.include_router(community_router, prefix=settings.API_V1_STR)

# Include routers - New premium features
app.include_router(insights.router)
app.include_router(payments.router)
app.include_router(pools.router)
app.include_router(astrologers.router)
app.include_router(intelligence.router)
app.include_router(social.router)
app.include_router(integrations.router)
app.include_router(statistics.router)


@app.get("/")
def read_root():
    """Health check endpoint"""
    return {
        "message": "AstroLuck Backend",
        "version": "1.0.0",
        "status": "running",
    }


@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
    )
