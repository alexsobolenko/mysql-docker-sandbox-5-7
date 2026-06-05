include .env

COMPOSE := docker compose
MYSQL_SERVICE := mysql
MYSQL := $(COMPOSE) exec -e MYSQL_PWD='$(MYSQL_ROOT_PASSWORD)' $(MYSQL_SERVICE) mysql -u root
MYSQL_NOTTY := $(COMPOSE) exec -e MYSQL_PWD='$(MYSQL_ROOT_PASSWORD)' -T $(MYSQL_SERVICE) mysql -u root
MYSQL_DUMP := $(COMPOSE) exec -e MYSQL_PWD='$(MYSQL_ROOT_PASSWORD)' -T $(MYSQL_SERVICE) mysqldump -u root
SCRIPTS_DIR := ./scripts

define require_database
@if [ -z "$(database)" ]; then \
	echo "database not passed. example: make $(MAKECMDGOALS) database=x"; \
	exit 1; \
fi
endef

.PHONY: help databases build up down restart rebuild ps logs sh mysql create-db drop-db query import export

help:
	@echo "databases       - list databases"
	@echo "build           - build containers"
	@echo "up              - start containers"
	@echo "down            - stop containers"
	@echo "restart         - restart containers"
	@echo "rebuild         - rebuild containers"
	@echo "ps              - show containers"
	@echo "logs            - containers logs"
	@echo "sh              - bash insied container"
	@echo "mysql           - mysql console"
	@echo "create-db       - create database"
	@echo "drop-db         - drop database"
	@echo "copy-db         - copy database to another"
	@echo "query           - run sql query"
	@echo "import          - import sql file"
	@echo "export          - export database"

databases:
	@$(MYSQL) -e "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('mysql','information_schema','performance_schema','sys')"

build:
	@$(COMPOSE) build

up:
	@$(COMPOSE) up -d

down:
	@$(COMPOSE) down

restart:
	@$(COMPOSE) restart

rebuild:
	@$(COMPOSE) down
	@$(COMPOSE) up -d --force-recreate

ps:
	@$(COMPOSE) ps

logs:
	@$(COMPOSE) logs -f

sh:
	@$(COMPOSE) exec -ti $(MYSQL_SERVICE) bash

mysql:
	@$(MYSQL)

create-db:
	$(require_database)
	@$(MYSQL) -e "CREATE DATABASE IF NOT EXISTS \`$(database)\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"

drop-db:
	$(require_database)
	@$(MYSQL) -e "DROP DATABASE IF EXISTS \`$(database)\`"

copy-db:
	@if [ -z "$(from)" ]; then \
		echo "from database not passed. example: make copy-db from=x to=y"; \
		exit 1; \
	fi
	@if [ -z "$(to)" ]; then \
		echo "to database not passed. example: make copy-db from=x to=y"; \
		exit 1; \
	fi
	@make --no-print-directory export database=$(from) file=tmp.sql
	@make --no-print-directory drop-db database=$(to)
	@make --no-print-directory create-db database=$(to)
	@make --no-print-directory import database=$(to) file=tmp.sql
	@rm -f $(SCRIPTS_DIR)/tmp.sql

query:
	$(require_database)
	@if [ -z "$(sql)" ]; then \
		echo 'sql not passed. example: make query database=x sql="select * from table"'; \
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

export:
	$(require_database)
	@if [ -z "$(file)" ]; then \
		echo "file not passed. example: make export database=x file=backup.sql"; \
		exit 1; \
	fi
	@$(MYSQL_DUMP) "$(database)" $(tables) > "$(SCRIPTS_DIR)/$(file)"
