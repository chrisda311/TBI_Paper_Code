function [spkHeight, spkWidth] = getSpikeHeightWidth_special_ExPlot(meanSpkWavs,fs,interpFact,msbase,peakRange,Enter1ToInvert,Enter1ToPlot)

% INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% meanSpkWavs = Matrix of mean spike waveforms from multiple cells (also
%       works for a single cell). Should be Cells X Samples
% 
% fs = Sampling frequency
%
% interpFact = Interpolation factor. How much do you want to upsample the
%       mean spike waveform to determine width
%
% msbase = how far back in time from the spike peak do you want to go to
%       compute the baseline voltage for a spike. Ex. [1.5 0.5] would mean
%       that the baseline voltage for the spike is the average of all
%       points from 1.5ms before the spike peak to 0.5ms before the spike
%       peak.
%
% peakRange = What is the range in samples you want to search to find the
%       peak. This is from the original (not upsampled) waveform. Ex. [500
%       700] would search for the max between the 500th and 700th sample.
%       This is used if there is noisey background or if the spike is
%       riding an oscillation that is larger in amplitude than the spike
%       itself in the timewindow the mean spike wave is computed from
%
% Enter1ToInvert = Enter 1 here if you would like to invert the data. This
%       is expecting the spike waveform to be positive (go up)
%
% Enter1ToPlot = Entering 1 here generates plots of each spike with the
%       peak, 1/4 width, and baseline components labeled
%
%
% OUTPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spkHeight = Amplitued of the spike in whatever unit the mean spike
%       waveform was in. (peak - baseline)
%
% spkWidth = Width at the 1/4 max spike amplitude. This mavlue is in
%       miliseconds

% Converts samples to miliseconds
ms2Samp=fs/1e3;

% Inverts the spikes to be positive if necessary
if Enter1ToInvert == 1
    meanSpkWavs = meanSpkWavs*-1;
end

% For each unit
for i=1:size(meanSpkWavs,1)

    % Upsamples spike waveform by a factor of interpFact
    spkUpsamp(i,:) = interp(meanSpkWavs(i,:),interpFact);

    % Up samples the peakRange values
    prUp = peakRange*interpFact;

    % Finds peak within the specified range
    [~, pki_inR(i)] = max(spkUpsamp(i,prUp(1):prUp(2)));

    % Converts peak point to the actual point in spkUpsamp
    pki(i) = pki_inR(i) + prUp(1) - 1;
    pk = spkUpsamp(i,pki(i));

%     % Finds the peak of the spike and its instance.
%     [pk, pki(i)] = max(spkUpsamp(i,:));

    % Computes the mean voltage 1ms before the spike fired. Chosen by
    % finding the peak then taking the mean from 45 samples back (1.5ms;
    % times 5 beacuse of upsampling) to 15 samples back (0.5ms). 0.5ms
    % seemes to be enough to avoid hyperpolerization before a spike
    b1(i) = pki(i)-msbase(1)*ms2Samp*interpFact; b2(i) = pki(i)-msbase(2)*ms2Samp*interpFact;
    base(i) = mean(spkUpsamp(i,b1(i):b2(i)));

    % Computes the spike height and the quarter spike height (which is used
    % to calaculate the spike width)
    spkHeight(i,:) = pk - base(i); quartspkheight(i) = spkHeight(i,:) * 0.25;

