#!/usr/bin/env python3
"""
Classify saliency patterns (A/B/C) for each explained graph.

Author: Haripriya Dhanasekaran
Year: 2025
"""

from pathlib import Path
from typing import Dict, List, Tuple

import numpy as np
import pandas as pd
import torch
import networkx as nx
from torch_geometric.data import Data


PATTERN_LABELS = {
    "patternA_local": "A",
    "patternB_remote": "B",
    "unclassified": "C",
}


def _load_global_ids(global_id_npz: Path, graph_idx: int) -> np.ndarray:
    arr = np.load(global_id_npz, allow_pickle=True)
    if "global_ids" in arr:
        return arr["global_ids"][graph_idx]
    if str(graph_idx) in arr:
        return arr[str(graph_idx)]
    if f"g{graph_idx}" in arr:
        return arr[f"g{graph_idx}"]
    raise KeyError(f"Missing global IDs for graph {graph_idx}")


def _get_origin_local_idx(
    origin_df: pd.DataFrame,
    gid: np.ndarray,
    graph_idx: int,
    graph_col: str = "graph_idx",
    id_col: str = "originID",
) -> int:
    row = origin_df.loc[origin_df[graph_col] == graph_idx]
    if row.empty:
        return -1
    origin_id = int(row.iloc[0][id_col])
    if origin_id not in gid:
        return -1
    return int(np.where(gid == origin_id)[0][0])


def classify_saliency_patterns(
    graphs_pt: Path,
    explain_root: Path,
    global_id_npz: Path,
    origin_csv: Path,
    graph_indices: List[int],
    category: str = "pre_burst",
    top_pct: float = 0.20,
    near_hops: Tuple[int, int] = (0, 1),
    far_min_hop: int = 3,
    near_thresh: float = 0.90,
    far_thresh: float = 0.90,
) -> pd.DataFrame:
    """
    Classify each graph into pattern A (local), B (remote), or C (other).

    The rule is intentionally simple and transparent:

    - Compute hop distance from origin to all nodes in the graph.
    - Restrict to top-P% most salient nodes (by node_mask).
    - Let p_near = saliency mass in hops ∈ near_hops.
      Let p_far  = saliency mass in hops ≥ far_min_hop.
    - If p_near ≥ near_thresh and p_far <= (1 - near_thresh) → 'patternA_local' (A).
    - If p_far  ≥ far_thresh  and p_near <= (1 - far_thresh)  → 'patternB_remote' (B).
    - Else → 'unclassified' (C).

    Parameters
    ----------
    graphs_pt : Path
        .pt file with list[Data].
    explain_root : Path
        Root of explanation masks (same as before).
    global_id_npz : Path
        Global neuron IDs per graph.
    origin_csv : Path
        CSV with origin neuron IDs per graph.
    graph_indices : list[int]
        Graph indices to classify.
    category : str
        Explanation subdir ('pre_burst' or 'non_burst').
    top_pct : float
        Fraction of nodes used for saliency stats.
    near_hops : (int, int)
        Inclusive hop range treated as 'near' origin.
    far_min_hop : int
        Minimum hop distance considered 'far'.
    near_thresh, far_thresh : float
        Thresholds for p_near, p_far.

    Returns
    -------
    pd.DataFrame
        One row per graph with classification & summary statistics.
        Columns include:
        ['idx','pattern','label','p_near','p_far','mean_hop','top_k','origin_local']
    """
    graphs_pt = Path(graphs_pt)
    explain_root = Path(explain_root)
    global_id_npz = Path(global_id_npz)
    origin_csv = Path(origin_csv)

    graph_list: List[Data] = torch.load(graphs_pt, weights_only=False)
    origin_df = pd.read_csv(origin_csv)

    records = []

    for idx in graph_indices:
        data: Data = graph_list[idx]
        gid = _load_global_ids(global_id_npz, idx)

        # origin in local index space
        origin_local = _get_origin_local_idx(origin_df, gid, idx)
        if origin_local < 0:
            pattern = "unclassified"
            records.append(
                {
                    "idx": idx,
                    "pattern": pattern,
                    "label": PATTERN_LABELS[pattern],
                    "p_near": np.nan,
                    "p_far": np.nan,
                    "mean_hop": np.nan,
                    "top_k": np.nan,
                    "origin_local": origin_local,
                }
            )
            continue

        # load node_mask
        graph_dir = explain_root / category / f"graph{idx}"
        node_mask_path = graph_dir / "node_mask.pt"
        if not node_mask_path.exists():
            raise FileNotFoundError(f"Missing node_mask: {node_mask_path}")
        node_mask = (
            torch.load(node_mask_path).detach().cpu().numpy().reshape(-1)
        )

        # build graph & hop distances
        edge_index = data.edge_index.cpu().numpy()
        G = nx.Graph()
        G.add_edges_from(zip(edge_index[0], edge_index[1]))

        dists = nx.single_source_shortest_path_length(G, origin_local)
        hops = np.array([dists.get(i, np.inf) for i in range(len(node_mask))])

        # restrict to finite distances
        valid = np.isfinite(hops)
        sal = node_mask[valid]
        hops = hops[valid]

        if len(sal) == 0:
            pattern = "unclassified"
            records.append(
                {
                    "idx": idx,
                    "pattern": pattern,
                    "label": PATTERN_LABELS[pattern],
                    "p_near": np.nan,
                    "p_far": np.nan,
                    "mean_hop": np.nan,
                    "top_k": 0,
                    "origin_local": origin_local,
                }
            )
            continue

        # top-P% nodes
        k = max(1, int(top_pct * len(sal)))
        top_idx = np.argpartition(sal, -k)[-k:]
        s_top = sal[top_idx]
        h_top = hops[top_idx]

        mass = s_top.sum()
        if mass <= 0:
            p_near = p_far = 0.0
        else:
            near_mask = np.isin(h_top, list(range(near_hops[0], near_hops[1] + 1)))
            far_mask = h_top >= far_min_hop
            p_near = float(s_top[near_mask].sum() / mass) if near_mask.any() else 0.0
            p_far = float(s_top[far_mask].sum() / mass) if far_mask.any() else 0.0

        # classification rule
        if (p_near >= near_thresh) and (p_far <= (1 - near_thresh)):
            pattern = "patternA_local"
        elif (p_far >= far_thresh) and (p_near <= (1 - far_thresh)):
            pattern = "patternB_remote"
        else:
            pattern = "unclassified"

        records.append(
            {
                "idx": idx,
                "pattern": pattern,
                "label": PATTERN_LABELS[pattern],
                "p_near": p_near,
                "p_far": p_far,
                "mean_hop": float(h_top.mean()),
                "top_k": int(k),
                "origin_local": origin_local,
            }
        )

    df = pd.DataFrame(records)
    return df
