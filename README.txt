PURPOSE
=======

This is an "umbrella" of many projects in the OPM suite. Its purpose is
to provide a way to build everything in one go. It demonstrates two
features:

  A. How to use sub-modules to maintain a consistent suite of projects

  B. How to use a top-level CMake project to drive the build

These two items are orthogonal; you can have one, the other or both at
the same time.

Notice that a bug/feature (depending on what you want) of Git submodules
is that the submodule is pinned to a particular version of the project,
and does not automatically track the running head/tip of the repository.

You can of course update the subdirectory, but if you want that change
to be persistent, you must do a commit in the parent directory, as if
the version of the submodule was the content of a file under version
control.


DIRECTORY ORGANIZATION
======================

I have a src directory which contains this project; all the individual
projects will be created as sub-directory underneath that one. Then I
have a build directory with the corresponding structure but in a
different location. It will look like this:

    ~ / opm / src / opm-core
                  / dune-cornerpoint
                  / opm-porsol

            / bld / opm-core
                  / dune-cornerpoint
                  / opm-porsol

BASIC USAGE
===========

# 0. Create directory structure

    mkdir -p ~/opm/bld

# 1. Get the repository from the 'net

    cd ~/opm
    git clone http://github.com/rolk/opm src
    cd src

# 2. Add submodule urls to config file

    git submodule init

# 3. Checkout the version of submodule specified in project

    git submodule update

# 4. Configure and build with:

    cd ../bld
    cmake ../src -DBUILD_SHARED_LIBS=ON
    env MAKEFLAGS="-j 5 -l 3" ionice -c2 -n7 nice -20 cmake --build .

The degree of parallelism depends on your system; in particular, if
you run this on your workstation you don't want the build to outcrowd
your X11 server! A rule of thumb is that the number of simultaneous
processes ("-j" parameter) should be:

    j = min (num of cores + 1, num of GiB RAM - 1)

and the load limit ("-l" parameter) should be:

    l = num of cores - 1


UPDATING LINKS TO SUB-PROJECTS
==============================

# 1. Retrieve latest tip of all sub-projects

    for module in $(cmake -P projects.cmake); do
      (cd $module ; git pull origin && git submodule update)
    done

# 2. Check-in these pointers

    for module in $(cmake -P projects.cmake); do
      git add $module
    done
    git commit
