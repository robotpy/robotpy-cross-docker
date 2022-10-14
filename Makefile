
# VERSION=$(shell git describe --tags)
VERSION=2023.1

.PHONY: image
image: base
	docker build . \
		-t robotpy/roborio-cross-ubuntu:$(VERSION) \
		--build-arg VERSION=$(VERSION) \
		-f cross.dockerfile

.PHONY: base
base:
	docker build . \
		-t robotpy/roborio-cross-ubuntu:$(VERSION)-base \
		-f base.dockerfile

.PHONY: dev
dev:
	docker build . \
		-t robotpy/roborio-cross-ubuntu:$(VERSION)-dev \
		--build-arg VERSION=$(VERSION) \
		-f dev.dockerfile
