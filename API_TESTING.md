# Testing the AI Meeting Assistant API

## Create Meeting Data

### Option 1: Upload Audio File (Full Flow)

This will trigger the complete workflow: upload → transcribe → summarize → store in MongoDB.

```bash
# Upload an audio file
curl -X POST http://localhost:8080/api/backend/v1/meetings \
  -F "audio=@test_meeting.wav" \
  -H "Accept: application/json"
```

**Expected Response:**
```json
{
  "id": "65abc123def456...",
  "audioPath": "uploads/audio/uuid.wav",
  "transcription": "Transcribed text from Whisper...",
  "summary": "Meeting summary from LLM...",
  "actionItems": ["Action item 1", "Action item 2"],
  "createdAt": "2026-01-22T20:30:00",
  "updatedAt": "2026-01-22T20:30:15"
}
```

### Option 2: Create Test Audio File

If you don't have an audio file, create a simple test file:

```bash
# Create a 5-second test audio file (requires ffmpeg)
ffmpeg -f lavfi -i "sine=frequency=1000:duration=5" \
  -ac 1 -ar 16000 test_meeting.wav -y

# Or download a sample
curl -o test_meeting.wav https://www2.cs.uic.edu/~i101/SoundFiles/BabyElephantWalk60.wav
```

### Option 3: Test with FastAPI Directly

Test the AI services independently:

**Transcribe Audio:**
```bash
curl -X POST http://localhost:8000/api/ai/v1/transcribe \
  -F "audio=@test_meeting.wav" \
  -H "Accept: application/json"
```

**Summarize Text:**
```bash
curl -X POST http://localhost:8000/api/ai/v1/summarize \
  -H "Content-Type: application/json" \
  -d '{
    "text": "This is a test meeting transcription. We discussed the project timeline and agreed to deliver the MVP by next month. Action items: John will prepare the design mockups, Sarah will set up the development environment."
  }'
```

## Retrieve Meeting Data

### Get All Meetings
```bash
curl http://localhost:8080/api/backend/v1/meetings
```

### Get Specific Meeting
```bash
# Replace {id} with actual meeting ID from creation response
curl http://localhost:8080/api/backend/v1/meetings/{id}
```

### Delete Meeting
```bash
# Replace {id} with actual meeting ID
curl -X DELETE http://localhost:8080/api/backend/v1/meetings/{id}
```

## Expected Workflow

1. **Upload Audio** → Spring Boot saves file, creates meeting record
2. **Transcribe** → Spring Boot calls FastAPI → Whisper processes audio
3. **Update Meeting** → Transcription saved to MongoDB
4. **Summarize** → Spring Boot calls FastAPI → LLM generates summary
5. **Final Update** → Summary and action items saved to MongoDB
6. **Return** → Complete meeting object returned to client

## Troubleshooting

**If transcription fails:**
- Check FastAPI logs: `./docker.sh logs`
- Whisper model might still be downloading (first run)
- Audio format might not be supported

**If summarization fails:**
- Verify `OPENAI_API_KEY` is set in `.env`
- Check OpenAI API quota/billing
- LLM will return error message in summary field

**If MongoDB save fails:**
- Check MongoDB Atlas connection
- Verify IP whitelist in Atlas
- Check logs for connection errors

## Quick Test Script

```bash
#!/bin/bash

# Create test audio
ffmpeg -f lavfi -i "sine=frequency=1000:duration=5" \
  -ac 1 -ar 16000 test_meeting.wav -y 2>/dev/null

# Upload and create meeting
echo "Creating meeting..."
RESPONSE=$(curl -s -X POST http://localhost:8080/api/backend/v1/meetings \
  -F "audio=@test_meeting.wav")

echo "Response: $RESPONSE"

# Extract meeting ID (requires jq)
MEETING_ID=$(echo $RESPONSE | jq -r '.id')

echo "Meeting ID: $MEETING_ID"

# Retrieve meeting
echo "Retrieving meeting..."
curl -s http://localhost:8080/api/backend/v1/meetings/$MEETING_ID | jq

# Clean up
rm test_meeting.wav
```
