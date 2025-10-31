# Makefile in the project root.
# Uses bash and loads config.sh into the environment before each command.

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

# Helper macro: sources config.sh and then executes the given command
define WITH_CONF
source ./config.sh; $(1)
endef

.PHONY: build run push

default: build

# ubupy: build + run + push

# -------------------------------------------------------------------
# build: removes the old test image (if it exists) and builds a new one
# -------------------------------------------------------------------
build:
	docker rmi jennerwein/ubupy:test || true
	docker build -t jennerwein/ubupy:test .

# -------------------------------------------------------------------
# run: starts the container interactively
# -------------------------------------------------------------------
run:
	docker run --name ubuntu-python3 --rm -it jennerwein/ubupy:test

# -------------------------------------------------------------------
# push: tags and uploads images to Docker Hub
# -------------------------------------------------------------------
push:
	$(call WITH_CONF, \
		docker tag jennerwein/ubupy:test jennerwein/ubupy:$${TAG}; \
		docker push jennerwein/ubupy:$${TAG}; \
		docker tag jennerwein/ubupy:test jennerwein/ubupy:latest; \
		docker push jennerwein/ubupy:latest; \
	)
