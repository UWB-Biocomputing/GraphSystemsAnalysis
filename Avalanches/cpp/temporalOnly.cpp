/**
 * @file    temporalOnly.cpp
 * @author  Arjun Taneja (arjun79@uw.edu)
 * @date    13 July, 2025
 * @brief   Perform temporal-only clustering on spikes to construct avalanches.
 *
 *          Reads a CSV with spikes (timestep, neuron IDs),
 *          groups them into avalanches based on a temporal threshold (tau),
 *          removes single-spike avalanches,
 *          and outputs avalanche information to CSV.
 *
 * Compilation Instruction:
 *   g++ -O3 -march=native -flto -funroll-loops temporalOnly.cpp
 */

#include <bits/stdc++.h>
#include "tqdm.h"  // CLI progress bar (for large datasets)

using namespace std;

// ----------------------------------------------------------------------------
// GLOBAL PARAMETERS
// ----------------------------------------------------------------------------

int tau = 1.5;  // meanISI is 1.5 - gets truncated to 1 with integer assignment 
                // truncation does not affect core logic

 /**
 * @brief Represents a single spike event with timestep and neuron ID.
 *
 * Defines comparison operators for use in sets/maps.
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

/**
 * @brief Reads spike data from CSV, clusters into avalanches,
 *        removes single-spike avalanches, and writes output.
 *
 * Input:
 *   - CSV file at specified path.
 * Output:
 *   - CSV file with avalanche statistics written to specified path.
 */
int main() {
    auto start = std::chrono::high_resolution_clock::now();
    tqdm bar;  // Progress bar
    
    int numSpikes = 0;  // Total number of spikes processed

    unordered_map<int, set<Spike>> avalanches;  // Map avalancheID -> spikes 

    int avalancheID = 0;  // Current avalanche ID

    int prevTimeStep = -100;  // Initialize to dummy value

    string directory = "/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/";
    string filename = "lastQuarter";
    
    ifstream iFile(directory + filename + ".csv");
    string line = "";
    
    // ------------------------------------------------------------------------
    // Read input file line-by-line
    // ------------------------------------------------------------------------
    while (getline(iFile, line)) {
        stringstream ss(line);
        string token = "";

        // First column: timestep
        getline(ss, token, ',');                           
        int currentTimestep = stoi(token);

        // If spike is more than tau away from previous, start new avalanche
        if(prevTimeStep + tau < currentTimestep) {
            avalancheID++;     
        } 

        // Neuron IDs for this timestep
        while (getline(ss, token, ',')) { 
            int currentNeuronID = stoi(token);
            Spike currentSpike = {currentTimestep, currentNeuronID};
            numSpikes++;
            bar.progress(numSpikes, 172323192);  // Hardcoded total spike count

            avalanches[avalancheID].insert(currentSpike);
        }

        prevTimeStep = currentTimestep;
    }

    // ------------------------------------------------------------------------
    // Remove single-spike avalanches
    // ------------------------------------------------------------------------
    vector<int> removals;
    for(auto [id,aval] : avalanches) {
        if(aval.size() == 1)
            removals.push_back(id);
    }

    for(int i = 0; i < removals.size(); i++) {
        avalanches.erase(removals[i]);
    }

    // ------------------------------------------------------------------------
    // Output results to CSV
    // ------------------------------------------------------------------------
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> duration = end - start;
    std::cout << "\nExecution time for " << numSpikes << " spikes: " 
        << duration.count() << " seconds\n";
    cout << "Number of avalanches: " << avalanches.size() << endl;

    std::ofstream outputFile("./output/TEMPORAL_" + filename + "_tau-" 
        + to_string(tau) + ".csv");
    if(outputFile.is_open()) {
        outputFile << "ID,StartRow,EndRow,StartT,EndT,Width,TotalSpikes\n";

        int i = 1;
        for(auto [id, aval] : avalanches) {
            outputFile << i << ",0,0," << aval.begin()->ts << "," 
            << aval.rbegin()->ts << "," 
            << (aval.rbegin()->ts - aval.begin()->ts + 1) << "," 
            << aval.size() << endl;
            i++;
        }
    
        outputFile.close();
        cout << "Output data written to csv file successfully" << endl;
    } else {
        cerr << "Unable to open file for writing." << endl;
    }


    // ------------------------------------------------------------------------
    // Optional: Output results to TXT for debugging
    // Uncomment to write detailed spike-ownership data.
    // ------------------------------------------------------------------------

    // outputFile.clear();

    // outputFile.open("./output/TEMPORAL_" + filename + "_tau-" + 
    // to_string(tau) + ".txt");
    // if(outputFile.is_open()) {

    //     //write avalanche data
    //     int i = 1;
    //     for(auto [id, aval] : avalanches) {
    //         outputFile << "Avalanche - " << i << " ; Size = " 
    //          << aval.size() << endl;
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
