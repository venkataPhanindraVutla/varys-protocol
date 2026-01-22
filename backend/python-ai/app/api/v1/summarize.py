from fastapi import APIRouter, HTTPException
from app.schemas import SummarizeRequest, SummarizeResponse
from app.core.llm_engine import LLMEngine

router = APIRouter()
llm_engine = LLMEngine()

@router.post("/summarize", response_model=SummarizeResponse)
async def summarize_text(request: SummarizeRequest):
    """
    Summarize meeting transcription and extract action items.
    
    Accepts: Transcription text
    Returns: Summary and action items
    """
    try:
        if not request.text or len(request.text.strip()) == 0:
            raise HTTPException(status_code=400, detail="Text cannot be empty")

        result = llm_engine.summarize_meeting(request.text)
        
        return SummarizeResponse(
            summary=result["summary"],
            action_items=result["action_items"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Summarization failed: {str(e)}")
