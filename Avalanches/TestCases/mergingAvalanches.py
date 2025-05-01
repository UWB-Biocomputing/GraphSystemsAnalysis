##############################################################################
# Author: Lawrence Scott
# Project: Test Case Data Generation for Neuronal Avalanche Detection Program
# Creation Date: 4/13/2025
# Date of Last Modification: 4/30/2025
##############################################################################
# Purpose:	To create test cases with at least two avalanches which
#           eventually merge together.

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
# Generate Spike - Threshold
# Selects an (x,y) co-ordinate for a spike within the avalanche threshold
def makeSpikeSpecific(neuronXY):
    x = random.randint(-8, 8)
    tempX = neuronXY[0] + x
    if (tempX < 0):
        x2 = 0
    elif (tempX > 99):
        x2 = 99
    else:
        x2 = tempX
    # d = sqrt(x^2-y^2) < 8; define spatial threshold less than 8
    y = math.sqrt(max(0, 63-(x2-neuronXY[0])**2))
    y = random.randint(-int(y), int(y))
    tempY = neuronXY[1] + y
    if (tempY < 0):
        y2 = 0
    elif (tempY > 99):
        y2 = 99
    else:
        y2 = tempY
    return x2, y2

# ---------------------------------------------------------------------------
# Spatial threshold check
# Threshold distance to be included in an avalanche must be less than 8
# d = sqrt((x2-x1)^2 + (y2-y1)^2) < 8
def spatialCheck(neuronA, neuronB):
    return math.sqrt((neuronA[0]-neuronB[0])**2 + (neuronA[1]-neuronB[1])**2) < 8

# ---------------------------------------------------------------------------
# Generate Avalanche
# Takes the available number of spikes and generates an avalanche
def generateAvalanche(currentTime, numSpikes):

    # DECLARE VARIABLES
    # number of spikes left to generate
    spikesRemaining = numSpikes

    # serves as the temporal queue for spikes, contains tuples(timestamp, [neuron array])
    temporalQueue = []

    # generate future timestamp far enough forward to include all spikes
    # for an avalanche of the given length
    minTime = numSpikes*49
    randomTime = random.randint(0, 1000)
    maxTime = minTime + randomTime
    startTime = currentTime + random.randint(minTime, maxTime)

    # generate the first spike in the data set
    currentSet = []
    # acts as the root node, connecting two avalanches
    # due to randomness, avalanches may connect in more than one location
    currentSpike = makeSpike()
    currentSet.append(currentSpike)
    tempTup = startTime, currentSet
    temporalQueue.append(tempTup)
    currentSet = []

    # set the starting points
    spikeA = currentSpike
    spikeB = currentSpike
    backwardsTime = startTime

    while spikesRemaining > 0:
        # Generate spikes for both avalanches
        tempA = makeSpikeSpecific(spikeA)
        # If spikes are not spatially close, generate a new spike
        while not spatialCheck(spikeA, tempA):
            tempA = makeSpikeSpecific(spikeA)

        tempB = makeSpikeSpecific(spikeA)
        # If spikes are not spatially close, generate a new spike
        while not spatialCheck(spikeB, tempB):
            tempB = makeSpikeSpecific(spikeB)

        backwardsTime = backwardsTime - random.randint(0, 49)

        currentSet.append(tempA)
        currentSet.append(tempB)
        tempTup = backwardsTime, currentSet
        temporalQueue.append(tempTup)
        currentSet = []

        spikeA = tempA
        spikeB = tempB
        spikesRemaining = spikesRemaining - 1

    temporalQueue.reverse()

    return temporalQueue, startTime

# ---------------------------------------------------------------------------
# data generator
# Arguments: length of avalanche in spikes, avalanche count
# will generate avalanches with a spike count of 2*length + 1
def makeStuff(avalancheLength, numAvalanches):
    # Define and check for the minimum number of spikes per avalanche
    # 2 spikes per avalanche - this is also the minimum length
    spikesPerAvalancheControl = 2
    if (avalancheLength / numAvalanches) < spikesPerAvalancheControl:
        raise Exception("Invalid number of spikes for the given number of avalanches.")

    # DECLARE VARIABLES
    avalanchesRemaining = numAvalanches     # number of avalanches left to generate
    currentTime = random.randint(0, 600)

    # serves as the temporal queue for spikes, contains tuples(timestamp, [neuron array])
    temporalQueue = []

    while avalanchesRemaining > 0:
        tempQueue, currentTime = generateAvalanche(currentTime, avalancheLength)
        avalanchesRemaining = avalanchesRemaining - 1
        temporalQueue = temporalQueue + tempQueue
        currentTime = currentTime + random.randint(70, 2800)

    # Debugging
    #for item in temporalQueue:
    #    print(f'{item}')

    return temporalQueue
# ---------------------------------------------------------------------------
# main()
if __name__ == '__main__':

    if len(sys.argv) > 1:
        if sys.argv[1].__eq__("help") or sys.argv[1].__eq__("Help"):
            print('-----Help-----')
            print('First Argument: length in spikes for a given avalanche')
            print('Second Argument: number of avalanches')
            print('Ex: python mergingAvalanches.py 20 2')
        else:
            avalancheLength = int(sys.argv[1])
            avalanches = int(sys.argv[2])
            output = makeStuff(avalancheLength, avalanches)
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
        path = './data/mergingAvalanches' + str(i) + '.csv'
        while (os.path.isfile(path)):
            i = i + 1
            path = './data/mergingAvalanches' + str(i) + '.csv'

        with open(path, 'w', newline='') as csvfile:
            write = csv.writer(csvfile)
            write.writerows(results)

        print(f'File Generated: {path}')

    else:
        print('Must provide input arguments.')
        print('Ex: python mergingAvalanches.py 20 2')
