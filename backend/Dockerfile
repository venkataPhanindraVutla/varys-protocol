FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install Java 17 and Python 3.11
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    python3.11 \
    python3.11-venv \
    python3-pip \
    maven \
    ffmpeg \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Spring Boot application
COPY springboot /app/springboot

# Build Spring Boot application
WORKDIR /app/springboot
RUN mvn clean package -DskipTests

# Copy Python application
COPY python-ai /app/python-ai

# Install Python dependencies
WORKDIR /app/python-ai
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Expose ports
EXPOSE 8000 8080

# Set working directory back to root
WORKDIR /app

# Run startup script
CMD ["/app/start.sh"]
