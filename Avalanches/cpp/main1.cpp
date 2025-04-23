//  g++ -std=c++11 main1.cpp -fmessage-length=0 -lpthread

#include <bits/stdc++.h>
#include "tqdm.h" // progress bar
#include "csv.h"

using namespace std;

// int meanISI = 10;
int tau = 50;
int radius = 8;

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

namespace std {
    template <>
    struct hash<Spike> {
        std::size_t operator()(const Spike& s) const {
            std::size_t h1 = std::hash<int>()(s.id);
            std::size_t h2 = std::hash<long long>()(s.ts);
            return h1 ^ (h2 << 1); // or use boost::hash_combine if available
        }
    };
}

double getDistance(int id1, int id2) {
    int y1 = (id1-1)/100 + 1;
    int x1 = id1 - (100*y1) + 100;

    int y2 = (id2-1)/100 + 1;
    int x2 = id2 - (100*y2) + 100;

    return sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2));
}



int main() {
    auto start = std::chrono::high_resolution_clock::now();
    tqdm bar;

    int numSpikes = 0;

    deque<Spike> recentSpikes; //maintains dynamic list of temporally close previous spikes up to tau steps back    
    unordered_map<Spike, int> spikeToAval;
    unordered_map<int, set<Spike>> avalanches;
    int avalancheID = 0;

    // io::LineReader inFile("/DATA/arjun79/GraphSystemsAnalysis/Avalanches/python/avalanche_and_burst_analysis_2.0/13_extract_spatiotemporal_avalanches/allSpikeTime.csv");
    io::LineReader inFile("/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/SpikeTimeSample_1M.csv");
    // io::LineReader inFile("/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/SpikeTimeSample_10000.csv");

    while (char* line = inFile.next_line()) {
        char* token = strtok(line, ",");
        int timestep = stoi(token);
        token = strtok(nullptr, ",");   // move to second column 

        // second column onwards
        while (token) { 
            int neuronID = stoi(token);
            Spike cur = {timestep, neuronID};
            numSpikes++;
            bar.progress(numSpikes, 570189562); //second number is hardcoded from testing
            // bar.progress(numSpikes, 1109799); //second number is hardcoded from testing

            // Maintain the recentSpikes window (<= tau)
            while (!recentSpikes.empty() && recentSpikes.front().ts < timestep - tau) {
                recentSpikes.pop_front();
            }
            

            // Find neighbor spikes
            vector<Spike> neighborSpikes;
            for (const Spike& s : recentSpikes) {
                if (getDistance(s.id, neuronID) < radius) {
                    neighborSpikes.push_back(s);
                }
            }

            // cout<<neighborSpikes.size()<<endl;

            if(neighborSpikes.empty()) {
                recentSpikes.push_back(cur);
                token = strtok(nullptr, ",");
                continue;
            }
                

            // Check all neighbor spikes and process the avalanches they belong to
            unordered_set<int> overlappingAvalIds;
            for (const Spike& s : neighborSpikes) {
                if (spikeToAval.count(s)) {
                    overlappingAvalIds.insert(spikeToAval[s]);
                }
            }

            if (overlappingAvalIds.empty()) {
                // Create new avalanche
                avalanches[avalancheID].insert(cur);
                for (const Spike& s : neighborSpikes) {
                    avalanches[avalancheID].insert(s);
                    spikeToAval[s] = avalancheID;
                }
                spikeToAval[cur] = avalancheID;
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

                avalanches[mainID].insert(cur);
                spikeToAval[cur] = mainID;
            }

            recentSpikes.push_back(cur);
            token = strtok(nullptr, ",");
        }
    }

    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> duration = end - start;
    std::cout << "\nExecution time for " << numSpikes << " spikes: " << duration.count() << " seconds\n";
    cout << "Number of avalanches: " << avalanches.size() << endl;

    unordered_set<int> sizes;
    for(auto [id, aval] : avalanches) {
        sizes.insert(aval.size());
    }

    // for(auto size : sizes) {
    //     cout<<size<<endl;
    // }
    cout<<"Number of unique sizes: " << sizes.size()<<endl;


    return 0;
}
