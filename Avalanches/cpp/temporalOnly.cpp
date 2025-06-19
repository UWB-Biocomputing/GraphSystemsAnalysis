// Compilation Instruction: g++ -O3 -march=native -flto -funroll-loops temporalOnly.cpp 
// -march=native on systems with AVX-512 can occasionally cause thermal throttling due to wide vector execution apparently

#include <bits/stdc++.h>
#include "tqdm.h"                   // CLI progress bar - does not affect core logic

using namespace std;

int tau = 1.5;                      // meanISI is 1.5 - gets truncated to 1 with integer assignment 
                                    // truncation does not affect core logic

/**
 * Define custom datatype for a Spike object containing a timestep and neuronID.
 * Define comparison logic to facilitate sorting and usage in ordered data types.
 */
struct Spike {
    int ts;
    int id;

    bool operator==(const Spike &s) const {
        return (ts == s.ts) && (id == s.id);
    }

    bool operator<(const Spike &r) const {
        if (ts < r.ts) {
            return true;
        } else if (ts == r.ts) {
            return id < r.id;
        }
        return false;
    }
};


int main() {
    auto start = std::chrono::high_resolution_clock::now();     // benchmark time
    tqdm bar;                                                   // progress bar

    int numSpikes = 0;                                          // total number of spikes encountered

    unordered_map<int, set<Spike>> avalanches;                  // each avalanche is identified by  
                                                                // an integer key

    int avalancheID = 0;                                        // initial avalanche

    int prevTimeStep = -100;

    string directory = "/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/";
    string filename = "lastQuarter";
    
    ifstream iFile(directory + filename + ".csv");
    string line = "";
    
    // read csv file line-by-line
    while (getline(iFile, line)) {
        stringstream ss(line);
        string token = "";

        // within each csv line, read each comma-separated-value
        getline(ss, token, ',');                                // fetch first column: timestep        
        int currentTimestep = stoi(token);

        // if the current spike is more than tau away 
        // from the previous spike, start new avalanche
        if(prevTimeStep + tau < currentTimestep) {
            avalancheID++;                                      // have to start a new avalanche
        } 

        // second column onwards (neuronIDs)
        while (getline(ss, token, ',')) { 
            int currentNeuronID = stoi(token);
            Spike currentSpike = {currentTimestep, currentNeuronID};
            numSpikes++;
            bar.progress(numSpikes, 172323192);                 // progress bar - hardcoded number

            // all spikes at the same timestep get added to the current avalanche
            avalanches[avalancheID].insert(currentSpike);
        }

        prevTimeStep = currentTimestep;
    }

    //remove 1-sized avalanches
    vector<int> removals;
    for(auto [id,aval] : avalanches) {
        if(aval.size() == 1)
            removals.push_back(id);
    }

    for(int i = 0; i < removals.size(); i++) {
        avalanches.erase(removals[i]);
    }

    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> duration = end - start;
    std::cout << "\nExecution time for " << numSpikes << " spikes: " << duration.count() << " seconds\n";
    cout << "Number of avalanches: " << avalanches.size() << endl;

    // Documentation and output
    std::ofstream outputFile("./output/TEMPORAL_" + filename + "_tau-" + to_string(tau) + ".csv");
    if(outputFile.is_open()) {
        //header row
        outputFile << "ID,StartRow,EndRow,StartT,EndT,Width,TotalSpikes\n";

        //write avalanche data
        int i = 1;
        for(auto [id, aval] : avalanches) {
            outputFile << i << ",0,0," << aval.begin()->ts << "," << aval.rbegin()->ts << "," << (aval.rbegin()->ts - aval.begin()->ts + 1) << "," << aval.size() << endl;
            i++;
        }
    
        outputFile.close();
        cout << "Output data written to csv file successfully" << endl;
    } else {
        cerr << "Unable to open file for writing." << endl;
    }

    // outputFile.clear();

    // outputFile.open("./output/TEMPORAL_" + filename + "_tau-" + to_string(tau) + ".txt");
    // if(outputFile.is_open()) {

    //     //write avalanche data
    //     int i = 1;
    //     for(auto [id, aval] : avalanches) {
    //         outputFile << "Avalanche - " << i << " ; Size = " << aval.size() << endl;
    //         for(auto spk : aval) {
    //             outputFile<<spk.ts<<", "<<spk.id<<endl;
    //         }
    //         i++;
    //     }
    
    //     outputFile.close();
    //     cout << "Output data written to txt file successfully" << endl;
    // } else {
    //     cerr << "Unable to open file for writing." << endl;
    // }
    

}

