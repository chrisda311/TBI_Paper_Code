%% Get Data
% Load & Clean Units
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'
load('Units2.mat'); umat = cell2mat(unitmat(:,1:4)); keymat = keymat(1:4); clear unitmat % Loads units and removes unnecessary data
load('FiringRatesFINAL.mat', 'fr_all') % Load Firing Rates
load('PyrInt_Classification_PAPER.mat') % Load Pyr/Int Classification
% Load Entrainment Stuff
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units\Entrainment Analysis'
load('EntAll_FINAL.mat') % Load EntAll formatted the same way as unitmat
load('Unit1_Channel28_OF.mat', 'franges', 'ed20', 'velocity_threshold') % Get frequency ranges used for entrainment along with MI bin edges and velocity threshold
f = mean(franges); % mean of filter freq ranges used for plotting

%% Remove Animal with Electrode Drift
classFinal = classFinal(umat(:,1) ~= 24,:);
fr_all = fr_all(umat(:,1) ~= 24,:);
uentOF_pyrSh = uentOF_pyrSh(umat(:,1) ~= 24,:);
uentRAM_pyrSh = uentRAM_pyrSh(umat(:,1) ~= 24,:);
umat = umat(umat(:,1) ~= 24,:); % Needs to be last

%% Pull out cells above 0.1Hz FR threshold (env specific)
% Pulls entrainment from cells above 0.1Hz FR threshold in each env
% independently. Does this for entrainment to maxCh and pyrSh

uentOF_pyrSh = uentOF_pyrSh(fr_all(:,1) >= 0.1,:); % OF
uentRAM_pyrSh = uentRAM_pyrSh(fr_all(:,2) >= 0.1,:); % RAM

% Because different cells are indexed for each env due to FR threshold
% being independently applied to each env, this keeps the meta data for
% each cell in each env.
classFinal_OF = classFinal(fr_all(:,1) >= 0.1,:); classFinal_RAM = classFinal(fr_all(:,2) >= 0.1,:); % Cell classification
umat_OF = umat(fr_all(:,1) >= 0.1,:); umat_RAM = umat(fr_all(:,2) >= 0.1,:); % Sham vs Inj and Animal ID
fr_OF = fr_all(fr_all(:,1) >= 0.1,1); fr_RAM = fr_all(fr_all(:,2) >= 0.1,2); % Firing Rate


%% Index cells that have a min number of spikes in each the moving and still condition

% Get number of spikes for each condition. If the - what's a reasonable min number
% OF
for i=1:length(uentOF_pyrSh)
    nSpks_OF(i,1) = sum(uentOF_pyrSh(i).entBin_less(1,:));
    nSpks_OF(i,2) = sum(uentOF_pyrSh(i).entBin_more(1,:));
end
% RAM
for i=1:length(uentRAM_pyrSh)
    nSpks_RAM(i,1) = sum(uentRAM_pyrSh(i).entBin_less(1,:));
    nSpks_RAM(i,2) = sum(uentRAM_pyrSh(i).entBin_more(1,:));
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


%% Extract cells that meet min number of spikes in each the moving and still condition
% Pull out cells that don't meet the nSpks_minThresh (env specific)
uentOF_pyrSh = uentOF_pyrSh(abvnSpkTh_OF,:);
uentRAM_pyrSh = uentRAM_pyrSh(abvnSpkTh_RAM,:);

% Because different cells are indexed for each env due to FR threshold
% being independently applied to each env, this keeps the meta data for
% each cell in each env.
classFinal_OF = classFinal_OF(abvnSpkTh_OF,:); classFinal_RAM = classFinal_RAM(abvnSpkTh_RAM,:); % Cell classification
umat_OF = umat_OF(abvnSpkTh_OF,:); umat_RAM = umat_RAM(abvnSpkTh_RAM,:); % Sham vs Inj and Animal ID
fr_OF = fr_OF(abvnSpkTh_OF,1); fr_RAM = fr_RAM(abvnSpkTh_RAM,1); % Firing Rate

%% Break down entrainment (to both maxCh and pyrSh) by Sham/Inj, Pyr/Int, & Fam/Nov
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

% Creates a key that will be used for cell matrices that are created below
Ent_KEY = fieldnames(uentOF_pyrSh)';

