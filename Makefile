ifeq ($(OS),Windows_NT)
	SHELL := pwsh.exe
else
	SHELL := pwsh
endif

.SHELLFLAGS := -NoProfile -Command

REGISTRY_NAME := 
REPOSITORY_NAME := bmcclure89/
IMAGE_NAME := elixirdemo
TAG := :latest
TARGET_ELIXER_TAG := elixir:1.14-alpine

# Run Options
RUN_PORTS := -p 8383:8383

.PHONY: all test clean

all: build

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
build: deps_get
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
build: getcommitid getbranchname
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) --build-arg TARGET_ELIXER_TAG=$(TARGET_ELIXER_TAG) .

build_multiarch:
	docker buildx build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) --platform $(PLATFORMS) .
mix_%:
	docker run --workdir /mnt -v $${PWD}:/mnt $(RUN_PORTS) $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) $*
run: build
	docker run -d --network elixir $(RUN_PORTS) $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)
run_it: build
	docker run --rm --entrypoint /bin/sh -it $(RUN_PORTS) -v $${PWD}/src/hello_pheonix:/src $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

package:
	$$PackageFileName = "$$("$(IMAGE_NAME)" -replace "/","_").tar"; docker save $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -o $$PackageFileName

size:
	docker inspect -f "{{ .Size }}" $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)
	docker history $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

publish:
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