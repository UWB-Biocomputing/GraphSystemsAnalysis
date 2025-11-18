"""
extract_subgraphs.py
====================

Extract 2-hop ego subgraphs centered around burst-origin neurons.

This script:
    1. Loads raw connectivity, neuron metadata, and burst origin CSVs.
    2. Filters bursts based on global simulation tick (last quarter of simulation).
    3. Merges metadata to ensure correct mapping from (x, y) → neuronID.
    4. Builds a NetworkX graph from synaptic connectivity.
    5. Extracts a 2-hop ego graph around each burst-origin neuron.
    6. Saves all extracted subgraphs as a list of dictionaries inside a .pt file.

Output format:
---------------
A .pt file containing a list of entries:
    [
        {
            'neuronID' : <int>,
            'globalBin': <int>,
            'subgraph' : <networkx.Graph>
        },
        ...
    ]

Author: Haripriya Dhanasekaran
Year: 2025
"""

import os
from pathlib import Path
import pandas as pd
import networkx as nx
import torch


# ---------------------------------------------------------------------
# Function: Load bursts & filter by global tick
# ---------------------------------------------------------------------
def load_and_filter_bursts(burst_file: str,
                           start_tick: int,
                           end_tick: int) -> pd.DataFrame:
    """
    Load burst-origin CSV and filter rows based on global simulation time.

    Parameters
    ----------
    burst_file : str
        Path to burst origin CSV file.
    start_tick : int
        Lower bound of allowed globalBin values.
    end_tick : int
        Upper bound of allowed globalBin values.

    Returns
    -------
    pd.DataFrame
        Filtered burst origin dataframe.
    """
    df = pd.read_csv(
        burst_file,
        header=0,
        names=['x', 'y', 'neuronID', 'localBin', 'globalBin'],
        dtype={
            'x': int,
            'y': int,
            'neuronID': int,
            'localBin': int,
            'globalBin': int
        }
    )

    df = df[df.globalBin.between(start_tick, end_tick)].reset_index(drop=True)
    return df


# ---------------------------------------------------------------------
# Function: Build the Graph
# ---------------------------------------------------------------------
def build_graph(connectivity_file: str) -> nx.Graph:
    """
    Build a NetworkX graph from connectivity CSV.

    Parameters
    ----------
    connectivity_file : str
        Path to CSV containing Source, Destination, Weight.

    Returns
    -------
    nx.Graph
        Undirected synaptic connectivity graph.
    """
    conn_df = pd.read_csv(connectivity_file)

    G = nx.from_pandas_edgelist(
        conn_df,
        source='Source',
        target='Destination',
        edge_attr='Weight',
        create_using=nx.Graph()
    )
    return G


# ---------------------------------------------------------------------
# Function: Extract Subgraphs
# ---------------------------------------------------------------------
def extract_ego_subgraphs(G: nx.Graph,
                          burst_df: pd.DataFrame,
                          radius: int = 2):
    """
    Extract 2-hop ego subgraphs around each burst origin neuron.

    Parameters
    ----------
    G : nx.Graph
        Full neural connectivity graph.
    burst_df : pd.DataFrame
        DataFrame containing 'neuronID' and 'globalBin'.
    radius : int, optional
        Hop radius for ego graph extraction (default = 2).

    Returns
    -------
    list of dict
        List of {neuronID, globalBin, subgraph}.
    """
    subgraphs = []

    for _, row in burst_df.iterrows():
        origin = int(row.neuronID)
        gbin = int(row.globalBin)

        sg = nx.ego_graph(G, origin, radius=radius)

        subgraphs.append({
            'neuronID': origin,
            'globalBin': gbin,
            'subgraph': sg
        })

    return subgraphs


# ---------------------------------------------------------------------
# Main Pipeline
# ---------------------------------------------------------------------
def extract_and_save_subgraphs(connectivity_file: str,
                               neurons_file: str,
                               burst_file: str,
                               output_pt: str,
                               start_tick: int = 4_500_000, # Last quarter of simulation
                               end_tick: int = 6_000_000,
                               radius: int = 2):
    """
    Full pipeline to extract burst-centered subgraphs and save to file.

    Parameters
    ----------
    connectivity_file : str
        Path to connectivity CSV.
    neurons_file : str
        Path to neuron metadata CSV. (loaded for validation or future use)
    burst_file : str
        Path to burst origin CSV.
    output_pt : str
        Output .pt file where results will be saved.
    start_tick : int
        Minimum allowed globalBin.
    end_tick : int
        Maximum allowed globalBin.
    radius : int
        Ego graph hop radius.
    """
    burst_df = load_and_filter_bursts(burst_file, start_tick, end_tick)
    print(f"Loaded and filtered bursts: {len(burst_df)} entries")
    # Validation / mapping checks can be added here if required

    G = build_graph(connectivity_file)
    print(f"Graph built with {G.number_of_nodes()} nodes and {G.number_of_edges()} edges")
    subgraph_entries = extract_ego_subgraphs(G, burst_df, radius)
    print(f"Extracted {len(subgraph_entries)} subgraphs")
    os.makedirs(os.path.dirname(output_pt), exist_ok=True)
    torch.save(subgraph_entries, output_pt)
    print(f"Saved subgraphs to {output_pt}")

if __name__ == "__main__":
    # Default paths – update these before running
    connectivity_file = "/DATA/hdhanu/GNN/Burst_Data/Output/Weights.csv"
    neurons_file = "/DATA/hdhanu/GNN/node_attributes.csv"
    burst_file = "/DATA/hdhanu/GNN/Burst_Data/Output/Burst_origin/allBurstOrigin.csv"
    output_pt = "/DATA/hdhanu/GNN/Subgraphs/last_quarter_subgraphs.pt"

    extract_and_save_subgraphs(
        connectivity_file=connectivity_file,
        neurons_file=neurons_file,
        burst_file=burst_file,
        output_pt=output_pt
    )
