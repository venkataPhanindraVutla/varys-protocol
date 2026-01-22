# AI Meeting Assistant

Production-ready backend for AI-powered meeting transcription and summarization.

## Architecture

```
┌─────────────────┐
│   Frontend      │
│  (Port 3000)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Spring Boot    │  ◄── REST API + Business Logic
│  (Port 8080)    │      /api/backend/v1/*
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   FastAPI       │  ◄── AI Processing
│  (Port 8000)    │      /api/ai/v1/*
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   MongoDB       │  ◄── External Database
│  (Cloud Atlas)  │
└─────────────────┘
```

## Tech Stack

- **Spring Boot 3.2**: REST API, business logic, MongoDB integration
- **FastAPI**: AI processing (Whisper + LLM)
- **MongoDB Atlas**: External database (your personal URL)
- **Docker**: Single container deployment
- **OpenAI Whisper**: Audio transcription
- **OpenAI GPT**: Meeting summarization

## Project Structure

```
varys-protocol/
├── backend/
│   ├── springboot/
│   │   ├── src/main/java/com/meetings/backend/
│   │   │   ├── BackendApplication.java
│   │   │   ├── config/
│   │   │   │   ├── MongoConfig.java
│   │   │   │   └── WebConfig.java
│   │   │   ├── controller/
│   │   │   │   └── MeetingController.java
│   │   │   ├── service/
│   │   │   │   ├── MeetingService.java
│   │   │   │   └── AiClientService.java
│   │   │   ├── repository/
│   │   │   │   └── MeetingRepository.java
│   │   │   └── model/
│   │   │       └── Meeting.java
│   │   ├── src/main/resources/
│   │   │   └── application.yml
│   │   └── pom.xml
│   │
│   ├── python-ai/
│   │   ├── app/
│   │   │   ├── main.py
│   │   │   ├── schemas.py
│   │   │   ├── api/v1/
│   │   │   │   ├── transcribe.py
│   │   │   │   └── summarize.py
│   │   │   └── core/
│   │   │       ├── whisper_engine.py
│   │   │       └── llm_engine.py
│   │   └── requirements.txt
│   │
│   ├── Dockerfile
│   └── start.sh
│
├── docker-compose.yml
├── .env
└── README.md
```

## Quick Start

### Prerequisites

- Docker & Docker Compose
- OpenAI API key (for summarization)
- **Docker Memory: 6GB recommended** (Settings → Resources → Memory)

### Setup

1. **Clone and navigate:**
   ```bash
   cd varys-protocol
   ```

2. **Configure environment:**
   ```bash
   # Edit .env file and add your OpenAI API key
   # MongoDB URL is already configured
   nano .env
   ```

3. **Start services using the management script:**
   ```bash
   ./docker.sh start-dev
   ```

4. **Verify:**
   - Spring Boot: http://localhost:8080
   - FastAPI: http://localhost:8000/docs
   - Health check: http://localhost:8000/health

## Docker Management Script

The `docker.sh` script provides convenient commands for managing your services:

### Available Commands

```bash
./docker.sh start           # Start services (production mode)
./docker.sh start-dev       # Start services (dev mode + auto cleanup)
./docker.sh stop            # Stop all services
./docker.sh restart         # Restart services
./docker.sh restart-dev     # Restart services (dev mode)
./docker.sh logs            # View backend logs (follow mode)
./docker.sh status          # Show service status
./docker.sh health          # Check service health
./docker.sh clean           # Clean up Docker resources
./docker.sh help            # Show help message
```

### Common Workflows

**Development:**
```bash
# First time setup
./docker.sh start-dev

# View logs
./docker.sh logs

# Restart after code changes
./docker.sh restart-dev

# Clean up when done
./docker.sh clean
```

**Production:**
```bash
# Start services
./docker.sh start

# Check health
./docker.sh health

# View status
./docker.sh status
```

### What the Script Does

- ✅ Checks Docker is running
- ✅ Validates `.env` file exists
- ✅ Checks Docker memory allocation (warns if < 4GB)
- ✅ Auto-prunes Docker system in dev mode (saves space)
- ✅ Waits for health checks (FastAPI: 30s, Spring Boot: 60s)
- ✅ Shows service URLs when ready
- ✅ Colored output for easy reading

## API Endpoints

### Spring Boot (`/api/backend/v1`)

#### Upload Meeting
```bash
POST /api/backend/v1/meetings
Content-Type: multipart/form-data

# Example
curl -X POST http://localhost:8080/api/backend/v1/meetings \
  -F "audio=@meeting.wav"
```

