/**
 * @file    spatiotemporal.cpp
 * @author  Arjun Taneja (arjun79@uw.edu)
 * @date    13 July, 2025
 * @brief   Perform spatiotemporal clustering on spikes to construct avalanches.
 *
 * Algorithm Overview:
 *   For each incoming spike (parsed chronologically in time):
 *     1. Sliding Window Maintenance:
 *          Maintain a deque (recentSpikes) of spikes within a temporal window (tau).
 *     2. Neighbor Scan:
 *          Find spatiotemporal neighbors by checking distance to spikes in the deque.
 *     3. Avalanche Insertion and Merging:
 *          Insert current spike and neighbors into avalanches.
 *          If neighbors span multiple avalanches, merge them into one.
 *
 * Compilation Instruction:
 *   g++ -O3 -march=native -flto -funroll-loops spatiotemporal.cpp
 */

#include <bits/stdc++.h>
#include "tqdm.h"  // CLI progress bar (optional, does not affect core logic)

using namespace std;


// ----------------------------------------------------------------------------
// GLOBAL PARAMETERS
// ----------------------------------------------------------------------------

int tau = 50;       // 5ms meanISI translates to 50 timesteps
int radius = 8;     // Spatial distance threshold for spatiotemporal neighbors

/**
 * @brief Represents a spike event with timestep and neuron ID.
 *
 * Defines comparison operators for sorting and hashing.
 */
struct Spike {
    int ts;         // Timestep
    int id;         // Neuron ID

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
 * @brief Define custom hash function to facilitate Spike usage as keys in hashmaps.
 */
namespace std {
    template <>
    struct hash<Spike> {
        std::size_t operator()(const Spike& s) const {
            std::size_t h1 = std::hash<int>()(s.id);
            std::size_t h2 = std::hash<long long>()(s.ts);
            return h1 ^ (h2 << 1); 
        }
    };
}

 /**
 * @brief Compute Euclidean distance between two neurons given their IDs.
 * @param id1, id2 Represents the 1-dimensional integer index of the neurons.
 * @return Distance between neurons in 2D grid.
 */
double getDistance(int id1, int id2) {
    int x1 = (id1-1)/100 + 1;
    int y1 = id1 - (100*x1) + 100;

    int x2 = (id2-1)/100 + 1;
    int y2 = id2 - (100*x2) + 100;

    return sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2));
}

/**
 * @brief Main function: read spike data, perform spatiotemporal clustering,
 *        merge avalanches as needed, and output results.
 *
 * Input:
 *   - CSV file at specified path.
 * Output:
 *   - CSV file with avalanche information written to specified path.
 */
int main() {
    auto start = std::chrono::high_resolution_clock::now();     
    tqdm bar;  // CLI progress bar

    int numSpikes = 0;  // Total number of spikes processed

    deque<Spike> recentSpikes;  // Sliding window of recent spikes (up to tau timesteps)
    unordered_map<Spike, int> spikeToAval;  // Map spike to its avalanche ID

    unordered_map<int, set<Spike>> avalanches;  // Map avalancheID -> spikes 

    int avalancheID = 0;  // Initial avalanche

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

        // Neuron IDs for this timestep
        while (getline(ss, token, ',')) { 
            int currentNeuronID = stoi(token);
            Spike currentSpike = {currentTimestep, currentNeuronID};
            numSpikes++;
            bar.progress(numSpikes, 172323192);  // Hardcoded total spike count

            // Maintain sliding window of recent spikes (< tau)
            while (!recentSpikes.empty() && recentSpikes.front().ts < (currentTimestep - tau)) {
                recentSpikes.pop_front();
            }
            

            // Find spatiotemporal neighbors
            vector<Spike> neighborSpikes;
            for (const Spike& s : recentSpikes) {
                if (getDistance(s.id, currentNeuronID) < radius) {
                    neighborSpikes.push_back(s);
                }
            }

            // Skip spike if it has no neighbors (avoids 1-sized avalanches)
            if(neighborSpikes.empty()) {
                recentSpikes.push_back(currentSpike);
                continue;
            }
                

            // Identify overlapping avalanche IDs from neighbors
            unordered_set<int> overlappingAvalIds;
            for (const Spike& s : neighborSpikes) {
                if (spikeToAval.count(s)) {
                    overlappingAvalIds.insert(spikeToAval[s]);
                }
            }

            if (overlappingAvalIds.empty()) {
                // Create new avalanche
                avalanches[avalancheID].insert(currentSpike);
                for (const Spike& s : neighborSpikes) {
                    avalanches[avalancheID].insert(s);
                    spikeToAval[s] = avalancheID;
                }
                spikeToAval[currentSpike] = avalancheID;
                avalancheID++;
            } else {
                // Merge avalanches into the first avalID
                auto it = overlappingAvalIds.begin();
                int mainID = *it++;  // Assign first and then increment

                for (; it != overlappingAvalIds.end(); ++it) {
                    for (const Spike& s : avalanches[*it]) {
                        avalanches[mainID].insert(s);
                        spikeToAval[s] = mainID;
                    }
                    avalanches.erase(*it);
                }

                for (const Spike& s : neighborSpikes) {
                    avalanches[mainID].insert(s);
                    spikeToAval[s] = mainID;
                }

                avalanches[mainID].insert(currentSpike);
                spikeToAval[currentSpike] = mainID;
            }

            recentSpikes.push_back(currentSpike);
        }
    }

    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> duration = end - start;
    std::cout << "\nExecution time for " << numSpikes << " spikes: " << duration.count() << " seconds\n";
    cout << "Number of avalanches: " << avalanches.size() << endl;

    // Output results to CSV
    std::ofstream outputFile("./output/SpaTemporal_" + filename + "_tau-" + to_string(tau) + ".csv");
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

    // ------------------------------------------------------------------------
    // Optional: Output results to TXT for debugging
    // Uncomment to write detailed spike-ownership data.
    // ------------------------------------------------------------------------

    // outputFile.clear();

    // outputFile.open("./output/SpaTemporal_" + filename + "_tau-" + to_string(tau)+ ".txt");
    // if(outputFile.is_open()) {
    //     //header row
    //     // outputFile << "ID,StartRow,EndRow,StartT,EndT,Width,TotalSpikes\n";

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

