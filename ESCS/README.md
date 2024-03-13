## Analysis of Emergency Services Communications Systems (ESCS) simulations

This directory contains code to analyze the results of ESCS simulations. It is
designed to read simulation output files in XML format. Specifically, the
format used in Graphitti's v0.9.2 release. The `test-data` directory contains
an example of such files.

An efficient "string to double conversion" MEX function is used because
MATLAB's built-in `str2double` function is very slow. The C++ code for
compiling the MEX function, under
the `str2doubleq` directory, was published by 
[Felipe G. Nievinski](https://www.mathworks.com/matlabcentral/fileexchange/61652-faster-alternative-to-builtin-str2double).

Instruction on how to build C++ MEX Programs can be found
[here](https://www.mathworks.com/help/matlab/matlab_external/build-c-mex-programs.html)
but in summary, you use the `mex` command. First, you must set up the
compiler for C++ MEX applications.
```
    mex -setup C++
```

Then, build the C++ MEX program using the MATLAB `mex` command.
```
    mex MyMEXCode.cpp
```

In Linux, this will generate a binary file with the extension `mexa64`.

In this directory, the important functions for analysis of ESCS simulation output are:

* __`readXmlFile`:__ reads all the XML file data into a Matlab
struct that can then be processed and used to generate figures.
* __`utilizationHist`:__ creates a utilization histogram from the struct returned
by `readXmlFile`.
* __`ringTimeHist`:__ creates a histogram from a vector containing a list of
ring times.
