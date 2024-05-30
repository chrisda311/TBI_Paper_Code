%% Load Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'
load('SpikeAutoCorrelogramFINAL.mat')
load('MeanSpikeWaveforms.mat')
load('PyrInt_Classification_PAPER.mat')
load('FiringRatesFINAL.mat')
load('Units2.mat')
load('spikeInstances_SlowAccurate.mat')

%% Separate Pyramidal Cells and Interneurons
pyr = classFinal == 0; int = classFinal == 1;

mfr_all = max(fr_all,[],2);

mspkPyr = mspkAll(pyr,:); spkAC_pyr = spkAC(pyr,:); fr_pyr = mfr_all(pyr); momAC1st_pyr = momAC1st(pyr); wPyr = w(pyr);
mspkInt = mspkAll(int,:); spkAC_int = spkAC(int,:); fr_int = mfr_all(int); momAC1st_int = momAC1st(int); wInt = w(int);

%% Get info about spikes
% From the original matrix of 405 cells, the following are the cell IDs & envs
% PYR - row 97 of umat in the OF - PP24 - Shank2 Chan13 - CSC29
% INT - row 212 of umat in the OF - PP27 Shank1 Chan10 - CSC10

% Find Unit ID from 405 block and env
id = 1:405;
% Sham
idP = id(pyr); idP(73) % 97
fr_all(97,:) % OF
unitmat{97,1} % PP24
unitmat{97,3} % Shank 2
unitmat{97,4} % Chan 13
(unitmat{97,3} - 1) * 16 + unitmat{97,4} % CSC 29
% Injured
idI = id(int); idI(53) % 212
fr_all(212,:) % OF
unitmat{212,1} % PP27
unitmat{212,3} % Shank 1
(unitmat{212,3} - 1) * 16 + unitmat{212,4} % CSC 10

%% Get Raw Data PYRAMIDAL CELL - PP24=Animal1 - OF - CSC29
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Animal1\Day1\OF'
load('Data30k.mat')
dat = Data30k(29,:); clear Data30k
% dat = Data30k(17:32,:); clear Data30k

% Pull waveforms (5ms) from raw data
spki = spkInst{97,1};
for i=1:length(spki)
    st = spki(i)-59; en = spki(i)+90;
    unitWavsPyr(i,:) = dat(st:en);
end
% figure; plot(mean(unitWavs))

% Subtract baseline (1.5ms before to 0.5ms before) from waves
unitWavsNormPyr = unitWavsPyr - mean(unitWavsPyr(:,15:45),2);
% figure; plot(mean(unitWavsNorm))

% figure; 
% subplot(1,2,1); plot(mean(unitWavs))
% subplot(1,2,2); plot(mean(unitWavsNorm))

% Get Mean And StDev across all spikes
mspkNORM_Pyr = mean(unitWavsNormPyr);
std_spkNORM_Pyr = std(unitWavsNormPyr);
se_spkNORM_Pyr = std(unitWavsNormPyr) / sqrt(size(unitWavsNormPyr,1));

figure;
plot(mspkNORM_Pyr,'b'); hold on; plot(mspkNORM_Pyr+std_spkNORM_Pyr,'--b'); plot(mspkNORM_Pyr-std_spkNORM_Pyr,'--b')

%% Get Raw Data INTERNEURON - PP27=Animal9 - OF - CSC10
% INT - row 212 of umat in the OF - PP27 Shank1 Chan10 - CSC10
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Animal9\Day1\OF'
load('Data30k.mat')
dat = Data30k(10,:); clear Data30k

% Pull waveforms (5ms) from raw data
spki = spkInst{212,1};
for i=1:length(spki)
    st = spki(i)-59; en = spki(i)+90;
    unitWavsInt(i,:) = dat(st:en);
end
% figure; plot(mean(unitWavsInt))

% Subtract baseline (1.5ms before to 0.5ms before) from waves
unitWavsNormInt = unitWavsInt - mean(unitWavsInt(:,15:45),2);
% figure; plot(mean(unitWavsNormInt))

% figure; 
% subplot(1,2,1); plot(mean(unitWavsInt))
% subplot(1,2,2); plot(mean(unitWavsNormInt))

% Get Mean And StDev across all spikes
mspkNORM_Int = mean(unitWavsNormInt);
std_spkNORM_Int = std(unitWavsNormInt);
se_spkNORM_Int = std(unitWavsNormInt) / sqrt(size(unitWavsNormInt,1));

figure;
plot(mspkNORM_Int,'r'); hold on; plot(mspkNORM_Int+std_spkNORM_Int,'--r'); plot(mspkNORM_Int-std_spkNORM_Int,'--r')

%% Get quarter spike height for plotting
QuartHeightPyr = mean(mspkNORM_Pyr(15:45)*1e6) + (min(mspkNORM_Pyr*1e6) - mean(mspkNORM_Pyr(15:45)*1e6))/4;
QuartHeightInt = mean(mspkNORM_Int(15:45)*1e6) + (min(mspkNORM_Int*1e6) - mean(mspkNORM_Int(15:45)*1e6))/4;

%% Plot - V2
% Time vector for plotting - Surface
xdat = 1/30:1/30:3; xx = [xdat fliplr(xdat)];
% Surface for StDev Plotting
stdPYR = [(mspkNORM_Pyr(31:120) + std_spkNORM_Pyr(31:120)) fliplr((mspkNORM_Pyr(31:120) - std_spkNORM_Pyr(31:120)))];
stdINT = [(mspkNORM_Int(31:120) + std_spkNORM_Int(31:120)) fliplr((mspkNORM_Int(31:120) - std_spkNORM_Int(31:120)))];

% Create Figure
figure;
% Pyramidal Cell
subplot(2,2,1); plot(xdat,mspkNORM_Pyr(31:120)*1e6,'-b'); hold on; h = fill(xx,stdPYR*1e6,'b'); set(h,'facealpha',.3); set(h,'edgealpha',0); yline(QuartHeightPyr,'-',num2str(round(wPyr(73),2))); title(['Mean Waveform FR:' num2str(round(fr_pyr(73),2)) 'Hz']); xlabel('Time (ms)'); ylabel('Voltage (uV)')
subplot(2,2,2); histogram('BinCounts',spkAC_pyr(73,:),'BinEdges',[lags(1:50) 0 lags(51:end)],'FaceColor','b'); hold on; xline(momAC1st_pyr(73),'--',num2str(round(momAC1st_pyr(73),1))); title ('Autocorrelation'); xlabel('Lags (ms)'); ylabel('Counts')
% Interneuron
subplot(2,2,3); plot(xdat,mspkNORM_Int(31:120)*1e6,'-r'); hold on; h = fill(xx,stdINT*1e6,'r'); set(h,'facealpha',.3); set(h,'edgealpha',0); yline(QuartHeightInt,'-',num2str(round(wInt(53),2))); title(['Mean Waveform FR:' num2str(round(fr_int(53),2)) 'Hz']); xlabel('Time (ms)'); ylabel('Voltage (uV)')
subplot(2,2,4); histogram('BinCounts',spkAC_int(53,:),'BinEdges',[lags(1:50) 0 lags(51:end)],'FaceColor','r'); hold on; xline(momAC1st_int(53),'--',num2str(round(momAC1st_int(53),1))); title('Autocorrelation'); xlabel('Lags (ms)'); ylabel('Counts')
