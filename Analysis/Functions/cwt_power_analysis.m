function channel=cwt_power_analysis(signal,fs,velocity,velocity_threshold)
fb = cwtfilterbank('SignalLength',length(signal),'SamplingFrequency',fs,'FrequencyLimits',[1,fs/2],'Wavelet','bump','VoicesPerOctave',36); % Only need to create the filterbank for cwt analysis once
for n=1:size(signal,1)% Looping through all channels
    current_signal=signal(n,:);
    [wt,~,~] = cwt(current_signal,'FilterBank',fb); %cwt analysis
    z=abs(wt);
    z_p=z.^2;
    inds=velocity>=velocity_threshold; % Picking up indices in which velocity crosses the threshold
    % Calculating metrics when animal is moving faster than the threshold
    mean_magnitude=mean(z(:,inds),2);
    mean_power=mean(z_p(:,inds),2);
    power_scale=var(current_signal(inds))/sum(mean_power);
    channel(n).power_more=mean_power;
    channel(n).magnitude_more=mean_magnitude;
    channel(n).power_scale_more=power_scale;
    % Calculating metrics when animal is moving slower than the threshold
    inds=~inds;
    mean_magnitude=mean(z(:,inds),2);
    mean_power=mean(z_p(:,inds),2);
    power_scale=var(current_signal(inds))/sum(mean_power);
    channel(n).power_less=mean_power;
    channel(n).magnitude_less=mean_magnitude;
    channel(n).power_scale_less=power_scale;
end