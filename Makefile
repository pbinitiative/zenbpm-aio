.PHONY: run-infra stop-infra run-app stop-app

# You can override COMPOSE if you prefer the legacy docker-compose CLI
# Example: make run-infra COMPOSE="docker-compose"
COMPOSE ?= docker compose
COMPOSE_FILE := infra/docker-compose.yml

run-infra:
	$(COMPOSE) -f $(COMPOSE_FILE) up -d

stop-infra:
	$(COMPOSE) -f $(COMPOSE_FILE) down
