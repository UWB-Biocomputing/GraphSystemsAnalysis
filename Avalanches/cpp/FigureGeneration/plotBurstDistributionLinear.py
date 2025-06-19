#!/usr/bin/env python3

import sys
sys.path.append("/home/NETID/arjun79/.local/bin")

import csv
import matplotlib.pyplot as plt
from statsmodels.nonparametric.smoothers_lowess import lowess

def load_bursts(file_path):
    sizes = []
    durations = []
    with open(file_path, 'r') as f:
        reader = csv.reader(f)
        header = next(reader)  # Skip header
        for row in reader:
            size = int(row[-1])
            duration = int(row[-2])
            if size > 1e4:
                sizes.append(size)
                durations.append(duration)
    return sizes, durations

# File paths
file1 = "/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/SpaTemporal_lastQuarter_tau-1.csv"
file2 = "/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/SpaTemporal_lastQuarter_tau-3.csv"
file3 = "/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/SpaTemporal_lastQuarter_tau-6.csv"
file4 = "/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/SpaTemporal_lastQuarter_tau-12.csv"
file5 = "/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/SpaTemporal_lastQuarter_tau-25.csv"
file6 = "/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/SpaTemporal_lastQuarter_tau-50.csv"
file7 = "/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/SpaTemporal_lastQuarter_tau-100.csv"

# Load data
sizes1, durations1 = load_bursts(file1)
# sizes2, durations2 = load_bursts(file2)
# sizes3, durations3 = load_bursts(file3)
# sizes4, durations4 = load_bursts(file4)
# sizes5, durations5 = load_bursts(file5)
sizes6, durations6 = load_bursts(file6)
# sizes7, durations7 = load_bursts(file7)

# LOWESS smoothing
lowess1 = lowess(durations1, sizes1, frac=0.4, return_sorted=True)
# lowess2 = lowess(durations2, sizes2, frac=0.4, return_sorted=True)
# lowess3 = lowess(durations3, sizes3, frac=0.4, return_sorted=True)
# lowess4 = lowess(durations4, sizes4, frac=0.4, return_sorted=True)
# lowess5 = lowess(durations5, sizes5, frac=0.4, return_sorted=True)
lowess6 = lowess(durations6, sizes6, frac=0.4, return_sorted=True)
# lowess7 = lowess(durations7, sizes7, frac=0.4, return_sorted=True)

# Sort datasets by size to ensure clean line plots
sorted1 = sorted(zip(sizes1, durations1))
# sorted2 = sorted(zip(sizes2, durations2))
# sorted3 = sorted(zip(sizes3, durations3))
# sorted4 = sorted(zip(sizes4, durations4))
# sorted5 = sorted(zip(sizes5, durations5))
sorted6 = sorted(zip(sizes6, durations6))
# sorted7 = sorted(zip(sizes7, durations7))

sizes1, durations1 = zip(*sorted1)
# sizes2, durations2 = zip(*sorted2)
# sizes3, durations3 = zip(*sorted3)
# sizes4, durations4 = zip(*sorted4)
# sizes5, durations5 = zip(*sorted5)
sizes6, durations6 = zip(*sorted6)
# sizes7, durations7 = zip(*sorted7)


plt.rcParams.update({
    'font.size': 11,            
    'axes.labelsize': 11,       
    'xtick.labelsize': 11,      
    'ytick.labelsize': 11,      
    'legend.fontsize': 11,      
    # 'figure.titlesize': 16,     
})

# Plot lines
plt.figure(figsize=(6.66, 4))
plt.plot(lowess1[:, 0], lowess1[:, 1], color='royalblue', label=f'τ-{1.5 if file1.split("-")[-1].split(".")[0] is "1" else file1.split("-")[-1].split(".")[0]} trend', linewidth=2)
# plt.plot(lowess2[:, 0], lowess2[:, 1], color='crimson', label=f'τ-{file2.split("-")[-1].split(".")[0]} trend', linewidth=2)
# plt.plot(lowess3[:, 0], lowess3[:, 1], color='goldenrod', label=f'τ-{file3.split("-")[-1].split(".")[0]} trend', linewidth=2)
# plt.plot(lowess4[:, 0], lowess4[:, 1], color='mediumseagreen', label=f'τ-{file4.split("-")[-1].split(".")[0]} trend', linewidth=2)
# plt.plot(lowess5[:, 0], lowess5[:, 1], color='darkorange', label=f'τ-{file5.split("-")[-1].split(".")[0]} trend', linewidth=2)
plt.plot(lowess6[:, 0], lowess6[:, 1], color='tomato', label=f'τ-{file6.split("-")[-1].split(".")[0]} trend', linewidth=2)
# plt.plot(lowess7[:, 0], lowess7[:, 1], color='slategray', label=f'τ-{file7.split("-")[-1].split(".")[0]} trend', linewidth=2)

# plt.figure(figsize=(10, 6))
plt.scatter(sizes1, durations1, color='royalblue', alpha=0.05, label=f'τ-{1.5 if file1.split("-")[-1].split(".")[0] is "1" else file1.split("-")[-1].split(".")[0]}', s=10)
# plt.scatter(sizes2, durations2, color='crimson', alpha=0.05, label=f'τ-{file2.split("-")[-1].split(".")[0]}', s=10)
# plt.scatter(sizes3, durations3, color='goldenrod', alpha=0.05, label=f'τ-{file3.split("-")[-1].split(".")[0]}', s=10)
# plt.scatter(sizes4, durations4, color='mediumseagreen', alpha=0.05, label=f'τ-{file4.split("-")[-1].split(".")[0]}', s=10)
# plt.scatter(sizes5, durations5, color='darkorange', alpha=0.05, label=f'τ-{file5.split("-")[-1].split(".")[0]}', s=10)
plt.scatter(sizes6, durations6, color='tomato', alpha=0.05, label=f'τ-{file6.split("-")[-1].split(".")[0]}', s=10)
# plt.scatter(sizes7, durations7, color='slategray', alpha=0.05, label=f'τ-{file7.split("-")[-1].split(".")[0]}', s=10)

plt.xlabel("Burst Size (# of Spikes)")
plt.ylabel("Burst Duration (Timesteps)")
# plt.title("Burst Size vs Duration (radius = 8)")
plt.legend(ncol=2, loc='upper right')
# plt.legend()
plt.grid(True, linestyle='--', alpha=0.5)
plt.tight_layout()
plt.savefig("/DATA/arjun79/GraphSystemsAnalysis/Avalanches/cpp/output/PlotsNFigures/BurstSizeDistribution/allBurstDistribution_1.5v50.pdf", bbox_inches="tight")
# plt.show()

