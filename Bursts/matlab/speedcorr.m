% Correlation of burst speed and burst origin
% SPEEDCORR compute Spearman rank correlation between burst speed and loc
%
%   Syntax: speedcorr(h5dir, chunks, layoutSize)
%
%   Input:
%   h5dir   -    Graphitti result filename (e.g. tR_1.0--fE_0.90)
%                the entire path may be required, for example
%                '/CSSDIV/research/biocomputing/data/tR_1.0--fE_0.90'
%
%   Output:
%   Spearman rho and p

function speedcorr(h5dir)

% Burst speeds (for all bursts)
meanSpeeds = readmatrix([h5dir '/allBurstSpeedMean.csv']);

% Burst origins
%
% burst origin (x, y), neuron ID, and origin bin # for every burst. (This
% is Graphitti neuron ID, i.e., zero-based, and (x, y) are also zero-based,
% ij coordinates))
origins = readmatrix([h5dir '/allBurstOrigin.csv']);

% Get multi-bursts (Matlab numbering; starting with 1)
multiBurstIDs = readmatrix([h5dir '/multipleBursts.csv']);

% Generate list of non-multibursts
burstIDs = 1:size(origins, 1);
burstIDs = setdiff(burstIDs, multiBurstIDs);

% Excise the multi-burst data from origins
origins = origins(burstIDs,:);

% Burst speeds were only computed for non-multi-bursts; let's just check
if length(burstIDs) ~= length(meanSpeeds)
    error('Inconsistent number of bursts between mean speeds and multi burst IDs.');
end

% Convert burst origins to linear indices, remembering that row = Y
% and col = X and that we need to convert zero-based to one-based. These
% should match the linear indices in "avgVec".
originInds = sub2ind([100 100], origins(:,2)+1, origins(:,1)+1);

% Compute Spearman stats
[rho, pval] = corr(meanSpeeds, originInds, 'Type', 'Spearman');
fprintf('Spearman rho=%f, pval=%f\n', rho, pval);

