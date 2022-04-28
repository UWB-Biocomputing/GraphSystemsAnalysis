import pandas as pd
import numpy as np
from tqdm import tqdm as tqdm
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
from matplotlib import colors
from matplotlib import rcParams


def extract_sequence(spike_count, num_bursts, burst_mask, duration, seq_type, into_burst=0, offset=0):
    """
    Extracts spike sequences of specified type and duration.

    Args:


    Returns:
        post_burst(2D array): 2D array contaning postburts spike sequences of duration
    """
    
    sequence = np.zeros((num_bursts, duration + into_burst))
    num_spikes = spike_count.shape[1]
    index = 0

    # postbursts
    if seq_type == 0:
        for i in tqdm(range(num_spikes)):
            if burst_mask[i] and i + duration + 1 + offset < num_spikes:
                sequence[index, 0:duration+into_burst] = spike_count[1][i+1-into_burst+offset:i+1+duration+offset]
                index += 1

        if index < num_bursts:
            sequence = np.delete(sequence, np.s_[index:num_bursts], 0)

    if seq_type == 1:
        for i in tqdm(range(num_spikes)):
            if burst_mask[i]:
                sequence[index, 0:duration + into_burst] = spike_count[1][i - duration-offset:i + into_burst - offset]
                index += 1

    return sequence.astype('uint8')


def process_sequence(sequence, bin_size=10):
    """
    """

    sequence_mean = np.mean(sequence, axis=0)
    sequence_std = np.std(sequence, axis=0)
    bins = np.add.reduceat(sequence, np.arange(0, sequence.shape[1], bin_size), axis=1)
    bins_mean = np.mean(bins, axis=0)
    bins_std = np.std(bins, axis=0)

    return sequence_mean, sequence_std, bins, bins_mean, bins_std


def plot_sequence(sequence, seq_type, figsize, elw=0.1, binned=False, with_std=False):
    """
    Creates a plot of the spiking activity.

    Args:
        sequence (2D array): 2D array contaning postburts spike sequences of duration produced by extract_post_burst
        figsize (tuple(int, int)): size of the plot, (width, height)
        elw (int): linewitdth of the errorbars
        binned (boolean): if True, plot binned postbursts
        with_std (Boolean): if True, plot standard deviation

    Returns:
        none
    """
    title_name = ''
    if seq_type == 0:
        title_name = 'Postburst Spiking Activity \nsequence duration = '

    if seq_type == 1:
        title_name = 'Preburst Spiking Activity \nsequence duration = '
    sequence_mean, sequence_std, bins, bins_mean, bins_std = process_sequence(sequence)

    plt.figure(figsize=figsize)

    if binned:
        plt.ylabel('spikes/ms', fontsize=16)
        plt.xlabel('ms', fontsize=16)
        plt.title(title_name + str(bins.shape[1]) + 'ms', fontsize=16)
    else:
        plt.ylabel('spikes/time step', fontsize=16)
        plt.xlabel('time steps', fontsize=16)
        plt.title(title_name + str(sequence.shape[1]) + ' time steps', fontsize=16)

    if not binned and not with_std:
        plt.plot(sequence_mean, color='k')

    if not binned and with_std:
        plt.errorbar(np.arange(sequence_mean.shape[0]), sequence_mean, sequence_std,
                     elinewidth=elw, color='k', ecolor='b')

    if binned and not with_std:
        plt.plot(bins_mean[:-1], color='k')

    if binned and with_std:
        plt.errorbar(np.arange(bins.shape[1] - 1), bins_mean[:-1], yerr=bins_std[:-1],
                     elinewidth=elw, color='k', ecolor='b')

    plt.show()

    
def set_axes(ax, seq_type, duration, into_burst, offset, step):
    
    ax.set_xlabel('time step', fontsize=14)
    ax.set_ylabel('spike count', fontsize=14)
    ax.set_zlabel('burst count', fontsize=14)
    if seq_type==0:
        ax.set_xticklabels(labels=np.arange(-(into_burst)+offset, duration+offset, step).astype('str'), fontsize=14)
    if seq_type==1:
        ax.set_xticklabels(labels=np.arange(into_burst-duration-offset, into_burst+step-offset, step).astype('str'), fontsize=14)
    ax.yaxis.set_tick_params(labelsize=14)
    ax.zaxis.set_tick_params(labelsize=14)
    
    
def plot_histogram(sequence, figsize, title, seq_type, step, duration, angle=30, colormap='jet', into_burst=0, offset=0):
    
    max_count = np.max(sequence)
    min_count = np.min(sequence)
    sequence = sequence.transpose()
    timesteps = sequence.shape[0]
    
    hist3d = np.zeros((timesteps, max_count))
    for i in range(timesteps):
        hist, __ = np.histogram(sequence[i], bins=np.arange(max_count+1))
        hist3d[i, 0:max_count] = hist
    
    fig = plt.figure(figsize=figsize)
    plt.rc('xtick', labelsize=16) 
    plt.rc('ytick', labelsize=16) 
    plt.title(title, fontsize=20)
    plt.axis('off')
    rcParams['axes.labelpad'] = 10
    
    ax1 = fig.add_subplot(1, 2, 1, projection='3d')
    set_axes(ax1 , seq_type, duration, into_burst, offset, step)

    ax2 = fig.add_subplot(1, 2, 2, projection='3d')
    set_axes(ax2, seq_type, duration, into_burst, offset, step)

    x, y = np.meshgrid(np.arange(timesteps), np.arange(max_count))
    z = hist3d.transpose().flatten()
    cmap = cm.get_cmap(colormap)
    rgba = [cmap((k-min_count)/max_count) for k in z] 
    
    ax1.bar3d(x.flatten(), y.flatten(), np.zeros(len(z)), 1, 1, z, color=rgba)
    ax1.view_init(azim=angle)
    ax2.bar3d(x.flatten(), y.flatten(), np.zeros(len(z)), 1, 1, z, color=rgba)
    ax2.view_init(azim=360-angle)
    plt.tight_layout()
    plt.show()
