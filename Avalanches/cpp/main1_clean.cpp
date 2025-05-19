// Compilation Instruction: g++ -O3 -march=native -flto -funroll-loops main1.cpp 
// -march=native on systems with AVX-512 can occasionally cause thermal throttling due to wide vector execution apparently

#include <bits/stdc++.h>
#include "tqdm.h"               // CLI progress bar - does not affect core logic

using namespace std;

int tau = 50;                   // 5ms meanISI translates to 50 timesteps
int radius = 8;

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

/**
 * Define custom hash function to facilitate Spike usage as keys in hashmaps.
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
 * Convert neuronID to x,y coordinates and get distance between two neurons.
 *
 * @param id1, id2 Represents the 1-dimensional integer index of the neurons.
 * @return floating point distance between the two neurons.
 */
double getDistance(int id1, int id2) {
    int y1 = (id1-1)/100 + 1;
    int x1 = id1 - (100*y1) + 100;

    int y2 = (id2-1)/100 + 1;
    int x2 = id2 - (100*y2) + 100;

    return sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2));
}


int main() {
    auto start = std::chrono::high_resolution_clock::now();     // benchmark time
    tqdm bar;                                                   // progress bar

    int numSpikes = 0;                                          // total number of spikes encountered

    deque<Spike> recentSpikes;                                  // double-ended queue maintains dynamic list 
                                                                // of temporally close spikes up to
                                                                // tau steps back (sliding window)

    unordered_map<Spike, int> spikeToAval;                      // each spike remembers which avalanche
                                                                // it belongs to

    unordered_map<int, set<Spike>> avalanches;                  // each avalanche is identified by  
                                                                // an integer key

    int avalancheID = 0;                                        // initial avalanche

    ifstream iFile("/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90/allSpikeTime.csv");
    string line = "";
	string del = ",";

	// read csv file line-by-line
	while (getline(iFile, line)) {

		// search line for first value - timestep
		auto pos = line.find(del);
		string token = "";
		token = line.substr(0, pos);
		line.erase(0, pos + del.length());
		pos = line.find(del);
		int currentTimestep = stoi(token);
		bool endOfLine = false;

		// increment through line for each subsequent value
		while (endOfLine == false) {
			// catch final line
			if (pos == string::npos) {
				endOfLine = true;
			}
			token = line.substr(0, pos);
			line.erase(0, pos + del.length());
			pos = line.find(del);
			int currentNeuronID = stoi(token);
            Spike currentSpike = {currentTimestep, currentNeuronID};
            numSpikes++;
            bar.progress(numSpikes, 570189562);                 // progress bar - hardcoded number

            // Maintain the recentSpikes sliding window (< tau)
            while (!recentSpikes.empty() && recentSpikes.front().ts < (currentTimestep - tau)) {
                recentSpikes.pop_front();
            }
            

            // Find neighbor spikes from list of recent spikes
            // A neighbor spike must be close to currentSpike in both space and time
            vector<Spike> neighborSpikes;
            for (const Spike& s : recentSpikes) {
                if (getDistance(s.id, currentNeuronID) < radius) {
                    neighborSpikes.push_back(s);
                }
            }

            // if no neighborSpikes found, skip the current spike
            // this avoids forming 1-sized avalanches
            if(neighborSpikes.empty()) {
                recentSpikes.push_back(currentSpike);
                continue;
            }
                

            // Check all neighbor spikes and document the avalanches they belong to
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
                int mainID = *it++; //assign first and then increment

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
            // token = strtok(nullptr, ",");
        }
    }

    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> duration = end - start;
    std::cout << "\nExecution time for " << numSpikes << " spikes: " << duration.count() << " seconds\n";
    cout << "Number of avalanches: " << avalanches.size() << endl;

    std::ofstream outputFile("./output/avalancheOutput_FULL.csv");
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
    

    }

