
VERSION=2020-18.04

.PHONY: image
image: base
	docker build -t robotpy/roborio-cross-ubuntu:$(VERSION) -f cross.dockerfile .

.PHONY: base
base:
	docker build -t robotpy/roborio-cpp-cross-ubuntu:$(VERSION) -f base.dockerfile .

.PHONY: dev
dev: image
	docker build -t robotpy/roborio-cross-ubuntu:$(VERSION)-dev -f dev.dockerfile .