%% Add path
% Only need cDist fxn here
addpath(genpath('\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'))

%% Get Data
% Load & Clean Units
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'
load('Units2.mat'); umat = cell2mat(unitmat(:,1:4)); keymat = keymat(1:4); clear unitmat % Loads units and removes unnecessary data
load('FiringRatesFINAL.mat', 'fr_all') % Load Firing Rates
load('PyrInt_Classification_PAPER.mat') % Load Pyr/Int Classification
% Go to directory with data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units\Entrainment Analysis\Theta_5_10'
load('Unit1_Channel28_OF.mat', 'franges', 'ed20', 'velocity_threshold') % Get frequency ranges used for entrainment along with MI bin edges and velocity threshold
load('ThetaEnt_stPyr.mat')
f = mean(franges); % mean of filter freq ranges used for plotting

%% Remove Animal with Electrode Drift
classFinal = classFinal(umat(:,1) ~= 24,:);
fr_all = fr_all(umat(:,1) ~= 24,:);
thetaEntOF = thetaEntOF(umat(:,1) ~= 24,:);
thetaEntRAM = thetaEntRAM(umat(:,1) ~= 24,:);
umat = umat(umat(:,1) ~= 24,:); % Needs to be last

%% Pull out cells above 0.1Hz FR threshold (env specific)
% Pulls entrainment from cells above 0.1Hz FR threshold in each env
% independently.
thetaEntOF = thetaEntOF(fr_all(:,1) >= 0.1,:);
thetaEntRAM = thetaEntRAM(fr_all(:,2) >= 0.1,:);

% Because different cells are indexed for each env due to FR threshold
% being independently applied to each env, this keeps the meta data for
% each cell in each env.
classFinal_OF = classFinal(fr_all(:,1) >= 0.1,:); classFinal_RAM = classFinal(fr_all(:,2) >= 0.1,:); % Cell classification
umat_OF = umat(fr_all(:,1) >= 0.1,:); umat_RAM = umat(fr_all(:,2) >= 0.1,:); % Sham vs Inj and Animal ID
fr_OF = fr_all(fr_all(:,1) >= 0.1,1); fr_RAM = fr_all(fr_all(:,2) >= 0.1,2); % Firing Rate

%% Extract cells that meet min number of spikes in each the moving and still condition
% Get number of spikes for each condition (still vs moving) in each env
% OF
for i=1:size(thetaEntOF,1)
    nSpks_OF(i,1) = sum(thetaEntOF{i,15});
    nSpks_OF(i,2) = sum(thetaEntOF{i,17});
end
% RAM
for i=1:size(thetaEntRAM,1)
    nSpks_RAM(i,1) = sum(thetaEntRAM{i,15});
    nSpks_RAM(i,2) = sum(thetaEntRAM{i,17});
end
% Determine how many units would get dropped with a min num of spikes
nSpks_minThresh = 25;
nDroppedUnits_OF = sum(nSpks_OF < nSpks_minThresh | isnan(nSpks_OF))
nDroppedUnits_RAM = sum(nSpks_RAM < nSpks_minThresh | isnan(nSpks_RAM))

% Indexes cells that meet min nSpks in BOTH moving & still conditions. NaNs
% removed by doing this too (NaN ~>= 25)
temp = nSpks_OF >= nSpks_minThresh; abvnSpkTh_OF = temp(:,1) & temp(:,2); sum(abvnSpkTh_OF)
temp = nSpks_RAM >= nSpks_minThresh; abvnSpkTh_RAM = temp(:,1) & temp(:,2); sum(abvnSpkTh_RAM)
clear temp

% Remove cells that don't meet the nSpks_minThresh (env specific)
thetaEntOF = thetaEntOF(abvnSpkTh_OF,:); thetaEntRAM = thetaEntRAM(abvnSpkTh_RAM,:);

% Because different cells are indexed for each env due to FR threshold
% being independently applied to each env, this keeps the meta data for
% each cell in each env.
classFinal_OF = classFinal_OF(abvnSpkTh_OF,:); classFinal_RAM = classFinal_RAM(abvnSpkTh_RAM,:); % Cell classification
umat_OF = umat_OF(abvnSpkTh_OF,:); umat_RAM = umat_RAM(abvnSpkTh_RAM,:); % Sham vs Inj and Animal ID
fr_OF = fr_OF(abvnSpkTh_OF,1); fr_RAM = fr_RAM(abvnSpkTh_RAM,1); % Firing Rate

