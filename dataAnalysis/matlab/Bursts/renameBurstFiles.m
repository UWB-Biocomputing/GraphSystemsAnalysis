function renameBurstFiles(h5file, n_bursts)
% h5file = 'tR_1.0--fE_0.90_10000';
for i = 1:n_bursts
    oldname = [h5file '/Binned/burst', num2str(i) '.mat'];
    %load(oldname, 'frames');
    %newname = [h5file '/Binned/burst_', num2str(i) '.csv'];
    %csvwrite(newname, frames);
    system(['rm ' oldname]);
end
end
