SHELL = /bin/bash
OS = $(shell uname -s)

# Project variables
PACKAGE = github.com/xingxing/random-schduler
BINARY_NAME = scheduler
IMAGE = xingxing/scheduler
TAG = v0.2

# Build variables
BUILD_DIR ?= build
BUILD_PACKAGE = ./cmd/scheduler
VERSION ?= $(shell git rev-parse --abbrev-ref HEAD)
COMMIT_HASH ?= $(shell git rev-parse --short HEAD 2>/dev/null)
BUILD_DATE ?= $(shell date +%FT%T%z)
LDFLAGS += -X main.Version=${VERSION} -X main.CommitHash=${COMMIT_HASH} -X main.BuildDate=${BUILD_DATE}
export CGO_ENABLED ?= 0
ifeq (${VERBOSE}, 1)
	GOARGS += -v
endif

DEP_VERSION = 0.5.0

.PHONY: clean
clean: ## Clean the working area and the project
	rm -rf bin/ ${BUILD_DIR}/ vendor/
	rm -rf ${BINARY_NAME}

.PHONY: build
build: GOARGS += -tags "${GOTAGS}" -ldflags "${LDFLAGS}" -o ${BUILD_DIR}/${BINARY_NAME}
build: ## Build a binary
	go build ${GOARGS} ${BUILD_PACKAGE}

.PHONY: docker-image
docker-image: ## Builds docker image for the scheduler
	docker build --rm -t $(IMAGE):$(TAG) .

.PHONY: list
list: ## List all make targets
	@$(MAKE) -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sort

.PHONY: help
.DEFAULT_GOAL := help
help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Variable outputting/exporting rules
var-%: ; @echo $($*)
varexport-%: ; @echo $*=$($*)
