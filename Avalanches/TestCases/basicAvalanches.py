##############################################################################
# Author: Lawrence Scott
# Project: Test Case Data Generation for Neuronal Avalanche Detection Program
# Creation Date: 4/13/2025
# Date of Last Modification: 4/24/2025
##############################################################################
# Purpose:	To create test cases with a known number of spikes and avalanches
#           to verify algorithmic accuracy and performance.

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

    # generate the first spike in the data set
    currentSet = []
    currentSpike = makeSpike()
    spikesRemaining = spikesRemaining - 1
    currentSet.append(currentSpike)
    tempTup = currentTime, currentSet
    temporalQueue.append(tempTup)
    currentSet = []

    # temporal threshold is 50
    currentTime = currentTime + random.randint(0, 49)

    while spikesRemaining > 0:
        nextSpike = makeSpikeSpecific(currentSpike)

        # If spikes are not spatially close, generate a new spike
        while not spatialCheck(currentSpike, nextSpike):
            nextSpike = makeSpikeSpecific(currentSpike)

        currentSet.append(nextSpike)
        spikesRemaining = spikesRemaining - 1
        chance = random.randint(0, 100)
        # Chance defines the frequency at which multiple spikes will appear in the same time period
        if chance < 70 or spikesRemaining == 0:
            tempTup = currentTime, currentSet
            temporalQueue.append(tempTup)
            currentTime = currentTime + random.randint(0, 49)
            currentSet = []

        currentSpike = nextSpike

    # Debugging
    #for item in temporalQueue:
    #    print(f'{item}')

    return temporalQueue

# ---------------------------------------------------------------------------
# data generator
# Arguments: spike count, avalanche count, single nonavalanche spike count
# NOTE: number of single nonavalanche spike count gets randomized therefore
#       the number provided acts as a maximum possible single spikes
def makeStuff(numSpikes, numAvalanches, singleSpikes):
    # Define and check for the minimum number of spikes per avalanche
    # 2 spikes per avalanche
    spikesPerAvalancheControl = 2
    if (numSpikes / numAvalanches) < spikesPerAvalancheControl:
        raise Exception("Invalid number of spikes for the given number of avalanches.")

    # DECLARE VARIABLES
    spikesRemainingAva = numSpikes          # number of spikes left to generate
    avalanchesRemaining = numAvalanches     # number of avalanches left to generate
    spikesRemainingSingle = singleSpikes    # number of single spikes left to generate

    currentTime = random.randint(0, 600)

    # serves as the temporal queue for spikes, contains tuples(timestamp, [neuron array])
    temporalQueue = []

    while avalanchesRemaining > 0:
        if (spikesRemainingAva / avalanchesRemaining) >= spikesPerAvalancheControl:
            availableSpikes = 2 + spikesRemainingAva - (spikesPerAvalancheControl * avalanchesRemaining)
            spikesToUse = random.randint(2, availableSpikes)
            tempQueue = generateAvalanche(currentTime, spikesToUse)
            spikesRemainingAva = spikesRemainingAva - spikesToUse
            avalanchesRemaining = avalanchesRemaining - 1
            temporalQueue = temporalQueue + tempQueue

        currentTime = currentTime + random.randint(51, 1400)

        if spikesRemainingSingle > 0:
            spikesToUse = random.randint(1, spikesRemainingSingle)
            for i in range(0, spikesToUse):
                tempSpike = makeSpike()
                tempSet = []
                tempSet.append(tempSpike)
                tempTup = currentTime, tempSet
                temporalQueue.append(tempTup)
                currentTime = currentTime + random.randint(51, 1400)
            spikesRemainingSingle = spikesRemainingSingle - spikesToUse

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
            print('First Argument: number of spikes available for avalanches')
            print('Second Argument: number of avalanches')
            print('Third Argument: number of single nonavalanche spikes')
            print('Ex: python noAvSpatial.py 20 2 25')
        else:
            avaSpikes = int(sys.argv[1])
            avalanches = int(sys.argv[2])
            singleSpikes = int(sys.argv[3])
            output = makeStuff(avaSpikes, avalanches, singleSpikes)
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
        path = './data/basicAvalanches' + str(i) + '.csv'
        while (os.path.isfile(path)):
            i = i + 1
            path = './data/basicAvalanches' + str(i) + '.csv'

        with open(path, 'w', newline='') as csvfile:
            write = csv.writer(csvfile)
            write.writerows(results)

        print(f'File Generated: {path}')

    else:
        print('Must provide input arguments.')
        print('Ex: python basicAvalanches.py 20 2 25')
