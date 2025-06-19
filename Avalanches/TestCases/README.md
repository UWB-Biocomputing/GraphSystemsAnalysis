# Generation of Synthetic Data for Avalanche Analysis Test Cases

## About

Scripts contained in this directory are used to generate test data for the Avalanche Analysis program.


## Data Format
Data is generated and saved as a .csv file in the data subdirectory. The data consists of a time stamp followed by the numerical representation of a spike's 2D co-ordinate grid location. Default grid is 100x100 and spike location values are from 1 to 10000.

Multiple spikes may be associated with the same timestamp.

Example:
| Time | Spike1 | Spike2 | Spike3 | Spike4 |
|-----|------|------|------|------|
| 279 | 2142 |      |   |   |
| 281 | 2036 | 1733 |   |   |
| 328 | 1034 | 1530 | 2489 |   |
| 379 | 1124 | 7254 | 3574 | 6581 |

