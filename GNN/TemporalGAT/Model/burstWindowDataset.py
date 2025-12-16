"""
BURSTWINDOWDATASET Windowed Burst Dataset for Temporal Graph Neural Networks

    This module defines the BurstWindowDataset class, which constructs a
    windowed, graph-structured dataset from binned spike count data generated
    by Graphitti simulations.

    Each sample in the dataset corresponds to a single burst and consists of:
      - a sequence of temporal windows of neuron-level features
      - a static graph connectivity structure (edge indices and attributes)
      - a target vector representing neuron importance in a future burst

    Dataset construction pipeline:
      1. Pad all burst frames to a fixed number of neurons (N = 10,000).
      2. Segment each burst into fixed-width temporal windows.
      3. Compute per-neuron vertex features for each window:
           - mean firing rate within the window
           - binary participation indicator (neuron fired at least once)
           - optional spatial (x, y) neuron coordinates
      4. Attach graph connectivity snapshots (edge indices and edge attributes).
      5. Generate training targets by computing each neuron’s normalized total
         outgoing synaptic strength in a future burst (prediction horizon).
      6. Scale targets for numerical stability during training.

    The dataset is compatible with PyTorch DataLoader objects and is intended
    for use with temporal GNN architectures such as BurstTemporalGAT.

Syntax:
    dataset = BurstWindowDataset(
                  allFrames=<list[np.ndarray]>,
                  adj_snapshots=<list[(edge_index, edge_attr)]>,
                  window_bins=<int>,
                  horizon=<int>,
                  include_coords=<bool>,
                  target_scale=<float>
              )

Input:
    allFrames       - List of arrays [N, T], containing binned spike counts
                      for each neuron across time bins for each burst.
    adj_snapshots   - List of graph snapshots, where each snapshot contains:
                        * edge_index [2, E]
                        * edge_attr  [E, edge_in]
    window_bins     - Number of time bins per temporal window.
    horizon         - Number of bursts ahead used to construct the target.
    include_coords  - Whether to append spatial (x, y) neuron coordinates
                      to the vertex feature vectors.
    target_scale    - Scalar factor applied to target values for normalization.

Output (per sample):
    x_seq           - Tensor [T_w, N, F] of windowed vertex features
    edge_index      - Tensor [2, E] of graph connectivity
    edge_attr       - Tensor [E, edge_in] of edge attributes
    target          - Tensor [N] of neuron importance values

Author: Marina Rosenwald

Last updated: 12/16/2025
"""

import torch
from torch.utils.data import Dataset
import numpy as np

class BurstWindowDataset(Dataset):
    @staticmethod
    def pad_frame(frame, n_total=10000):
        n_neurons, width = frame.shape
        if n_neurons == n_total:
            return frame
        padded = np.zeros((n_total, width), dtype=frame.dtype)
        padded[:n_neurons, :] = frame
        return padded

    def __init__(self, allFrames, adj_snapshots, window_bins=20, horizon=1, include_coords=True, target_scale=1e6):
        self.nNeurons = 10000
        self.window_bins = window_bins
        self.horizon = horizon
        self.nBursts = len(allFrames)
        self.include_coords = include_coords
        self.target_scale = target_scale

        self.allFrames = [self.pad_frame(f, n_total=self.nNeurons) for f in allFrames]

        self.windowed_frames = []
        for frame in self.allFrames:
            width = frame.shape[1]
            windows = []
            for start in range(0, width, self.window_bins):
                end = min(start + self.window_bins, width)
                win = frame[:, start:end] 

                firing_counts = win.astype(np.float32)
                print(firing_counts.mean(axis=1))
                participation = (win.sum(axis=1) > 0).astype(np.float32)

                vertex_feat = np.stack(
                    [firing_counts.mean(axis=1), participation],
                    axis=1
                )  

                if self.include_coords:
                    coords = np.array(
                        [[i % 100, i // 100] for i in range(self.nNeurons)],
                        dtype=np.float32
                    )
                    vertex_feat = np.concatenate([vertex_feat, coords], axis=1)

                windows.append(vertex_feat)

            self.windowed_frames.append(np.stack(windows))

        self.edge_lists = [
            (edge_index, edge_attr if edge_attr.ndim == 2 else edge_attr.unsqueeze(1))
            for edge_index, edge_attr in adj_snapshots
        ]

        self.targets = []
        for future_edge_index, future_edge_attr in self.edge_lists[horizon:]:
            src = future_edge_index[0]
            w = future_edge_attr
            if w.ndim > 1:
                w = w.squeeze() 

            out_strength = np.zeros(self.nNeurons, dtype=np.float32)
            np.add.at(out_strength, src, w.numpy())

            out_strength /= (out_strength.max() + 1e-12)
            out_strength *= self.target_scale

            self.targets.append(out_strength)

        targets_array = np.stack(self.targets)  
        print("\n========== GLOBAL TARGET STATISTICS ==========")
        print("Total samples:", len(self.targets))
        print("min =", targets_array.min())
        print("max =", targets_array.max())
        print("mean =", targets_array.mean())
        print("median =", np.median(targets_array))
        nonzero = np.count_nonzero(targets_array)
        print("nonzero count =", nonzero)
        print("percent nonzero =", nonzero / targets_array.size * 100, "%")
        print("==============================================\n")

    def __len__(self):
        return self.nBursts - self.horizon

    def __getitem__(self, idx):
        x_seq = torch.tensor(self.windowed_frames[idx], dtype=torch.float)
        edge_index = torch.tensor(self.edge_lists[idx][0], dtype=torch.long)
        edge_attr = torch.tensor(self.edge_lists[idx][1], dtype=torch.float)
        target = torch.tensor(self.targets[idx], dtype=torch.float)
        return x_seq, edge_index, edge_attr, target
