ifeq ($(OS),Windows_NT)
	SHELL := pwsh.exe
else
	SHELL := pwsh
endif

.SHELLFLAGS := -NoProfile -Command

.PHONY: all test clean

all: build

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
run: deps_get
	#mix run --no-halt
	iex -S mix
test: deps_get
	mix test
clean:
	rm -r $${PWD}/_build
	rm -r $${PWD}/deps
	rm $${PWD}/mix.lock