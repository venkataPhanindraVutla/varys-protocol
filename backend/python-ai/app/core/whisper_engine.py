import whisper
import os

class WhisperEngine:
    """
    Singleton Whisper model for audio transcription.
    Loads model once and reuses for all requests.
    """
    _instance = None
    _model = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(WhisperEngine, cls).__new__(cls)
        return cls._instance

    def __init__(self):
        if self._model is None:
            model_size = os.getenv("WHISPER_MODEL", "base")
            print(f"Loading Whisper model: {model_size}")
            self._model = whisper.load_model(model_size)
            print("Whisper model loaded successfully")

    def transcribe(self, audio_path: str) -> dict:
        """
        Transcribe audio file.
        
        Args:
            audio_path: Path to audio file
            
        Returns:
            dict with 'text', 'language', and other metadata
        """
        result = self._model.transcribe(audio_path)
        return result
