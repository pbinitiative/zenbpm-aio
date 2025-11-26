.PHONY: run-infra stop-infra run-app stop-app

# You can override COMPOSE if you prefer the legacy docker-compose CLI
# Example: make run-infra COMPOSE="docker-compose"
COMPOSE ?= docker compose
COMPOSE_FILE := infra/docker-compose.yml

run-infra:
	$(COMPOSE) -f $(COMPOSE_FILE) up -d

stop-infra:
	$(COMPOSE) -f $(COMPOSE_FILE) down

# Run the app service (docker run) from project root with access to host localhost
run-app:
	docker run -d \
	  --name vig-showcase-be \
	  --add-host=host.docker.internal:host-gateway \
	  -v "./app/vig-showcase:/app/vig-showcase/vig-showcase" \
	  -v "./app/rules:/rules" \
	  alpine:3.18 \
	  /app/vig-showcase/vig-showcase \
	  --openai-api-key "put_your_key_here" \

# Stop and remove the app container
stop-app:
	-@docker rm -f vig-showcase-be 2>/dev/null || true
