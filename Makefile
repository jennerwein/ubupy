# Makefile in the project root.
# Uses bash and loads config.sh into the environment before each command.

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:

# Default target when only "make" is called
.DEFAULT_GOAL := help

# Helper macro: sources config.sh and then executes the given command
define WITH_CONF
source ./config.sh; $(1)
endef

.PHONY: help build run push update

# -------------------------------------------------------------------
# help: prints available targets
# -------------------------------------------------------------------
help:
	@echo ""
	@echo "Available targets:"
	@echo "  make build   - Remove old test image and build a new one"
	@echo "  make run     - Start the container interactively"
	@echo "  make push    - Tag and push images to Docker Hub"
	@echo "  make update  - Rebuild image with latest base image and push it"
	@echo "  make help    - Show this help"
	@echo ""

# -------------------------------------------------------------------
# build: removes the old test image (if it exists) and builds a new one
# Uses --pull to ensure the latest base image is used and --no-cache
# to force a completely fresh build.
# -------------------------------------------------------------------
build:
	docker rmi jennerwein/ubupy:test || true
	docker build --pull --no-cache -t jennerwein/ubupy:test .

# -------------------------------------------------------------------
# run: starts the container interactively
# -------------------------------------------------------------------
run:
	docker run --name ubuntu-python3 --rm -it jennerwein/ubupy:test

# -------------------------------------------------------------------
# push: tags and uploads images to Docker Hub
# Uses TAG from config.sh.
# If "latest=true" in config.sh, the latest tag will also be pushed.
# -------------------------------------------------------------------
push:
	$(call WITH_CONF, \
		echo "Pushing version tag $$TAG"; \
		docker tag jennerwein/ubupy:test jennerwein/ubupy:$${TAG}; \
		docker push jennerwein/ubupy:$${TAG}; \
		\
		if [ "$${latest}" = "true" ]; then \
			echo "Also updating latest tag"; \
			docker tag jennerwein/ubupy:test jennerwein/ubupy:latest; \
			docker push jennerwein/ubupy:latest; \
		else \
			echo "Skipping latest tag (latest=false)"; \
		fi \
	)

# -------------------------------------------------------------------
# update: rebuilds the image from the latest base image and pushes it
# This is useful to refresh the base image regularly so that security
# updates from the Ubuntu base image are included.
# -------------------------------------------------------------------
update: build push