# CorticalCultureAnalysis

A repository with code to analyze data from simulations of development in
cultures of dissociated cortical neurons. This code is primarily used by the
[UW Bothell Biocomputing Laboratory](http://depts.washington.edu/biocomp/). See the
[BrainGrid simulator](https://github.com/UWB-Biocomputing/BrainGrid) and [Workbench
provenance system](https://github.com/UWB-Biocomputing/WorkBench) repositories for
the other components of our research infrastructure.

## Contents

* __Avalanches.__ Code to identify neuronal avalanches from spike trains, based both
  on spike times and on spike times and neuron locations combined.
* __Bursts.__ Code to analyze whole-network bursts, identified either from aggregated
  network spiking behavior or from avalanches.
* __DataReorganization.__ Code to read and write different file formats, extract subsets
  of data, etc.
* __ML.__ Machine learning code.
* __Ratime.__ Code to analyze aggregate network spiking behavior, i.e., spike counts
  within equal time bins (and therefore spiking rate versus time).
* __scripts.__ Miscellaneous scripts to do various tasks.
