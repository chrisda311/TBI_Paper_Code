%% Load Data
% Load & Clean Units
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'
load('Units2.mat'); umat = cell2mat(unitmat(:,1:5)); kmat = keymat(1:5); % Loads units and removes spike times
load('PyrInt_Classification_PAPER.mat'); umat(:,5) = classFinal; % Loads classification
ppkey = [24 12 28 11 25 3 29 10 27]; % Animal# to pp# key
clear keymat unitmat i
% Bad channels in ripple power plots
badChan{2} = [8 24 57]; badChan{3} = [18 64]; badChan{4} = [41 56];
badChan{6} = [35]; badChan{7} = [6 18 21 27]; badChan{8} = [10 13 15 18 41]; badChan{9} = [11 18];
% Define the center of the pyramidal cell layer for each animal on each shank
peakPyr = [12 12 16 16; 23 26 0 0; 7 12 12 13; 23 25 0 0; 8 10 10 10;...
    28 30 0 0; 7 8 11 13; 24 25 0 0; 12 15 16 16];

%% Generate plots for all 4 shank animals
ii=7;
% Get RAM CSD data
cd(['X:\Chris\R01RatPaper\DataBlocks\Animal' num2str(ii) '\Day1\RAM\CSD Analysis'])
load('Shank1_mean.mat'); s1csdram = CSD_cs_smoothed(:,[3000/2-750:3000/2+749]);
clear CSD_cs_smoothed CSD_cs parameters
load('Shank2_mean.mat'); s2csdram = CSD_cs_smoothed(:,[3000/2-750:3000/2+749]);
clear CSD_cs_smoothed CSD_cs parameters
load('Shank3_mean.mat'); s3csdram = CSD_cs_smoothed(:,[3000/2-750:3000/2+749]);
clear CSD_cs_smoothed CSD_cs parameters
load('Shank4_mean.mat'); s4csdram = CSD_cs_smoothed(:,[3000/2-750:3000/2+749]);
clear CSD_cs_smoothed CSD_cs parameters
% x values for plotting CSD
x = [1:1500]/3000; xall = [1:1500*4]/3000; xsmall = [0.5:6.6667e-04:4.5];
% figure; imagesc(x,zs*10e5,s1csd)
% figure; imagesc(xall,zs*10e5,[s1csd s2csd s3csd s4csd])
% figure; imagesc(xsmall,zs*10e5,[s1csd s2csd s3csd s4csd])

% Get RAM ripple power data
cd(['X:\Chris\R01RatPaper\DataBlocks\Animal' num2str(ii) '\Day1\RAM'])
load('SWR_cont_power.mat','channel','f_welch')
% Get welch power in phys ripple range
for i=1:64
    rippowram(i,1) = sum(channel(i).welch_power(1001:2500));
end

% For each bad channel take the mean of the surrounding channels
if ismember(1,diff(badChan{ii})) % warns you if consecutive channels are bad. Even if consecutive channels are not continous (bottom of 1 shank and top of next) - not a problem with this dataset
    error('Consecutive bad channels. Go in and manually fix')
end
if ~isempty(badChan{ii})
    for b=1:length(badChan{ii})
        if badChan{ii}(b)~=1 & badChan{ii}(b)~=16 & badChan{ii}(b)~=17 & badChan{ii}(b)~=32 & badChan{ii}(b)~=33 & badChan{ii}(b)~=48 & badChan{ii}(b)~=49 & badChan{ii}(b)~=64 % Doesn't take mean of surrounding channels if bad chan is at top or bottom of probe
            rippowram(badChan{ii}(b)) = (rippowram(badChan{ii}(b)-1) + rippowram(badChan{ii}(b)+1))/2;
        end
    end
end

% Normalizes ripple power for plotting
rippow_pltram = ((rippowram - min(rippowram)) / range(rippowram)) / 2 - 0.25;
rippow_pltram = reshape(rippow_pltram,16,4);

utemp = umat(umat(:,1) == ppkey(ii),:);
putemp = utemp(utemp(:,5) == 0,:); xscp = putemp(:,3) - 1 + 0.75 + rand(size(putemp,1),1)/2;
iutemp = utemp(utemp(:,5) == 1,:); xsci = iutemp(:,3) - 1 + 0.75 + rand(size(iutemp,1),1)/2;
uutemp = utemp(utemp(:,5) == 2,:); xscu = uutemp(:,3) - 1 + 0.75 + rand(size(uutemp,1),1)/2;

% Create Master Plot RAM
figure; 
imagesc(xsmall,zs*10e5,[s1csdram s2csdram s3csdram s4csdram]); colorbar; hold on % Plot CSDs
scatter(repmat([-0.1 0.1],1,8),[1:16]*20,100,'filled','square'); % Plot Probe Contacts
plot(rippow_pltram(:,1)+1,(1:16)*20,'m','LineWidth',3); plot(rippow_pltram(:,2)+2,(1:16)*20,'m','LineWidth',3); plot(rippow_pltram(:,3)+3,(1:16)*20,'m','LineWidth',3); plot(rippow_pltram(:,4)+4,(1:16)*20,'m','LineWidth',3); % Plot ripple power
scatter(xscp,putemp(:,4)*20,15,'v','b','filled'); scatter(xsci,iutemp(:,4)*20,15,'r','filled'); scatter(xscu,uutemp(:,4)*20,15,'square','c','filled')  % Plot pyramidal cells (blue), interneurons (red), & unsure (black)
plot([0.5 1.5],[peakPyr(ii,1)-4 peakPyr(ii,1)-4]*20,'--k'); plot([0.5 1.5],[peakPyr(ii,1)+4 peakPyr(ii,1)+4]*20,'--k'); % Marks defined pyr layer shank 1
plot([1.5 2.5],[peakPyr(ii,2)-4 peakPyr(ii,2)-4]*20,'--k'); plot([1.5 2.5],[peakPyr(ii,2)+4 peakPyr(ii,2)+4]*20,'--k'); % Marks defined pyr layer shank 2
plot([2.5 3.5],[peakPyr(ii,3)-4 peakPyr(ii,3)-4]*20,'--k'); plot([2.5 3.5],[peakPyr(ii,3)+4 peakPyr(ii,3)+4]*20,'--k'); % Marks defined pyr layer shank 3
plot([3.5 4.5],[peakPyr(ii,4)-4 peakPyr(ii,4)-4]*20,'--k'); plot([3.5 4.5],[peakPyr(ii,4)+4 peakPyr(ii,4)+4]*20,'--k'); % Marks defined pyr layer shank 4
title(['Animal' num2str(ii) ' RAM']); xlim([-0.5 5]); ylim([0 340])
% Pulls x,y coord for bad channels to plot - Can remove (comment out) if desired
if ~isempty(badChan{ii})
    for bCh=1:length(badChan{ii})
        sh = ceil(badChan{ii}(bCh)/16);
        if rem(badChan{ii}(bCh),16) ~=0 % if bad channel is bottom of shank, remainder is 0 so we need to set to bottom
            ibadChan(bCh) = rem(badChan{ii}(bCh),16);
        else
            ibadChan(bCh) = 16;
        end
        bcPlt(bCh) = rippow_pltram(ibadChan(bCh),sh) + sh;
    end
    scatter(bcPlt,ibadChan*20,'square','k')
end
clear bcPlt ibadChan

%
% end

cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'

%% Plot Ripple Frequency Power (100-250Hz)

% Shank 3 - Area Under Curve
for i=1:64
    rippowram2(i,1) = trapz(f_welch(1001:2500),channel(i).welch_power(1001:2500));
end

figure; plot(rippowram2(33:48),-[1:16])

