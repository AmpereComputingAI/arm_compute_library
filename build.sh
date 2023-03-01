#!/bin/bash
scons Werror=1 -j8 debug=0 neon=1 opencl=0 os=linux arch=armv8.2-a cppthreads=1 openmp=1
