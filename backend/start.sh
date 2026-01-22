#!/bin/bash
set -e

echo "Starting AI Meeting Assistant services..."

# Start FastAPI in background
echo "Starting FastAPI service on port 8000..."
cd /app/python-ai
uvicorn app.main:app --host 0.0.0.0 --port 8000 &
FASTAPI_PID=$!

# Wait for FastAPI to be ready with health check
echo "Waiting for FastAPI to be ready..."
MAX_ATTEMPTS=30
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "✓ FastAPI health check passed (PID: $FASTAPI_PID)"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
        echo "ERROR: FastAPI failed to respond to health check after 30 seconds"
        kill $FASTAPI_PID 2>/dev/null || true
        exit 1
    fi
    sleep 1
done

# Check if FastAPI process is still running
if ! kill -0 $FASTAPI_PID 2>/dev/null; then
    echo "ERROR: FastAPI process died"
    exit 1
fi

echo "FastAPI started successfully on port 8000"

# Start Spring Boot in foreground
echo "Starting Spring Boot service on port 8080..."
cd /app/springboot
java -jar target/backend-1.0.0.jar &
SPRINGBOOT_PID=$!

# Wait for Spring Boot to be ready with health check
echo "Waiting for Spring Boot to be ready..."
MAX_ATTEMPTS=60
ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s http://localhost:8080/api/backend/v1/meetings > /dev/null 2>&1; then
        echo "✓ Spring Boot health check passed (PID: $SPRINGBOOT_PID)"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
        echo "ERROR: Spring Boot failed to respond after 60 seconds"
        kill $FASTAPI_PID 2>/dev/null || true
        kill $SPRINGBOOT_PID 2>/dev/null || true
        exit 1
    fi
    sleep 1
done

echo ""
echo "✓ All services started successfully!"
echo "  - FastAPI: http://localhost:8000 (PID: $FASTAPI_PID)"
echo "  - Spring Boot: http://localhost:8080 (PID: $SPRINGBOOT_PID)"
echo ""
echo "Services are ready to accept requests."

# Wait for Spring Boot to exit (foreground)
wait $SPRINGBOOT_PID

# If Spring Boot exits, kill FastAPI
echo "Spring Boot exited, shutting down FastAPI..."
kill $FASTAPI_PID 2>/dev/null || true
