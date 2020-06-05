// Cereal Serialization Binary File Synaptic Weight Data to CSV File Converter

// Author: Emily Hsu (hsuy717@uw.edu)
// last_time_modified: June 04 2020

// This is the C++ file to convert synaptic weight data from Cereal serialization binary file to a CSV file

// the Cereal library : https://uscilab.github.io/cereal/index.html

// Instructions:
// 1) Have your Cereal serialization binary file, this cerealconverter.cpp file, and the Cereal library (source code folder) in the same location
//    Note: the Cereal library source code folder can also be downloaded from the site (see Cereal website for details)
// 2) Compile the program by entering "g++ -std=c++11 cerealconverter.cpp -I ." in the command line
// 3) Run the program by entering "./a.out <your_file_name>" (note: typically, binary file has no extension)
//    For example, if the name of serialization file is "serial", then enter "./a.out serial"
// 4) the program will generate a CSV file named "synaptic_weight.csv" at the same location


#include <fstream>
#include <iostream>
#include <cereal/archives/xml.hpp>
#include <cereal/archives/binary.hpp>
#include <cereal/types/vector.hpp>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
    #define BGFLOAT float

    if(argc!= 2) {
        cerr<< "Error: please enter only Cereal serialization file name" <<endl;
        return false;
    } 

    ifstream memory_in (argv[1], std::ios::binary);

    // Checks to see if serialization file exists
    if(!memory_in) {
        cerr << "The serialization file doesn't exist" << endl;
        return false;
    }

    cereal::BinaryInputArchive archive(memory_in);

    // uses vectors to load synapse weights
    vector<BGFLOAT> WVector;

    // deserializing data to these vectors
    archive(WVector);

    ofstream outputFile;
    outputFile.open("synaptic_weight.csv");

    for(int i = 0; i < WVector.size(); i++) {
        outputFile << WVector[i] << endl;
    }

    return 0;
}



