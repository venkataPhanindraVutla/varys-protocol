import os
import openai
from typing import Dict, List

class LLMEngine:
    """
    LLM client for text summarization and action item extraction.
    """
    
    def __init__(self):
        self.api_key = os.getenv("OPENAI_API_KEY")
        if self.api_key:
            openai.api_key = self.api_key
        else:
            print("WARNING: OPENAI_API_KEY not set. LLM features will not work.")

    def summarize_meeting(self, transcription: str) -> Dict[str, any]:
        """
        Summarize meeting transcription and extract action items.
        
        Args:
            transcription: Full meeting transcription text
            
        Returns:
            dict with 'summary' and 'action_items'
        """
        if not self.api_key:
            return {
                "summary": "LLM not configured. Please set OPENAI_API_KEY.",
                "action_items": []
            }

        prompt = f"""
You are an AI assistant that summarizes meeting transcriptions.

Given the following meeting transcription, provide:
1. A concise summary (2-3 paragraphs)
2. A list of action items (if any)

Format your response as JSON with keys "summary" and "action_items" (array of strings).

Transcription:
{transcription}

Response (JSON only):
"""

        try:
            response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are a helpful assistant that summarizes meetings."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.3,
                max_tokens=1000
            )
            
            content = response.choices[0].message.content
            
            # Try to parse JSON response
            import json
            result = json.loads(content)
            
            return {
                "summary": result.get("summary", ""),
                "action_items": result.get("action_items", [])
            }
            
        except Exception as e:
            print(f"Error in LLM summarization: {e}")
            return {
                "summary": f"Error generating summary: {str(e)}",
                "action_items": []
            }
