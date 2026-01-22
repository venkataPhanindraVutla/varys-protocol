# Docker Management Script - Quick Reference

## Usage

```bash
./docker.sh [COMMAND]
```

## Commands

| Command | Description |
|---------|-------------|
| `start` | Start services (production mode) |
| `start-dev` | Start services (dev mode + auto cleanup) |
| `stop` | Stop all services |
| `restart` | Restart services |
| `restart-dev` | Restart services (dev mode) |
| `logs` | View backend logs (follow mode) |
| `status` | Show service status |
| `health` | Check service health |
| `clean` | Clean up Docker resources |
| `help` | Show help message |

## Examples

### First Time Setup
```bash
# Make script executable (one time)
chmod +x docker.sh

# Start in development mode
./docker.sh start-dev
```

### Development Workflow
```bash
# Start services
./docker.sh start-dev

# View logs
./docker.sh logs

# Check health
./docker.sh health

# Restart after changes
./docker.sh restart-dev

# Clean up when done
./docker.sh clean
```

### Production
```bash
# Start services
./docker.sh start

# Check status
./docker.sh status

# View logs
./docker.sh logs
```

## What Happens

### On `start-dev`:
1. ✅ Checks Docker is running
2. ✅ Validates `.env` file
3. ✅ Checks Docker memory (warns if < 4GB)
4. ✅ Runs `docker system prune -f` (frees space)
5. ✅ Builds and starts containers
6. ✅ Waits for FastAPI health (30s timeout)
7. ✅ Waits for Spring Boot health (60s timeout)
8. ✅ Shows service URLs

### On `clean`:
1. Stops all containers
2. Removes volumes
3. Removes orphaned containers
4. Runs `docker system prune -f`

## Troubleshooting

**Script not executable:**
```bash
chmod +x docker.sh
```

**Docker memory warning:**
- Open Docker Desktop
- Settings → Resources → Memory
- Increase to 6GB
- Apply & Restart

**Services not starting:**
```bash
# Check logs
./docker.sh logs

# Check status
./docker.sh status

# Clean and restart
./docker.sh clean
./docker.sh start-dev
```

**MongoDB connection issues:**
- Verify `MONGODB_URI` in `.env`
- Check MongoDB Atlas whitelist includes your IP

**OpenAI API errors:**
- Verify `OPENAI_API_KEY` in `.env`
- Check OpenAI account has credits
