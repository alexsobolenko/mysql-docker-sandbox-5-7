# MySQL 5.7 Docker Sandbox

A lightweight local MySQL 5.7 environment powered by Docker Compose and managed through Make.

## Requirements

* Docker Compose
* GNU Make

## Features

* MySQL 5.7
* Persistent data storage
* SQL query execution from the command line
* SQL dump import support
* Simple Makefile-based workflow

## Installation

Clone the repository and create a local configuration file:

```bash
cp .env.example .env
```

Edit `.env` according to your needs:

```env
MYSQL_ROOT_PASSWORD=root
MYSQL_USER=example
MYSQL_PASSWORD=example
MYSQL_PORT=3306
```

## Usage

Start the database:

```bash
make up
```

Stop the database:

```bash
make down
```

Show container status:

```bash
make ps
```

Open a shell inside the MySQL container:

```bash
make sh
```

## Execute a Query

Run a SQL query against a database:

```bash
make query database=example sql="SELECT * FROM users"
```

## Import a SQL File

Import a SQL file from the `scripts` directory:

```bash
make import database=example file=dump.sql
```

The file must exist at `scripts/dump.sql`

## Directory Structure

```
.
├── data/
├── scripts/
├── .env.example
├── docker-compose.yml
├── Makefile
└── README.md
```

### data/

Persistent MySQL data directory. Database contents survive container restarts and recreation.

### scripts/

Directory containing SQL files used for imports.

## Notes

The `.env` file contains local configuration and should not be committed to version control. Only `.env.example` should be tracked by git.
