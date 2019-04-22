#include <iostream>
#include <math.h>
#include <vector>
#include <algorithm>
#include <fstream>
#include "tqdm.h"
using namespace std;

const int NEURON_COUNT = 10000;
const int SPIKE_COUNT = 430128718;
const int NEURONS_MATRIX_COLS = 2;
const int SPIKES_MATRIX_COLS = 2;
const int RADIUS = 8;
const int TAU = 50;
char neuronsFilename[] = "/home/NETID/lundvm/data/neurons.csv";
char spikesFilename[] = "/home/NETID/lundvm/data/allSpikeTime.csv";

struct Spike{
  int timeStep;
  int id;

  bool operator==(const Spike &s) const{
    return (this->timeStep == s.timeStep) && (this->id == s.id);
  }

  bool operator<(const Spike& r) const{
    return (timeStep < r.timeStep && id == r.id && id < r.id);
  }

};


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
  int neurons[NEURON_COUNT][NEURONS_MATRIX_COLS];
  int** dist = new int*[NEURON_COUNT];
  for(int i = 0; i < NEURON_COUNT; ++i)
    dist[i] = new int[NEURON_COUNT];
  int** spikes = new int*[SPIKE_COUNT];
  for(int i = 0; i < SPIKE_COUNT; ++i)
    spikes[i] = new int[SPIKES_MATRIX_COLS];
  vector<vector<Spike>> avalanches;
  int mergeCount = 0;

  FILE *neuronsFile = fopen(neuronsFilename, "r");
  for (int i = 0; i < NEURON_COUNT; i++) {
    for (int j = 0; j < NEURONS_MATRIX_COLS; j++) {
      fscanf(neuronsFile, "%d,", &neurons[i][j]);
    }
  }
  tqdm bar;
  computeDist(dist, neurons, bar);

  FILE *spikesFile = fopen(spikesFilename, "r");
  for (int i = 0; i < SPIKE_COUNT; i++) {
    bar.progress(i, SPIKE_COUNT);
    for (int j = 0; j < SPIKES_MATRIX_COLS; j++) {
      fscanf(spikesFile, "%d,", &spikes[i][j]);
    }
  }

  for(int i = 0; i < SPIKE_COUNT; i++){
    bar.progress(i, SPIKE_COUNT);
    vector<Spike> neighborSpikes;
    int currentTimeStep = spikes[i][0];
    int currentId = spikes[i][1];
    struct Spike currentSpike = {currentTimeStep, currentId};
    int pos = i - 1;
    if(pos >= 0){
      int prevTimeStep = spikes[pos][0];
      int prevId = spikes[pos][1];
      while(pos >= 0 && prevTimeStep >= currentTimeStep - TAU ){
        prevTimeStep = spikes[pos][0];
        prevId = spikes[pos][1];
        if(dist[currentId][prevId] <= RADIUS){
          struct Spike prevSpike = {prevTimeStep, prevId};
          neighborSpikes.push_back(prevSpike);
        }
        pos--;
      }
    }
    if(i == 0){
      neighborSpikes.push_back(currentSpike);
    }
    if(neighborSpikes.empty()){
      continue;
    }
    //TODO: only look at avalanches that are close in time
    vector<int> avalancheIndex;
    for(vector<int>::size_type j = avalanches.size() - 1; j != (vector<int>::size_type) -1; j--){
      bool exitLoop = false;
      vector<Spike> currentAvalanche = avalanches[j];
      for(vector<int>::size_type k = neighborSpikes.size() - 1; k != (vector<int>::size_type) -1; k--){
        struct Spike temp = neighborSpikes[k];
        if(currentAvalanche.back().timeStep < temp.timeStep){
          exitLoop = true;
          break;
        }
        if(binary_search(currentAvalanche.begin(), currentAvalanche.end(), temp)){
          avalancheIndex.push_back(j);
          break;
        }
      }
      if(exitLoop){
        break;
      }
    }

    if(avalancheIndex.empty()){
      vector<Spike> newAvalanche;
      newAvalanche.push_back(currentSpike);
      avalanches.push_back(newAvalanche);
    }
    else if(avalancheIndex.size() == 1){
      avalanches[avalancheIndex[0]].push_back(currentSpike);
    }
    else{
      mergeCount++;
      cout << mergeCount << ": merging " << avalancheIndex.size() << " avalanches" << endl;
      vector<Spike> first = avalanches[avalancheIndex.back()];
      for(int i = avalancheIndex.size()-2; i >= 0; --i){
        vector<Spike> second = avalanches[avalancheIndex[i]];
        int size = first.size() + second.size();
        vector<Spike> result(size);
        merge(first.begin(), first.end(), second.begin(), second.end(), result.begin());
        avalanches[avalancheIndex[i+1]] = result;
        first = result;
        avalanches.erase(avalanches.begin() + avalancheIndex[i]);
      }
      avalanches[avalancheIndex.back()].push_back(currentSpike);
    }
  }

  ofstream fs;
  string filename = "/home/NETID/lundvm/data/spatiotemporal_avalanches.csv";
  fs.open(filename);
  for(auto it = avalanches.begin(); it != avalanches.end(); ++it){
    vector<Spike> currentAvalanche = *it;
    if(!currentAvalanche.empty() && currentAvalanche.size() != 1){
      fs << currentAvalanche.front().timeStep << "," << currentAvalanche.back().timeStep << ","
      << currentAvalanche.size() << std::endl;
    }

  }
  fs.close();
  return 0;
}