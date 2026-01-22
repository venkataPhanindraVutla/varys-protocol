from fastapi import APIRouter, File, UploadFile, HTTPException
from app.schemas import TranscribeResponse
from app.core.whisper_engine import WhisperEngine
import tempfile
import os

router = APIRouter()
whisper_engine = WhisperEngine()

@router.post("/transcribe", response_model=TranscribeResponse)
async def transcribe_audio(audio: UploadFile = File(...)):
    """
    Transcribe audio file using Whisper model.
    
    Accepts: Audio file (wav, mp3, m4a, etc.)
    Returns: Transcription text with metadata
    """
    try:
        # Save uploaded file temporarily
        with tempfile.NamedTemporaryFile(delete=False, suffix=os.path.splitext(audio.filename)[1]) as temp_file:
            content = await audio.read()
            temp_file.write(content)
            temp_path = temp_file.name

        try:
            # Transcribe
            result = whisper_engine.transcribe(temp_path)
            
            return TranscribeResponse(
                transcription=result["text"],
                language=result.get("language"),
                duration=None  # Can be extracted from audio metadata if needed
            )
        finally:
            # Clean up temp file
            if os.path.exists(temp_path):
                os.remove(temp_path)
                
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Transcription failed: {str(e)}")
