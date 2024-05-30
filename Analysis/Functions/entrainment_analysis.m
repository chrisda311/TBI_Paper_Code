function [MVL_more,MVL_less,mAng_more,mAng_less,entBinned_more,entBinned_less,MI_more,MI_less,MVL_more_shuffled,MVL_less_shuffled,mAng_more_shuffled,mAng_less_shuffled,entBinned_more_shuffled,entBinned_less_shuffled,MI_more_shuffled,MI_less_shuffled]=entrainment_analysis(signal,spike_times,fs,franges,velocity,velocity_threshold)
ed20 = deg2rad(-180):deg2rad(20):deg2rad(180);%Edges for Modulation Index. Use these bins! Based on Tort et al. 2008
filter_order=2;
minOffset = 10 * fs;
%%
num_phases=length(franges);
num_data_phase=length(signal);
phase_freq_matrix=single(zeros(num_phases,num_data_phase));
for n_phase=1:num_phases
    low=franges(1,n_phase);
    high=franges(2,n_phase);
    temp=bandpass_filter_single_channel(signal,low, high, fs,filter_order);
    temp=single(temp);
    temp=angle(hilbert(temp));
    phase_freq_matrix(n_phase,:)=temp;
end
%%
spki3k = round(spike_times/ 10);% Thses are the instances in the 3k data where the spike occurred
v_spikes=velocity(spki3k);
inds_more=spki3k(v_spikes>=velocity_threshold);
inds_less=spki3k(v_spikes<velocity_threshold);
MVL_more=zeros(num_phases,1)+nan;
MVL_less=zeros(num_phases,1)+nan;
mAng_more=zeros(num_phases,1)+nan;
mAng_less=zeros(num_phases,1)+nan;
entBinned_more=zeros(num_phases,length(ed20)-1)+nan;
entBinned_less=zeros(num_phases,length(ed20)-1)+nan;
MI_more=zeros(num_phases,1)+nan;
MI_less=zeros(num_phases,1)+nan;
MVL_more_shuffled=zeros(num_phases,nperm)+nan;
MVL_less_shuffled=zeros(num_phases,nperm)+nan;
mAng_more_shuffled=zeros(num_phases,nperm)+nan;
mAng_less_shuffled=zeros(num_phases,nperm)+nan;
entBinned_more_shuffled=zeros(num_phases,length(ed20)-1,nperm)+nan;
entBinned_less_shuffled=zeros(num_phases,length(ed20)-1,nperm)+nan;
MI_more_shuffled=zeros(num_phases,nperm)+nan;
MI_less_shuffled=zeros(num_phases,nperm)+nan;
for n_phase=1:num_phases
    phase_spikes_more=phase_freq_matrix(n_phase,inds_more)';
    phase_spikes_less=phase_freq_matrix(n_phase,inds_less)';
    if ~isempty(phase_spikes_more)
        MVL_more(n_phase)=circ_r(phase_spikes_more);
        mAng_more(n_phase)=circ_mean(phase_spikes_more);
        entBinned_more(n_phase,:)=histcounts(phase_spikes_more',ed20);
        MI_more(n_phase)=getMI_spkEntrainment(entBinned_more(n_phase,:),ed20);
    end
    if ~isempty(phase_spikes_less)
        mAng_less(n_phase)=circ_mean(phase_spikes_less);
        MVL_less(n_phase)=circ_r(phase_spikes_less);
        entBinned_less(n_phase,:)=histcounts(phase_spikes_less',ed20);
        MI_less(n_phase)=getMI_spkEntrainment(entBinned_less(n_phase,:),ed20);
    end
end
l_v=length(velocity);
ipermCut = randperm(size(signal,2)-2*minOffset,nperm) + minOffset;
for p=1:nperm
    inds_p=[ipermCut(p):l_v,1:ipermCut(p)-1];
    temp_phase_freq_matrix=phase_freq_matrix(:,inds_p);
    for n_phase=1:num_phases
        phase_spikes_more=temp_phase_freq_matrix(n_phase,inds_more)';
        phase_spikes_less=temp_phase_freq_matrix(n_phase,inds_less)';
        if ~isempty(phase_spikes_more)
            MVL_more_shuffled(n_phase,p)=circ_r(phase_spikes_more);
            mAng_more_shuffled(n_phase,p)=circ_mean(phase_spikes_more);
            entBinned_more_shuffled(n_phase,:,p)=histcounts(phase_spikes_more',ed20);
            MI_more_shuffled(n_phase,p)=getMI_spkEntrainment(entBinned_more_shuffled(n_phase,:,p),ed20);
        end
        if ~isempty(phase_spikes_less)
            MVL_less_shuffled(n_phase,p)=circ_r(phase_spikes_less);
            mAng_less_shuffled(n_phase,p)=circ_mean(phase_spikes_less);
            entBinned_less_shuffled(n_phase,:,p)=histcounts(phase_spikes_less',ed20);
            MI_less_shuffled(n_phase,p)=getMI_spkEntrainment(entBinned_less_shuffled(n_phase,:,p),ed20);
        end
    end
end