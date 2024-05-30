%% Load firing rates (excluding bad animal and cells below 0.1Hz in an env)
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Units'
load('FR_for_cDist_PAPER.mat')

%% Get Cumulative Distributions
edInt = [0:0.1:60]; % Interneurons
cd_sif = cDist(sif,edInt);
cd_sin = cDist(sin,edInt);
cd_iif = cDist(iif,edInt);
cd_iin = cDist(iin,edInt);

edPyr = [0:0.1:20]; % Pyramidal Cells
cd_spf = cDist(spf,edPyr);
cd_spn = cDist(spn,edPyr);
cd_ipf = cDist(ipf,edPyr);
cd_ipn = cDist(ipn,edPyr);

%% Plot Distributions
figure; subplot(1,2,1); % Log Scale
semilogx(edPyr(2:end),cd_spf,'-b'); hold on; title('Pyramidal Cells')
semilogx(edPyr(2:end),cd_spn,'--b')
semilogx(edPyr(2:end),cd_ipf,'-r')
semilogx(edPyr(2:end),cd_ipn,'--r')
subplot(1,2,2);
semilogx(edInt(2:end),cd_sif,'-b'); hold on; title('Interneurons')
semilogx(edInt(2:end),cd_sin,'--b')
semilogx(edInt(2:end),cd_iif,'-r')
semilogx(edInt(2:end),cd_iin,'--r')
