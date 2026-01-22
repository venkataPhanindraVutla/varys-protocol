from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1 import transcribe, summarize

app = FastAPI(
    title="AI Meeting Assistant - AI Service",
    description="FastAPI service for audio transcription and text summarization",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(transcribe.router, prefix="/api/ai/v1", tags=["transcribe"])
app.include_router(summarize.router, prefix="/api/ai/v1", tags=["summarize"])

@app.get("/")
async def root():
    return {"message": "AI Meeting Assistant - AI Service", "status": "running"}

@app.get("/health")
async def health():
    return {"status": "healthy"}
