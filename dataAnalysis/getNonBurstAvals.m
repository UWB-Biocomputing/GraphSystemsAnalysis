function getNonBurstAvals(h5dir)
spikeTimeFile = [h5dir '/allSpikeTime.csv'];      
burstInfo = csvread([h5dir '/allBurst.csv'],1,1);
b_scol = burstInfo(:,1);    % start column
b_ecol = burstInfo(:,2);    % end column

% break data into 10 chunks
start = zeros(10,1);
start(1) = find(burstInfo(:,3)>3.75*1e8, 1);  %7850
ended = find(burstInfo(:,3)>5*1e8, 1);
%ended = length(burstInfo);
start = [start; ended];
chunk = ceil((ended - start(1))/5);
for i = 2:10
    start(i) = start(i-1) + chunk;
end
j = 1;
while j <= 10 %length(start)
    % create a new output file
    outfile = [h5dir '/nonBurstAvals_' num2str(j+10) '.csv'];
    command = ['touch ', outfile]; system(command);    
    count = start(j);
    disp(count);
    while count < start(j+1)
        disp(count);
        s = b_ecol(count) + 1;
        e = b_scol(count+1) - 1;
        command = ['sed -n ''',num2str(s),',', num2str(e), ' p'' ', ...
                spikeTimeFile,' >> ', outfile];
        system(command);
        count = count + 1;
    end   
    j = j + 1;
end
% disp(j)
% % while count < length(burstInfo) %9729
% count = start(j);
% disp(count);
% s = b_ecol(count) + 1;  % 127453826
% command = ['sed -n ''',num2str(s),',' ' $p'' ', ...
%            spikeTimeFile,' >> ', outfile];
% system(command);
end

