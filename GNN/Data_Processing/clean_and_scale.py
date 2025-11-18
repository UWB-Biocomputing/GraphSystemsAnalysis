"""
clean_and_scale_graphs.py
==========================

Clean and scale burst feature graphs prior to GNN training.

This module:
    • Takes a list of PyG Data objects structured as:
          [pre_0, non_0, pre_1, non_1, ...]
    • Drops any burst-pair containing NaN node features
    • Fits a StandardScaler on ALL remaining node features
    • Transforms each graph.x in place
    • Saves:
          - cleaned + scaled list   → scaled_pt
          - fitted scaler           → scaler.pkl

Author: Haripriya Dhanasekaran
Year: 2025
"""

import os
import numpy as np
import torch
import joblib
from pathlib import Path
from typing import List, Tuple
from sklearn.preprocessing import StandardScaler


# ---------------------------------------------------------
# Core Function
# ---------------------------------------------------------

def clean_and_scale_data(
        data_list: List,
        scaled_pt: str,
        scaler_pkl: str = None,
        verbose: bool = True
) -> Tuple[List, StandardScaler]:
    """
    Clean and scale PyG Data graphs.

    Parameters
    ----------
    data_list : list
        List of PyG Data objects: [pre_0, non_0, pre_1, non_1, ...]
    scaled_pt : str
        Destination path for the scaled .pt file.
    scaler_pkl : str, optional
        Path to dump the fitted StandardScaler via joblib.
    verbose : bool
        Whether to print summary messages.

    Returns
    -------
    clean_scaled_list : list
        Cleaned + scaled PyG Data objects.
    scaler : StandardScaler
        The fitted scaler instance.
    """

    # Drop NaN burst-pairs
    clean_list = []
    dropped_bursts = 0

    for i in range(0, len(data_list), 2):
        pre, non = data_list[i], data_list[i + 1]

        if torch.isnan(pre.x).any() or torch.isnan(non.x).any():
            dropped_bursts += 1
            continue

        clean_list.extend([pre, non])

    if verbose:
        print(f"Dropped {dropped_bursts} bursts → {dropped_bursts * 2} graphs")

    # Stack all node features for scaling
    if verbose:
        print("Fitting StandardScaler on all remaining node features...")

    F = np.vstack([g.x.numpy() for g in clean_list])
    scaler = StandardScaler().fit(F)

    # Transform graph.x in place
    for g in clean_list:
        X = g.x.numpy()
        g.x = torch.tensor(scaler.transform(X), dtype=torch.float)

    # Save scaled graph list
    scaled_pt = Path(scaled_pt)
    scaled_pt.parent.mkdir(parents=True, exist_ok=True)
    torch.save(clean_list, scaled_pt)

    if verbose:
        print(f"Saved scaled graphs → {scaled_pt}")

    # Save scaler.pkl (optional but recommended)
    if scaler_pkl:
        joblib.dump(scaler, scaler_pkl)
        if verbose:
            print(f"Saved fitted scaler → {scaler_pkl}")
    return clean_list, scaler

if __name__ == "__main__":
    INPUT = "data/NETID/burst_features.pt"
    OUTPUT = "data/NETID/burst_features_scaled.pt"
    SCALER = "data/NETID/burst_features_scaler.pkl"

    print(f"Loading {INPUT}")
    data_list = torch.load(INPUT, weights_only=False)

    clean_and_scale_data(
        data_list=data_list,
        scaled_pt=OUTPUT,
        scaler_pkl=SCALER,
        verbose=True
    )
