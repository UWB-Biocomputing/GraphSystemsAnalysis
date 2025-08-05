'''
GETNEURONTYPES 

Parse the graphml file to get a mapping of neurons and their types, where
1 means the neuron is of that type. Each entry is formatted as
[endogenously active, excitatory, inhibitory]

Input:
file_name - graphml file to parse

Output:
neuron_types.csv - mapping of neurons and their types

Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)
Last updated: 06/04/2025
'''

import numpy as np
import pandas as pd
import xml.etree.ElementTree as ET 


def get_neuron_types(file_name):  
    tree = ET.parse(graph_file)
    root = tree.getroot()

    neuron_types = np.zeros((10000,3), dtype=np.int32)
    graph = root.find('./{http://graphml.graphdrawing.org/xmlns}graph')

    for node in graph:
        i = int(node.attrib["id"])
        active = int(node[2].text) == 1
        exc = node[3].text == 'EXC'
        inh = node[3].text == 'INH'
        neuron_types[i] = [int(active), int(exc), int(inh)]

    df = pd.DataFrame(data=neuron_types, columns=["active", "exc", "inh"])
    df.to_csv('/DATA/arndorvf/Graphitti/build/Output/Results/fE_0.90_10000_neuron_types.csv')


if __name__ == "__main__": 
    graph_file = "/DATA/arndorvf/Graphitti/configfiles/graphs/fE_0.90_10000.graphml"
    get_neuron_types(graph_file)