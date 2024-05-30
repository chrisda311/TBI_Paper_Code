function MI = getMI_spkEntrainment(spkCounts,edges)

% Computes Modulation index based on the histcounts of spikes in each phase
% bin

pj = spkCounts / sum(spkCounts); % Normalize
pj=pj+eps;
H = sum(pj .* log(pj)) * -1; % Compute Shannon Entropy
MI = (log(length(edges)-1) - H)/log(length(edges)-1); % Compute Modulation Index (based on Kullback–Leibler distance)

end

% Based on Tort et al 2008

% Great explination here:
% https://www.frontiersin.org/articles/10.3389/fnins.2019.00573/full#F1