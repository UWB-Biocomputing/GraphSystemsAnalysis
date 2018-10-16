% tspf = time steps per frame

function frames = getBinnedBurstFrames(h5file, s_bin, e_bin, binSize, max)
dataset = 'spikesProbedNeurons';
n_neurons = length(hdf5read([h5file '.h5'], 'neuronTypes')); 
s_time = s_bin*binSize; 
e_time = e_bin*binSize;
columns = e_bin-s_bin+1;
frames = zeros(n_neurons, columns, 'uint8');
for idx = 1:n_neurons 
    %% implementation #1, read one neuron's data at once
    SPN = h5read([h5file '.h5'], ['/' dataset],[idx,1],[1,max]);
    counter = find(SPN(:) >= s_time, 1); 
    while (SPN(counter) < e_time) && (SPN(counter) > 0) 
        col = fix(((SPN(counter) - s_time - 1)) / binSize) + 1;
        frames(idx,col) = frames(idx,col) + 1;
        counter = counter + 1;
    end
end
%% implementation #2, read one by one
%     counter = 0;
%     SPN = 1;
%     while (SPN < e_time) && (SPN > 0) 
%         if (SPN >= s_time)
%             col = fix(((SPN - s_time - 1)) / binSize) + 1;
%             frames(idx,col) = frames(idx,col) + 1;
%         end
%         counter = counter + 1;
%         SPN = h5read([h5file '.h5'], ['/' dataset],[idx,counter],[1,1]);
%     end
end