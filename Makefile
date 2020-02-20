
VERSION=$(git describe --tags)

.PHONY: image
image: base
	docker build -t robotpy/roborio-cross-ubuntu:$(VERSION) -f cross.dockerfile .

.PHONY: base
base:
	docker build -t roborio-cross-ubuntu:$(VERSION)-base -f base.dockerfile .

.PHONY: dev
dev: image
	docker build -t robotpy/roborio-cross-ubuntu:$(VERSION)-dev -f dev.dockerfile .