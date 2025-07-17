#!/usr/bin/env python3
"""
@file     burstRasterPlot_2dwnoise_final.py
@author   Arjun Taneja (arjun79@uw.edu)
@date     13 July, 2025

@brief    Raster plot of an isolated burst.

Usage:
    python3 burstRasterPlot_2dwnoise_final.py
"""

import pandas as pd
import matplotlib.pyplot as plt
import re
from collections import defaultdict
from tqdm import tqdm

# File paths (update if needed)
csv_file = "/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/lastQuarter.csv"
t15_file = "/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/SpaTemporal_lastQuarter_tau-1.txt"

# Burst boundaries (hardcoded)
burst_start = 584822105
burst_end = 584823004
start_time = burst_start - 150
end_time = burst_end + 150

# Track categorized avalanche spikes
burst_spikes = set()
before_spikes = set()
after_spikes = set()
all_avalanche_spikes = set()

# Parse avalanche file line-by-line
with open(t15_file, 'r') as file:
    current_spikes = set()
    current_size = 0
    current_times = []

    for line in tqdm(file, desc="Parsing avalanche file"):
        line = line.strip()
        if line.startswith("Avalanche"):
            # Process previous avalanche
            if current_spikes:
                min_t, max_t = min(current_times), max(current_times)
                if min_t == burst_start and max_t == burst_end:
                    burst_spikes.update(current_spikes)
                elif 2 <= current_size <= 16:
                    if burst_start - 50 <= max_t < burst_start:
                        before_spikes.update(current_spikes)
                    elif burst_end < min_t <= burst_end + 50:
                        after_spikes.update(current_spikes)
                all_avalanche_spikes.update(current_spikes)
            # Start new avalanche
            match = re.search(r"Size\s*=\s*(\d+)", line)
            current_size = int(match.group(1)) if match else 0
            current_spikes = set()
            current_times = []
        elif ',' in line:
            time_str, neuron_str = line.split(',')
            t = int(time_str.strip())
            n = int(neuron_str.strip())
            if start_time <= t <= end_time:
                current_spikes.add((t, n))
                current_times.append(t)

# Load spike CSV and filter time window
spikes = []
with open(csv_file, 'r') as f:
    for line in f:
        parts = line.strip().split(',')
        timestamp = int(parts[0])
        if start_time <= timestamp <= end_time:
            neuron_ids = [int(n) for n in parts[1:] if n.strip()]
            for neuron in neuron_ids:
                spikes.append((timestamp, neuron))

df = pd.DataFrame(spikes, columns=["time", "neuron_id"])

# Assign color based on avalanche ownership
def get_color(row):
    spike = (row.time, row.neuron_id)
    if spike in burst_spikes:
        # return "#990000"  # crimson
        # return "dimgray"
        # return "gray"
        return "black"
    elif spike in before_spikes:
        # return "blue"
        # return "black"
        return "#990000"  # crimson
    elif spike in after_spikes:
        # return "orange"
        # return "black"
        return "#990000"  # crimson
    else:
        # return "lightblack"
        # return "black"
        return "#990000"  # crimson

df["color"] = df.apply(get_color, axis=1)

# Plot raster
plt.rcParams.update({
        'font.size': 11,            
        'axes.labelsize': 11,       
        'xtick.labelsize': 11,      
        'ytick.labelsize': 11,      
        'legend.fontsize': 11,      
        # 'figure.titlesize': 16,     
    })

plt.figure(figsize=(6, 3))
plt.scatter(df["time"], df["neuron_id"], c=df["color"], s=1.3, lw=0)

# Reference lines
plt.axvline(burst_start, color='black', linestyle='--', linewidth=1, label='burst start/end')
plt.axvline(burst_end, color='black', linestyle='--', linewidth=1)
plt.axvline(burst_start - 50, color='red', linestyle=':', linewidth=1, label='burst boundary ± 50 ts')
plt.axvline(burst_end + 50, color='red', linestyle=':', linewidth=1)

plt.xlabel("Time (timesteps)")
plt.ylabel("Neuron ID")
# plt.title("Neuron Spiking Activity with Avalanche Ownership (τ=1.5)")
plt.xlim(start_time, end_time)
plt.ylim(0, 10000)
plt.legend()
plt.tight_layout()

# Save PDF
plt.savefig(f"/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/PlotsNFigures/burstRasterWithNoise_final.pdf", bbox_inches="tight")
