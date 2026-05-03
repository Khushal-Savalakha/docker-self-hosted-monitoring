APP_NAME=suppot-platform

.PHONY: build up down restart logs

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

restart:
	docker-compose down
	docker-compose up -d --build

logs:
	docker-compose logs -f

shell:
	docker-compose exec suppot-platform