% OF
EntPyrSh_OF_ShPyr = uentOF_pyrSh(iShPyrOF,:); EntPyrSh_OF_ShPyr = struct2cell(EntPyrSh_OF_ShPyr)';
EntPyrSh_OF_ShInt = uentOF_pyrSh(iShIntOF,:); EntPyrSh_OF_ShInt = struct2cell(EntPyrSh_OF_ShInt)';
EntPyrSh_OF_InjPyr = uentOF_pyrSh(iInjPyrOF,:); EntPyrSh_OF_InjPyr = struct2cell(EntPyrSh_OF_InjPyr)';
EntPyrSh_OF_InjInt = uentOF_pyrSh(iInjIntOF,:); EntPyrSh_OF_InjInt = struct2cell(EntPyrSh_OF_InjInt)';

% RAM
EntPyrSh_RAM_ShPyr = uentRAM_pyrSh(iShPyrRAM,:); EntPyrSh_RAM_ShPyr = struct2cell(EntPyrSh_RAM_ShPyr)';
EntPyrSh_RAM_ShInt = uentRAM_pyrSh(iShIntRAM,:); EntPyrSh_RAM_ShInt = struct2cell(EntPyrSh_RAM_ShInt)';
EntPyrSh_RAM_InjPyr = uentRAM_pyrSh(iInjPyrRAM,:); EntPyrSh_RAM_InjPyr = struct2cell(EntPyrSh_RAM_InjPyr)';
EntPyrSh_RAM_InjInt = uentRAM_pyrSh(iInjIntRAM,:); EntPyrSh_RAM_InjInt = struct2cell(EntPyrSh_RAM_InjInt)';

