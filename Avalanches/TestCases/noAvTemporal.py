##############################################################################
# Author: Lawrence Scott
# Project: Test Case Data Generation for Neuronal Avalanche Detection Program
# Creation Date: 4/13/2025
# Date of Last Modification: 4/23/2025
##############################################################################
# Purpose:	Creates test data which is temporally close but not spatially.
#

import csv
import math
import os
import pathlib
import random
import sys

# ---------------------------------------------------------------------------
# Generate Grid
# Creates a 2d array of 100x100 with values ranging from 1 to 10000
# Increase from 1 (top left), to 10000 (bottom right)
# Serves as storage array for (x,y) neuron grid
def makeGrid():
    neuron = 1
    data = [[0 for x in range(100)] for y in range(100)]
    for i in range(100):
        for p in range(100):
            data[i][p] = neuron
            neuron += 1

    # Verification Check
    #print(f'First Neuron: {data[0][0]}, Last Neuron: {data[99][99]}')
    return data

# ---------------------------------------------------------------------------
# Generate Spike
# Randomly selects an (x,y) co-ordinate for a spike
def makeSpike():
    return random.randint(0, 99), random.randint(0, 99)

# ---------------------------------------------------------------------------
# Spatial threshold check
# Threshold distance to be included in an avalanche must be less than 8
# d = sqrt((x2-x1)^2 + (y2-y1)^2) < 8
def spatialCheck(neuronA, neuronB):
    return math.sqrt((neuronA[0]-neuronB[0])**2 + (neuronA[1]-neuronB[1])**2) < 8

# ---------------------------------------------------------------------------
# CSV data file generator
# Arguments:    numSpikes: number of spikes to use in data generation
#               multipleFlag: should multiple spikes be generated in the same time instance?
def generateData(numSpikes, multipleFlag):

    # DECLARE VARIABLES
    # number of spikes left to generate
    spikesRemaining = numSpikes

    currentTime = random.randint(0, 700)

    # serves as the temporal queue for spikes, contains tuples(timestamp, [neuron array])
    temporalQueue = []

    # generate the first spike in the data set
    currentSet = []
    currentSpike = makeSpike()
    spikesRemaining = spikesRemaining - 1
    currentSet.append(currentSpike)
    tempTup = currentTime, currentSet
    temporalQueue.append(tempTup)
    currentSet = []

    # temporal threshold is 50, therefore a gap of 26 to 49 ensures that at least
    # two spikes are within range of one another, but eliminates the need to
    # check for additional spikes
    currentTime = currentTime + random.randint(26, 49)

    while spikesRemaining > 0:
        nextSpike = makeSpike()

        # If spikes are spatially close, generate a new spike
        while spatialCheck(currentSpike, nextSpike):
            nextSpike = makeSpike()

        currentSet.append(nextSpike)
        spikesRemaining = spikesRemaining - 1
        if multipleFlag:
            chance = random.randint(0, 100)
            # Chance defines the frequency at which multiple spikes will appear in the same time period
            if chance < 70 or spikesRemaining == 0:
                tempTup = currentTime, currentSet
                temporalQueue.append(tempTup)
                currentTime = currentTime + random.randint(26, 49)
                currentSet = []
        else:
            tempTup = currentTime, currentSet
            temporalQueue.append(tempTup)
            currentTime = currentTime + random.randint(26, 49)
            currentSet = []

        currentSpike = nextSpike

    # Debugging
    #for item in temporalQueue:
    #    print(f'{item}')

    return temporalQueue

# ---------------------------------------------------------------------------
# main()
if __name__ == '__main__':

    # Debugging
    # output = generateData(20, 1)
    # grid = makeGrid()
    # results = []
    # tempArray = []
    # i = 0
    # for item in output:
    #     tempArray.append(item[0])
    #     for ele in item[1]:
    #         tempArray.append(grid[ele[0]][ele[1]])
    #     results.append(tempArray)
    #     tempArray = []
    # for item in results:
    #     print(f'{item}')

    if len(sys.argv) > 1:
        if sys.argv[1].__eq__("help") or sys.argv[1].__eq__("Help"):
            print('-----Help-----')
            print('First Argument: number of spikes')
            print('Second Argument: whether multiple spikes should appear in the same time period')
            print('Ex: python noAvTemporal.py 20 1')
        else:
            spikes = int(sys.argv[1])
            multipleFlag = int(sys.argv[2])
            output = generateData(spikes, multipleFlag)
            grid = makeGrid()
            results = []
            tempArray = []
            for item in output:
                tempArray.append(item[0])
                for ele in item[1]:
                    tempArray.append(grid[ele[0]][ele[1]])
                results.append(tempArray)
                tempArray = []

        # Generate data directory if does not exist
        pathlib.Path("./data").mkdir(parents=True, exist_ok=True)
        i = 0
        path = './data/noAvTemporal' + str(i) + '.csv'
        while (os.path.isfile(path)):
            i = i + 1
            path = './data/noAvTemporal' + str(i) + '.csv'

        with open(path, 'w', newline='') as csvfile:
            write = csv.writer(csvfile)
            write.writerows(results)

        print(f'File Generated: {path}')

    else:
        print('Must provide input arguments.')
        print('Ex: python noAvTemporal.py 20 1')



