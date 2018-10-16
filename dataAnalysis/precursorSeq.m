% script to generate precursor sequences with different window and gap size
h5file = 'tR_1.0--fE_0.90_10000';
window = [70 50 30 20 10];
gapPre = [0 10 20 30 50];
gapNon = 1000;                  % fixed
% output files
for i = 1:length(window)
    for j = 1:length(gapPre)
        [prefile, nonfile] = getPrecursors(window(i), gapPre(j), gapNon);
        makeAllSequence(h5file, prefile, window(i));
    end
    makeAllSequence(h5file, nonfile, window(i));   
end