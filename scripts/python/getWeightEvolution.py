'''
GETWEIGHTEVOLUTION Generate a matrix showing the evolution of each edge
weight over time

This function reads the series of Graphitti weight matrices output 
after each epoch and generates a single matrix showing the edge
weight evolution over time. An edge map is also output to map the
edge row to the source and dest neurons.

Input:
weights_dir - Directory containing the weights-epoch-#.xml files output
              by Grpahitti. The entire path can be used; for example
              '/CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000'

Output:
  - weight_evolution.csv
  - edge_map.csv

Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)
Last updated: 07/01/2025
'''

import numpy as np
import pandas as pd
import xml.etree.ElementTree as ET 


def xmlToNumpy(node, rows, cols):
    print("Converting node to matrix for: " + node.tag)

    m = np.zeros(shape=(rows, cols))
    r = 0
    c = 0
    for child in node:
        m[r][c] = float(child.text)
        c += 1

        # new row
        if c == cols:
            r += 1
            c = 0

    return m


def getWeightMatrix(file_name, src_root, weights_root):
    print("Building weights matrix for: " + file_name)

    tree = ET.parse(file_name)
    root = tree.getroot()

    idNum = 0
    srcIdx = root.find(src_root)
    weights = root.find(weights_root)

    rows = 10000
    cols = 200

    srcIdx_np = xmlToNumpy(srcIdx, rows, cols)
    weights_np = xmlToNumpy(weights, rows, cols)

    print("Converting matrices into square format...")
    edge_weights = np.zeros(shape=(rows, rows))

    weight_count = 0

    for r in range(weights_np.shape[0]):
        for c in range(weights_np.shape[1]):
            if weights_np[r][c] != 0:
                weight_count += 1
                src = int(srcIdx_np[r][c])
                edge_weights[src][r] = weights_np[r][c]

    print("Total weighted edges: " + str(weight_count))

    return edge_weights


if __name__ == "__main__": 
    # example execution: python ./getWeightEvolution.py /CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000
    weights_dir = sys.argv[1]

    sim_length = 100    # change as needed, this function expects 1 epoch per second

    # iterate weight files per epoch
    for epoch in range(1,sim_length+1):
        print(f"Parse matrix {t_sec}")
        weights_file = weights_dir + "/weights-epoch-" + str(epoch) + ".xml"
        edge_weights = getWeightMatrix(weights_file, "SourceVertexIndex", "WeightMatrix")
        weight_matrix = edge_weights.to_numpy()
        
        # instantiate output variables
        if epoch == 1:
            # compile all the weight files into a n_edges x sim_length 
            n_edges = np.count_nonzero(weight_matrix)
            print(f"Found {n_edges} non-zero edges.")
            weight_evolution = np.zeros(shape=(n_edges, sim_length))

            # map weight_evolution edges to src and dest neurons
            edge_map = np.zeros(shape=(n_edges, 2))

        e = 0
        for r in range(weight_matrix.shape[0]):
            for c in range(weight_matrix.shape[1]):
                if(weight_matrix[r][c] != 0):
                    weight_evolution[e][t_sec-1] = weight_matrix[r][c]

                    if t_sec == 1:
                        edge_map[e][0] = int(r) #srcVertex
                        edge_map[e][1] = int(c) #destVertex

                    e +=1 

    # Output to csv
    df_evolution = pd.DataFrame(weight_evolution)
    df_evolution.to_csv("/DATA/arndorvf/Graphitti/build/Output/Results/dynamic_stdp_fE_0.90_10000_1000sec_EpochWeights/weight_evolution.csv", index=False)

    df_edgeMap = pd.DataFrame(edge_map)
    df_edgeMap.to_csv("/DATA/arndorvf/Graphitti/build/Output/Results/dynamic_stdp_fE_0.90_10000_1000sec_EpochWeights/edge_map.csv", index=False)
        