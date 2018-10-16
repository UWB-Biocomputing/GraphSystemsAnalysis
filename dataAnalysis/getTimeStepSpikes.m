%% Jewel Y. Lee 2017
funciton getTimeStepSpikes
infile = '1011_half_tR_1.0--fE_0.90_10000';
% infile = '1102_full_tR_1.0--fE_0.90_10000'; (infile)
P = double((hdf5read([infile '.h5'], 'spikesProbedNeurons'))');
spikesHistory = double((hdf5read([infile '.h5'], 'spikesHistory'))');  
imax = sum(spikesHistory);
% ------------------------------------------------------------------------ 
% get spiking position for every time step that has activities
% ------------------------------------------------------------------------
fid = fopen('allSpikeTime.csv', 'w');  % write information 
fprintf(fid, 'FiringTime,NeuronNumber\n');

for i = 1:imax 
    if any(P(1,:)) == 0 % if there are no more non-recorded data
        break;
    end
    time = min(P(1, P(1,:) > 0));       % get next spike time 
    place = find(P(1,:) == time);       % and place (neuron index)
    fprintf(fid, '%d,', time);          % record time step
    
    for j = 1:length(place)   
        % write neuron number to outfile
        fprintf(fid, '%d,', place(j));     
        % copy the neuron's next firing time to first row
        counter = 2;
        while P(counter, place(j)) < 1
            if P(counter, place(j)) == 0 % no more spike for this neuron
                break;
            else
                counter = counter+1;                 
            end
        end     
        P(1, place(j)) = P(counter, place(j));
        P(counter, place(j)) = -1;        % mark it as recorded
    end
fprintf(fid, '\n');
end
fclose(fid);
disp(i);
