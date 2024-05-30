%% Load Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'
load('PyrInt_Classification_PAPER.mat') % 0=Pyr 1=Int 2=NotSure
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

%% Plot
% All Cells in pyr layer
pyr_fin_ip = sortParam(classFinal==0 & inPyrLay,:);
int_fin_ip = sortParam(classFinal==1 & inPyrLay,:);
uns_fin_ip = sortParam(classFinal==2 & inPyrLay,:);

figure;
scatter3(uns_fin_ip(:,2),uns_fin_ip(:,3),uns_fin_ip(:,1),15,'filled','c'); hold on
scatter3(pyr_fin_ip(:,2),pyr_fin_ip(:,3),pyr_fin_ip(:,1),15,'filled','b')
scatter3(int_fin_ip(:,2),int_fin_ip(:,3),int_fin_ip(:,1),15,'filled','r')
xlabel('1st Moment of AC (ms)'); ylabel('Spike Width (ms)'); zlabel('Firing Rate (Hz)'); title('In Pyr Layer')
xlim([10 40]); ylim([0 1]); zlim([0 60])
