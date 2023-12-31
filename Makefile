.PHONY: env-up clean

docker-hub-login:
	$$(gimme-aws-creds --action-list-profiles)

remove_stopped_containers:
	docker rm $$(docker ps -a -q)

delete_images:
	docker rmi $$(docker images -q)

clean: remove_stopped_containers delete_images

env-up:
	docker build -t gen-ai:local .
	docker run -it --rm -u genai -v ${HOME}/.aws:/home/genai/.aws --env-file .env -w /app gen-ai:local /bin/bash

init:
	poetry install
	pre-commit install
	pre-commit install -c .pre-push-config.yaml -t pre-push
