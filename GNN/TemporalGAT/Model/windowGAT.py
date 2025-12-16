"""
WINDOWGAT Window-Level Graph Attention Network for Burst-Based Neural Data

    This module defines the WindowGAT class, a graph attention mechanism used
    to compute neuron level embeddings for a single temporal window of a burst.

    The WindowGAT operates on a graph where vertices represent neurons and edges
    represent synaptic connections. For each edge, attention scores are computed
    using both source vertex features and edge attributes, allowing the model to
    weight incoming messages based on synaptic strength and vertex activity.

    Core components:
      - group_softmax: a destination-wise softmax operation that normalizes
        attention scores across all incoming edges for each target vertex.
      - Multi-head attention mechanism that aggregates messages from source
        neurons to destination neurons.
      - Edge-aware attention, where edge attributes are concatenated with
        source-vertex features during key and value computation.

    This module is designed to be used as a building block within higher-level
    temporal models (e.g., BurstTemporalGAT), where it is applied independently
    to each temporal window.

Syntax:
    gat = WindowGAT(
              vertex_in=<int>,
              edge_in=<int>,
              hid=<int>,
              heads=<int>
          )

Input:
    x            - Tensor [N, F] of vertex (neuron) features
    edge_index   - Tensor [2, E] specifying source and destination vertices
    edge_attr    - Tensor [E, edge_in] of edge attributes (e.g., synaptic weights)
    return_attn  - Boolean flag indicating whether to return attention weights

Output:
    out          - Tensor [N, hid * heads] of vertex embeddings
    attn         - (optional) Tensor [E, heads] of attention weights
    (src, dst)   - (optional) Edge index tuple corresponding to attention values

Author: Marina Rosenwald

Last updated: 12/16/2025
"""


import torch.nn as nn
import torch
import torch.nn.functional as F

def group_softmax(scores, dst, num_vertices):
    H = scores.size(1)
    max_scores = torch.full((num_vertices, H), -1e9, device=scores.device, dtype=scores.dtype)
    max_scores.index_reduce_(0, dst, scores, reduce='amax')
    exp_scores = torch.exp(scores - max_scores[dst])
    denom = torch.zeros(num_vertices, H, device=scores.device, dtype=scores.dtype)
    denom.index_add_(0, dst, exp_scores)
    return exp_scores / (denom[dst] + 1e-12)

class WindowGAT(nn.Module):
    def __init__(self, vertex_in, edge_in, hid=64, heads=4):
        super().__init__()
        self.q = nn.Linear(vertex_in, hid*heads, bias=False)
        self.k = nn.Linear(vertex_in + edge_in, hid*heads, bias=False)
        self.v = nn.Linear(vertex_in + edge_in, hid*heads, bias=False)
        self.heads, self.hid = heads, hid

    def forward(self, x, edge_index, edge_attr, return_attn=False):
        src, dst = edge_index
        q = self.q(x[dst]).view(-1, self.heads, self.hid)

        if edge_attr.ndim == 1:
            edge_attr = edge_attr.unsqueeze(-1)

        kv_in = torch.cat([x[src], edge_attr], dim=-1)
        k = self.k(kv_in).view(-1, self.heads, self.hid)
        v = self.v(kv_in).view(-1, self.heads, self.hid)
        scores = (q * k).sum(-1) / (self.hid ** 0.5)
        attn = group_softmax(scores, dst, x.size(0))

        out = torch.zeros(x.size(0), self.heads, self.hid, device=x.device)
        out.index_add_(0, dst, attn.unsqueeze(-1) * v)
        out = F.elu(out.reshape(x.size(0), -1))
        if return_attn:
            return out, attn, (src, dst)
        return out