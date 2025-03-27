include extra/.env

help:
	@echo "Main targets: build / specs / up / console / shell"

# Docker commands

build:
	@rm -f Gemfile.lock
	@docker compose -f extra/docker-compose.yml build

cleanup:
	@docker compose -f extra/docker-compose.yml rm -f
	@docker image rm -f ${COMPOSE_PROJECT_NAME}-app

up: build
	@docker compose -f extra/docker-compose.yml up

# App commands
console:
	@docker compose -f extra/docker-compose.yml exec -e "PAGER=more" app bin/rails console

specs:
	@docker compose -f extra/docker-compose.yml exec app bin/rspec --fail-fast

shell:
	@docker compose -f extra/docker-compose.yml exec -e "PAGER=more" app bash


# Docker commands
# down:
# 	docker compose down

# up:
# 	docker compose up

# attach:
# 	docker compose attach app

# up_attach:
# 	docker compose up -d && docker compose attach app

# cleanup:
# 	docker container rm -f activeadmin_dynamic_fields_app && docker image rm -f activeadmin_dynamic_fields-app

# Rails specific commands
# console:
# 	docker compose exec -e "PAGER=more" app bin/rails console

# specs:
# 	docker compose exec app bin/rspec --fail-fast

# Other commands

# shell:
# 	docker compose exec -e "PAGER=more" app bash

# lint:
# 	docker compose exec app bin/rubocop
