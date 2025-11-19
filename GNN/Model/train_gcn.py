"""
train_gcn.py
============================
Clean GCN training script.

Loads:
    data/cleaned_scaled.pt

Outputs:
    model/best_gcn.pt
    model/training_history.csv
    model/test_report.png

Author: Haripriya Dhanasekaran
Year: 2025
"""

import os
import torch
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    accuracy_score, precision_recall_fscore_support,
    confusion_matrix, roc_curve, auc, precision_recall_curve
)
from torch_geometric.loader import DataLoader
from torch_geometric.nn import GCNConv, global_mean_pool
import torch.nn.functional as F


# ------------------------------------------------------------
# 1. Model Definition
# ------------------------------------------------------------
class GCN(torch.nn.Module):
    def __init__(self, in_channels, hidden_channels, num_classes):
        super().__init__()
        torch.manual_seed(42)

        self.conv1 = GCNConv(in_channels, hidden_channels)
        self.conv2 = GCNConv(hidden_channels, hidden_channels)
        self.conv3 = GCNConv(hidden_channels, hidden_channels)
        self.lin   = torch.nn.Linear(hidden_channels, num_classes)

    def forward(self, x, edge_index, batch, return_embed=False):
        x = F.relu(self.conv1(x, edge_index))
        x = F.relu(self.conv2(x, edge_index))
        x = self.conv3(x, edge_index)

        embed = global_mean_pool(x, batch)  # graph-level embedding

        if return_embed:
            return embed

        out = F.dropout(embed, p=0.5, training=self.training)
        return self.lin(out)


# ------------------------------------------------------------
# 2. Training utilities
# ------------------------------------------------------------
def train_epoch(model, loader, opt, crit, device):
    model.train()
    total_loss = 0
    correct = 0

    for data in loader:
        data = data.to(device)
        opt.zero_grad()

        out = model(data.x, data.edge_index, data.batch)
        loss = crit(out, data.y.view(-1))
        loss.backward()
        opt.step()

        total_loss += loss.item() * data.num_graphs
        pred = out.argmax(dim=1)
        correct += (pred == data.y.view(-1)).sum().item()

    avg_loss = total_loss / len(loader.dataset)
    acc = correct / len(loader.dataset)
    return avg_loss, acc


def eval_epoch(model, loader, crit, device):
    model.eval()
    total_loss = 0
    correct = 0

    all_y, all_pred, all_prob = [], [], []

    with torch.no_grad():
        for data in loader:
            data = data.to(device)
            out = model(data.x, data.edge_index, data.batch)

            total_loss += crit(out, data.y.view(-1)).item() * data.num_graphs
            pred = out.argmax(dim=1)
            prob = torch.softmax(out, dim=1)[:, 1]

            correct += (pred == data.y.view(-1)).sum().item()
            all_y.extend(data.y.view(-1).cpu().numpy())
            all_pred.extend(pred.cpu().numpy())
            all_prob.extend(prob.cpu().numpy())

    avg_loss = total_loss / len(loader.dataset)
    acc = correct / len(loader.dataset)

    prec, rec, f1, _ = precision_recall_fscore_support(
        all_y, all_pred, average="binary", zero_division=0
    )

    return avg_loss, acc, prec, rec, f1, np.array(all_y), np.array(all_pred), np.array(all_prob)


