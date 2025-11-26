# ZenBPM All In One docker image

## Quick Start (Using Pre-built Image)

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

## Building Locally

If you want to build the image yourself:

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

## Automated Builds

This project uses GitHub Actions to automatically build and publish Docker images to GitHub Container Registry (ghcr.io). Images are built:

- On every push to the `main` branch (tagged as `latest` and `main`)
- On every pull request (for testing, not published)
- On every tagged release (tagged with the version number)

The workflow includes:

- Multi-platform builds (AMD64 and ARM64)
- Vulnerability scanning with Trivy
- Automated tagging based on Git references
- Build caching for faster subsequent builds

## Security

All published images are automatically scanned for vulnerabilities using Trivy. Security scan results are available in the GitHub Security tab of this repository.