%% Break down entrainment by Sham/Inj, Pyr/Int, & Fam/Nov
% Indexes for OF
iShPyrOF = umat_OF(:,2) == 0 & classFinal_OF(:,1) == 0;
iShIntOF = umat_OF(:,2) == 0 & classFinal_OF(:,1) == 1;
iInjPyrOF = umat_OF(:,2) == 1 & classFinal_OF(:,1) == 0;
iInjIntOF = umat_OF(:,2) == 1 & classFinal_OF(:,1) == 1;
% Indexes for RAM
iShPyrRAM = umat_RAM(:,2) == 0 & classFinal_RAM(:,1) == 0;
iShIntRAM = umat_RAM(:,2) == 0 & classFinal_RAM(:,1) == 1;
iInjPyrRAM = umat_RAM(:,2) == 1 & classFinal_RAM(:,1) == 0;
iInjIntRAM = umat_RAM(:,2) == 1 & classFinal_RAM(:,1) == 1;

% Key for cell matrices below
% Ent_KEY
% OF - PyrOnShank
EntPyrSh_OF_ShPyr = thetaEntOF(iShPyrOF,:);
EntPyrSh_OF_ShInt = thetaEntOF(iShIntOF,:);
EntPyrSh_OF_InjPyr = thetaEntOF(iInjPyrOF,:);
EntPyrSh_OF_InjInt = thetaEntOF(iInjIntOF,:);
% RAM - PyrOnShank
EntPyrSh_RAM_ShPyr = thetaEntRAM(iShPyrRAM,:);
EntPyrSh_RAM_ShInt = thetaEntRAM(iShIntRAM,:);
EntPyrSh_RAM_InjPyr = thetaEntRAM(iInjPyrRAM,:);
EntPyrSh_RAM_InjInt = thetaEntRAM(iInjIntRAM,:);

%% Mean Angle - ONLY SIG ENT CELLS
% Mean Angle - Significant cells only
% mAng_less
mAng_less_sig = {cell2mat(EntPyrSh_OF_ShPyr(cell2mat(EntPyrSh_OF_ShPyr(:,3))<=0.05,4)) cell2mat(EntPyrSh_RAM_ShPyr(cell2mat(EntPyrSh_RAM_ShPyr(:,3))<=0.05,4)) cell2mat(EntPyrSh_OF_InjPyr(cell2mat(EntPyrSh_OF_InjPyr(:,3))<=0.05,4)) cell2mat(EntPyrSh_RAM_InjPyr(cell2mat(EntPyrSh_RAM_InjPyr(:,3))<=0.05,4))...
    cell2mat(EntPyrSh_OF_ShInt(cell2mat(EntPyrSh_OF_ShInt(:,3))<=0.05,4)) cell2mat(EntPyrSh_RAM_ShInt(cell2mat(EntPyrSh_RAM_ShInt(:,3))<=0.05,4)) cell2mat(EntPyrSh_OF_InjInt(cell2mat(EntPyrSh_OF_InjInt(:,3))<=0.05,4)) cell2mat(EntPyrSh_RAM_InjInt(cell2mat(EntPyrSh_RAM_InjInt(:,3))<=0.05,4))};
% mAng_more
mAng_more_sig = {cell2mat(EntPyrSh_OF_ShPyr(cell2mat(EntPyrSh_OF_ShPyr(:,7))<=0.05,8)) cell2mat(EntPyrSh_RAM_ShPyr(cell2mat(EntPyrSh_RAM_ShPyr(:,7))<=0.05,8)) cell2mat(EntPyrSh_OF_InjPyr(cell2mat(EntPyrSh_OF_InjPyr(:,7))<=0.05,8)) cell2mat(EntPyrSh_RAM_InjPyr(cell2mat(EntPyrSh_RAM_InjPyr(:,7))<=0.05,8))...
    cell2mat(EntPyrSh_OF_ShInt(cell2mat(EntPyrSh_OF_ShInt(:,7))<=0.05,8)) cell2mat(EntPyrSh_RAM_ShInt(cell2mat(EntPyrSh_RAM_ShInt(:,7))<=0.05,8)) cell2mat(EntPyrSh_OF_InjInt(cell2mat(EntPyrSh_OF_InjInt(:,7))<=0.05,8)) cell2mat(EntPyrSh_RAM_InjInt(cell2mat(EntPyrSh_RAM_InjInt(:,7))<=0.05,8))};

