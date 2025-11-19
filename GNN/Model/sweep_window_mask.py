"""
sweep_window_mask.py
===============================
sweep runner that:
    • Imports the GCN model from train_gcn.py
    • Iterates over (window, mask_shift)
    • Loads the cleaned + scaled dataset for that configuration
    • Trains GCN using a shared training function
    • Saves only evaluation metrics (Acc/Precision/Recall/F1, loss)
    • Appends all results into: experiments/sweep_summary.csv

Author: Haripriya Dhanasekaran
Year: 2025
"""

import os
import json
import time
import torch
import pandas as pd
from pathlib import Path
from sklearn.model_selection import train_test_split
from torch_geometric.loader import DataLoader

# Import minimal GCN + training function from your train_gcn file
from train_gcn import GCN, run_epoch, plot_test_metrics   # <-- we reuse these


# -----------------------------
# Simple train function
# -----------------------------
def train_single_model(data_list, device):
    """
    Trains a GCN on a single dataset.
    Returns a dictionary of test metrics.
    """

    # Split
    train_list, test_list = train_test_split(
        data_list,
        test_size=0.2,
        shuffle=True,
        random_state=42
    )

    train_loader = DataLoader(train_list, batch_size=32, shuffle=True)
    test_loader  = DataLoader(test_list,  batch_size=32, shuffle=False)

    # Model
    in_channels = train_list[0].x.size(1)
    model = GCN(in_channels=in_channels, hidden_channels=64, num_classes=2)
    model = model.to(device)

    optimizer = torch.optim.Adam(model.parameters(), lr=0.01)
    criterion = torch.nn.CrossEntropyLoss()

    best_f1 = 0
    best_epoch = -1

    # Train
    for epoch in range(1, 51):  # 50 epochs for sweeps
        train_loss, train_acc, *_ = run_epoch(
            model, train_loader, criterion, device, train=True, opt=optimizer
        )

        val_loss, val_acc, val_prec, val_rec, val_f1, val_y, val_pred, val_prob = run_epoch(
            model, test_loader, criterion, device, train=False
        )

        if val_f1 > best_f1:
            best_f1 = val_f1
            best_epoch = epoch

    # Return final evaluation metrics
    return {
        "test_loss": float(val_loss),
        "test_acc": float(val_acc),
        "test_prec": float(val_prec),
        "test_rec": float(val_rec),
        "test_f1": float(val_f1),
        "best_epoch": int(best_epoch)
    }


# -----------------------------
# Main Sweep Runner
# -----------------------------
def main():

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print("Device =", device)

    EXP_DIR = Path("experiments")
    EXP_DIR.mkdir(exist_ok=True)

    summary_rows = []

    # These cleaned_scaled.pt files must already exist!
    windows = [5, 10, 20]
    mask_shifts = [0, 5, 10]

    for w in windows:
        for m in mask_shifts:

            run_dir = EXP_DIR / f"w{w}_m{m}"
            data_path = run_dir / "cleaned_scaled.pt"

            if not data_path.exists():
                print(f"[SKIP] {data_path} does not exist yet.")
                continue

            print(f"\n---- Running sweep: window={w}, mask={m} ----")

            # Load data
            data_list = torch.load(data_path, weights_only=False)

            # Train model
            metrics = train_single_model(data_list, device)

            # Add sweep info
            metrics["window"] = w
            metrics["mask_shift"] = m

            summary_rows.append(metrics)

            # Save per-run results
            with open(run_dir / "eval_metrics.json", "w") as f:
                json.dump(metrics, f, indent=2)

            print(f"[DONE] F1={metrics['test_f1']:.4f}")

    # Save global summary
    df = pd.DataFrame(summary_rows)
    df.to_csv(EXP_DIR / "sweep_summary.csv", index=False)
    print("Full sweep completed!")

if __name__ == "__main__":
    main()