**Response:**
```json
{
  "id": "65abc123...",
  "audioPath": "uploads/audio/uuid.wav",
  "transcription": "Full meeting transcription...",
  "summary": "Meeting summary...",
  "actionItems": ["Action 1", "Action 2"],
  "createdAt": "2026-01-22T19:30:00",
  "updatedAt": "2026-01-22T19:30:15"
}
```

#### Get Meeting
```bash
GET /api/backend/v1/meetings/{id}
```

#### List All Meetings
```bash
GET /api/backend/v1/meetings
```

#### Delete Meeting
```bash
DELETE /api/backend/v1/meetings/{id}
```

### FastAPI (`/api/ai/v1`)

#### Transcribe Audio
```bash
POST /api/ai/v1/transcribe
Content-Type: multipart/form-data

curl -X POST http://localhost:8000/api/ai/v1/transcribe \
  -F "audio=@meeting.wav"
```

#### Summarize Text
```bash
POST /api/ai/v1/summarize
Content-Type: application/json

curl -X POST http://localhost:8000/api/ai/v1/summarize \
  -H "Content-Type: application/json" \
  -d '{"text": "Meeting transcription..."}'
```

## Development

### Run Spring Boot Locally
```bash
cd backend/springboot
mvn spring-boot:run
```

### Run FastAPI Locally
```bash
cd backend/python-ai
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MONGODB_URI` | MongoDB connection string | (your Atlas URL) |
| `OPENAI_API_KEY` | OpenAI API key | Required |
| `WHISPER_MODEL` | Whisper model size | `base` |

**Whisper Models:**
- `tiny`: Fastest, least accurate
- `base`: Good balance (default)
- `small`: Better accuracy
- `medium`: High accuracy
- `large`: Best accuracy, slowest

## File Responsibilities

### Spring Boot

- **BackendApplication.java**: Entry point, starts Spring Boot
- **MongoConfig.java**: MongoDB connection setup
- **WebConfig.java**: CORS and SPA routing
- **Meeting.java**: MongoDB document model
- **MeetingRepository.java**: Database CRUD operations
- **AiClientService.java**: HTTP client for FastAPI
- **MeetingService.java**: Business logic orchestration
- **MeetingController.java**: REST API endpoints
- **application.yml**: Configuration (ports, DB, logging)

### FastAPI

- **main.py**: FastAPI app entry point
- **schemas.py**: Pydantic request/response models
- **whisper_engine.py**: Whisper model loader and inference
- **llm_engine.py**: LLM client for summarization
- **transcribe.py**: Transcription endpoint
- **summarize.py**: Summarization endpoint

### Docker

- **Dockerfile**: Multi-service container (Java + Python)
- **start.sh**: Startup script (FastAPI → Spring Boot)
- **docker-compose.yml**: Service orchestration

## Testing

### Manual Testing Flow

1. **Upload audio:**
   ```bash
   curl -X POST http://localhost:8080/api/backend/v1/meetings \
     -F "audio=@test.wav"
   ```

2. **Check response** for transcription and summary

3. **List meetings:**
   ```bash
   curl http://localhost:8080/api/backend/v1/meetings
   ```

4. **Verify MongoDB** (check Atlas dashboard for new documents)

### Health Checks

```bash
# FastAPI health
curl http://localhost:8000/health

# Spring Boot actuator (if enabled)
curl http://localhost:8080/actuator/health
```

## Deployment

### Production Checklist

- [ ] Set strong MongoDB password
- [ ] Secure OpenAI API key
- [ ] Enable HTTPS
- [ ] Configure firewall rules
- [ ] Set up monitoring/logging
- [ ] Configure backup strategy
- [ ] Review CORS settings

### Scaling to Microservices

This architecture is microservice-ready:

1. **Separate containers:**
   - Split Dockerfile into two
   - Create separate docker-compose services

2. **Add API Gateway:**
   - Use Nginx or Kong
   - Route `/api/backend/*` → Spring Boot
   - Route `/api/ai/*` → FastAPI

3. **Add message queue:**
   - RabbitMQ or Kafka
   - Async processing for long transcriptions

## Troubleshooting

### MongoDB Connection Failed
- Verify `MONGODB_URI` in `.env`
- Check network connectivity
- Confirm MongoDB Atlas whitelist includes your IP

### FastAPI Not Starting
- Check Python dependencies: `pip install -r requirements.txt`
- Verify port 8000 is available
- Check logs: `docker-compose logs backend`

### Transcription Errors
- Ensure audio format is supported (wav, mp3, m4a)
- Check file size (< 100MB)
- Verify FFmpeg is installed in container

### Summarization Errors
- Confirm `OPENAI_API_KEY` is set
- Check OpenAI API quota/billing
- Review FastAPI logs for detailed errors

## License

MIT

## Author

Phani Vutla