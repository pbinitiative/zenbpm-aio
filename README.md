# ZenBPM All In One docker image

## Quick Start Options

### Option 1: Using Makefile for Development

For local development with infrastructure services and the showcase app:

```sh
# Start infrastructure services (using docker compose)
make run-infra

# Stop infrastructure services
make stop-infra
```

### Option 2: Using Pre-built All-in-One Image

Pull and run the latest pre-built image from GitHub Container Registry:

```sh
# Pull the latest image
docker pull ghcr.io/pbinitiative/zenbpm-aio:latest --platform linux/amd64

# Run the container
docker run -p 3000:80 -p 8080:8080 -p 9090:9090 \
  -v ./forms:/app/forms \
  -v ./node-1:/app/zenbpm/node-1 \
  --name zenbpm-aio \
  ghcr.io/pbinitiative/zenbpm-aio:latest
```

### Option 3: Building All-in-One Image Locally

If you want to build the all-in-one image yourself:

```sh
docker build -t zenbpm-aio .
docker run -p 3000:80 -p 8080:8080 -p 9090:9090 -v ./forms:/app/forms -v ./node-1:/app/zenbpm/node-1 --name zenbpm-aio zenbpm-aio
```

## Available Image Tags

The following tags are available on GitHub Container Registry:

- `ghcr.io/pbinitiative/zenbpm-aio:latest` - Latest stable release
- `ghcr.io/pbinitiative/zenbpm-aio:main` - Latest development build
- `ghcr.io/pbinitiative/zenbpm-aio:v1.0.0` - Specific version releases
- `ghcr.io/pbinitiative/zenbpm-aio:main-<sha>` - Specific commit builds

## Makefile Commands

The project includes a Makefile with the following commands:

| Command           | Description                                            |
| ----------------- | ------------------------------------------------------ |
| `make run-infra`  | Start infrastructure services using docker compose     |
| `make stop-infra` | Stop infrastructure services                           |

**Customization:** You can override the compose command by setting the `COMPOSE` variable:

```sh
make run-infra COMPOSE="docker-compose"
```

## Services

| Service         | Port | Description                                              |
| --------------- | ---- | -------------------------------------------------------- |
| Nginx           | 3000 | Serving frontend and providing reverse proxy for backend |
| ZenBPM REST API | 8080 |                                                          |
| ZenBPM gRPC API | 9090 |                                                          |

## Volumes

| Volume               | Description                     |
| -------------------- | ------------------------------- |
| `/app/forms`         | Form definitions and metadata   |
| `/app/zenbpm/node-1` | Persistent engine state storage |

## Environment Variables

| Variable      | Default Value                        | Description                    |
| ------------- | ------------------------------------ | ------------------------------ |
| `PROFILE`     | `DEV`                                | Application profile            |
| `CONFIG_FILE` | `/zenhome/conf/zenbpm/conf-dev.yaml` | ZenBPM configuration file path |
