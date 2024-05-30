%% Get PAC Ex Trace
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Animal1\Day3\OF'
load('Data3k.mat')
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\PAC_Summary'

%% Filter and Index Data
% Pulls channel we want to plot
x = Data3k(58,:); clear Data3k

% Filters for theta
xth=x;
[A,B] = butter(2,[5/(3000/2) 10/(3000/2)]);
xth(1,:)=filtfilt(A,B,x);
clear A B

% Filters for gamma
xgam=x;
[A,B] = butter(2,[30/(3000/2) 59/(3000/2)]);
xgam(1,:)=filtfilt(A,B,x);
clear A B

% Gets gamma amplitude envelope
gamamp = abs(hilbert(xgam));

% Creates tvector
tv3 = 1/3000:1/3000:3;

% Index parts of the data we want
t = 2273101+6000+750;
xplt = x(t:t+8999); clear x
xplt_th = xth(t:t+8999); clear xth
xplt_gam = xgam(t:t+8999); clear xgam
gamamp_plt = gamamp(t:t+8999); clear gamamp

%% Find Peaks and Plot
% Find Peaks Of Gamma Amp
[pk,ipk] = findpeaks(gamamp_plt);
pkPlt = ipk(pk>(mean(gamamp_plt) + std(gamamp_plt)));

% Plot
figure;
plot(tv3,xplt); hold on;
plot(tv3,xplt_th-1e-3);
plot(tv3,gamamp_plt-1.5e-3);
plot(tv3,xplt_gam-1.5e-3);
ylim([-2e-3 1e-3])
for i=2:length(pkPlt)
    xline(tv3(pkPlt(i))); hold on
end
plot([0 0],[0 -0.5e-3],'-k','LineWidth',2)
plot([0 0.25],[-1.25e-3 -1.25e-3],'-k','LineWidth',2)
