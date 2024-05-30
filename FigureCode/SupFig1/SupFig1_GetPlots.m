%% Manual Clustering
% Load Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'
load('PyrInt_Classification_PAPER.mat') % 0=Pyr 1=Int 2=NotSure
load('SpikeClassParams_V1.mat'); % Firing rate used here is from whichever env it was maximal in
load('CellsInPyrLayer.mat', 'inPyrLay')
load('DistanceFromPyr_FINAL.mat')
load('Units2.mat'); umat = cell2mat(unitmat(:,1:5)); keymat = keymat(1:5); clear unitmat

% Remove Animal with Electrode Drift
classFinal = classFinal(umat(:,1) ~= 24,:);
inPyrLay = inPyrLay(umat(:,1) ~= 24,:);
sortParam = sortParam(umat(:,1) ~= 24,:);
DisFrPyr = DisFrPyr(umat(:,1) ~= 24,:);
umat = umat(umat(:,1) ~= 24,:); % This needs to be last

% All Cells
pyr_fin = sortParam(classFinal==0,:);
int_fin = sortParam(classFinal==1,:);
uns_fin = sortParam(classFinal==2,:);

% Sham and Injured
s_pyr_fin = sortParam((classFinal==0 & umat(:,2)==0),:); i_pyr_fin = sortParam((classFinal==0 & umat(:,2)==1),:);
s_int_fin = sortParam((classFinal==1 & umat(:,2)==0),:); i_int_fin = sortParam((classFinal==1 & umat(:,2)==1),:);
s_uns_fin = sortParam((classFinal==2 & umat(:,2)==0),:); i_uns_fin = sortParam((classFinal==2 & umat(:,2)==1),:);

% ONLY CELLS IN PYR LAYER
all_inp = sortParam(inPyrLay,:);

% All Cells
pyr_fin_ip = sortParam(classFinal==0 & inPyrLay,:);
int_fin_ip = sortParam(classFinal==1 & inPyrLay,:);
uns_fin_ip = sortParam(classFinal==2 & inPyrLay,:);

% PLOT
figure;
subplot(2,2,1); 
scatter3(pyr_fin_ip(:,2),pyr_fin_ip(:,3),pyr_fin_ip(:,1),15,'filled','b'); hold on
scatter3(int_fin_ip(:,2),int_fin_ip(:,3),int_fin_ip(:,1),15,'filled','r')
scatter3(uns_fin_ip(:,2),uns_fin_ip(:,3),uns_fin_ip(:,1),15,'filled','c')
xlabel('1st Moment of AC (ms)'); ylabel('Spike Width (ms)'); zlabel('Firing Rate (Hz)'); title('Manual Pyr')
xlim([10 40]); ylim([0 1]); zlim([0 60]); zticks([0:20:60])
subplot(2,2,2); scatter(pyr_fin_ip(:,2),pyr_fin_ip(:,3),15,'filled','b'); hold on
scatter(int_fin_ip(:,2),int_fin_ip(:,3),15,'filled','r')
scatter(uns_fin_ip(:,2),uns_fin_ip(:,3),15,'filled','c')
xlabel('1st Moment of AC (ms)'); ylabel('Spike Width (ms)')
xlim([10 40]); ylim([0 1]);
subplot(2,2,3); scatter(pyr_fin_ip(:,2),pyr_fin_ip(:,1),15,'filled','b'); hold on
scatter(int_fin_ip(:,2),int_fin_ip(:,1),15,'filled','r')
scatter(uns_fin_ip(:,2),uns_fin_ip(:,1),15,'filled','c')
xlabel('1st Moment of AC (ms)'); ylabel('Firing Rate (Hz)')
xlim([10 40]); ylim([0 60]);
subplot(2,2,4); scatter(pyr_fin_ip(:,3),pyr_fin_ip(:,1),15,'filled','b'); hold on
scatter(int_fin_ip(:,3),int_fin_ip(:,1),15,'filled','r')
scatter(uns_fin_ip(:,3),uns_fin_ip(:,1),15,'filled','c')
xlabel('Spike Width (ms)'); ylabel('Firing Rate (Hz)')
xlim([0 1]); ylim([0 60]);

