"""
Plot salient subgraph for a single explained graph.

Author: Haripriya Dhanasekaran
Year: 2025
"""

from pathlib import Path
from typing import Optional

import numpy as np
import pandas as pd
import torch
import networkx as nx
import matplotlib.pyplot as plt
from torch_geometric.data import Data


def plot_saliency_subgraph(
    graph_idx: int,
    graphs_pt: Path,
    explain_root: Path,
    global_id_npz: Path,
    node_meta_csv: Path,
    origin_csv: Optional[Path] = None,
    top_pct: float = 0.20,
    save_path: Optional[Path] = None,
    category: str = "pre_burst",
    show: bool = False,
) -> Path:
    """
    Plot the top-P% most salient nodes and their induced edges for one graph.

    Parameters
    ----------
    graph_idx : int
        Index of the graph in `graphs_pt` and in `global_id_npz`.
    graphs_pt : Path
        Path to the cleaned/scaled graphs (.pt) – list[Data].
    explain_root : Path
        Root dir containing explanation masks, e.g.
        `.../Explainability/output_mask`.
        Inside we expect subdirs like `pre_burst/graph{idx}/node_mask.pt`.
    global_id_npz : Path
        npz file mapping local node indices → global neuron IDs.
        Must contain an array per graph index, e.g. key f"g{idx}" or a 2D array.
    node_meta_csv : Path
        CSV with at least columns: 'neuronID', 'x', 'y'.
    origin_csv : Path, optional
        CSV with origin neuron per graph. Must contain columns:
        'graph_idx' (or 'burst_id') and 'originID' (you can adjust below).
        If None, no origin star is drawn.
    top_pct : float
        Fraction of nodes to treat as "salient" (e.g., 0.20 → top 20%).
    save_path : Path, optional
        Where to save the PNG. If None, uses
        `{explain_root}/{category}/graph{idx}_saliency.png`.
    category : str
        Explanation category subdir, e.g. 'pre_burst' or 'non_burst'.
    show : bool
        If True, also display the figure in an interactive window.

    Returns
    -------
    Path
        Path to the saved PNG.
    """
    graphs_pt = Path(graphs_pt)
    explain_root = Path(explain_root)
    global_id_npz = Path(global_id_npz)
    node_meta_csv = Path(node_meta_csv)

    # --- load graph & masks ------------------------------------------------
    graph_list = torch.load(graphs_pt, weights_only=False)
    data: Data = graph_list[graph_idx]

    graph_dir = explain_root / category / f"graph{graph_idx}"
    node_mask_path = graph_dir / "node_mask.pt"
    edge_mask_path = graph_dir / "edge_mask.pt"

    if not node_mask_path.exists():
        raise FileNotFoundError(f"Missing node_mask at {node_mask_path}")
    if not edge_mask_path.exists():
        raise FileNotFoundError(f"Missing edge_mask at {edge_mask_path}")

    node_mask = torch.load(node_mask_path).detach().cpu().numpy().reshape(-1)
    edge_mask = torch.load(edge_mask_path).detach().cpu().numpy().reshape(-1)

    # convert edge_index → networkx graph
    edge_index = data.edge_index.cpu().numpy()
    G = nx.Graph()
    G.add_edges_from(zip(edge_index[0], edge_index[1]))

    # --- get neuron IDs & metadata ----------------------------------------
    gid_npz = np.load(global_id_npz, allow_pickle=True)

    # support either:
    #  - one array per graph: keys like '0', '1', ... or 'g0', 'g1', ...
    #  - or a single 2D array 'global_ids' [num_graphs, num_nodes]
    if "global_ids" in gid_npz:
        gid = gid_npz["global_ids"][graph_idx]
    elif str(graph_idx) in gid_npz:
        gid = gid_npz[str(graph_idx)]
    elif f"g{graph_idx}" in gid_npz:
        gid = gid_npz[f"g{graph_idx}"]
    else:
        raise KeyError(
            f"Could not find global IDs for graph {graph_idx} in {global_id_npz}"
        )

    gid = np.asarray(gid)

    meta = (
        pd.read_csv(node_meta_csv)
        .rename(columns=str.strip)
        .set_index("neuronID")
    )
    meta_sub = meta.loc[gid].copy()
    meta_sub["saliency"] = node_mask

    # --- origin neuron (optional) -----------------------------------------
    origin_local_idx = None
    if origin_csv is not None:
        origin_df = pd.read_csv(origin_csv)
        # You can adjust these column names if needed:
        if "graph_idx" in origin_df.columns:
            row = origin_df.loc[origin_df["graph_idx"] == graph_idx]
        else:
            # fall back: assume 'burst_id' is the graph index
            row = origin_df.loc[origin_df["burst_id"] == graph_idx]

        if not row.empty:
            origin_id = int(row.iloc[0]["originID"])
            if origin_id in gid:
                origin_local_idx = int(np.where(gid == origin_id)[0][0])

    # --- pick top-P% nodes and induced edges -------------------------------
    sal = node_mask
    k = max(1, int(top_pct * len(sal)))
    top_nodes_idx = np.argpartition(sal, -k)[-k:]
    top_nodes_idx = np.sort(top_nodes_idx)

    node_cut = sal[top_nodes_idx].min()
    edge_cut = np.percentile(edge_mask, 100 * (1 - top_pct))

    # high-sal edges
    hi_edges_idx = np.where(edge_mask >= edge_cut)[0]
    hi_edges = [
        (int(edge_index[0, i]), int(edge_index[1, i])) for i in hi_edges_idx
    ]

    # induced edges among top nodes
    top_nodes_set = set(top_nodes_idx.tolist())
    induced_edges = [
        (u, v)
        for (u, v) in G.edges()
        if (u in top_nodes_set) and (v in top_nodes_set)
    ]

    # origin→top edges (optional)
    origin_edges = []
    if origin_local_idx is not None:
        for n in top_nodes_idx:
            if G.has_edge(origin_local_idx, int(n)):
                origin_edges.append((origin_local_idx, int(n)))

    # --- plot --------------------------------------------------------------
    x = meta_sub["x"].to_numpy()
    y = meta_sub["y"].to_numpy()

    fig, ax = plt.subplots(figsize=(6, 5))
    fig.suptitle(f"Graph {graph_idx} – top {top_pct:.0%} saliency", fontsize=12)

    # all nodes in light gray
    ax.scatter(x, y, s=10, c="#DDDDDD", alpha=0.4, label="All neurons")

    # top nodes colored by saliency
    cmap = plt.get_cmap("plasma")
    norm = plt.Normalize(vmin=sal[top_nodes_idx].min(), vmax=sal[top_nodes_idx].max())
    ax.scatter(
        x[top_nodes_idx],
        y[top_nodes_idx],
        s=40,
        c=sal[top_nodes_idx],
        cmap=cmap,
        norm=norm,
        edgecolors="k",
        linewidths=0.3,
        label=f"Top {top_pct:.0%}",
    )

    # induced edges
    for u, v in induced_edges:
        ax.plot(
            [x[u], x[v]],
            [y[u], y[v]],
            color="#888888",
            linewidth=0.7,
            alpha=0.7,
            zorder=0,
        )

    # high-sal edges in bold
    for u, v in hi_edges:
        ax.plot(
            [x[u], x[v]],
            [y[u], y[v]],
            color="#FFAA00",
            linewidth=1.8,
            alpha=0.9,
            zorder=1,
        )

    # origin star
    if origin_local_idx is not None:
        ax.scatter(
            [x[origin_local_idx]],
            [y[origin_local_idx]],
            s=120,
            marker="*",
            c="cyan",
            edgecolors="k",
            linewidths=0.8,
            label="Burst origin",
            zorder=3,
        )

    ax.set_xlabel("x (µm)")
    ax.set_ylabel("y (µm)")
    ax.set_aspect("equal")
    ax.legend(loc="best", fontsize=8)
    cbar = fig.colorbar(
        plt.cm.ScalarMappable(norm=norm, cmap=cmap),
        ax=ax,
        fraction=0.046,
        pad=0.04,
    )
    cbar.set_label("Node saliency", fontsize=8)

    ax.set_xticks([])
    ax.set_yticks([])

    if save_path is None:
        save_path = graph_dir / f"graph{graph_idx}_saliency.png"
    save_path = Path(save_path)
    save_path.parent.mkdir(parents=True, exist_ok=True)

    plt.tight_layout()
    plt.savefig(save_path, dpi=300, bbox_inches="tight")
    if show:
        plt.show()
    plt.close(fig)

    return save_path
