function [MI_more,MI_shuffled_more,p_more,p_shuffled_more,MVL_more,MVL_shuffled_more,MA_more,MA_shuffled_more,MI_less,MI_shuffled_less,p_less,p_shuffled_less,MVL_less,MVL_shuffled_less,MA_less,MA_shuffled_less] = PAC_analysis(data_phase,data_amp,fs,phase_freq_range,phase_freq_width,amp_freq_range,amp_freq_width,num_bins,num_perm,velocity,velocity_threshold,n_down)
%% Inputs
% data: the raw data [1xN] should be downsampled before passing to the function
% fs: sampling frequency (different from original fs if downsampled
% phase_freq_range: frequencies for the phases to be checked [1xM]
% phase_freq_width: determines the band to filter the data for the phase
% amp_freq_range: frequencies for the amps to be checked [1xL]
% amp_freq_width: determines the band to filter the data for the amplitude
% num_bins: number of bins for phases
% num_perm: number of permutations
%% Outputs:
% comodulogram: comodulogram [LxM] (Tort et al.)
% comodulogram_shuffled: shuffeld comodulogram for statistal testing [LxMxnum_perm] (Tort et al.)
%%
condition=velocity>=velocity_threshold(1);
%%
condition=downsample(condition,n_down);
condition=logical(condition);
fs=fs/n_down;
%%
data_phase=downsample(data_phase,n_down);
data_amp=downsample(data_amp,n_down);
data_phase=double(data_phase);
data_amp=double(data_amp);
%%
num_phases=length(phase_freq_range);
num_amps=length(amp_freq_range);
num_data_phase=length(data_phase);
num_data_amp=length(data_amp);
%%
filter_order=2;
%%
phase_freq_matrix=single(zeros(num_phases,num_data_phase));% You need to check if you can use single data instead of double data. Be cautious!
for i=1:num_phases
    low=phase_freq_range(i);
    high=phase_freq_range(i)+phase_freq_width;
    temp=bandpass_filter_single_channel(data_phase,low, high, fs,filter_order);
    temp=single(temp);
    temp=angle(hilbert(temp));
    phase_freq_matrix(i,:)=temp;
end
%%
amp_freq_matrix=single(zeros(num_amps,num_data_amp));% You need to check if you can use single data instead of double data. Be cautious!
for i=1:num_amps
    low=amp_freq_range(i);
    high=amp_freq_range(i)+amp_freq_width;
    temp=bandpass_filter_single_channel(data_amp,low, high, fs,filter_order);
    temp=single(temp);
    temp=abs(hilbert(temp));
    amp_freq_matrix(i,:)=temp;
end
%%
bins=-pi:2*pi/num_bins:+pi-2*pi/num_bins;
MI_more=single(zeros(num_phases,num_amps));
p_more=single(zeros(num_phases,num_amps,num_bins));
MVL_more=single(zeros(num_phases,num_amps));
MA_more=single(zeros(num_phases,num_amps));
MI_less=single(zeros(num_phases,num_amps));
p_less=single(zeros(num_phases,num_amps,num_bins));
MVL_less=single(zeros(num_phases,num_amps));
MA_less=single(zeros(num_phases,num_amps));
if num_phases>num_amps
    parfor i=1:num_phases
        X_more=phase_freq_matrix(i,condition);
        X_less=phase_freq_matrix(i,~condition);
        for j=1:num_amps
            Y_more=amp_freq_matrix(j,condition);
            Y_less=amp_freq_matrix(j,~condition);
            [MI_more(i,j),p_more(i,j,:)]=modulation_index(X_more,Y_more,bins);
            [MVL_more(i,j),MA_more(i,j)]=mean_vector_length_angle(X_more,Y_more);
            [MI_less(i,j),p_less(i,j,:)]=modulation_index(X_less,Y_less,bins);
            [MVL_less(i,j),MA_less(i,j)]=mean_vector_length_angle(X_less,Y_less);
        end
    end
else
    parfor i=1:num_amps
        Y_more=amp_freq_matrix(i,condition);
        Y_less=amp_freq_matrix(i,~condition);
        for j=1:num_phases
            X_more=phase_freq_matrix(j,condition);
            X_less=phase_freq_matrix(j,~condition);
            [MI_more(j,i),p_more(j,i,:)]=modulation_index(X_more,Y_more,bins);
            [MVL_more(j,i),MA_more(j,i)]=mean_vector_length_angle(X_more,Y_more);
            [MI_less(j,i),p_less(j,i,:)]=modulation_index(X_less,Y_less,bins);
            [MVL_less(j,i),MA_less(j,i)]=mean_vector_length_angle(X_less,Y_less);
        end
    end
end
r=randperm(num_data_amp,num_perm);
MI_shuffled_more=single(zeros(size(MI_more,1),size(MI_more,2),num_perm));
p_shuffled_more=single(zeros(size(MI_more,1),size(MI_more,2),num_perm,num_bins));
MVL_shuffled_more=single(zeros(size(MI_more,1),size(MI_more,2),num_perm));
MA_shuffled_more=single(zeros(size(MI_more,1),size(MI_more,2),num_perm));
MI_shuffled_less=single(zeros(size(MI_less,1),size(MI_less,2),num_perm));
p_shuffled_less=single(zeros(size(MI_more,1),size(MI_more,2),num_perm,num_bins));
MVL_shuffled_less=single(zeros(size(MI_less,1),size(MI_less,2),num_perm));
MA_shuffled_less=single(zeros(size(MI_less,1),size(MI_less,2),num_perm));
parfor k=1:num_perm
    R=r(k);
    temp_amp=amp_freq_matrix;
    temp_amp(:,1:R)=amp_freq_matrix(:,num_data_amp-R+1:num_data_amp);
    temp_amp(:,R+1:num_data_amp)=amp_freq_matrix(:,1:num_data_amp-R);
    for i=1:num_phases
        X_more=phase_freq_matrix(i,condition);
        X_less=phase_freq_matrix(i,~condition);
        for j=1:num_amps
            Y_more=temp_amp(j,condition);
            Y_less=temp_amp(j,~condition);
            [MI_shuffled_more(i,j,k),p_shuffled_more(i,j,k,:)]=modulation_index(X_more,Y_more,bins);
            [MVL_shuffled_more(i,j,k),MA_shuffled_more(i,j,k)]=mean_vector_length_angle(X_more,Y_more);
            [MI_shuffled_less(i,j,k),p_shuffled_less(i,j,k,:)]=modulation_index(X_less,Y_less,bins);
            [MVL_shuffled_less(i,j,k),MVL_shuffled_less(i,j,k)]=mean_vector_length_angle(X_less,Y_less);
        end
    end
end
