from pydantic import BaseModel
from typing import List, Optional

class TranscribeResponse(BaseModel):
    transcription: str
    language: Optional[str] = None
    duration: Optional[float] = None

class SummarizeRequest(BaseModel):
    text: str

class SummarizeResponse(BaseModel):
    summary: str
    action_items: List[str]
