SRCS         = srcs
DC_FILE = $(SRCS)/docker-compose.yml
ENV_FILE     = $(SRCS)/.env
DC_CMD = docker compose -f $(DC_FILE) --env-file $(ENV_FILE)

#Dir Host volume /home/login/data...
LOGIN = $(shell whoami)
DOCKER_DATA_DIR = /home/$(LOGIN)/data/docker

all: up

volumes:
	@mkdir -p "$(DOCKER_DATA_DIR)"
	@echo " Host data directories ready:"
	@echo " $(DOCKER_DATA_DIR)"

build: volumes
	$(DC_CMD) build

up: volumes
	$(DC_CMD) up -d --build

down:
	$(DC_CMD) down

start:
	$(DC_CMD) start

stop:
	$(DC_CMD) stop

restart:
	$(DC_CMD) restart

logs:
	-$(DC_CMD) logs --tail=200

ps:
	$(DC_CMD) ps

config:
	$(DC_CMD) config

clean:
	$(DC_CMD) down --remove-orphans

fclean:
	$(DC_CMD) down --remove-orphans -v --rmi all

prune:
	docker system prune -f --volumes

re: down up

help:
	@echo "Available targets:"
	@echo "make / make up   - Create host data directories, build images and start the project"
	@echo "make volumes     - Create the persistent host data directories"
	@echo "make build       - Build all service images"
	@echo "make down        - Stop and remove project containers"
	@echo "make start       - Start existing containers"
	@echo "make stop        - Stop running containers without removing them"
	@echo "make restart     - Restart project containers"
	@echo "make logs        - Show service logs"
	@echo "make ps          - Show project container status"
	@echo "make config      - Show resolved docker compose configuration"
	@echo "make clean       - Stop and remove containers and orphan containers"
	@echo "make fclean      - clean + remove volumes and built images"
	@echo "make prune       - Remove all unused Docker resources, including unused volumes"
	@echo "make re          - Recreate the project"

.PHONY: all volumes build up down start stop restart logs ps config clean fclean re prune help
