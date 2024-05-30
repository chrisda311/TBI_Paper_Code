%% Load Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'
load('PyrInt_Classification_PAPER.mat') % 0=Pyr 1=Int 2=NotSure
load('SpikeClassParams_V1.mat'); % Firing rate used here is from whichever env it was maximal in
load('CellsInPyrLayer.mat', 'inPyrLay')
load('Units2.mat'); umat = cell2mat(unitmat(:,1:5)); keymat = keymat(1:5); clear unitmat

%% Remove Animal with Electrode Drift
classFinal = classFinal(umat(:,1) ~= 24,:);
inPyrLay = inPyrLay(umat(:,1) ~= 24,:);
sortParam = sortParam(umat(:,1) ~= 24,:);
umat = umat(umat(:,1) ~= 24,:); % This needs to be last

%% Done for all cells (not just in pyr layer)
% % Normalize features
% sortParam_norm = (sortParam - min(sortParam)) ./ range(sortParam);
% % Plot Normalized Features
% figure; 
% subplot(1,2,1); scatter3(sortParam(:,2),sortParam(:,3),sortParam(:,1),20,'filled')
% xlabel('1st Moment of AC (ms)'); ylabel('Spike Width (ms)'); zlabel('Firing Rate (Hz)'); title ('All Cells: Raw Features')
% subplot(1,2,2); scatter3(sortParam_norm(:,2),sortParam_norm(:,3),sortParam_norm(:,1),20,'filled')
% xlabel('1st Moment of AC'); ylabel('Spike Width'); zlabel('Firing Rate'); title ('All Cells: Normalized Features')
% 
% %% K means consensus clustering - all cells (not just in pyr layer)
% % % Define number of permutations desired
% % nperm = 1000;
% % for i=1:nperm
% %     cTemp = kmeans(sortParam_norm,2);
% %     % force data to be: 0=pyr and 1=int
% %     if max(sortParam_norm(cTemp==1,1)) == 1
% %         cAll(:,i) = (cTemp * -1) + 2;
% %     else
% %         cAll(:,i) = cTemp - 1;
% %     end
% % end
% % 
% % % Looks at how consistantly a cell was classified as a particular type
% % consensusCertantity = sum(cAll,2) / nperm;
% % unique(consensusCertantity)
% % 
% % % Defines the subtype based on the consensus
% % cCon = mode(cAll,2);
% % 
% % % save('ConsensusClustAllAll_PAPER.mat','nperm','cAll','consensusCertantity','cCon')
% 
% % Ran the above code to generate consensus Clusters created below. Due to
% % randomization this can change slightly with each iteration so load this
% % randomally generated version for consistancy
% load('ConsensusClustAllAll_PAPER.mat')
% 
% %% Plot Data from Consensus Clusters All All
% % Creates scatter plots based on consensus clustering
% sortPerm_pyrC = sortParam(cCon==0,:); sortPerm_intC = sortParam(cCon==1,:);
% nsortPerm_pyrC = sortParam_norm(cCon==0,:); nsortPerm_intC = sortParam_norm(cCon==1,:);
% % sortPermNorm_pyrC = sortParam_norm(cCon==0,:); sortPermNorm_intC = sortParam_norm(cCon==1,:);
% figure;
% subplot(1,2,1); scatter3(sortPerm_pyrC(:,2),sortPerm_pyrC(:,3),sortPerm_pyrC(:,1),20,'filled','b'); hold on
% scatter3(sortPerm_intC(:,2),sortPerm_intC(:,3),sortPerm_intC(:,1),20,'filled','r');
% xlabel('1st Moment of AC'); ylabel('Spike Width'); zlabel('Firing Rate'); title ('All Cells: K-Means Consensus Clustering')
% subplot(1,2,2); scatter3(nsortPerm_pyrC(:,2),nsortPerm_pyrC(:,3),nsortPerm_pyrC(:,1),20,'filled','b'); hold on
% scatter3(nsortPerm_intC(:,2),nsortPerm_intC(:,3),nsortPerm_intC(:,1),20,'filled','r');
% xlabel('1st Moment of AC'); ylabel('Spike Width'); zlabel('Firing Rate'); title ('All Cells: K-Means Consensus Clustering NORM')


