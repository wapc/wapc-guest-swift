CONTAINER_RUNTIME ?= $(shell command -v podman 2> /dev/null || shell command -v docker 2> /de/null)
CONTAINER_IMAGE := "ghcr.io/swiftwasm/swiftwasm-action:5.3"

containerized-build: clean
ifndef CONTAINER_RUNTIME
	@printf "Please install either docker or podman"
	exit 1
endif
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/code --entrypoint /bin/bash $(CONTAINER_IMAGE) -c "cd /code && swift build --triple wasm32-unknown-wasi"

test:
ifndef CONTAINER_RUNTIME
	@printf "Please install either docker or podman"
	exit 1
endif
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/code --entrypoint /bin/bash $(CONTAINER_IMAGE) -c "cd /code && carton test"

clean:
	rm -rf .build
