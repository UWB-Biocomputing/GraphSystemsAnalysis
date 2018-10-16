function subdata = getPartialSeq(data,window,gap)
    offset = size(data,2)-3*(window+gap);
    subdata = data(:,offset+1:end-(3*gap));
    % set starting time step as zero
    align = subdata(:,1);
    for m = 1:3:size(subdata,2)
        subdata(:,m) = subdata(:,m)-align;
    end
end