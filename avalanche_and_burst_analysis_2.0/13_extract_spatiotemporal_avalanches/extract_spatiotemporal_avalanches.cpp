#include <iostream>
#include <math.h>
#include <vector>
#include <set>
#include <algorithm>
#include <fstream>
#include "tqdm.h"
using namespace std;

const int NEURON_COUNT = 10000;
const int SPIKE_COUNT = 570189562; //430128718;
const int NEURONS_MATRIX_COLS = 2;
const int SPIKES_MATRIX_COLS = 2;
const int RADIUS = 8;
const int TAU = 50;
char neuronsFilename[] = "/home/NETID/lundvm/data/neurons.csv";
char spikesFilename[] = "/home/NETID/lundvm/data/allSpikeTime_all.csv";

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
  vector<set<Spike>> avalanches;
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
    if(neighborSpikes.empty()){
      continue;
    }
    vector<int> avalancheIndex;
    for(vector<int>::size_type j = avalanches.size() - 1; j != (vector<int>::size_type) -1; j--){
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

    if(avalancheIndex.empty()){
      set<Spike> newAvalanche;
      for(int i = 0; i < neighborSpikes.size(); i++){
        newAvalanche.insert(neighborSpikes[i]);
      }
      newAvalanche.insert(currentSpike);
      avalanches.push_back(newAvalanche);
    }
    else if(avalancheIndex.size() == 1){
      avalanches[avalancheIndex[0]].insert(neighborSpikes.begin(), neighborSpikes.end());
      avalanches[avalancheIndex[0]].insert(currentSpike);
    }
    else{
      mergeCount++;
      //cout << mergeCount << ": merging " << avalancheIndex.size() << " avalanches" << endl;
      for(int idx = 1; idx < avalancheIndex.size(); idx++){
        avalanches[avalancheIndex[idx]].insert(avalanches[avalancheIndex[idx - 1]].begin(), avalanches[avalancheIndex[idx - 1]].end());
        avalanches.erase(avalanches.begin() + avalancheIndex[idx - 1]);
      }
      avalanches[avalancheIndex.back()].insert(neighborSpikes.begin(), neighborSpikes.end());
      avalanches[avalancheIndex.back()].insert(currentSpike);

    }
  }

  int countSingles = 0;
  int countAvalanches = 0;
  ofstream fs;
  string filename = "/home/NETID/lundvm/data/spatiotemporal_avalanches_06052019.csv";
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
  cout << "Found " << countAvalanches << " avalanches" << endl;
  cout << "Found " << countSingles << " single spikes" << endl;
  cout << mergeCount << " merges" << endl;
  
  for(int i = 0; i < NEURON_COUNT; ++i)
    delete[] dist[i];
  delete[] dist;
  for(int i = 0; i < SPIKE_COUNT; ++i)
    delete[] spikes[i];
  delete[] spikes;
  return 0;
}