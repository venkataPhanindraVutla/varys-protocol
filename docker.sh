#!/bin/bash

# Docker Management Script for AI Meeting Assistant
# Features:
# - Automatic Docker system prune on start-dev (for space management)
# - Health checks for FastAPI and Spring Boot services
# - Environment validation
# - Support for both Docker Compose v1 and v2

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    print_success "Docker is running"
}

# Function to check if Docker Compose is available
check_docker_compose() {
    # Check for docker compose (v2) first
    if docker compose version > /dev/null 2>&1; then
        print_success "Docker Compose (v2) is available"
        return 0
    # Fallback to docker-compose (v1)
    elif command -v docker-compose &> /dev/null; then
        print_success "Docker Compose (v1) is available"
        return 0
    else
        print_error "Docker Compose is not installed. Please install Docker Compose and try again."
        exit 1
    fi
}

# Function to check system requirements
check_system_requirements() {
    print_status "Checking system requirements..."
    
    # Check Docker memory allocation
    docker_mem=$(docker info --format '{{.MemTotal}}' 2>/dev/null || echo "0")
    if [ "$docker_mem" -gt 0 ]; then
        docker_mem_gb=$((docker_mem / 1024 / 1024 / 1024))
        if [ "$docker_mem_gb" -lt 4 ]; then
            print_warning "Docker memory is ${docker_mem_gb}GB. Recommended: 6GB or more"
            print_warning "Increase in Docker Desktop → Settings → Resources → Memory"
        else
            print_success "Docker memory: ${docker_mem_gb}GB"
        fi
    fi
    
    print_success "System requirements check completed"
}

# Function to check environment file
check_env_file() {
    if [ ! -f .env ]; then
        print_error ".env file not found!"
        print_status "Please create a .env file with your environment variables."
        print_status "You can copy from .env.example:"
        print_status "  cp .env.example .env"
        print_status "Then edit .env with your actual values."
        exit 1
    fi
    
    # Check if .env file has required variables
    if ! grep -q "MONGODB_URI" .env; then
        print_warning ".env file found but MONGODB_URI is not set"
    fi
    
    if ! grep -q "OPENAI_API_KEY" .env; then
        print_warning ".env file found but OPENAI_API_KEY is not set"
        print_warning "LLM summarization will not work without OpenAI API key"
    fi
    
    print_success ".env file found and checked"
}

# Function to run docker compose command
run_docker_compose() {
    # Try docker compose (v2) first
    if docker compose version > /dev/null 2>&1; then
        docker compose "$@"
    # Fallback to docker-compose (v1)
    else
        docker-compose "$@"
    fi
}

# Function to build and start services
start_services() {
    local should_prune=${1:-false}
    
    # Check system requirements
    check_system_requirements
    
    # Check environment file before starting
    check_env_file
    
    # Perform Docker system prune if requested (for development)
    if [ "$should_prune" = "true" ]; then
        print_status "Performing Docker system prune to free up space..."
        docker system prune -f
        print_success "Docker system prune completed"
    fi
    
    print_status "Building and starting AI Meeting Assistant services..."
    run_docker_compose up --build -d
    
    print_success "Services started successfully!"
    print_status "Waiting for services to be ready..."
    sleep 5
    
    # Check service health
    check_service_health
}

# Function to check service health
check_service_health() {
    print_status "Checking service health..."
    
    # Wait up to 30 seconds for FastAPI
    print_status "Checking FastAPI health..."
    for i in {1..30}; do
        if curl -f -s http://localhost:8000/health > /dev/null 2>&1; then
            print_success "✓ FastAPI is healthy (http://localhost:8000)"
            break
        fi
        if [ $i -eq 30 ]; then
            print_warning "FastAPI health check timed out"
            print_status "Check logs with: $0 logs"
        fi
        sleep 1
    done
    
    # Wait up to 60 seconds for Spring Boot
    print_status "Checking Spring Boot health..."
    for i in {1..60}; do
        if curl -f -s http://localhost:8080/api/backend/v1/meetings > /dev/null 2>&1; then
            print_success "✓ Spring Boot is healthy (http://localhost:8080)"
            break
        fi
        if [ $i -eq 60 ]; then
            print_warning "Spring Boot health check timed out"
            print_status "Check logs with: $0 logs"
        fi
        sleep 1
    done
    
    echo ""
    print_success "Services are ready!"
    echo ""
    echo "  FastAPI Docs:  http://localhost:8000/docs"
    echo "  Spring Boot:   http://localhost:8080/api/backend/v1/meetings"
    echo ""
}

# Function to stop services
stop_services() {
    print_status "Stopping services..."
    run_docker_compose down
    print_success "Services stopped"
}

# Function to show logs
show_logs() {
    local service=${1:-backend}
    
    print_status "Showing logs for $service..."
    run_docker_compose logs -f $service
}

# Function to show service status
show_status() {
    print_status "Service status:"
    run_docker_compose ps
}

# Function to clean up
cleanup() {
    print_status "Cleaning up Docker resources..."
    run_docker_compose down -v --remove-orphans
    docker system prune -f
    print_success "Cleanup completed"
}

# Function to show help
show_help() {
    echo "Docker Management Script for AI Meeting Assistant"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start           - Start all services (production mode)"
    echo "  start-dev       - Start all services (development mode + auto Docker prune)"
    echo "  stop            - Stop all services"
    echo "  restart         - Restart all services"
    echo "  restart-dev     - Restart all services (development mode)"
    echo "  logs            - Show logs for backend service"
    echo "  status          - Show service status"
    echo "  health          - Check service health"
    echo "  clean           - Clean up Docker resources (volumes, orphans, system prune)"
    echo "  help            - Show this help message"
    echo ""
    echo "Environment:"
    echo "  The script requires a .env file with:"
    echo "    - MONGODB_URI (your MongoDB Atlas connection string)"
    echo "    - OPENAI_API_KEY (for LLM summarization)"
    echo "    - WHISPER_MODEL (optional, default: base)"
    echo ""
    echo "Examples:"
    echo "  $0 start-dev     # Start in development mode with auto-cleanup"
    echo "  $0 logs          # View backend logs"
    echo "  $0 health        # Check if services are healthy"
    echo "  $0 clean         # Clean up all Docker resources"
}

# Main script logic
case "${1:-help}" in
    start)
        check_docker
        check_docker_compose
        start_services false
        ;;
    start-dev)
        check_docker
        check_docker_compose
        start_services true
        ;;
    stop)
        stop_services
        ;;
    restart)
        stop_services
        start_services false
        ;;
    restart-dev)
        stop_services
        start_services true
        ;;
    logs)
        show_logs "${2:-backend}"
        ;;
    status)
        show_status
        ;;
    health)
        check_service_health
        ;;
    clean)
        cleanup
        ;;
    help|*)
        show_help
        ;;
esac
