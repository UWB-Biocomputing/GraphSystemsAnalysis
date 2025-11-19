#!/usr/bin/env python3
"""
run_gnn_explainer.py
====================

Run GNNExplainer on a trained GCN model and save edge/node masks
for every graph in a dataset.

This script performs the following steps:
       - Reconstructs the GCN architecture from a checkpoint (trained weights)
       - Uses best hyperparameters chosen from a sweep
       - Organizes explanations by class and graph ID
       - Runs GNNExplainer on each graph (graph-level explanation).
       - Saves:
            - edge_mask.pt
            - node_mask.pt
            - metadata.json

These files are organized in such a way that downstream visualizations can
easily consume them.

NOTE: The `best_params` dictionary encodes the GNNExplainer
hyperparameters that were selected by a prior hyperparameter sweep.

Author: Haripriya Dhanasekaran
Year: 2025
"""

import argparse
import json
import os
from pathlib import Path
from typing import Optional

from GNN.Model.train_gcn import GCN
import torch
from torch_geometric.data import Data
from torch_geometric.explain import Explainer, GNNExplainer
from torch_geometric.explain.config import (
    ModelConfig,
    ModelTaskLevel,
    ModelReturnType,
)
from torch_geometric.nn import GCNConv, global_mean_pool
import torch.nn.functional as F


# ---------------------------------------------------------------------
# Best explainer hyperparameters (from previous sweeps)
# ---------------------------------------------------------------------
# NOTE:
#   These were chosen by running a sweep of explainer hyperparameters
#   (epochs, lr, num_hops, etc.) and selecting the combination that
#   provided the best trade-off between fidelity and sparsity.
best_params = {
    "epochs": 50,
    "num_hops": 2,
    "lr": 0.005,
    "mask_threshold": 0.05,  # used later when thresholding masks, not here
}


def load_gcn_from_checkpoint(checkpoint_path: Path, device: torch.device) -> GCN:
    """
    Load a GCN model from a checkpoint and infer input/output dimensions
    from the state_dict.

    The checkpoint is expected to be either:
      • a raw state_dict, or
      • a dict with key 'model_state_dict'.
    """
    ckpt = torch.load(checkpoint_path, map_location=device, weights_only=False)

    # Handle both plain state_dict and dict with 'model_state_dict'
    state_dict = ckpt.get("model_state_dict", ckpt)

    # GCNConv uses an internal linear layer "lin.weight" with shape [hidden, in_feats]
    # This assumes the same naming as used during training.
    try:
        in_feats = state_dict["conv1.lin.weight"].shape[1]
        hidden = state_dict["conv1.lin.weight"].shape[0]
        out_feats = state_dict["lin.weight"].shape[0]
    except KeyError as e:
        raise KeyError(
            f"Expected keys like 'conv1.lin.weight' in checkpoint, but got {e}. "
            "Make sure the architecture here matches the training script."
        )

    print(f"[INFO] Reconstructed GCN shape from checkpoint: "
          f"in={in_feats}, hidden={hidden}, out={out_feats}")

    model = GCN(in_channels=in_feats, hidden=hidden, num_classes=out_feats).to(device)
    model.load_state_dict(state_dict)
    model.eval()
    return model


# ---------------------------------------------------------------------
# Utility: ensure batch vector & (optionally) handle feature dims
# ---------------------------------------------------------------------
def prepare_graph_for_model(
    data: Data,
    in_feats: int,
    drop_feature_index: Optional[int] = None,
) -> Data:
    """
    Ensure that:
      • data.x has the same number of features as expected by the model.
      • data.batch exists (graph-level explanation: single graph → all zeros).

    If drop_feature_index is not None and data.x has in_feats + 1 columns,
    the feature column at that index will be dropped to match in_feats.
    This is an explicit version of the "drop the 3rd feature" logic used
    in an earlier prototype.
    """
    # Feature dimension handling
    if data.x.size(1) == in_feats:
        pass  # all good
    elif drop_feature_index is not None and data.x.size(1) == in_feats + 1:
        # Explicitly drop a feature that was not used during training
        keep_idx = [i for i in range(data.x.size(1)) if i != drop_feature_index]
        data.x = data.x[:, keep_idx]
        print(f"[WARN] Dropped feature index {drop_feature_index} "
              f"to match in_feats={in_feats}")
    else:
        raise RuntimeError(
            f"Unexpected feature dimension {data.x.size(1)}; "
            f"model expects {in_feats}."
        )

    # Batch vector: all zeros for a single graph
    if not hasattr(data, "batch") or data.batch is None:
        data.batch = torch.zeros(data.x.size(0), dtype=torch.long)

    return data


