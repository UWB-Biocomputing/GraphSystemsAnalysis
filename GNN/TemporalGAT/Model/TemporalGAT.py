"""
TEMPORALGAT Train a Temporal Graph Attention Network on binned burst spike data

    This script constructs a windowed burst dataset from binned spike count data
    produced by Graphitti simulations, trains a Temporal Graph Attention Network (Temporal GAT)
    to predict neuron-level importance scores for future bursts, and saves the trained
    model to disk.

    The pipeline performs the following steps:
      1. Load binned spike data (allFrames.npz), where each frame contains spike counts
         for all neurons across time bins.
      2. Segment each burst frame into fixed-width temporal windows.
      3. Compute per-neuron vertex features for each window:
           - mean firing rate within the window
           - binary participation indicator (whether the neuron fired at least once)
           - optional spatial (x, y) neuron coordinates
      4. Load a structural connectivity graph from a GraphML file and construct
         edge indices and edge attributes.
      5. Generate training targets by computing each neuron's normalized total
         outgoing synaptic strength in the future burst.
      6. Train a Temporal Graph Attention Network consisting of:
           - a window-level Graph Attention Network (GAT)
           - a temporal GRU to integrate information across windows
           - a linear output layer producing neuron-level importance scores
      7. Evaluate the model after each epoch using Spearman and Pearson correlation
         and Top-K precision/recall metrics.
      8. Save the trained model weights and configuration as a PyTorch checkpoint.

    Model output:
      - A vector of predicted neuron importance values for each burst, where higher
        values indicate greater structural influence on future bursting behavior.

Syntax:
    getBinnedBurstSpikes.py <h5dir> <graphml_path> <num_epochs>

Input:
    h5dir         - Path to the Graphitti dataset directory containing:
                      * allFrames.npz (binned spike count data)
                    Example:
                      '/CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000'

    graphml_path  - Path to the GraphML file describing the network connectivity
                    (edge weights represent synaptic strength).

    num_epochs    - Number of training epochs for the Temporal GAT model.

Output:
    - <burst_temporal_gat.pt> - PyTorch checkpoint containing:
                                 * trained model state_dict
                                 * model architecture configuration
                               Saved to the input dataset directory (h5dir).

Author: Marina Rosenwald

Last updated: 12/16/2025 
"""

import numpy as np
import networkx as nx
import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from scipy.stats import spearmanr, pearsonr
import torch.optim as optim
import sys
import time
import os
from burstTemporalGAT import BurstTemporalGAT
from burstWindowDataset import BurstWindowDataset


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


def evaluate(model, loader, k=50):
    model.eval()
    all_spearman, all_pearson, all_precisions, all_recalls = [], [], [], []
    with torch.no_grad():
        for i, (x_seq_batch, edge_index_batch, edge_attr_batch, target_batch) in enumerate(loader):
            for j, (x_seq, ei_seq, ea_seq, target) in enumerate(
                zip(x_seq_batch, edge_index_batch, edge_attr_batch, target_batch)
            ):
                preds = model(x_seq, [ei_seq]*x_seq.shape[0], [ea_seq]*x_seq.shape[0])  
                preds = preds.squeeze().cpu().numpy()
                target = target.cpu().numpy()

                rho, _ = spearmanr(preds, target)
                r, _ = pearsonr(preds, target)
                all_spearman.append(rho)
                all_pearson.append(r)

                true_topk = set(target.argsort()[-k:])
                pred_topk = set(preds.argsort()[-k:])
                precision = len(true_topk & pred_topk) / len(pred_topk)
                recall = len(true_topk & pred_topk) / len(true_topk)
                all_precisions.append(precision)
                all_recalls.append(recall)

    print(f"Spearman: {sum(all_spearman)/len(all_spearman):.3f}")
    print(f"Pearson:  {sum(all_pearson)/len(all_pearson):.3f}")
    print(f"Top-{k} Precision: {sum(all_precisions)/len(all_precisions):.3f}")
    print(f"Top-{k} Recall:    {sum(all_recalls)/len(all_recalls):.3f}")

    return {
        "spearman": all_spearman,
        "pearson": all_pearson,
        "precision": all_precisions,
        "recall": all_recalls,
    }

def train(loader, dataset, num_epochs):
    model = BurstTemporalGAT(vertex_in=4, edge_in=1, hid=64, heads=4, gru_hid=128)
    criterion = nn.SmoothL1Loss()
    optimizer = optim.Adam(model.parameters(), lr=1e-3)

    for epoch in range(num_epochs):
        model.train()
        total_loss = 0
        for x_seq_batch, edge_index_batch, edge_attr_batch, target_batch in loader:
            optimizer.zero_grad()
            preds = []
            targets = []
            for x_seq, ei_seq, ea_seq, target in zip(x_seq_batch, edge_index_batch, edge_attr_batch, target_batch):
                pred = model(x_seq, [ei_seq]*x_seq.shape[0], [ea_seq]*x_seq.shape[0])
                pred_scaled = pred.squeeze() / dataset.target_scale
                target_scaled2 = target / dataset.target_scale

                preds.append(pred_scaled)
                targets.append(target_scaled2)

            preds = torch.stack(preds) 
            targets = torch.stack(targets) 
            loss = criterion(preds, targets)
            loss.backward()
            optimizer.step()
            total_loss += loss.item()
        print(f"Epoch {epoch}: loss={total_loss/len(loader):.4f}")
        evaluate(model, loader, k=50)
    return model

def save_model(model, path):
    checkpoint = {
        "model_state_dict": model.state_dict(),
        "model_config": {
            "vertex_in": 4,
            "edge_in": 1,
            "hid": 64,
            "heads": 4,
            "gru_hid": 128,
        }
    }
    torch.save(checkpoint, path)


def main(h5dir, graphml_path, num_epochs):
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
    out_model = train(loader, dataset, num_epochs)
    save_model(out_model, os.path.join(h5dir, "burst_temporal_gat.pt"))


if __name__ == "__main__": 
    # example execution: python ./TemporalGAT.py /CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000 /CSSDIV/research/biocomputing/data/2025/tR_1.0--fE_0.90_10000_growth_weights.graphml
    #                           number of epochs to train model over 
    h5dir = sys.argv[1]
    graphml_path = sys.argv[2]
    num_epochs = sys.argv[3]
    
    start = time.time()
    main(h5dir, graphml_path, int(num_epochs))
    end = time.time()

    elapsed_time = end - start
    
    print('Elapsed time: ' + str(elapsed_time) + ' seconds')