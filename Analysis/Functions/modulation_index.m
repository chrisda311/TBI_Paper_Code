function [MI,p]=modulation_index (phase,amp,bins)
%% Inputs:
% phase: the phase of the signal in the desired frequency
% amp: the amplitude of the signal in the desired frequency
% bins: the bins for the phase
%% Output:
% MI: modulation index [Tort et al.]
nbins=length(bins);
[~,~,bin_index] = histcounts(phase,bins);
mean_amp=zeros(1,nbins);
for k=1:nbins
    if k==nbins
        inds=bin_index==0;
    else
        inds=bin_index==k;
    end
    mean_amp(k)=mean(amp(inds));
end
p=mean_amp/sum(mean_amp);
H=-sum(p.*log(p));
H_max=log(nbins);
MI=(H_max-H)/H_max;
end