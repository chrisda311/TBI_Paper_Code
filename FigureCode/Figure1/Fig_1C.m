%% Load Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Animal7\Day1\RAM'
load('SWR_Centered_1_second.mat'); 
cd('CSD Analysis')
load('Shank3_mean.mat', 'CSD_cs_smoothed', 'zs')
meanRipSham = mean(SWR,3); CSD_Sham = CSD_cs_smoothed;

%% Plot Data

% Creates 300ms time vector
xdata=[1:900]/3;

% Y axis of CSD is in mm
% Y axis of traces is in mV

figure;
subplot(1,2,2); imagesc(xdata,zs*1000,CSD_Sham(:,1051:1950)); yticks(fliplr([02:-0.02:-0.34]))

data = meanRipSham(33:48,1051:1950)*1000;
offset=0.2;
subplot(1,2,1)
for i=1:size(data,1)
    plot(xdata,data(i,:)-(i-1)*offset,'b');
    hold on;
end
ylim([-4 0.5]); xlabel('Time (ms)'); ylabel('Voltage (mV)')