%% PLOT - Mean Angle - ONLY SIG ENT CELLS
% Plot
figure;
subplot(2,2,1); polarhistogram(mAng_more_sig{1},ed20,'Normalization','probability'); hold on; polarhistogram(mAng_more_sig{3},ed20,'Normalization','probability'); title('Pyr OF Sig Moving'); rlim([0 0.3])
polarplot([0 circ_mean(mAng_more_sig{1})],[0 circ_r(mAng_more_sig{1})]*0.3,'c','LineWidth',3); polarplot([0 circ_mean(mAng_more_sig{3})],[0 circ_r(mAng_more_sig{3})]*0.3,'m','LineWidth',3)
subplot(2,2,2); polarhistogram(mAng_more_sig{2},ed20,'Normalization','probability'); hold on; polarhistogram(mAng_more_sig{4},ed20,'Normalization','probability'); title('Pyr RAM Sig Moving'); rlim([0 0.3])
polarplot([0 circ_mean(mAng_more_sig{2})],[0 circ_r(mAng_more_sig{2})]*0.3,'c','LineWidth',3); polarplot([0 circ_mean(mAng_more_sig{4})],[0 circ_r(mAng_more_sig{4})]*0.3,'m','LineWidth',3)
subplot(2,2,3); polarhistogram(mAng_more_sig{5},ed20,'Normalization','probability'); hold on; polarhistogram(mAng_more_sig{7},ed20,'Normalization','probability'); title('Int OF Sig Moving'); rlim([0 0.3])
polarplot([0 circ_mean(mAng_more_sig{5})],[0 circ_r(mAng_more_sig{5})]*0.3,'c','LineWidth',3); polarplot([0 circ_mean(mAng_more_sig{7})],[0 circ_r(mAng_more_sig{7})]*0.3,'m','LineWidth',3)
subplot(2,2,4); polarhistogram(mAng_more_sig{6},ed20,'Normalization','probability'); hold on; polarhistogram(mAng_more_sig{8},ed20,'Normalization','probability'); title('Int RAM Sig Moving'); rlim([0 0.3])
polarplot([0 circ_mean(mAng_more_sig{6})],[0 circ_r(mAng_more_sig{6})]*0.3,'c','LineWidth',3); polarplot([0 circ_mean(mAng_more_sig{8})],[0 circ_r(mAng_more_sig{8})]*0.3,'m','LineWidth',3)

%% Choose what you want to look at - ADD SIG TO THIS PART %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Based on Ent_KEY: 1=MVL_less 5=MVL_more 9=MI_less 12=MI_more
mStatLabels = {'ShPyOF' 'ShPyRAM' 'InjPyOF' 'InjPyRAM' 'ShIntOF' 'ShIntRAM' 'InjIntOF' 'InjIntRAM'};

% Significant cells only
% MVL_less
temp_MVL_less_sig = {cell2mat(EntPyrSh_OF_ShPyr(cell2mat(EntPyrSh_OF_ShPyr(:,3))<=0.05,1)) cell2mat(EntPyrSh_RAM_ShPyr(cell2mat(EntPyrSh_RAM_ShPyr(:,3))<=0.05,1)) cell2mat(EntPyrSh_OF_InjPyr(cell2mat(EntPyrSh_OF_InjPyr(:,3))<=0.05,1)) cell2mat(EntPyrSh_RAM_InjPyr(cell2mat(EntPyrSh_RAM_InjPyr(:,3))<=0.05,1))...
    cell2mat(EntPyrSh_OF_ShInt(cell2mat(EntPyrSh_OF_ShInt(:,3))<=0.05,1)) cell2mat(EntPyrSh_RAM_ShInt(cell2mat(EntPyrSh_RAM_ShInt(:,3))<=0.05,1)) cell2mat(EntPyrSh_OF_InjInt(cell2mat(EntPyrSh_OF_InjInt(:,3))<=0.05,1)) cell2mat(EntPyrSh_RAM_InjInt(cell2mat(EntPyrSh_RAM_InjInt(:,3))<=0.05,1))};
