#!/usr/bin/env python3
"""
@file     plotMidSizedAvalancheProximity.py
@author   Arjun Taneja (arjun79@uw.edu)
@date     13 July, 2025

@brief    Histogram mid-sized avalanche proximity to burst start/end.

Usage:
    python3 plotMidSizedAvalancheProximity.py
"""
import sys
sys.path.append("/home/NETID/arjun79/.local/bin")

import csv
import numpy as np
import matplotlib.pyplot as plt

# Input file path
infile = "/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/SpaTemporal_lastQuarter_tau-1.csv"

bursts = []
mids = []

# Read avalanche data from csv file
with open(infile, newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        aval_size = int(row['TotalSpikes'])
        start_time = int(row['StartT'])
        end_time = int(row['EndT'])

        if aval_size > 1e4:
            bursts.append((start_time, end_time))
        elif 16 < aval_size < 1000:
            mids.append((start_time, end_time))

# Sort bursts by start time to enable efficient proximity checks
bursts.sort()
print(f'Number of mid-sized avalanches - {len(mids)}')
print(f'Number of burst-sized avalanches - {len(bursts)}')

# Result containers
before_burst_distances = []
after_burst_distances = []
overlaps = 0

# Process each mid-sized avalanche
for mid_start, mid_end in mids:
    preceding = None
    following = None

    # Scan through bursts to find nearest preceding and following burst
    for burst_start, burst_end in bursts:
        if((burst_start < mid_start and burst_end < mid_start) or (burst_start > mid_end and burst_end > mid_end)):
            if burst_end < mid_start:
                preceding = burst_end  # update until last one before mid_start
            elif burst_start > mid_end and following is None:
                following = burst_start
                break  # no need to check further, as bursts are sorted
        else:                           
            preceding = None
            following = None
            break

    # Compute distances if found
    dist_to_preceding = abs(mid_start - preceding) if preceding is not None else 0
    dist_to_following = abs(mid_end - following) if following is not None else 0

    # if dist_to_following is 0 and dist_to_preceding is 0:
    #     overlaps += 1
    #     continue

    # Categorize based on which burst is closer
    if dist_to_preceding is not None and (dist_to_following is None or dist_to_preceding < dist_to_following):
        after_burst_distances.append(dist_to_preceding)
            
    elif dist_to_following is not None:
        before_burst_distances.append(dist_to_following)


# Convert lists to numpy arrays
before = np.array(before_burst_distances)
after = np.array(after_burst_distances)

overlaps = np.sum(before == 0) + np.sum(after == 0)
print(f'Number of overlapping avalanches (distance=0): {overlaps}')

# -----------------------------------------------------------------------------
# HISTOGRAM PLOT
# -----------------------------------------------------------------------------
# Get distance range
min_dist = 0
max_dist = max(np.max(before), np.max(after))

# Choose # of bins 
num_bins = 25
linear_bins = np.linspace(min_dist, max_dist, num=num_bins + 1)

# Histogram counts 
before_counts, _ = np.histogram(before, bins=linear_bins)
after_counts, _ = np.histogram(after, bins=linear_bins)

# Compute bin centers
bin_centers = 0.5 * (linear_bins[1:] + linear_bins[:-1])
neg_bin_centers = -bin_centers  # left side = 'before burst', right side = 'after burst'

plt.rcParams.update({
    'font.size': 11,            
    'axes.labelsize': 11,       
    'xtick.labelsize': 11,      
    'ytick.labelsize': 11,      
    'legend.fontsize': 11,      
    # 'figure.titlesize': 16,     
})

plt.figure(figsize=(6, 3))

plt.bar(neg_bin_centers, before_counts, width=np.diff(linear_bins), align='center', alpha=0.7, label='Before Burst')
plt.bar(bin_centers, after_counts, width=np.diff(linear_bins), align='center', alpha=0.7, label='After Burst')

# Styling
plt.axvline(-50, color='gray', linestyle='--', label='τ = 50 threshold')
plt.axvline(50, color='gray', linestyle='--')

plt.xlabel('Temporal Distance from Burst')
plt.ylabel('Number of Mid-sized Avalanches')
# plt.title('Proximity of Mid-sized Avalanches to Bursts')
plt.legend()
plt.grid(True, which='both', ls='--', lw=0.5)
plt.tight_layout()

# Add text annotation for overlapping avalanches
# plt.text(0.02, 0.98, f'Avalanches that overlap \nwith bursts: {overlaps}', 
#             transform=plt.gca().transAxes, verticalalignment='top',
#             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.savefig(f"/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/PlotsNFigures/BurstProximity/midSizeProximity.pdf", bbox_inches="tight")
# plt.show()



