.PHONY: lint lint-fix test test-fast format build_images build_helm_chart

REGISTRY ?= ghcr.io
IMAGE_NAME ?= ytsaurus/ytsaurus-identity-sync
IMAGE_TAG ?= $(shell date -u +%Y-%m-%d)-$(shell git rev-parse --short HEAD)
IMAGE_REF ?= $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)

CHART_PATH ?= ytsaurus-identity-sync-chart
CHART_NAME ?= ytsaurus-identity-sync-chart
CHART_REPOSITORY ?= ytsaurus
CHART_VERSION ?= 0.0.0-$(IMAGE_TAG)
CHART_PACKAGE ?= $(CHART_NAME)-$(CHART_VERSION).tgz
CHART_REGISTRY ?= oci://$(REGISTRY)/$(CHART_REPOSITORY)

# Set PUSH=true to push built artifacts to registries.
PUSH ?= false

lint:
	golangci-lint run

lint-fix:
	golangci-lint run --fix

test:
	go test ./...

test-fast:
	REUSE_YT_CONTAINER=yes go test ./...

format:
	go fmt

build_images:
	docker build --tag "$(IMAGE_REF)" .
	@if [ "$(PUSH)" = "true" ]; then docker push "$(IMAGE_REF)"; fi

build_helm_chart:
	helm package "$(CHART_PATH)" --version "$(CHART_VERSION)"
	@if [ "$(PUSH)" = "true" ]; then helm push "$(CHART_PACKAGE)" "$(CHART_REGISTRY)"; fi
