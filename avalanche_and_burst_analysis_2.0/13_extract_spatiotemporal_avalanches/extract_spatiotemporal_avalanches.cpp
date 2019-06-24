// Script that clusters spikes into spatiotemporal avalanches 
// Author: Mariia Lundvall lundvm@uw.edu
// Date: 06/05/2019
// How to compile: g++ -O2 -std=c++11 extract_spatiotemporal_avalanches.cpp -o st_avals 

#include <iostream>
#include <math.h>
#include <vector>
#include <set>
#include <algorithm>
#include <fstream>
#include "tqdm.h" // progress bar
using namespace std;

// number of neurons 
const int NEURON_COUNT = 10000;
// spike count, when processing all spikes it should be equal to 570189562,
// when processing nonstarter spikes only, it should be equal to 430128718
// these values are valid for the tR_1.0--fE_0.90 simulation, but might be
// different for other simulations
const int SPIKE_COUNT = 570189562; 
// columns in the neuron matrix, needed when loading the neurons csv into a 2D array
const int NEURONS_MATRIX_COLS = 2;
// columns in the spikes matrix, needed when loading the spikes csv into a 2D array
const int SPIKES_MATRIX_COLS = 2;
// spatiotemporal constraints 
// 8 neurons
const int RADIUS = 8;
// 50 timesteps
const int TAU = 50;
// path to the neurons file
// the file must have x and y coordinates of neurons, row index == neuron id
char neuronsFilename[] = "/home/NETID/lundvm/data/neurons.csv";
// path to the spikes file
// the file must contain timestep and id of the spiking neuron
// this file is produced by 05_extract_spike_data.ipynb
char spikesFilename[] = "/home/NETID/lundvm/data/allSpikeTime_all.csv";
// file where to save extracted avalanches 
string filename = "/home/NETID/lundvm/data/spatiotemporal_avalanches_060519.csv";

struct Spike{
  int timeStep;
  int id;

  bool operator==(const Spike &s) const{
    return (this->timeStep == s.timeStep) && (this->id == s.id);
  }

  bool operator<(const Spike& r) const{
    if(timeStep < r.timeStep){
      return true;
    }
    else if(timeStep == r.timeStep){
      return id < r.id;
    }
    return false;
  }
};

// computes euclidean distances between all neurons and saves them in a 2D matrix
// PARAMS
// distArray: preallocated array for holding distances
// neuronArray: array with neuron x and y coordinates
// bar: tqdm progress bar
void computeDist(int **distArray, int neuronArray[][NEURONS_MATRIX_COLS], tqdm bar){
  for (int i = 0; i < NEURON_COUNT; i++){
    bar.progress(i, NEURON_COUNT);
    for (int j = 0; j < NEURON_COUNT; j++){
      distArray[i][j] = sqrt((neuronArray[i][0] - neuronArray[j][0])*(neuronArray[i][0] - neuronArray[j][0])
                            + (neuronArray[i][1] - neuronArray[j][1])*(neuronArray[i][1] - neuronArray[j][1]));
    }
  }
}

