%% Load Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'
% load('FINAL_Classification_PyrInt.mat'); % load('DistanceFromPyr_FINAL.mat'); classFinal(DisFrPyr(:,2) > 80) = 2;
load('PyrInt_Classification_PAPER.mat')
load('SpikeClassParams_V1.mat'); % Firing rate used here is from whichever env it was maximal in
load('CellsInPyrLayer.mat', 'inPyrLay')
load('DistanceFromPyr_FINAL.mat')
load('Units2.mat'); umat = cell2mat(unitmat(:,1:5)); keymat = keymat(1:5); clear unitmat

%% Remove Animal with Electrode Drift
classFinal = classFinal(umat(:,1) ~= 24,:);
inPyrLay = inPyrLay(umat(:,1) ~= 24,:);
sortParam = sortParam(umat(:,1) ~= 24,:);
DisFrPyr = DisFrPyr(umat(:,1) ~= 24,:);
umat = umat(umat(:,1) ~= 24,:); % This needs to be last

%%
% OR THIS WAY
all_inp = sortParam(inPyrLay,:);
all_outp = sortParam(~inPyrLay & (DisFrPyr(:,2) < 99),:); % Excludes 3 cells below the pyr layer
% Plot Both
figure;
subplot(2,2,1); scatter3(all_inp(:,2),all_inp(:,3),all_inp(:,1),15,'filled','k'); hold on
scatter3(all_outp(:,2),all_outp(:,3),all_outp(:,1),15,'filled','r')
xlabel('1st Moment of AC (ms)'); ylabel('Spike Width (ms)'); zlabel('Firing Rate (Hz)')
xlim([10 40]); ylim([0 1]); zlim([0 60])
subplot(2,2,2); scatter(all_inp(:,2),all_inp(:,3),15,'filled','k'); hold on
subplot(2,2,2); scatter(all_outp(:,2),all_outp(:,3),15,'filled','r');
xlabel('1st Moment of AC (ms)'); ylabel('Spike Width (ms)')
xlim([10 40]); ylim([0 1]);
subplot(2,2,3); scatter(all_inp(:,2),all_inp(:,1),15,'filled','k'); hold on
subplot(2,2,3); scatter(all_outp(:,2),all_outp(:,1),15,'filled','r');
xlabel('1st Moment of AC (ms)'); ylabel('Firing Rate (Hz)')
xlim([10 40]); ylim([0 60]);
subplot(2,2,4); scatter(all_inp(:,3),all_inp(:,1),15,'filled','k'); hold on
subplot(2,2,4); scatter(all_outp(:,3),all_outp(:,1),15,'filled','r');
xlabel('Spike Width (ms)'); ylabel('Firing Rate (Hz)')
