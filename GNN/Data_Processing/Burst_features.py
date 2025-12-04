"""
burst_features.py
==================

Extracts node-level spike features for each burst-centered subgraph.

This module:
    • Loads subgraphs produced by extract_subgraphs.py
    • Uses the HDF5 spike file from the simulation to fetch spike trains for each neuron
    • Computes windowed spike-timing features:
         - mean_isi
         - entropy_isi
         - last_lag
         - rate
    • For each subgraph, produces TWO graph samples:
         (1) Pre-burst window → label=1
         (0) Non-burst window → label=0
    • Converts each into a PyTorch Geometric Data object
    • Saves all graphs 

Author: Haripriya Dhanasekaran
Year: 2025
"""

import os
from pathlib import Path
from typing import List, Dict

import numpy as np
import pandas as pd
import torch
import h5py
from scipy.stats import entropy

import networkx as nx
from torch_geometric.utils import from_networkx
from torch_geometric.data import Data

# ----------------------------------------------------
# Configuration
# ----------------------------------------------------

H5_PATH = "/DATA/hdhanu/GNN/tR_1.0--fE_0.98_10000.h5"
OUTPUT_DIR = Path("data/NETID/")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

FEAT_NAMES = ["mean_isi", "entropy_isi", "last_lag", "rate"]


# ----------------------------------------------------
# Utility Functions
# ----------------------------------------------------

def bin_to_tick(burst_bin, bin_width_ms=10, tick_ms=0.1):
    """Convert burst bin (10 ms units) → actual tick index."""
    return int(burst_bin * (bin_width_ms / tick_ms))


def get_spikes_for_neuron(neuron_id: int, h5_obj: h5py.File) -> np.ndarray:
    """Load and cache spike train for a single neuron."""
    ds_name = f"Neuron_{neuron_id}"
    if ds_name not in h5_obj:
        return np.array([], dtype=float)
    return np.sort(h5_obj[ds_name][()]).astype(float)


def compute_spike_features(spikes: np.ndarray, window_ms: int) -> Dict[str, float]:
    """
    Compute the four main spike-based features.
    spikes: array of spike times within window (ms)
    """
    if len(spikes) == 0:
        return dict(mean_isi=window_ms, entropy_isi=0.0,
                    last_lag=window_ms, rate=0.0)

    isis = np.diff(spikes)
    mean_isi = np.mean(isis) if len(isis) > 0 else window_ms
    entropy_isi = entropy(isis) if len(isis) > 1 else 0.0
    last_lag = window_ms - spikes[-1]
    rate = len(spikes) / (window_ms * 1e-3)  # Hz

    return dict(
        mean_isi=mean_isi,
        entropy_isi=entropy_isi,
        last_lag=last_lag,
        rate=rate
    )


def slice_window(spikes, burst_tick, offset, window):
    """
    Extract a spike window:
        spikes: full spike train for neuron
        burst_tick: time of burst in ticks
        offset: how far before burst to start (tick units)
        window: window length (in number of 10ms bins)
    """
    start = burst_tick - offset - window
    end   = burst_tick - offset

    # Keep only window spikes
    window_spikes = spikes[(spikes >= start) & (spikes < end)]
    return window_spikes - start  # normalize to [0, window_ms]


# ----------------------------------------------------
# Core Feature Extraction
# ----------------------------------------------------

def extract_features_for_entry(entry: Dict, h5_obj: h5py.File,
                               window: int, mask_shift: int) -> List[Data]:
    """
    Build two graphs (pre-burst = 1, neutral = 0) for a single subgraph entry.
    """
    G = entry["subgraph"]
    burst_bin = entry["globalBin"]
    burst_tick = bin_to_tick(burst_bin)

    nodes = list(G.nodes())
    edge_index = from_networkx(G).edge_index

    window_ms = window * 10  # because each bin = 10 ms

    pre_feats = np.zeros((len(nodes), len(FEAT_NAMES)), dtype=np.float32)
    non_feats = np.zeros_like(pre_feats)

    for idx, n in enumerate(nodes):
        spikes = get_spikes_for_neuron(n, h5_obj)

        # Pre-burst window (label=1)
        pre_spikes = slice_window(
            spikes, burst_tick,
            offset=mask_shift,
            window=window
        )

        # Non-burst window: 2000 ticks before (determined from previous study)
        non_spikes = slice_window(
            spikes, burst_tick,
            offset=2000 + mask_shift,
            window=window
        )

        pre_feats[idx] = list(compute_spike_features(pre_spikes, window_ms).values())
        non_feats[idx] = list(compute_spike_features(non_spikes, window_ms).values())

    # Build Data objects
    bid = entry.get("burst_id", f"burst_{burst_bin}")

    g_pre = Data(
        x=torch.tensor(pre_feats),
        edge_index=edge_index,
        y=torch.tensor([1], dtype=torch.long),
        burst_id=bid,
        raw_features=pre_feats
    )

    g_non = Data(
        x=torch.tensor(non_feats),
        edge_index=edge_index,
        y=torch.tensor([0], dtype=torch.long),
        burst_id=bid,
        raw_features=non_feats
    )

    return [g_pre, g_non]


# ----------------------------------------------------
# Main pipeline
# ----------------------------------------------------

def process_all_subgraphs(subgraph_pt: str,
                          window: int = 10,
                          mask_shift: int = 0):
    """
    Loads all subgraphs and extracts pre-burst vs neutral-window features.
    """
    print(f"Loading subgraphs from {subgraph_pt}")
    entries = torch.load(subgraph_pt, weights_only=False)

    print(f"Opening HDF5 spike file {H5_PATH}")
    h5 = h5py.File(H5_PATH, "r")

    out = []

    for idx, entry in enumerate(entries):
        if idx % 100 == 0:
            print(f"  → Processed {idx}/{len(entries)} entries")

        graphs = extract_features_for_entry(
            entry, h5,
            window=window,
            mask_shift=mask_shift
        )
        out.extend(graphs)

    h5.close()

    # Save
    out_path = OUTPUT_DIR / f"burst_features_w{window}_m{mask_shift}.pt"
    torch.save(out, out_path)

    print(f"Saved {len(out)} graph samples to {out_path}")
    return out_path

if __name__ == "__main__":
    process_all_subgraphs(
        subgraph_pt="data/NETID/last_quarter_subgraphs.pt",
        window=10,
        mask_shift=0
    )

