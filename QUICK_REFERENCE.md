# AI Meeting Assistant - Quick Reference

## ✅ Current Status

**All services are running and verified!**

```bash
✓ Spring Boot: http://localhost:8080
✓ FastAPI: http://localhost:8000
✓ MongoDB: meetingdb (connected)
```

## Quick Commands

```bash
# Start services
./docker.sh start-dev

# View logs
./docker.sh logs

# Check health
./docker.sh health

# Test API
./test_api.sh

# Stop services
./docker.sh stop

# Clean up
./docker.sh clean
```

## Create Meeting Data

### Simple curl command:
```bash
curl -X POST http://localhost:8080/api/backend/v1/meetings \
  -F "audio=@your_audio_file.wav"
```

### Get all meetings:
```bash
curl http://localhost:8080/api/backend/v1/meetings
```

## Database Info

- **Database Name:** `meetingdb`
- **Collection:** `meetings`
- **Connection:** MongoDB Atlas (cluster0.gddku.mongodb.net)

View in MongoDB Atlas:
1. Go to MongoDB Atlas dashboard
2. Browse Collections
3. Database: `meetingdb` → Collection: `meetings`

## Files Created

| File | Purpose |
|------|---------|
| `docker.sh` | Docker management (start, stop, logs, etc.) |
| `test_api.sh` | API testing script |
| `API_TESTING.md` | Complete API documentation |
| `DOCKER_USAGE.md` | Docker script reference |
| `QUICKSTART.md` | Quick start guide |
| `README.md` | Full documentation |

## Next Steps

1. **Add OpenAI API Key** (for summarization):
   ```bash
   nano .env
   # Add: OPENAI_API_KEY=sk-your-key-here
   ```

2. **Test with real audio**:
   - Record audio with QuickTime
   - Upload via curl command above

3. **Check MongoDB**:
   - Verify data appears in Atlas dashboard

## Architecture

```
User → Spring Boot (8080) → FastAPI (8000) → Whisper/LLM
                ↓
         MongoDB Atlas
```

## Troubleshooting

**Services not responding?**
```bash
./docker.sh status
./docker.sh logs
```

**Need to restart?**
```bash
./docker.sh restart-dev
```

**Clean slate?**
```bash
./docker.sh clean
./docker.sh start-dev
```

## Documentation

- [README.md](file:///Users/abcd/Desktop/files/varys-protocol/README.md) - Full documentation
- [API_TESTING.md](file:///Users/abcd/Desktop/files/varys-protocol/API_TESTING.md) - API examples
- [DOCKER_USAGE.md](file:///Users/abcd/Desktop/files/varys-protocol/DOCKER_USAGE.md) - Docker commands
- [QUICKSTART.md](file:///Users/abcd/Desktop/files/varys-protocol/QUICKSTART.md) - Setup guide