int main() {
  // matrix to hold neuron data
  int neurons[NEURON_COUNT][NEURONS_MATRIX_COLS];
  // matrix to hold distances
  int** dist = new int*[NEURON_COUNT];
  for(int i = 0; i < NEURON_COUNT; ++i)
    dist[i] = new int[NEURON_COUNT];
  // matrix to hold spikes
  int** spikes = new int*[SPIKE_COUNT];
  for(int i = 0; i < SPIKE_COUNT; ++i)
    spikes[i] = new int[SPIKES_MATRIX_COLS];
  // vector of sets, to hold extracted avalanches 
  vector<set<Spike>> avalanches;
  // count merged avalanches
  int mergeCount = 0;

  // load neuron data from a csv into a matrix
  FILE *neuronsFile = fopen(neuronsFilename, "r");
  for (int i = 0; i < NEURON_COUNT; i++) {
    for (int j = 0; j < NEURONS_MATRIX_COLS; j++) {
      fscanf(neuronsFile, "%d,", &neurons[i][j]);
    }
  }
  tqdm bar;
  // compute distances between all neurons
  computeDist(dist, neurons, bar);
  
  // load spike data from a csv into a matrix 
  FILE *spikesFile = fopen(spikesFilename, "r");
  for (int i = 0; i < SPIKE_COUNT; i++) {
    bar.progress(i, SPIKE_COUNT);
    for (int j = 0; j < SPIKES_MATRIX_COLS; j++) {
      fscanf(spikesFile, "%d,", &spikes[i][j]);
    }
  }
  
  // for every spike 
  for(int i = 0; i < SPIKE_COUNT; i++){
    bar.progress(i, SPIKE_COUNT);
	// find all neighbors (spikes within 8 neurons and 50 timesteps)
    vector<Spike> neighborSpikes;
    int currentTimeStep = spikes[i][0];
    int currentId = spikes[i][1];
    Spike currentSpike = {currentTimeStep, currentId};
    int pos = i-1;
    if(pos > 0){
      int prevTimeStep = spikes[pos][0];
      int prevId = spikes[pos][1];
      while(pos > 0 && prevTimeStep >= currentTimeStep - TAU ){
        if(dist[currentId][prevId] <= RADIUS){
          Spike prevSpike = {prevTimeStep, prevId};
          neighborSpikes.push_back(prevSpike);
        }
        pos--;
        prevTimeStep = spikes[pos][0];
        prevId = spikes[pos][1];
      }
    }
	// if no neighbors are found, continue to the next spike
    if(neighborSpikes.empty()){
      continue;
    }
	// otherwise find all avalanches containing a spike from the list of neighbors
    vector<int> avalancheIndex;
    for(vector<int>::size_type j = avalanches.size() - 1; j != (vector<int>::size_type) -1; j--){
	  // if the last spike of the current avalanche happened 5000 timesteps
	  // earlier than the earliest spike in the list of neighbors, break: the 
	  // following avalanches happened too early and cannot contain any of the
	  // neighbor spikes 
      if(avalanches[j].rbegin()->timeStep + 5000 < neighborSpikes.back().timeStep){
        break;
      }
      for(vector<int>::size_type k = neighborSpikes.size() - 1; k != (vector<int>::size_type) -1; k--){
        if(avalanches[j].count(neighborSpikes[k]) > 0){
          avalancheIndex.push_back(j);
          break;
        }
      }
    }
	
	// if no avalanches found, create a new avalanche
    if(avalancheIndex.empty()){
      set<Spike> newAvalanche;
	  // add all spikes from neighbor spikes  to that avalanche
      for(int i = 0; i < neighborSpikes.size(); i++){
        newAvalanche.insert(neighborSpikes[i]);
      }
	  // add current spike to the avalanches 
      newAvalanche.insert(currentSpike);
	  // add the avalanche to the avalanches vector 
      avalanches.push_back(newAvalanche);
    }
	// if one avalanche found, add all neighbor spikes and the current spikes to 
	// that avalanches 
    else if(avalancheIndex.size() == 1){
      avalanches[avalancheIndex[0]].insert(neighborSpikes.begin(), neighborSpikes.end());
      avalanches[avalancheIndex[0]].insert(currentSpike);
    }
	// if more than one avalanche found 
    else{
	  // merge all of the found avalanches into one
      mergeCount++;
      for(int idx = 1; idx < avalancheIndex.size(); idx++){
        avalanches[avalancheIndex[idx]].insert(avalanches[avalancheIndex[idx - 1]].begin(), avalanches[avalancheIndex[idx - 1]].end());
        avalanches.erase(avalanches.begin() + avalancheIndex[idx - 1]);
      }
	  // add all neighbor spikes and the current spikes to that avalanches 
      avalanches[avalancheIndex.back()].insert(neighborSpikes.begin(), neighborSpikes.end());
      avalanches[avalancheIndex.back()].insert(currentSpike);

    }
  }
  
  // single spike count (spikes that are not a part of any avalanche)
  int countSingles = 0;
  // avalanche count 
  int countAvalanches = 0;
  // write extracted avalanches into a csv file (start timestep, end timestep, 
  // and spike count)
  ofstream fs;
  fs.open(filename);
  for(auto it = avalanches.begin(); it != avalanches.end(); ++it){
    set<Spike> currentAvalanche = *it;
    if(!currentAvalanche.empty() && currentAvalanche.size() != 1){
      fs << currentAvalanche.begin()->timeStep << "," << currentAvalanche.rbegin()->timeStep << ","
      << currentAvalanche.size() << std::endl;
      countAvalanches++;
    }
    if(currentAvalanche.size() == 1){
      countSingles++;
    }
  }
  fs.close();
  // output statistics 
  cout << "Found " << countAvalanches << " avalanches" << endl;
  cout << "Found " << countSingles << " single spikes" << endl;
  cout << mergeCount << " merges" << endl;
  
  // free memory 
  for(int i = 0; i < NEURON_COUNT; ++i)
    delete[] dist[i];
  delete[] dist;
  for(int i = 0; i < SPIKE_COUNT; ++i)
    delete[] spikes[i];
  delete[] spikes;
  return 0;
}