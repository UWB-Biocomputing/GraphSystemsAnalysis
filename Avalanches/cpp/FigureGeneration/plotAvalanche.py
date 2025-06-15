#!/usr/bin/env python3

import sys
sys.path.append("/home/NETID/arjun79/.local/bin")

import csv
import numpy as np
import matplotlib.pyplot as plt


infile = "/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/"
# filename = "SpaTemporal_lastQuarter_tau-1"
# filename = "SpaTemporal_lastQuarter_tau-3"
# filename = "SpaTemporal_lastQuarter_tau-6"
# filename = "SpaTemporal_lastQuarter_tau-12"
# filename = "SpaTemporal_lastQuarter_tau-25"
# filename = "SpaTemporal_lastQuarter_tau-33"
filename = "SpaTemporal_lastQuarter_tau-50"
# filename = "SpaTemporal_lastQuarter_tau-100"
# filename = "TEMPORAL_lastQuarter_tau-1"
# filename = "TEMPORAL_lastQuarter_tau-50"


readCSV = csv.reader(open(infile+filename+".csv"), delimiter=',')

avalSizes = {}
i = 0
burstCount = 0

for line in readCSV:
    if(i == 0):
        i = i + 1
        continue
    # print(line)
    aval_size = np.uint32(line[-1])
    if(aval_size > 1e4):
        burstCount += 1

    if aval_size in avalSizes:
        avalSizes[aval_size] += 1
    else:
        avalSizes[aval_size] = 1

    i = i + 1

print(f'Number of bursts in {filename}: {burstCount}\n')

numAvalanches = i-1
x = []
for key in avalSizes:
    x.append(key)
x.sort()

y = []
for size in x:
    y.append(float(avalSizes[size])/numAvalanches)

print("\n")

plt.rcParams.update({
    'font.size': 11,            
    'axes.labelsize': 11,       
    'xtick.labelsize': 11,      
    'ytick.labelsize': 11,      
    'legend.fontsize': 11,      
    # 'figure.titlesize': 16,     
})

plt.figure(figsize=(5.2, 4))
plt.loglog(x, y, marker='o', markerfacecolor='none', linestyle='none', color='blue')
plt.xlabel('Avalanche Size (# of spikes)')
plt.ylabel('Probability of occurence')
# plt.title(f"Log-Log Plot of Size vs. Probability, τ-{1.5 if filename.split('-')[-1].strip() is '1' else filename.split('-')[-1]}")
plt.grid(True, which="both", ls="--")
x_max = max(x)
y_max = max(y)
plt.text(
    0.97, 0.95,
    f'Total avalanches: {numAvalanches}\nNumber of Bursts: {burstCount}',
    bbox=dict(boxstyle='round',facecolor='white',alpha=0.8),
    fontsize=11,
    va='top',
    ha='right',
    transform=plt.gca().transAxes  # Use axes-relative coordinates (0 to 1)
)

x = np.array(x)
y = np.array(y)

# Plot line of best fit for non-burst avalanches only
mask = x < 1e4
x_nonburst = x[mask]
y_nonburst = y[mask]

# Perform linear fit in log-log space
log_x = np.log10(x_nonburst)
log_y = np.log10(y_nonburst)
slope, intercept = np.polyfit(log_x, log_y, 1)

# Compute R^2
fit_y = slope * log_x + intercept
ss_res = np.sum((log_y - fit_y) ** 2)
ss_tot = np.sum((log_y - np.mean(log_y)) ** 2)
r_squared = 1 - (ss_res / ss_tot)

# Generate fitted line
x_fit = np.logspace(np.log10(min(x_nonburst)), np.log10(max(x_nonburst)), 100)
y_fit = 10 ** (slope * np.log10(x_fit) + intercept)

# Plot the best-fit line
plt.loglog(x_fit, y_fit, color='red', linestyle='--', label=f'Fit (slope={slope:.2f}), R²={r_squared:.3f}')

# Add legend
plt.legend( 
    bbox_to_anchor=(1, 0.83),
    fontsize=11,
    framealpha=0.8,
    edgecolor='black',
)

plt.tight_layout()
plt.savefig(f"/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/PlotsNFigures/sizeVprobability/{filename}.pdf", bbox_inches="tight")
# plt.show()
