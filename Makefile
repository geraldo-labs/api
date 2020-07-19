.PHONY: build test coverage run clean wait

OK_COLOR=\033[32;01m
NO_COLOR=\033[0m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m

# Build Flags
BUILD_DATE = $(date -u --rfc-3339=seconds)
BUILD_HASH ?= $(git rev-parse --short HEAD)
APP_VERSION ?= undefined
BUILD_NUMBER ?= dev

NOW = $(date -u '+%Y%m%d%I%M%S')

GO := go
DOCKER := docker
DOCKER_EXISTS := $(type $(DOCKER) > /dev/null 2> /dev/null; echo $$? )
BUILDOS ?= $(go env GOHOSTOS)
BUILDARCH ?= amd64
GOFLAGS ?=
ECHOFLAGS ?=
ROOT_DIR := $(realpath .)

BIN_WEBSERVER := api
BUILD_PATH := ./cmd/api
LOCAL_VARIABLES := $(env)

PKGS = $($(GO) list ./...)

ENVFLAGS = GO111MODULE=on CGO_ENABLED=0 GOOS=$(BUILDOS) GOARCH=$(BUILDARCH)
ENVFLAGS_EVENTS = GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH=amd64
BUILDENV ?= GOOS=$(BUILDOS) GOARCH=$(BUILDARCH)
BUILDFLAGS ?= -a $(GOFLAGS) $(GO_LINKER_FLAGS)
EXTLDFLAGS = -extldflags "-lm -lstdc++ -static"

## usage: show available actions
usage: Makefile
	@echo $(ECHOFLAGS) "to use make call:"
	@echo $(ECHOFLAGS) "    make <action>"
	@echo $(ECHOFLAGS) ""
	@echo $(ECHOFLAGS) "list of available actions:"
	@if [ -x /usr/bin/column ]; \
	then \
		echo "$$(sed -n 's/^## /    /p' $< | column -t -s ':')"; \
	else \
		echo "$$(sed -n 's/^## /    /p' $<)"; \
	fi

## build: build server
build:
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Building binary webserver (bin/$(BIN_WEBSERVER))...$(NO_COLOR)"
	@echo $(ECHOFLAGS) $(LOCAL_VARIABLES)
	$(GO) build -v -o bin/$(BIN_WEBSERVER) $(BUILD_PATH)

## test: run unit tests
test:
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Running tests with envs:$(NO_COLOR)"
	@echo $(ECHOFLAGS) $(LOCAL_VARIABLES)
	$(GO) test -v $(PKGS) $(BUILD_PATH)

## coverage: run unit test and generate code coverage reports
coverage:
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Running tests with envs:$(NO_COLOR)"
	@echo $(ECHOFLAGS) $(LOCAL_VARIABLES)
	@$(LOCAL_VARIABLES) $(ENVFLAGS) $(GO) test -coverprofile=./reports/coverage.out $(GOFLAGS) $(PKGS)
	@$(GO) tool cover -html=./reports/coverage.out -o=./reports/coverage.html
	@echo $(ECHOFLAGS) "$(OK_COLOR)coverage reports created at ./reports/coverage.html$(NO_COLOR)"

## run: run server
run:
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Running server with envs:$(NO_COLOR)"
	@echo $(ECHOFLAGS) $(LOCAL_VARIABLES)
	./bin/$(BIN_WEBSERVER) $(args)

## wait: used only to wait for database connections
wait:
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Waiting for the database...$(NO_COLOR)"
	bash ./scripts/tcp-port-wait.sh $(DATABASE_HOST) $(DATABASE_PORT)

## clean: clean local binaries
clean:
	@echo $(ECHOFLAGS) "$(OK_COLOR)==> Running clean...$(NO_COLOR)"
	@rm -rf bin/$(BIN_WEBSERVER)
	@echo $(ECHOFLAGS) "$(OK_COLOR)App clear! :)$(NO_COLOR)"