%     % Finds the instance where the waveform is closest to the value of
%     % baseline plus the quarter spike height. This is done separately for
%     % points before the peak and points after the peak since we need the
%     % time between these 2 points. 
%     [~,widthStr(i)] = min(abs((base(i)+quartspkheight(i)) - spkUpsamp(i,1:pki(i)))); % These steps need to be improved to make sure they only select the actual spike
%     [~,widthEnd(i)] = min(abs((base(i)+quartspkheight(i)) - spkUpsamp(i,pki(i):end))); % These steps need to be improved to make sure they only select the actual spike
%     widthEnd(i) = widthEnd(i) + (pki(i)-1);
    
    % This starts at the instance of the spike peak and works BACKWARDS in
    % time until the value drops below baseline.
    widthStr(i) = pki(i);
    while spkUpsamp(i,widthStr(i)) - (base(i)+quartspkheight(i)) > 0
        widthStr(i) = widthStr(i)-1;
    end
    % Then this determines whether the point just below baseline or the
    % point just above baseline is closer to the baseline value.
    if abs(spkUpsamp(i,widthStr(i)) - (base(i)+quartspkheight(i))) > abs(spkUpsamp(i,widthStr(i)+1) - (base(i)+quartspkheight(i)))
        widthStr(i) = widthStr(i) + 1;
    end

    % This starts at the instance of the spike peak and works FORWARDS in
    % time until the value drops below baseline.
    widthEnd(i) = pki(i);
    while spkUpsamp(i,widthEnd(i)) - (base(i)+quartspkheight(i)) > 0
        widthEnd(i) = widthEnd(i)+1;
    end
    % Then this determines whether the point just below baseline or the
    % point just above baseline is closer to the baseline value.
    if abs(spkUpsamp(i,widthEnd(i)) - (base(i)+quartspkheight(i))) > abs(spkUpsamp(i,widthEnd(i)-1) - (base(i)+quartspkheight(i)))
        widthEnd(i) = widthEnd(i) - 1;
    end

    % Computes the spike width and divides by 150 to convert back to ms (30
    % samples for 1ms times 5 because we upsampled by 5 at the beginning)
    spkWidth(i,:) = (widthEnd(i) - widthStr(i)) / (ms2Samp*interpFact);
end


% Plots if desired
if Enter1ToPlot == 1
    
    % Plots all the spikes with a red * at the quarter max height, a green
    % triangle at the peak, and blue Xs marking the 1ms start and stop
    % points used for averaging to obtain a baseline value
    ppfig = 1; % number of plots per figure
    sc = 1e6; % Scaling factor to put into microvolts
    for f=1:ceil(size(spkUpsamp,1)/ppfig^2)
        figure;
        for ii=1:ppfig^2
            if ((f-1) * ppfig^2 + ii) <= size(spkUpsamp,1)
                subplot(ppfig,ppfig,ii);
                plot([1:size(spkUpsamp,2)]/(ms2Samp*interpFact),(spkUpsamp((f-1) * ppfig^2 + ii,:)-base((f-1) * ppfig^2 + ii))*sc,'k'); hold on;
                scatter(pki((f-1) * ppfig^2 + ii)/(ms2Samp*interpFact),(spkUpsamp((f-1) * ppfig^2 + ii,pki((f-1) * ppfig^2 + ii))-base((f-1) * ppfig^2 + ii))*sc,'v','g')
                scatter(b1((f-1) * ppfig^2 + ii)/(ms2Samp*interpFact),(spkUpsamp((f-1) * ppfig^2 + ii,b1((f-1) * ppfig^2 + ii))-base((f-1) * ppfig^2 + ii))*sc,'x','c');
                scatter(b2((f-1) * ppfig^2 + ii)/(ms2Samp*interpFact),(spkUpsamp((f-1) * ppfig^2 + ii,b2((f-1) * ppfig^2 + ii))-base((f-1) * ppfig^2 + ii))*sc,'x','c');
                scatter(widthStr((f-1) * ppfig^2 + ii)/(ms2Samp*interpFact),(spkUpsamp((f-1) * ppfig^2 + ii,widthStr((f-1) * ppfig^2 + ii))-base((f-1) * ppfig^2 + ii))*sc,'*','r')
                scatter(widthEnd((f-1) * ppfig^2 + ii)/(ms2Samp*interpFact),(spkUpsamp((f-1) * ppfig^2 + ii,widthEnd((f-1) * ppfig^2 + ii))-base((f-1) * ppfig^2 + ii))*sc,'*','r')
            end
        end
    end
xlim([18 23])
end


end
