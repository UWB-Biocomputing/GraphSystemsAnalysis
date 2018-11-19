% save spike places for every 10ms (100 timesteps) in frames
function getBurstFrames(h5dir)
binSize = 100;              % aggregate 100 timesteps into one frame
n_neurons = 1e4;
spikeTimeFile = [h5dir '/allSpikeTime.csv'];   
spikeTime = csvread(spikeTimeFile);
% (1) startRow (2) endRow (5)width (6)totalSpikes 
burstFile = [h5dir '/allBurst.csv'];
b = csvread(burstFile,1,1);
n_bursts = length(b);                  
maxK = size(spikeTime,2);
for i = 1:n_bursts
    s_row = b(i,1); 
    e_row = b(i,2);     
    s_time = b(i,3);  
    frames = zeros(n_neurons, ceil(b(i,5)/binSize), 'uint16');
    for j = s_row:e_row
        ts = spikeTime(j,1);
        col = fix(((ts-s_time))/binSize)+1;
        k = 2;
        while(spikeTime(j,k)~=0 && k < maxK)
            frames(spikeTime(j,k),col) = frames(spikeTime(j,k),col)+1;
            k = k + 1;
        end
    end  
    outfile = [h5dir '/allBurst/frames_', num2str(i), '.csv'];
    csvwrite(outfile, frames);
    fprintf('done with burst:%d/%d\n', i, n_bursts);
end
