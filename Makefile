.PHONY: lint lint-fix test test-fast format build build_images build_helm_chart push clean

REGISTRY ?= ghcr.io
IMAGE_NAME ?= ytsaurus/ytsaurus-identity-sync
IMAGE_TAG ?= $(shell date -u +%Y-%m-%d)-$(shell git rev-parse --short HEAD)
IMAGE_REF ?= $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
DOCKER_CONTEXT ?=
DOCKER_CONTEXT_ARG := $(if $(strip $(DOCKER_CONTEXT)),--context "$(DOCKER_CONTEXT)",)

CHART_PATH ?= ytsaurus-identity-sync-chart
CHART_NAME ?= ytsaurus-identity-sync-chart
CHART_REPOSITORY ?= ytsaurus
CHART_VERSION ?= $(IMAGE_TAG)
CHART_PACKAGE ?= $(CHART_NAME)-$(CHART_VERSION).tgz
CHART_REGISTRY ?= oci://$(REGISTRY)/$(CHART_REPOSITORY)

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
	docker $(DOCKER_CONTEXT_ARG) build --tag "$(IMAGE_REF)" .

build_helm_chart: build_images
	@TMP_CHART_DIR=$$(mktemp -d); \
	cp -R "$(CHART_PATH)/." "$$TMP_CHART_DIR/"; \
	sed 's|^[[:space:]]*tag:[[:space:]]*".*"|  tag: "$(IMAGE_TAG)"|' "$$TMP_CHART_DIR/values.yaml" > "$$TMP_CHART_DIR/values.yaml.tmp"; \
	mv "$$TMP_CHART_DIR/values.yaml.tmp" "$$TMP_CHART_DIR/values.yaml"; \
	sed -e 's|^version:.*|version: $(CHART_VERSION)|' \
		-e 's|^appVersion:.*|appVersion: "$(IMAGE_TAG)"|' \
		"$$TMP_CHART_DIR/Chart.yaml" > "$$TMP_CHART_DIR/Chart.yaml.tmp"; \
	mv "$$TMP_CHART_DIR/Chart.yaml.tmp" "$$TMP_CHART_DIR/Chart.yaml"; \
	helm package "$$TMP_CHART_DIR" --destination . --version "$(CHART_VERSION)"; \
	rm -rf "$$TMP_CHART_DIR"

push: build_images build_helm_chart
	docker $(DOCKER_CONTEXT_ARG) push "$(IMAGE_REF)"
	helm push "$(CHART_PACKAGE)" "$(CHART_REGISTRY)"

clean:
	rm -f "$(CHART_NAME)-"*.tgz
