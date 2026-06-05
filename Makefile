include .env

COMPOSE := docker compose
MYSQL_SERVICE := -e MYSQL_PWD='$(MYSQL_ROOT_PASSWORD)' mysql
MYSQL := $(COMPOSE) exec $(MYSQL_SERVICE) mysql -u root
MYSQL_NOTTY := $(COMPOSE) exec -T $(MYSQL_SERVICE) mysql -u root
SCRIPTS_DIR := ./scripts

define require_database
@if [ -z "$(database)" ]; then \
	echo "database not passed. example: make $(MAKECMDGOALS) database=x"; \
	exit 1; \
fi
endef

.PHONY: up down ps sh query import

up:
	@$(COMPOSE) up -d

down:
	@$(COMPOSE) down

ps:
	@$(COMPOSE) ps

sh:
	@$(COMPOSE) exec -ti $(MYSQL_SERVICE) bash

query:
	$(require_database)
	@if [ -z "$(sql)" ]; then \
		echo 'sql not passed. example: make sql database=x sql="select * from table"'; \
		exit 1; \
	fi
	@$(MYSQL) -e "$(sql)" "$(database)"

import:
	$(require_database)
	@if [ -z "$(file)" ]; then \
		echo "file not passed. example: make import database=x file=test.sql"; \
		exit 1; \
	fi
	@if ! echo "$(file)" | grep -q '\.sql$$'; then \
		echo "Error: file must have .sql extension. Got: $(file)"; \
		exit 1; \
	fi
	@if [ ! -f "$(SCRIPTS_DIR)/$(file)" ]; then \
		echo 'file "$(file)" not found'; \
		exit 1; \
	fi
	@$(MYSQL_NOTTY) "$(database)" < "$(SCRIPTS_DIR)/$(file)"
