%% Get Ripple CSD for Power Fig
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Animal5\Day3\OF\CSD Analysis'
load('Shank2_mean.mat')

%% Plot
figure; imagesc(CSD_cs_smoothed(:,1500-149:1500+150))
c = linspace(0,200,17) + mean(diff(linspace(0,200,17))) / 2;
yticks(c(1:end-1))