%% ONLY CELLS IN THE PYRAMIDAL CELL LAYER
% Pull out only cells in the pyramidal cell layer
sortParam_pyrLayer = sortParam(inPyrLay,:);
% Normalize features
sortParam_normPyr = (sortParam_pyrLayer - min(sortParam_pyrLayer)) ./ range(sortParam_pyrLayer);
% Plot Normalized Features
figure;
subplot(1,2,1); scatter3(sortParam_pyrLayer(:,2),sortParam_pyrLayer(:,3),sortParam_pyrLayer(:,1),20,'filled')
xlabel('1st Moment of AC'); ylabel('Spike Width'); zlabel('Firing Rate'); title ('Cells In Pyr Layer Only: Raw Features')
subplot(1,2,2); scatter3(sortParam_normPyr(:,2),sortParam_normPyr(:,3),sortParam_normPyr(:,1),20,'filled')
xlabel('1st Moment of AC'); ylabel('Spike Width'); zlabel('Firing Rate'); title ('Cells In Pyr Layer Only: Normalized Features')

%% K means consensus clustering - ONLY CELLS IN THE PYRAMIDAL CELL LAYER

%% This was run once then saved as ConsensusClustAllPyr_PAPER.mat
% % Define number of permutations desired
% nperm = 1000;
% for i=1:nperm
%     cTemp = kmeans(sortParam_normPyr,2);
%     % force data to be: 0=pyr and 1=int
%     if max(sortParam_normPyr(cTemp==1,1)) == 1
%         cAll_PyrLayer(:,i) = (cTemp * -1) + 2;
%     else
%         cAll_PyrLayer(:,i) = cTemp - 1;
%     end
% end
% 
% % Looks at how consistantly a cell was classified as a particular type
% consensusCertantity_PyrLayer = sum(cAll_PyrLayer,2) / nperm;
% unique(consensusCertantity_PyrLayer)
% 
% % Defines the subtype based on the consensus
% cCon_PyrLayer = mode(cAll_PyrLayer,2);
% 
% % save('ConsensusClustAllPyr_PAPER.mat','nperm','cAll_PyrLayer','consensusCertantity_PyrLayer','cCon_PyrLayer')

%% Load What was run above
% Ran the above code to generate consensus Clusters created below. Due to
% randomization this can change slightly with each iteration so load this
% randomally generated version for consistancy
load('ConsensusClustAllPyr_PAPER.mat')

%% Plot Data from Consensus Clusters All Pyr
% Creates scatter plots based on consensus clustering
sortPerm_pyrC_pLayer = sortParam_pyrLayer(cCon_PyrLayer==0,:); sortPerm_intC_pLayer = sortParam_pyrLayer(cCon_PyrLayer==1,:);
nsortPerm_pyrC_pLayer = sortParam_normPyr(cCon_PyrLayer==0,:); nsortPerm_intC_pLayer = sortParam_normPyr(cCon_PyrLayer==1,:);

figure;
subplot(1,2,1); 
scatter3(sortPerm_pyrC_pLayer(:,2),sortPerm_pyrC_pLayer(:,3),sortPerm_pyrC_pLayer(:,1),20,'filled','b'); hold on
scatter3(sortPerm_intC_pLayer(:,2),sortPerm_intC_pLayer(:,3),sortPerm_intC_pLayer(:,1),20,'filled','r');
xlabel('1st Moment of AC'); ylabel('Spike Width'); zlabel('Firing Rate'); title ('Cells In Pyr Layer Only: K-Means Consensus Clustering')
subplot(1,2,2); 
scatter3(nsortPerm_pyrC_pLayer(:,2),nsortPerm_pyrC_pLayer(:,3),nsortPerm_pyrC_pLayer(:,1),20,'filled','b'); hold on
scatter3(nsortPerm_intC_pLayer(:,2),nsortPerm_intC_pLayer(:,3),nsortPerm_intC_pLayer(:,1),20,'filled','r');
xlabel('1st Moment of AC'); ylabel('Spike Width'); zlabel('Firing Rate'); title ('Cells In Pyr Layer Only: K-Means Consensus Clustering NORM')


figure;
subplot(2,2,1); 
scatter3(sortPerm_pyrC_pLayer(:,2),sortPerm_pyrC_pLayer(:,3),sortPerm_pyrC_pLayer(:,1),20,'filled','b'); hold on
scatter3(sortPerm_intC_pLayer(:,2),sortPerm_intC_pLayer(:,3),sortPerm_intC_pLayer(:,1),20,'filled','r');
xlabel('1st Moment of AC'); ylabel('Spike Width'); zlabel('Firing Rate'); title ({['K-Means Consensus Clustering:']; ['Cells In Pyr Layer Only']})
subplot(2,2,2); scatter(sortPerm_pyrC_pLayer(:,2),sortPerm_pyrC_pLayer(:,3),15,'filled','b'); hold on
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

%% See overlap of manual clustering with k-means
asdf = classFinal(inPyrLay);
pOverlapAllPyr = sum(asdf(asdf~=2) == cCon_PyrLayer(asdf~=2)) / length(asdf(asdf~=2))
