# Multi-stage Dockerfile for ZenBPM AIO

# Stage 1: Build ZenBPM (Go app)
FROM golang:1.24.5-alpine AS zenbpm-builder

# Install git and other dependencies
RUN apk add --no-cache git ca-certificates make bash curl gcc g++ musl-dev


# Set working directory
WORKDIR /app

# Clone ZenBPM repository
RUN git clone https://github.com/pbinitiative/zenbpm.git .

# Set environment variables for gcc
ENV CC=gcc
ENV CXX=g++
ENV CGO_CFLAGS='-w'
ENV CGO_CPPFLAGS='-w'
ENV CGO_CFLAGS_ALLOW="-Wno-error"
ENV CGO_ENABLED=1


# Build the Go application
RUN make build

# Stage 2: Build ZenBPM Showcase FE (Vue app)
FROM node:18-alpine AS frontend-builder

# Set working directory
WORKDIR /app

RUN apk add --no-cache git

# Clone ZenBPM Showcase FE repository
RUN git clone https://github.com/pbinitiative/zenbpm-showcase-fe.git .

# Install dependencies and build with development settings for readable output
RUN npm install
# Build with source maps and unminified output for debugging (Quasar specific)
# Increase Node.js heap size to prevent out of memory errors
RUN NODE_OPTIONS="--max-old-space-size=4096" npm run build -- --debug

# Final Stage: Runtime container
FROM alpine:3.18

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    bash \
    curl \
    supervisor \
    nginx

# Create application directories
RUN mkdir -p /app/zenbpm \
    /app/frontend \
    /zenhome/conf/zenbpm \
    /var/log/supervisor \
    /var/log/nginx \
    /run/nginx

# Copy built applications
COPY --from=zenbpm-builder /app/zenbpm /app/zenbpm/zenbpm
COPY --from=frontend-builder /app/dist/spa /app/frontend/

# Copy forms (forms and metadata)
COPY forms/ /app/forms/

# Copy configuration files
COPY conf-dev.yaml /zenhome/conf/zenbpm/conf-dev.yaml
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Create data directory
RUN mkdir -p /zenhome/data

# Expose ports
EXPOSE 80 8080 9090

# Set working directory
WORKDIR /app


ENV PROFILE="DEV"       
ENV CONFIG_FILE="/zenhome/conf/zenbpm/conf-dev.yaml"

VOLUME [ "/app/zenbpm/node-1",  "/app/forms"]

# Use supervisord to manage both processes
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
