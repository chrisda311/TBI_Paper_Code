%% Sham - Animal7 - PP29
% Get Unit Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'
load('SpikeInstances.mat'); load('Units2.mat'); load('PyrInt_Classification_PAPER.mat')
% Get CSC Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Animal7\Day1\RAM'
load('Data30k.mat')

% Index cells from shank 3 (what I plotted in the fig) from this rat
spkI = SpkInst(cell2mat(unitmat(:,1)) == 29 & cell2mat(unitmat(:,3)) == 3,:);
classF = classFinal(cell2mat(unitmat(:,1)) == 29 & cell2mat(unitmat(:,3)) == 3,:);
dat = Data30k(33:48,:);

% Remove extra variables
clearvars -except dat dat_filt spkI classF

%% Plot Cells
% Define cells to plot
pcells = [4 7 11 14 18 23];

figure;
for cid=1:length(pcells)

i=pcells(cid);
si = cell2mat(spkI(i,2));

% Pull Spikes from raw data (2ms before 3ms after)
for ii=1:length(si)
    st = si(ii) - 59; en = si(ii) + 90;
    asdf(:,:,ii) = dat(:,st:en);
end


% Subtract baseline (1.5ms before to 0.5ms before) from waves
for u=1:size(asdf,3)
    base = mean(asdf(:,15:45,u),2);
    asdfnorm(:,:,u) = asdf(:,:,u) - base;
end

% Get Mean And StDev across all spikes
mspkNORM = mean(asdfnorm,3);
std_spkNORM = std(asdfnorm,[],3);

% Plot mean wave +/- StDev from all chan on shank 3
subplot(1,length(pcells),cid)
for c=1:size(mspkNORM,1)
    plot([1/30:1/30:2],mspkNORM(c,46:105)-(c-1)*9e-4,'-k'); hold on; ylim([-14e-3 1e-3])
end

clearvars -except dat dat_filt spkI classF pcells cid

end
