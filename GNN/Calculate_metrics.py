#!/usr/bin/env python3
"""
Compute DSI and related graph-level saliency metrics.

Author: Haripriya Dhanasekaran
Year: 2025
"""

from pathlib import Path
from typing import List, Dict

import numpy as np
import pandas as pd
import torch
import networkx as nx
from scipy.stats import entropy, pearsonr
from torch_geometric.data import Data


def compute_dsi_metrics(
    graphs_pt: Path,
    explain_root: Path,
    global_id_npz: Path,
    origin_csv: Path,
    graph_indices: List[int],
    category: str = "pre_burst",
    top_pct: float = 0.20,
) -> pd.DataFrame:
    """
    Compute Distance Saliency Index(DSI), hop-wise saliency, saliency entropy, and BC summary per graph.

    This implements the metrics from the thesis notebook:

    For each graph:
    ----------------
    1) Build Graph G from edge_index.
    2) Load node_mask saliency and restrict to origin-connected nodes.
    3) Compute hop distance from origin to each node.
    4) Keep top-P% nodes by saliency.
    5) Metrics on these top-k nodes:
       - DSI = Σ (sal * hop) / Σ sal
       - std_s, std_d
       - mean saliency in hop rings: h0, h1, h2, h3+ (≥3)
       - entropy of saliency mass across hops
       - mean_hop, mean_sal
       - correlation between betweenness centrality and saliency

    Parameters
    ----------
    graphs_pt : Path
        .pt file with list[Data].
    explain_root : Path
        Root dir of explanation outputs.
    global_id_npz : Path
        Global neuron IDs (not strictly required for DSI, but kept for symmetry).
    origin_csv : Path
        CSV with origin neuron per graph.
    graph_indices : list[int]
        Graph indices to process.
    category : str
        Explanation subdir ('pre_burst' / 'non_burst').
    top_pct : float
        Fraction of nodes to treat as salient.

    Returns
    -------
    pd.DataFrame
        One row per graph with columns:
        ['idx','DSI','std_s','std_d','h0','h1','h2','h3p',
         'entropy','mean_hop','mean_sal','bc_corr','bc_mean','bc_std','n_top']
    """
    graphs_pt = Path(graphs_pt)
    explain_root = Path(explain_root)
    global_id_npz = Path(global_id_npz)  # not strictly used here
    origin_csv = Path(origin_csv)

    graph_list: List[Data] = torch.load(graphs_pt, weights_only=False)
    origin_df = pd.read_csv(origin_csv)

    records: List[Dict] = []

    for idx in graph_indices:
        data: Data = graph_list[idx]

        # origin: same assumption as before – adjust column names if needed
        row = origin_df.loc[origin_df.get("graph_idx", origin_df.index) == idx]
        if row.empty and "burst_id" in origin_df.columns:
            row = origin_df.loc[origin_df["burst_id"] == idx]

        if row.empty:
            print(f"[DSI] Warning: no origin for graph {idx}, skipping")
            continue

        origin_id = int(row.iloc[0]["originID"])

        # if you have a global_id map, you can use it to go originID -> local idx
        gid_arr = np.load(global_id_npz, allow_pickle=True)
        if "global_ids" in gid_arr:
            gid = gid_arr["global_ids"][idx]
        elif str(idx) in gid_arr:
            gid = gid_arr[str(idx)]
        elif f"g{idx}" in gid_arr:
            gid = gid_arr[f"g{idx}"]
        else:
            raise KeyError(f"Missing global IDs for graph {idx}")

        if origin_id not in gid:
            print(f"[DSI] originID {origin_id} not in gid for graph {idx}, skipping")
            continue
        origin_local = int(np.where(gid == origin_id)[0][0])

        # GNN graph
        edge_index = data.edge_index.cpu().numpy()
        G = nx.Graph()
        G.add_edges_from(zip(edge_index[0], edge_index[1]))

        # node-level saliency
        graph_dir = explain_root / category / f"graph{idx}"
        node_mask_path = graph_dir / "node_mask.pt"
        if not node_mask_path.exists():
            raise FileNotFoundError(f"Missing node_mask: {node_mask_path}")
        sal_all = (
            torch.load(node_mask_path).detach().cpu().numpy().reshape(-1)
        )

        # hop distances from origin
        dists = nx.single_source_shortest_path_length(G, origin_local)
        hops_all = np.array(
            [dists.get(i, np.inf) for i in range(len(sal_all))]
        )

        # restrict to finite distances
        valid = np.isfinite(hops_all)
        sal = sal_all[valid]
        hops = hops_all[valid]

        if len(sal) == 0:
            print(f"[DSI] no finite hops for graph {idx}, skipping")
            continue

        # top-P% nodes
        k = max(1, int(top_pct * len(sal)))
        top_idx = np.argpartition(sal, -k)[-k:]
        s_top = sal[top_idx]
        h_top = hops[top_idx]

        # DSI and simple stats
        mass = s_top.sum()
        if mass <= 0:
            dsi = 0.0
        else:
            dsi = float((s_top * h_top).sum() / mass)
        std_s = float(s_top.std())
        std_d = float(h_top.std())

        # hop-ring mean saliencies (0,1,2,≥3)
        means = [
            float(s_top[h_top == k].mean()) if np.any(h_top == k) else 0.0
            for k in (0, 1, 2)
        ]
        means.append(
            float(s_top[h_top >= 3].mean()) if np.any(h_top >= 3) else 0.0
        )

        # entropy of saliency mass across hops
        max_k = int(h_top.max())
        p = np.array(
            [
                float(s_top[h_top == k].sum())
                for k in range(max_k + 1)
            ]
        )
        if p.sum() > 0:
            p = p / p.sum()
        H = float(entropy(p)) if p.sum() > 0 else 0.0

        # betweenness centrality (whole graph)
        bc = nx.betweenness_centrality(G, normalized=True)
        bc_vec = np.array([bc.get(i, 0.0) for i in range(len(sal_all))])[valid]
        bc_top = bc_vec[top_idx]

        # correlation between BC and saliency (top nodes)
        if len(bc_top) > 1 and s_top.std() > 0 and bc_top.std() > 0:
            bc_corr = float(pearsonr(s_top, bc_top)[0])
        else:
            bc_corr = np.nan

        records.append(
            {
                "idx": idx,
                "DSI": dsi,
                "std_s": std_s,
                "std_d": std_d,
                "h0": means[0],
                "h1": means[1],
                "h2": means[2],
                "h3p": means[3],
                "entropy": H,
                "mean_hop": float(h_top.mean()),
                "mean_sal": float(s_top.mean()),
                "bc_corr": bc_corr,
                "bc_mean": float(bc_top.mean()),
                "bc_std": float(bc_top.std()),
                "n_top": int(k),
            }
        )

    df = pd.DataFrame(records)
    return df
