include extra/.env

help:
	@echo "Main targets: build / specs / up / server / specs / shell"

# Docker commands

build:
	@rm -f Gemfile.lock
	@docker compose -f extra/docker-compose.yml build

up: build
	@docker compose -f extra/docker-compose.yml up

cleanup:
	@docker compose -f extra/docker-compose.yml down --volumes --rmi local --remove-orphans

# App commands

server:
	@docker compose -f extra/docker-compose.yml exec app bin/rails s -b 0.0.0.0 -p ${SERVER_PORT}

specs:
	@docker compose -f extra/docker-compose.yml exec app bin/rspec --fail-fast

lint:
	@docker compose -f extra/docker-compose.yml exec app bin/rubocop

shell:
	@docker compose -f extra/docker-compose.yml exec app bash