%% BREAK
clear
clc

%% Auto Clustering
% Load Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'
load('PyrInt_Classification_PAPER.mat') % 0=Pyr 1=Int 2=NotSure
load('SpikeClassParams_V1.mat'); % Firing rate used here is from whichever env it was maximal in
load('CellsInPyrLayer.mat', 'inPyrLay')
load('Units2.mat'); umat = cell2mat(unitmat(:,1:5)); keymat = keymat(1:5); clear unitmat

% Remove Animal with Electrode Drift
classFinal = classFinal(umat(:,1) ~= 24,:);
inPyrLay = inPyrLay(umat(:,1) ~= 24,:);
sortParam = sortParam(umat(:,1) ~= 24,:);
umat = umat(umat(:,1) ~= 24,:); % This needs to be last


% ONLY CELLS IN THE PYRAMIDAL CELL LAYER
sortParam_pyrLayer = sortParam(inPyrLay,:);
% Normalize features
sortParam_normPyr = (sortParam_pyrLayer - min(sortParam_pyrLayer)) ./ range(sortParam_pyrLayer);


% K means consensus clustering - ONLY CELLS IN THE PYRAMIDAL CELL LAYER
load('ConsensusClustAllPyr_PAPER.mat')

% Plot Data from Consensus Clusters All Pyr
% Creates scatter plots based on consensus clustering
sortPerm_pyrC_pLayer = sortParam_pyrLayer(cCon_PyrLayer==0,:); sortPerm_intC_pLayer = sortParam_pyrLayer(cCon_PyrLayer==1,:);
nsortPerm_pyrC_pLayer = sortParam_normPyr(cCon_PyrLayer==0,:); nsortPerm_intC_pLayer = sortParam_normPyr(cCon_PyrLayer==1,:);

% PLOT
figure;
subplot(2,2,1); 
scatter3(sortPerm_pyrC_pLayer(:,2),sortPerm_pyrC_pLayer(:,3),sortPerm_pyrC_pLayer(:,1),15,'filled','b'); hold on
scatter3(sortPerm_intC_pLayer(:,2),sortPerm_intC_pLayer(:,3),sortPerm_intC_pLayer(:,1),15,'filled','r');
xlabel('1st Moment of AC (ms)'); ylabel('Spike Width (ms)'); zlabel('Firing Rate (Hz)'); title ('K-Means Pyr')
xlim([10 40]); ylim([0 1]); zlim([0 60]); zticks([0:20:60])
subplot(2,2,2);
scatter(sortPerm_pyrC_pLayer(:,2),sortPerm_pyrC_pLayer(:,3),15,'filled','b'); hold on
scatter(sortPerm_intC_pLayer(:,2),sortPerm_intC_pLayer(:,3),15,'filled','r')
xlabel('1st Moment of AC (ms)'); ylabel('Spike Width (ms)')
xlim([10 40]); ylim([0 1]);
subplot(2,2,3); scatter(sortPerm_pyrC_pLayer(:,2),sortPerm_pyrC_pLayer(:,1),15,'filled','b'); hold on
scatter(sortPerm_intC_pLayer(:,2),sortPerm_intC_pLayer(:,1),15,'filled','r')
xlabel('1st Moment of AC (ms)'); ylabel('Firing Rate (Hz)')
xlim([10 40]); ylim([0 60]);
subplot(2,2,4); scatter(sortPerm_pyrC_pLayer(:,3),sortPerm_pyrC_pLayer(:,1),15,'filled','b'); hold on
scatter(sortPerm_intC_pLayer(:,3),sortPerm_intC_pLayer(:,1),15,'filled','r')
xlabel('Spike Width (ms)'); ylabel('Firing Rate (Hz)')
xlim([0 1]); ylim([0 60]);

%% See overlap of my clustering with k-means
asdf = classFinal(inPyrLay);
pOverlapAllPyr = sum(asdf(asdf~=2) == cCon_PyrLayer(asdf~=2)) / length(asdf(asdf~=2))