% MVL_more
temp_MVL_more_sig = {cell2mat(EntPyrSh_OF_ShPyr(cell2mat(EntPyrSh_OF_ShPyr(:,7))<=0.05,5)) cell2mat(EntPyrSh_RAM_ShPyr(cell2mat(EntPyrSh_RAM_ShPyr(:,7))<=0.05,5)) cell2mat(EntPyrSh_OF_InjPyr(cell2mat(EntPyrSh_OF_InjPyr(:,7))<=0.05,5)) cell2mat(EntPyrSh_RAM_InjPyr(cell2mat(EntPyrSh_RAM_InjPyr(:,7))<=0.05,5))...
    cell2mat(EntPyrSh_OF_ShInt(cell2mat(EntPyrSh_OF_ShInt(:,7))<=0.05,5)) cell2mat(EntPyrSh_RAM_ShInt(cell2mat(EntPyrSh_RAM_ShInt(:,7))<=0.05,5)) cell2mat(EntPyrSh_OF_InjInt(cell2mat(EntPyrSh_OF_InjInt(:,7))<=0.05,5)) cell2mat(EntPyrSh_RAM_InjInt(cell2mat(EntPyrSh_RAM_InjInt(:,7))<=0.05,5))};

%% Plot Theta Entrainment - CumulativeDist
% Create Edges for Cumulative Distributions
edMVL = [0:0.0005:0.6];
% Just for reference:
% {'ShPyOF' 'ShPyRAM' 'InjPyOF' 'InjPyRAM' 'ShIntOF' 'ShIntRAM' 'InjIntOF' 'InjIntRAM'};
for i=1:8
    % SIG ONLY
    cd_MVL_less_sig(:,i) = cDist(temp_MVL_less_sig{i},edMVL);
    cd_MVL_more_sig(:,i) = cDist(temp_MVL_more_sig{i},edMVL);
end

% Plot Cumulitive Distributions - SIG ENT CELLS ONLY
figure;
subplot(2,1,1)
plot(edMVL(2:end),cd_MVL_less_sig(:,1),'-b','LineWidth',1); hold on
plot(edMVL(2:end),cd_MVL_less_sig(:,2),':b','LineWidth',1)
plot(edMVL(2:end),cd_MVL_more_sig(:,1),'-b','LineWidth',2)
plot(edMVL(2:end),cd_MVL_more_sig(:,2),':b','LineWidth',2)
plot(edMVL(2:end),cd_MVL_less_sig(:,3),'-r','LineWidth',1)
plot(edMVL(2:end),cd_MVL_less_sig(:,4),':r','LineWidth',1)
plot(edMVL(2:end),cd_MVL_more_sig(:,3),'-r','LineWidth',2)
plot(edMVL(2:end),cd_MVL_more_sig(:,4),':r','LineWidth',2)
title('MVL Pyramidal Cells - SIG Ent')
legend('ShFamStill','ShNovStill','ShFamMov','ShNovMov','InjFamStill','InjNovStill','InjFamMov','InjNovMov','Location','southeast')
% figure;
subplot(2,1,2)
plot(edMVL(2:end),cd_MVL_less_sig(:,5),'-b','LineWidth',1); hold on
plot(edMVL(2:end),cd_MVL_less_sig(:,6),':b','LineWidth',1)
plot(edMVL(2:end),cd_MVL_more_sig(:,5),'-b','LineWidth',2)
plot(edMVL(2:end),cd_MVL_more_sig(:,6),':b','LineWidth',2)
plot(edMVL(2:end),cd_MVL_less_sig(:,7),'-r','LineWidth',1)
plot(edMVL(2:end),cd_MVL_less_sig(:,8),':r','LineWidth',1)
plot(edMVL(2:end),cd_MVL_more_sig(:,7),'-r','LineWidth',2)
plot(edMVL(2:end),cd_MVL_more_sig(:,8),':r','LineWidth',2)
title('MVL Interneurons - SIG Ent')
legend('ShFamStill','ShNovStill','ShFamMov','ShNovMov','InjFamStill','InjNovStill','InjFamMov','InjNovMov','Location','southeast')
