"""
TEMPORALGATINFERENCE Load a Trained Temporal GAT and Visualize Neuron Importance

    This script loads a previously trained BurstTemporalGAT model and applies it
    to windowed burst data to compute and visualize neuron-level importance scores.

    The pipeline performs the following steps:
      1. Load a trained Temporal Graph Attention Network (Temporal GAT) checkpoint.
      2. Reconstruct the burst window dataset from binned spike count data.
      3. Load the network connectivity graph from a GraphML file.
      4. Run inference on each burst to generate predicted neuron importance values.
      5. Optionally visualize predicted importance values at regular burst intervals.
      6. Compute and visualize the mean neuron importance across all bursts.

    Neuron importance values are visualized spatially using neuron (x, y)
    coordinates, allowing structural and spatial patterns in burst influence
    to be examined.

Syntax:
    TemporalGATInference.py <h5dir> <graphml_path>

Input:
    h5dir         - Path to the Graphitti dataset directory containing:
                      * allFrames.npz
                      * burst_temporal_gat.pt (trained model checkpoint)
                    Example:
                      '/CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000'

    graphml_path  - Path to the GraphML file describing synaptic connectivity.

Output:
    - Spatial scatter plots showing:
         * neuron importance for selected bursts (optional)
         * mean neuron importance averaged across all bursts

Author: Marina Rosenwald

Last updated:12/16/2025
"""


import torch
from burstTemporalGAT import BurstTemporalGAT 
from burstWindowDataset import BurstWindowDataset
from torch.utils.data import DataLoader
import sys
import time
import os
import matplotlib.pyplot as plt
import numpy as np
import networkx as nx

def load_model(path, device="cpu"):
    checkpoint = torch.load(path, map_location=device)

    config = checkpoint["model_config"]
    model = BurstTemporalGAT(
        vertex_in=config["vertex_in"],
        edge_in=config["edge_in"],
        hid=config["hid"],
        heads=config["heads"],
        gru_hid=config["gru_hid"],
    )

    model.load_state_dict(checkpoint["model_state_dict"])
    model.to(device)
    model.eval()

    return model

def load_graphml_edge_index(graphml_file):
    G = nx.read_graphml(graphml_file)
    if len(G.edges) == 0:
        print("Warning: Graph has no edges!")
        return torch.empty((2,0), dtype=torch.long), torch.empty((0,1), dtype=torch.float)

    mapping = {n:i for i,n in enumerate(G.nodes())}
    G = nx.relabel_nodes(G, mapping)

    edges = list(G.edges)
    edge_index = torch.tensor(edges, dtype=torch.long).t().contiguous()

    edge_attr = [G[u][v].get('weight', 1.0) for u,v in edges]
    edge_attr = torch.tensor(edge_attr, dtype=torch.float).unsqueeze(1)

    return edge_index, edge_attr


def collate_fn(batch):
    x_seqs, edge_indices, edge_attrs, targets = zip(*batch)
    return list(x_seqs), list(edge_indices), list(edge_attrs), torch.stack(targets)

def get_neuron_coords():
    neuron_coords = np.array([[i % 100, i // 100] for i in range(10000)])
    return neuron_coords  

def visualizeAvg(model, loader, neuron_coords, plot_50=False):
    total_bursts = 0
    all_predictions = []   
    for batch_idx, (x_seq_batch, edge_index_batch, edge_attr_batch, target_batch) in enumerate(loader):
        for burst_idx, (x_seq, ei_seq, ea_seq, target) in enumerate(
            zip(x_seq_batch, edge_index_batch, edge_attr_batch, target_batch)
        ):
            total_bursts += 1

            preds = model(
                x_seq,
                [ei_seq] * x_seq.shape[0],
                [ea_seq] * x_seq.shape[0]
            ).squeeze().detach().cpu().numpy()

            all_predictions.append(preds)
            # Plot every 50 bursts
            if plot_50: 
                if total_bursts % 50 == 0:
                    print(
                        f"Burst {total_bursts} -- min: {preds.min():.4f}, "
                        f"max: {preds.max():.4f}, mean: {preds.mean():.4f}"
                    )

                    plt.figure(figsize=(6, 6))
                    sc = plt.scatter(neuron_coords[:, 0], neuron_coords[:, 1], c=preds, cmap='viridis', s=10)
                    plt.colorbar(sc, label='Mean Predicted Importance')
                    plt.title(f"Mean Neuron Importance At Burst {total_bursts}")
                    plt.xlabel("X Coordinate")
                    plt.ylabel("Y Coordinate")
                    plt.show()
    all_predictions = np.vstack(all_predictions)

    mean_importance = all_predictions.mean(axis=0)
    plt.figure(figsize=(6, 6))
    sc = plt.scatter(
        neuron_coords[:, 0], neuron_coords[:, 1],
        c=mean_importance, cmap='gray_r', s=10
    )
    plt.colorbar(sc, label='Mean Predicted Importance')
    plt.title("Mean Neuron Importance Across All Bursts")
    plt.xlabel("X Coordinate")
    plt.ylabel("Y Coordinate")
    plt.show()

def main(h5dir, graphml_path):
    model = load_model(os.path.join(h5dir, "burst_temporal_gat.pt"))

    data = np.load(os.path.join(h5dir, "allFrames.npz"))
    allFrames = [data[key] for key in data]

    edge_index, edge_attr = load_graphml_edge_index(graphml_path)
    adj_snapshots = [(edge_index, edge_attr)] * len(allFrames)

    dataset = BurstWindowDataset(
        allFrames=allFrames,
        adj_snapshots=adj_snapshots,
        window_bins=20,
        horizon=1,
        include_coords=True
    )
    loader = DataLoader(dataset, batch_size=4, shuffle=True, collate_fn=collate_fn)
    neuron_coords = get_neuron_coords()
    visualizeAvg(model, loader, neuron_coords)

if __name__ == "__main__":
    # example execution: python ./TemporalGAT.py /CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000 /CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000_growth_weights.graphml

    h5dir = sys.argv[1]
    graphml_path = sys.argv[2]
    
    start = time.time()
    main(h5dir, graphml_path)
    end = time.time()

    elapsed_time = end - start
    
    print('Elapsed time: ' + str(elapsed_time) + ' seconds')