# ------------------------------------------------------------
# 3. Plot utility functions
# ------------------------------------------------------------
def save_test_plots(y_true, y_pred, y_prob, outdir):
    outdir = Path(outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    # Confusion matrix
    cm = confusion_matrix(y_true, y_pred)
    plt.figure(figsize=(6,5))
    plt.imshow(cm, cmap="Blues")
    plt.title("Confusion Matrix")
    plt.colorbar()
    plt.xticks([0,1], ["Non-burst","Pre-burst"])
    plt.yticks([0,1], ["Non-burst","Pre-burst"])
    plt.xlabel("Predicted")
    plt.ylabel("Actual")
    plt.savefig(outdir/"test_confusion_matrix.png", dpi=300)
    plt.close()

    # ROC
    fpr, tpr, _ = roc_curve(y_true, y_prob)
    plt.figure(figsize=(6,5))
    plt.plot(fpr, tpr, label=f"AUC = {auc(fpr,tpr):.3f}")
    plt.plot([0,1],[0,1],'k--')
    plt.xlabel("FPR"); plt.ylabel("TPR")
    plt.title("ROC Curve")
    plt.legend()
    plt.savefig(outdir/"test_roc.png", dpi=300)
    plt.close()

    # PR
    prec, rec, _ = precision_recall_curve(y_true, y_prob)
    plt.figure(figsize=(6,5))
    plt.plot(rec, prec)
    plt.xlabel("Recall"); plt.ylabel("Precision")
    plt.title("PR Curve")
    plt.savefig(outdir/"test_pr.png", dpi=300)
    plt.close()


def tsne_embeddings(model, loader, device, outpath):
    from sklearn.manifold import TSNE

    model.eval()
    embs, labs = [], []

    with torch.no_grad():
        for data in loader:
            data = data.to(device)
            z = model(data.x, data.edge_index, data.batch, return_embed=True)
            embs.append(z.cpu().numpy())
            labs.append(data.y.view(-1).cpu().numpy())

    embs = np.vstack(embs)
    labs = np.hstack(labs)

    tsne = TSNE(n_components=2, random_state=42)
    emb2d = tsne.fit_transform(embs)

    plt.figure(figsize=(7,6))
    for cls in np.unique(labs):
        idx = labs == cls
        plt.scatter(emb2d[idx,0], emb2d[idx,1], s=20, alpha=0.6, label=f"Class {cls}")

    plt.legend()
    plt.title("t-SNE Embeddings")
    plt.tight_layout()
    plt.savefig(outpath, dpi=300)
    plt.close()


# ------------------------------------------------------------
# 4. Main Training Script
# ------------------------------------------------------------
def main():

    print("Loading dataset...")
    data_list = torch.load("data/cleaned_scaled.pt", weights_only=False)
    print(f"Loaded {len(data_list)} graphs")

    # Split
    train_list, test_list = train_test_split(
        data_list, test_size=0.2, random_state=42, shuffle=True
    )

    train_loader = DataLoader(train_list, batch_size=32, shuffle=True)
    test_loader  = DataLoader(test_list,  batch_size=32, shuffle=False)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")

    # Model
    sample = next(iter(train_loader))
    in_ch = sample.x.size(1)
    model = GCN(in_channels=in_ch, hidden_channels=64, num_classes=2).to(device)

    opt = torch.optim.Adam(model.parameters(), lr=0.01)
    crit = torch.nn.CrossEntropyLoss()

    # Training log
    history = {
        'epoch': [], 'train_loss': [], 'train_acc': [],
        'test_loss': [], 'test_acc': [], 'test_f1': []
    }

    best_f1 = 0
    outdir = Path("model")
    outdir.mkdir(exist_ok=True)

    # Train
    for epoch in range(1, 101):
        tr_loss, tr_acc = train_epoch(model, train_loader, opt, crit, device)
        te_loss, te_acc, te_prec, te_rec, te_f1, y_true, y_pred, y_prob = eval_epoch(
            model, test_loader, crit, device
        )

        history['epoch'].append(epoch)
        history['train_loss'].append(tr_loss)
        history['train_acc'].append(tr_acc)
        history['test_loss'].append(te_loss)
        history['test_acc'].append(te_acc)
        history['test_f1'].append(te_f1)

        print(f"Epoch {epoch:03d} | "
              f"Train Loss {tr_loss:.4f}, Acc {tr_acc:.3f} | "
              f"Test Loss {te_loss:.4f}, Acc {te_acc:.3f}, F1 {te_f1:.3f}")

        # Save best model
        if te_f1 > best_f1:
            best_f1 = te_f1
            torch.save(model.state_dict(), outdir/"best_gcn.pt")

    # Save metrics
    pd.DataFrame(history).to_csv(outdir/"training_history.csv", index=False)

    # Final plots
    save_test_plots(y_true, y_pred, y_prob, outdir)
    print("Training complete! Files saved in model/")


if __name__ == "__main__":
    main()
