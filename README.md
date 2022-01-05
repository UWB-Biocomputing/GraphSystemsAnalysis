[![DOI](https://zenodo.org/badge/153203376.svg)](https://zenodo.org/badge/latestdoi/153203376)

# GraphSystemsAnalysis

A repository with code to analyze data from simulations of graph-structured systems, such as development in
cultures of dissociated cortical neurons or interactions in emergency services communications systems. In particular, this code targets systems that produce spatiotemporal point processes, i.e., events at discrete points in time at either or both of graph vertices or graph edges. This code is primarily used by the
[UW Bothell Intelligent Networks Laboratory](http://depts.washington.edu/biocomp/). See the
[Graphitti simulator](https://github.com/UWB-Biocomputing/Graphitti) and [Workbench
provenance system](https://github.com/UWB-Biocomputing/WorkBench) repositories for
the other components of our research infrastructure.

## Contents

* __Avalanches.__ Code to identify event avalanches from spatiotemporal point processes in graphs, based both
  on event times and on event times and vertex locations combined.
* __Bursts.__ Code to analyze whole-graph bursts, identified either from aggregated
  network event timing characteristics or from avalanches.
* __DataReorganization.__ Code to read and write different file formats, extract subsets
  of data, etc.
* __ML.__ Machine learning code.
* __Ratime.__ Code to analyze aggregate graph event behaviors, i.e., event counts
  within equal time bins (and therefore event rate versus time).
* __scripts.__ Miscellaneous scripts to do various tasks.

## Code of Conduct

This project and everyone participating in it is governed by the [Intelligent Networks Laboratory Code of Conduct](https://github.com/UWB-Biocomputing/Graphitti/blob/master/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Contributing
Please refer to the [Contributing Guide](CONTRIBUTING.md) for information about
how internal and external contributors can work on this code.