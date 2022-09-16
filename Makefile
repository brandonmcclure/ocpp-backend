ifeq ($(OS),Windows_NT)
	SHELL := pwsh.exe
else
	SHELL := pwsh
endif

.SHELLFLAGS := -NoProfile -Command

REGISTRY_NAME := 
REPOSITORY_NAME := bmcclure89/
IMAGE_NAME := elixir_occpbackend
TAG := :latest
TARGET_ELIXER_TAG := elixir:1.14-alpine

# Run Options
RUN_PORTS := -p 8383:8383

.PHONY: all test clean build

all: build
build: app_build docker_build

getcommitid:
	$(eval COMMITID = $(shell git log -1 --pretty=format:'%H'))
getbranchname:
	$(eval BRANCH_NAME = $(shell (git branch --show-current ) -replace '/','.'))

setup:
	mix local.hex --force --if-missing && mix local.rebar --force --if-missing
setup_db:
	-mix ecto.create
	-mix ecto.migrate
deps_outdated:
	mix hex.outdated
deps_get: setup
	mix deps.get
	mix deps.compile
app_build: deps_get
	mix compile 
release: build
	echo y | mix release.clean
app_run: deps_get
	#mix run --no-halt
	iex -S mix
test: deps_get
	mix test
clean:
	rm -r $${PWD}/_build
	rm -r $${PWD}/deps
	rm $${PWD}/mix.lock
	rm -r megalinter-reports

DOCKER_MIX_RUN:= docker run -d --rm elixir$(TARGET_ELIXER_TAG)
DOCKER_BUILD_ARGS:= --build-arg TARGET_ELIXER_TAG=$(TARGET_ELIXER_TAG)
docker_build: getcommitid getbranchname
	docker buildx build --target export -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) --output ocpp-backend $(DOCKER_BUILD_ARGS) .
	docker buildx build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) $(DOCKER_BUILD_ARGS) . 

build_multiarch:
	docker buildx build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) --platform $(PLATFORMS) .
mix_%:
	docker run --workdir /mnt -v $${PWD}:/mnt $(RUN_PORTS) $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) $*

docker_network:
	-docker network create elixir --attachable
docker_run: docker_build docker_network
	docker run -d --network elixir $(RUN_PORTS) $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)
docker_run_it: docker_build docker_network
	docker run --rm --entrypoint /bin/sh -it $(RUN_PORTS) -v $${PWD}:/src $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

package:
	$$PackageFileName = "$$("$(IMAGE_NAME)" -replace "/","_").tar"; docker save $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -o $$PackageFileName

size:
	docker inspect -f "{{ .Size }}" $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)
	docker history $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

docker_publish:
	docker login; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG); docker logout

lint: lint_mega lint_credo

lint_mega:
	docker run -v $${PWD}:/tmp/lint oxsecurity/megalinter:v6
lint_goodcheck:
	docker run -t --rm -v $${PWD}:/work sider/goodcheck check
lint_goodcheck_test:
	docker run -t --rm -v $${PWD}:/work sider/goodcheck test
lint_credo: 
	docker run --rm -v $${PWD}:/home/credo/code -t renderedtext/credo

CORE_SERVICES := db adminer app
ALL_SERVICES := ${CORE_SERVICES} 

COMPOSE_ALL_FILES := ${CORE_SERVICES_FILES}
CORE_SERVICES_FILES := -f docker-compose.yml

# --------------------------

compose_core:
	@docker-compose ${COMPOSE_CORE_FILES} up -d --build ${CORE_SERVICES}

compose_down:
	@docker-compose ${COMPOSE_ALL_FILES} down

compose_stop:
	@docker-compose ${COMPOSE_ALL_FILES} stop ${ALL_SERVICES}

compose_restart:
	@docker-compose ${COMPOSE_ALL_FILES} restart ${ALL_SERVICES}

compose_rm:
	@docker-compose $(COMPOSE_ALL_FILES) rm -f ${ALL_SERVICES}

compose_logs:
	@docker-compose $(COMPOSE_ALL_FILES) logs --follow --tail=1000 ${ALL_SERVICES}

compose_images:
	@docker-compose $(COMPOSE_ALL_FILES) images ${ALL_SERVICES}

compose_clean: ## Remove all Containers and Delete Volume Data
	@docker-compose ${COMPOSE_ALL_FILES} down -v