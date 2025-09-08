# ZenBPM All In One docker image

## Running

```sh
docker build -t zenbpm-aio .
docker run -p 3000:80 -p 8080:8080 -p 9090:9090 -v ./forms:/app/forms -v ./node-1:/app/zenbpm/node-1 --name zenbpm-aio zenbpm-aio
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
