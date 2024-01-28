build:
	docker-compose build

bundle:
	docker-compose run --rm web bundle install

server:
	docker-compose run --rm --service-ports web

bash:
	docker-compose run --rm web bash
