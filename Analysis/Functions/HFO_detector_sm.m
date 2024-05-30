% This is the main function to detect HFOs
% https://github.com/WolfLabPenn/HFO-Detector
function [results,results_map]=HFO_detector_sm(signal,parameters)
% signal (N_channels,data_points): signal containing potential HFOs
% parameters of the detector
signal=single(signal); % converting to single for faster operation (necessary for gpu)
fs=parameters.fs; % sampling frequency
L=size(signal,2); % length of the signal
time=0:L-1;
time=time/fs; % creating time vector based on the length of the signal and fs
time=single(time);
%%
temp=mod(L,parameters.chunks); % making sure the user knows some data might be discarded.
% I can run the HFO detector for what remains but that does not make sense!
if temp~=0
    warning('%.0f data points are discarded because mod(L,chunk)~=0',temp);
end
l_chuncks=floor(L/parameters.chunks); % length of each data chunk
%
first=true;
for channel=parameters.channels % looping through the channels
    for chunk=1:parameters.chunks % looping through data chunks
        current_inds= (chunk-1)*l_chuncks+1:chunk*l_chuncks; % picking up the indices of the current chunk
        if parameters.verbose
            fprintf('Channel %.0f, chunk %.0f\n',channel,chunk); % displaying where we are if verbose is true.
        end
        %
        data=signal(channel,current_inds); % picking up the current data to process
        current_time=time(current_inds); % picking up current time
        if parameters.gpu==true
            data=gpuArray(data); % creating gpu array if chosen by the user
        end
        if first==true % is this the first time we are going through the data? We only need to create the filter bank once!
            first=false; % not anymore!
            % creating the filter bank for cwt analysis
            if strcmp(parameters.wavelet,'morse')
                fb = cwtfilterbank(SignalLength=length(data),SamplingFrequency=fs,Wavelet=parameters.wavelet,WaveletParameters=parameters.WaveletParameters,VoicesPerOctave=parameters.VoicesPerOctave,FrequencyLimits=parameters.FrequencyLimits);
            else
                fb = cwtfilterbank(SignalLength=length(data),SamplingFrequency=fs,Wavelet=parameters.wavelet,VoicesPerOctave=parameters.VoicesPerOctave,FrequencyLimits=parameters.FrequencyLimits);
            end
        end
        [B,f] = cwt(data,FilterBank=fb); % performing cwt analysis
        if parameters.gpu==true % sending the data back to cpu if we are doing gpu calculation
            B=gather(B);
            f=gather(f);
        end
        z=abs(B); % finding the magnitude.
        clear B; % clean up some big array
        f=f';
        %
        mean_magnitude=mean(z,2)'; % calculating mean of magnitude for the whole signal.
        if strcmp(parameters.compare,'power')
            z=z.^2; % getting read of z itself if it is chosen to use power for comparison
            mean_power=mean(z,2)'; % calculating mean of power for the whole signal.
        else
            temp=z.^2;
            mean_power=mean(temp,2)';
            clear temp;
        end

        results.channel(channel,chunk).mean_magnitude=mean_magnitude; % saving mean magnitude in the resutls
        results.channel(channel,chunk).mean_power=mean_power; % saving mean power in the results.

        log_z=log(z);
        log_mean=mean(log_z,2)';
        log_std=std(log_z,0,2)';


        rng(1); % setting rng for reproducibility

        mu_th=zeros(length(f),1);

        for i_r=1:size(parameters.range,1)
            cutoff=(f>=parameters.range(i_r,1)).*(f<=parameters.range(i_r,2));
            cutoff=logical(cutoff);
            test=z(cutoff,:); % cutting off data
            r=randi(size(test,1)*size(test,2),floor(size(z,2)/5),1);% picking up 5% of the data for ecdf creation.
            [yy,xx]=ecdf(double(test(r))); % constructing ecdf. I convert the data back to double here because I have seen issues if I use signle here.
            [~,im]=min(abs(yy-parameters.ecdf(i_r))); % find where we are crossing threshold
            mu_th(cutoff)=xx(im);
        end
        mu_th=smoothdata(mu_th,'gaussian',parameters.smoothing_window);

        cutoff=(f>=parameters.range(1,1)).*(f<=parameters.range(end,2));
        cutoff=logical(cutoff);
        mu_th=mu_th(cutoff);
        z_th=z(cutoff,:);
        z_th(z_th<mu_th)=0;
        f_cut=f(cutoff); % frequency range for the cutoff
        CC = bwconncomp(z_th,4); % finding connected blobs.
        [events_R,TF_R,merge,artifacts_R.frequency_range,artifacts_R.amplitude]=clean_results_sm(CC,f,z,f_cut,current_time,log_mean,log_std,parameters.compare,parameters.center,parameters,parameters.save_map);
        results.channel(channel,chunk).events=events_R; % saving resutls
        results.channel(channel,chunk).merge=merge; % saving resutls
        results.channel(channel,chunk).artifacts=artifacts_R; % saving events that are potentialy artifacts
        results_map.channel(channel,chunk).TF=TF_R;
        results_map.channel(channel,chunk).th=mu_th;
        %%
    end
    %%
    results.data_length=length(data);
    results.frequency=f; % saving the frequncies of the filter bank
    results.parameters=parameters; % saving the parameters in the results to make sure that we know what parameters were used.

    results_map.data_length=length(data);
    results_map.frequency=f; % saving the frequncies of the filter bank
    results_map.parameters=parameters; % saving the parameters in the results to make sure that we know what parameters were used.
end