# ---------------------------------------------------------------------
# Main explainability routine
# ---------------------------------------------------------------------
def run_explainability(
    run_dir: Path,
    checkpoint_name: str = "best_gcn_model.pt",
    graphs_name: str = "cleaned_scaled.pt",
    output_subdir: str = "explainability",
    drop_feature_index: Optional[int] = None,
) -> None:
    """
    Run GNNExplainer on all graphs in `run_dir / graphs_name` using the
    model checkpoint at `run_dir / checkpoint_name`.

    Explanations are stored under:
        run_dir / output_subdir /
            class_pre_burst/graph_00000/{edge_mask.pt,node_mask.pt,metadata.json}
            class_non_burst/graph_00001/{...}
    """
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")

    checkpoint_path = run_dir / checkpoint_name
    graphs_path = run_dir / graphs_name
    out_base = run_dir / output_subdir

    if not checkpoint_path.exists():
        raise FileNotFoundError(f"Checkpoint not found: {checkpoint_path}")
    if not graphs_path.exists():
        raise FileNotFoundError(f"Graphs file not found: {graphs_path}")

    print(f"Loading model from: {checkpoint_path}")
    model = load_gcn_from_checkpoint(checkpoint_path, device)

    # Build explainer with best_params from sweep
    explainer = Explainer(
        model=model,
        algorithm=GNNExplainer(
            epochs=best_params["epochs"],
            lr=best_params["lr"],
            num_hops=best_params["num_hops"],
        ),
        explanation_type="phenomenon",
        edge_mask_type="object",
        node_mask_type="object",
        model_config=ModelConfig(
            mode="multiclass_classification",
            task_level=ModelTaskLevel.graph,
            return_type=ModelReturnType.raw,
        ),
    )

    print(f"Loading graphs from: {graphs_path}")
    graphs = torch.load(graphs_path, weights_only=False)
    print(f"Loaded {len(graphs)} graphs")

    out_base.mkdir(parents=True, exist_ok=True)

    # Main loop over graphs
    for idx, data in enumerate(graphs):
        data = prepare_graph_for_model(data, in_feats=model.conv1.in_channels,
                                       drop_feature_index=drop_feature_index)
        data = data.to(device)

        # True label (0 = non-burst, 1 = pre-burst)
        label = int(data.y.item())
        category = "pre_burst" if label == 1 else "non_burst"

        graph_dir = out_base / f"class_{category}" / f"graph_{idx:05d}"
        graph_dir.mkdir(parents=True, exist_ok=True)

        # Run explainer
        explanation = explainer(
            x=data.x,
            edge_index=data.edge_index,
            batch=data.batch,
            target=torch.tensor([label], device=device),
        )

        edge_mask = explanation.edge_mask.detach().cpu()
        node_mask = explanation.node_mask.detach().cpu()

        # Save masks
        torch.save(edge_mask, graph_dir / "edge_mask.pt")
        torch.save(node_mask, graph_dir / "node_mask.pt")

        # Save metadata (for plotting / analysis later)
        metadata = {
            "graph_index": idx,
            "label": label,
            "category": category,
            "num_nodes": int(data.x.size(0)),
            "num_edges": int(data.edge_index.size(1)),
            "checkpoint": str(checkpoint_path),
            "graphs_file": str(graphs_path),
            "best_params": best_params,
        }
        with open(graph_dir / "metadata.json", "w") as f:
            json.dump(metadata, f, indent=2)

        print(f"Saved explanation for graph {idx} → {graph_dir}")

    print("\nAll explanations saved.")
    print(f"Base directory: {out_base}")

# ---------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run GNNExplainer over a set of cleaned & scaled graphs."
    )
    parser.add_argument(
        "--run-dir",
        type=str,
        required=True,
        help="Directory containing the checkpoint and cleaned_scaled.pt "
             "(e.g., enhanced_results/w5_m5 or experiments/w5_m5).",
    )
    parser.add_argument(
        "--checkpoint-name",
        type=str,
        default="best_gcn_model.pt",
        help="Checkpoint filename inside run-dir (default: best_gcn_model.pt).",
    )
    parser.add_argument(
        "--graphs-name",
        type=str,
        default="cleaned_scaled.pt",
        help="Graphs filename inside run-dir (default: cleaned_scaled.pt).",
    )
    parser.add_argument(
        "--output-subdir",
        type=str,
        default="explainability",
        help="Subdirectory inside run-dir where explainability outputs will be "
             "written (default: 'explainability').",
    )
    parser.add_argument(
        "--drop-feature-index",
        type=int,
        default=None,
        help=(
            "If set and data.x has in_feats + 1 features, the feature at this "
            "index will be dropped to match the model's expected in_feats. "
            "Use this only if you know one feature was not used at training time."
        ),
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    run_explainability(
        run_dir=Path(args.run_dir),
        checkpoint_name=args.checkpoint_name,
        graphs_name=args.graphs_name,
        output_subdir=args.output_subdir,
        drop_feature_index=args.drop_feature_index,
    )
