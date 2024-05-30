%% Load Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'
load('PyrInt_Classification_PAPER.mat') % 0=Pyr 1=Int 2=NotSure
load('FiringRatesFINAL.mat') % 1stCol=Familiar 2ndCol=Novel
load('Units2.mat'); umat = cell2mat(unitmat(:,1:5)); keymat = keymat(1:5); clear unitmat

%% Separate Sham/Injured, Pyr/Int, & OF/RAM (excluding animal that had electrode drift between envs)
% Exclude Animal1 (PP24) because probe shifted significantally b/w familiar
% and novel environment. % umat(:,2) == 0; %sham     % umat(:,2) == 1; %inj

% Both Env with no FR cutoff
fr.sh.pyr = fr_all(umat(:,2) == 0 & classFinal(:,1) == 0 & umat(:,1) ~= 24,:);
fr.sh.int = fr_all(umat(:,2) == 0 & classFinal(:,1) == 1 & umat(:,1) ~= 24,:);
fr.inj.pyr = fr_all(umat(:,2) == 1 & classFinal(:,1) == 0 & umat(:,1) ~= 24,:);
fr.inj.int = fr_all(umat(:,2) == 1 & classFinal(:,1) == 1 & umat(:,1) ~= 24,:);

%% Set Firing Rate Cutoff
% Select only data when firing rate is above threshold
frCutoff = 0.1; % Min FR in both environments

%% Pie Chart of cells active in specific environments
% Find where cells are active
key_ActEnv = {'FamOnly' 'NovOnly' 'Both' 'Neither'};
ActEnv_Sham_Pyr = [size(fr.sh.pyr(fr.sh.pyr(:,1)>frCutoff & fr.sh.pyr(:,2)<frCutoff,:),1) size(fr.sh.pyr(fr.sh.pyr(:,1)<frCutoff & fr.sh.pyr(:,2)>frCutoff,:),1) size(fr.sh.pyr(fr.sh.pyr(:,1)>frCutoff & fr.sh.pyr(:,2)>frCutoff,:),1) size(fr.sh.pyr(fr.sh.pyr(:,1)<frCutoff & fr.sh.pyr(:,2)<frCutoff,:),1)] ;
ActEnv_Inj_Pyr = [size(fr.inj.pyr(fr.inj.pyr(:,1)>frCutoff & fr.inj.pyr(:,2)<frCutoff,:),1) size(fr.inj.pyr(fr.inj.pyr(:,1)<frCutoff & fr.inj.pyr(:,2)>frCutoff,:),1) size(fr.inj.pyr(fr.inj.pyr(:,1)>frCutoff & fr.inj.pyr(:,2)>frCutoff,:),1) size(fr.inj.pyr(fr.inj.pyr(:,1)<frCutoff & fr.inj.pyr(:,2)<frCutoff,:),1)] ;

% Create Pie Charts - PYR ONLY
figure;
labels = {['FamOnly (' num2str(ActEnv_Sham_Pyr(1)) ')'],['NovOnly (' num2str(ActEnv_Sham_Pyr(2)) ')'],['Both (' num2str(ActEnv_Sham_Pyr(3)) ')']};
subplot(1,2,1); pie(ActEnv_Sham_Pyr(1:3)); legend(labels); title(['Sham Pyramidal'])
labels = {['FamOnly (' num2str(ActEnv_Inj_Pyr(1)) ')'],['NovOnly (' num2str(ActEnv_Inj_Pyr(2)) ')'],['Both (' num2str(ActEnv_Inj_Pyr(3)) ')']};
subplot(1,2,2); pie(ActEnv_Inj_Pyr(1:3)); legend(labels); title(['Injured Pyramidal'])
