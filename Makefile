SHELL := /bin/bash
NAME := gokv
CONTAINER_NAME := i0nw/${NAME}

REV := $(shell git rev-parse --short HEAD 2> /dev/null || echo 'unknown')

BRANCH     := $(shell git rev-parse --abbrev-ref HEAD 2> /dev/null  || echo 'unknown')
BUILD_DATE := $(shell date +%Y%m%d-%H:%M:%S)
BUILD_USER := $(shell whoami)

all: build

check: fmt build test

# Variables for build flags.
GO := go
GO_VERSION := $(shell $(GO) version | sed -e 's/^[^0-9.]*\([0-9.]*\).*/\1/')
ROOT_PACKAGE := github.com/i0n/${NAME}

version:
ifeq (,$(wildcard pkg/version/VERSION))
TAG := $(shell git fetch --all -q 2>/dev/null && git describe --abbrev=0 --tags 2>/dev/null)
ON_EXACT_TAG := $(shell git name-rev --name-only --tags --no-undefined HEAD 2>/dev/null | sed -n 's/^\([^^~]\{1,\}\)\(\^0\)\{0,1\}$$/\1/p')
VERSION := $(shell [ -z "$(ON_EXACT_TAG)" ] && echo "$(TAG)-dev-$(REV)" | sed 's/^v//' || echo "$(TAG)" | sed 's/^v//' )
else
VERSION := $(shell cat pkg/version/VERSION)
endif
BUILDFLAGS := -ldflags \
  " -X $(ROOT_PACKAGE)/pkg/version.Version=$(VERSION)\
		-X $(ROOT_PACKAGE)/pkg/version.Revision='$(REV)'\
		-X $(ROOT_PACKAGE)/pkg/version.Branch='$(BRANCH)'\
		-X $(ROOT_PACKAGE)/pkg/version.BuildDate='$(BUILD_DATE)'\
		-X $(ROOT_PACKAGE)/pkg/version.BuildUser='$(BUILD_USER)'\
		-X $(ROOT_PACKAGE)/pkg/version.GoVersion='$(GO_VERSION)'"

DOCKER_BUILDFLAGS := -ldflags \
  " -X $(ROOT_PACKAGE)/pkg/version.Version=$(DOCKER_ARG_VERSION)\
		-X $(ROOT_PACKAGE)/pkg/version.Revision='$(DOCKER_ARG_REV)'\
		-X $(ROOT_PACKAGE)/pkg/version.Branch='$(DOCKER_ARG_BRANCH)'\
		-X $(ROOT_PACKAGE)/pkg/version.BuildDate='$(BUILD_DATE)'\
		-X $(ROOT_PACKAGE)/pkg/version.BuildUser='$(DOCKER_ARG_BUILD_USER)'\
		-X $(ROOT_PACKAGE)/pkg/version.GoVersion='$(GO_VERSION)'"

DOCKER_NETWORK := $(shell docker network ls --filter name=${NAME} -q)

print-version: version
	@echo $(VERSION)

print-rev:
	@echo $(REV)

print-branch:
	@echo $(BRANCH)

print-build-date:
	@echo $(BUILD_DATE)

print-build-user:
	@echo $(BUILD_USER)

build: version
	$(GO) build $(BUILDFLAGS) -o build/$(NAME) main.go

linux: version
	GOOS=linux GOARCH=amd64 $(GO) build $(BUILDFLAGS) -o build/linux/$(NAME) main.go

linux-from-docker:
	GOOS=linux GOARCH=amd64 $(GO) build $(DOCKER_BUILDFLAGS) -o build/linux/$(NAME) main.go

docker-create-network:
ifeq ($(strip $(DOCKER_NETWORK)),)
	@echo Creating docker network ${NAME}...
	docker network create ${NAME}
else
	@echo Docker network ${NAME} already created.
endif

docker-build: print-version print-rev print-branch
	docker build --no-cache . --build-arg DOCKER_ARG_VERSION=$(VERSION) --build-arg DOCKER_ARG_REV=$(REV) --build-arg DOCKER_ARG_BRANCH=$(BRANCH) --build-arg DOCKER_ARG_BUILD_USER=${BUILD_USER} -t ${CONTAINER_NAME}:latest
	docker tag ${CONTAINER_NAME}:latest ${CONTAINER_NAME}:$(VERSION)

docker-run: docker-build docker-create-network
	docker run --name ${NAME} --rm --network ${NAME} -p 8080:8080 ${CONTAINER_NAME}:latest

docker-run-d: docker-build docker-create-network
	docker run -d --name ${NAME} --rm --network ${NAME} -p 8080:8080 ${CONTAINER_NAME}:latest

docker-push:
	docker push ${CONTAINER_NAME}:latest
	docker push ${CONTAINER_NAME}:$(VERSION)

docker-test-unit: docker-create-network
	docker run --rm --network ${NAME} -w /opt/bin -v $(shell pwd):/opt/bin golang:1.20 make test-unit

docker-test-integration: docker-create-network
	docker run --rm --network ${NAME} -w /opt/bin -v $(shell pwd):/opt/bin golang:1.20 make test-integration

docker-test-functional:
	docker run --rm --network ${NAME} -e GOKV_URL=${NAME}:8080 -v $(shell pwd)/test/functional:/opt/bin grafana/k6 run /opt/bin/k6.js

kubernetes-rolling-update-current-version:
	kubectl set image -f kube/deployment.yaml app=${CONTAINER_NAME}:${VERSION}

kubernetes-rolling-update-latest:
	kubectl set image -f kube/deployment.yaml app=${CONTAINER_NAME}:latest

deploy: clean docker-build docker-push kubernetes-rolling-update-current-version

run: 	
	$(GO) run main.go

run-binary: 	
	./build/${NAME}

test:
	$(GO) test -count=1 -coverprofile=cover.out ./...

test-unit:
	$(GO) test -count=1 -coverprofile=cover.out -failfast -short -parallel 12 ./...

test-integration:
	$(GO) test -v -coverprofile=cover.out -failfast -run Integration  ./...

test-functional:
	GOKV_URL=0.0.0.0:8080 k6 run ./test/functional/k6.js

test-report: test
	@gocov convert cover.out | gocov report

test-report-html: test
	@gocov convert cover.out | gocov-html > cover.html && open cover.html

clean:
	rm -rf build release cover.out cover.html dist

# This will stop make linking directories with these names to make commands
.PHONY: all test clean
