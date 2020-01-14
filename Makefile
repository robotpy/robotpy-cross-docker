
.PHONY: image
image:
	docker build -t robotpy/roborio-cross-ubuntu:2020-18.04 -f Dockerfile .