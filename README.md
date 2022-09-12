robotpy-cross-docker
====================

A docker image to be used for cross-compiling packages for the RoboRIO
platform.

Usage
=====

Note: these instructions should work on OSX and Linux

Build the container
-------------------

If you want to just download our docker image from docker hub, you can skip
this step. This step will take a *long* time.

    $ make image

Use the container
-----------------

Run the docker image (note that we map the current directory to the `/v`
directory):

    $ docker run --rm -it -v $(pwd):/v robotpy/roborio-cross-ubuntu:2022.4

Once you're in the container, source the virtual environment and you can now
build python packages for the RoboRIO!

    # source /build/venv/bin/activate
    (use pip as normal)

For example, to create a wheel for `pyyaml`, you could do:

    (cross) root@container:/# pip wheel pyyaml
    
Author
======

Many thanks to @DirtyJerz for putting the initial version of this together!
