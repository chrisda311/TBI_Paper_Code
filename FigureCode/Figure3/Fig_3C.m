%% Get Data
% Load & Clean Units
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'
load('PyrInt_Classification_PAPER.mat') % 0=Pyr 1=Int 2=NotSure
load('DistanceFromPyr_FINAL.mat') % Load distance from defined pyr chan
load('Units2.mat'); umat = cell2mat(unitmat(:,1:4)); kmat = keymat(1:4); % Loads units and removes unnecessary vars
clear unitmat

%% Remove Animal with Electrode Drift
classFinal = classFinal(umat(:,1) ~= 24,:);
DisFrPyr = DisFrPyr(umat(:,1) ~= 24,:);
umat = umat(umat(:,1) ~= 24,:); % This needs to be last

%% Plot Location of all units
% Order for plotting
r = randi(length(classFinal),length(classFinal),1);

% x values to separate units for plotting
xval = randperm(length(r),length(r)) / (length(r)); xval = xval';

% Make Figure
figure;
for i=1:length(r)
    if classFinal(r(i)) == 0 % Pyr Cell
        scatter(xval(r(i)),-DisFrPyr(r(i),2),'v','filled','b'); hold on
    elseif classFinal(r(i)) == 1 % Interneuron
        scatter(xval(r(i)),-DisFrPyr(r(i),2),'o','filled','r'); hold on
    elseif classFinal(r(i)) == 2 % Unclassified
        scatter(xval(r(i)),-DisFrPyr(r(i),2),'square','filled','c'); hold on
    else
        error('Unidentified Cell Type')
    end
end
yline(80,'-','Pyr','LabelVerticalAlignment','middle'); % Lines that define the pyr layer
yline(-80,'-','Pyr','LabelVerticalAlignment','middle'); % Lines that define the pyr layer
ylim([-300 300]); ylabel('Distance from Chan of Max Ripple Power (um)')
title('Laminar Location of Neuron Subtypes: All Cells')

%% Histograms
% Gets coordinates for each unit subtype
locPyr = [xval(classFinal == 0) DisFrPyr(classFinal == 0,2)];
locInt = [xval(classFinal == 1) DisFrPyr(classFinal == 1,2)];
locUnsure = [xval(classFinal == 2) DisFrPyr(classFinal == 2,2)];

figure; % Grouped
histogram(-locPyr(:,2),[-300+10:20:300-10],'FaceColor','b','Orientation','horizontal'); hold on
histogram(-locInt(:,2),[-300+10:20:300-10],'FaceColor','r','Orientation','horizontal')
histogram(-locUnsure(:,2),[-300+10:20:300-10],'FaceColor','c','Orientation','horizontal')
yline(-80,'--','Pyr','LabelVerticalAlignment','middle'); yline(80,'--','Pyr','LabelVerticalAlignment','middle')
title('TITLE'); ylim([-300 300]); legend('Pyramidal Cells','Interneurons','Unclassified','Location','southeast')

