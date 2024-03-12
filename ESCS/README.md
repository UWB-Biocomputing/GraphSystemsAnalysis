## Analysis of Emergency Services Communications Systems (ESCS) simulations

This directory contains code to analyze the results of ESCS simulations. It is
designed to read simulation output files in XML format. Specifically, the
format used in Graphitti's v0.9.2 release. The `test-data` directory contains
an example of such files.

An efficient "string to double conversion" MEX function is used because
Matlab's built-in `str2double` function is very slow. The C++ code for
compiling the MEX function, under
the `str2doubleq` directory, was published by 
[Felipe G. Nievinski](https://www.mathworks.com/matlabcentral/fileexchange/61652-faster-alternative-to-builtin-str2double).

Here, the important functions for analysis of ESCS simulation output are:

* __`readXmlFile`:__ reads all the XML file data into a Matlab
struct that can then be processed and used to generate figures.
* __`utilizationHist`:__ creates a utilization histogram from the struct returned
by `readXmlFile`.
* __`ringTimeHist`:__ creates a histogram from a vector containing a list of
ring times.