%% Choose what you want to look at
getcellmat = @(x,c) cell2mat(x(:,c)')';
% Based on Ent_KEY
% 1=MVL_less 5=MVL_more 9=MI_less 12=MI_more

% MVL_less
temp_MVL_less_stP = {getcellmat(EntPyrSh_OF_ShPyr,1) getcellmat(EntPyrSh_RAM_ShPyr,1) getcellmat(EntPyrSh_OF_InjPyr,1) getcellmat(EntPyrSh_RAM_InjPyr,1)...
    getcellmat(EntPyrSh_OF_ShInt,1) getcellmat(EntPyrSh_RAM_ShInt,1) getcellmat(EntPyrSh_OF_InjInt,1) getcellmat(EntPyrSh_RAM_InjInt,1)};
% MVL_more
temp_MVL_more_stP = {getcellmat(EntPyrSh_OF_ShPyr,5) getcellmat(EntPyrSh_RAM_ShPyr,5) getcellmat(EntPyrSh_OF_InjPyr,5) getcellmat(EntPyrSh_RAM_InjPyr,5)...
    getcellmat(EntPyrSh_OF_ShInt,5) getcellmat(EntPyrSh_RAM_ShInt,5) getcellmat(EntPyrSh_OF_InjInt,5) getcellmat(EntPyrSh_RAM_InjInt,5)};

%% Organizes Data
temp_MVL_less_stP_CombEnv{1,1} = [temp_MVL_less_stP{1,1}; temp_MVL_less_stP{1,2}];
temp_MVL_less_stP_CombEnv{1,2} = [temp_MVL_less_stP{1,3}; temp_MVL_less_stP{1,4}];
temp_MVL_less_stP_CombEnv{1,3} = [temp_MVL_less_stP{1,5}; temp_MVL_less_stP{1,6}];
temp_MVL_less_stP_CombEnv{1,4} = [temp_MVL_less_stP{1,7}; temp_MVL_less_stP{1,8}];

temp_MVL_more_stP_CombEnv{1,1} = [temp_MVL_more_stP{1,1}; temp_MVL_more_stP{1,2}];
temp_MVL_more_stP_CombEnv{1,2} = [temp_MVL_more_stP{1,3}; temp_MVL_more_stP{1,4}];
temp_MVL_more_stP_CombEnv{1,3} = [temp_MVL_more_stP{1,5}; temp_MVL_more_stP{1,6}];
temp_MVL_more_stP_CombEnv{1,4} = [temp_MVL_more_stP{1,7}; temp_MVL_more_stP{1,8}];

%%
% Pyramidal Cells stPyr
figure;
pts = [1 2]; % Pyr (1,2)
subplot(2,1,1);
shPlt = mean(temp_MVL_less_stP_CombEnv{1,pts(1)}); inPlt = mean(temp_MVL_less_stP_CombEnv{1,pts(2)});
shPlt2 = std(temp_MVL_less_stP_CombEnv{1,pts(1)})/sqrt(size(temp_MVL_less_stP_CombEnv{1,pts(1)},1)); inPlt2 = std(temp_MVL_less_stP_CombEnv{1,pts(2)})/sqrt(size(temp_MVL_less_stP_CombEnv{1,pts(2)},1)); % SEM
semilogx(f,shPlt,'--b'); hold on; semilogx(f,inPlt,'--r')
spfill = fill([f fliplr(f)],[shPlt+shPlt2 fliplr(shPlt-shPlt2)],'b'); set(spfill,'facealpha',.3); set(spfill,'edgealpha',0);
sifill = fill([f fliplr(f)],[inPlt+inPlt2 fliplr(inPlt-inPlt2)],'r'); set(sifill,'facealpha',.3); set(sifill,'edgealpha',0);
xlim([1 200]); ylim([0 0.3]); title('MVL Pyr Still stPyr');

subplot(2,1,2);
shPlt = mean(temp_MVL_more_stP_CombEnv{1,pts(1)}); inPlt = mean(temp_MVL_more_stP_CombEnv{1,pts(2)});
shPlt2 = std(temp_MVL_more_stP_CombEnv{1,pts(1)})/sqrt(size(temp_MVL_more_stP_CombEnv{1,pts(1)},1)); inPlt2 = std(temp_MVL_more_stP_CombEnv{1,pts(2)})/sqrt(size(temp_MVL_more_stP_CombEnv{1,pts(2)},1)); % SEM
semilogx(f,shPlt,'-b'); hold on; semilogx(f,inPlt,'-r')
spfill = fill([f fliplr(f)],[shPlt+shPlt2 fliplr(shPlt-shPlt2)],'b'); set(spfill,'facealpha',.3); set(spfill,'edgealpha',0);
sifill = fill([f fliplr(f)],[inPlt+inPlt2 fliplr(inPlt-inPlt2)],'r'); set(sifill,'facealpha',.3); set(sifill,'edgealpha',0);
xlim([1 200]); ylim([0 0.3]); title('MVL Pyr Moving stPyr');


% Interneurons stPyr
figure;
pts = [3 4]; % Int (3,4)
subplot(2,1,1);
shPlt = mean(temp_MVL_less_stP_CombEnv{1,pts(1)}); inPlt = mean(temp_MVL_less_stP_CombEnv{1,pts(2)});
shPlt2 = std(temp_MVL_less_stP_CombEnv{1,pts(1)})/sqrt(size(temp_MVL_less_stP_CombEnv{1,pts(1)},1)); inPlt2 = std(temp_MVL_less_stP_CombEnv{1,pts(2)})/sqrt(size(temp_MVL_less_stP_CombEnv{1,pts(2)},1)); % SEM
semilogx(f,shPlt,'--b'); hold on; semilogx(f,inPlt,'--r')
spfill = fill([f fliplr(f)],[shPlt+shPlt2 fliplr(shPlt-shPlt2)],'b'); set(spfill,'facealpha',.3); set(spfill,'edgealpha',0);
sifill = fill([f fliplr(f)],[inPlt+inPlt2 fliplr(inPlt-inPlt2)],'r'); set(sifill,'facealpha',.3); set(sifill,'edgealpha',0);
xlim([1 200]); ylim([0 0.3]); title('MVL Int Still stPyr');

subplot(2,1,2);
shPlt = mean(temp_MVL_more_stP_CombEnv{1,pts(1)}); inPlt = mean(temp_MVL_more_stP_CombEnv{1,pts(2)});
shPlt2 = std(temp_MVL_more_stP_CombEnv{1,pts(1)})/sqrt(size(temp_MVL_more_stP_CombEnv{1,pts(1)},1)); inPlt2 = std(temp_MVL_more_stP_CombEnv{1,pts(2)})/sqrt(size(temp_MVL_more_stP_CombEnv{1,pts(2)},1)); % SEM
semilogx(f,shPlt,'-b'); hold on; semilogx(f,inPlt,'-r')
spfill = fill([f fliplr(f)],[shPlt+shPlt2 fliplr(shPlt-shPlt2)],'b'); set(spfill,'facealpha',.3); set(spfill,'edgealpha',0);
sifill = fill([f fliplr(f)],[inPlt+inPlt2 fliplr(inPlt-inPlt2)],'r'); set(sifill,'facealpha',.3); set(sifill,'edgealpha',0);
xlim([1 200]); ylim([0 0.3]); title('MVL Int Moving stPyr');

