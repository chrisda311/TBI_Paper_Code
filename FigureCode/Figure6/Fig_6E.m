%% Amplitude
clear
clc
addpath(genpath('X:\Chris\CODE'))
cd 'X:\Chris\R01RatPaper\DataBlocks\SW_Fig'
load('ImportantVarsChris.mat')
colors{1}=my_colors('blue'); colors{2}=my_colors('cyan'); colors{3}=my_colors('red');
colors{4}=my_colors('orange'); colors{5}=my_colors('blue'); colors{6}=my_colors('red');

ed = [0.02:0.001:0.5];
for i=1:6
    cdAmp(i,:) = cdist(amp{i,1},ed);
end
figure;
for i=1:4
    semilogx(ed(2:end),cdAmp(i,:),color=colors{i},LineWidth=2); hold on
end

%% Duration
clear
clc
cd 'X:\Chris\R01RatPaper\DataBlocks\SW_Fig'
load('ImportantVarsChris.mat')
colors{1}=my_colors('blue'); colors{2}=my_colors('cyan'); colors{3}=my_colors('red');
colors{4}=my_colors('orange'); colors{5}=my_colors('blue'); colors{6}=my_colors('red');

ed = [6:0.2:195];
for i=1:6
    cdDur(i,:) = cdist(dur{i,1},ed);
end
figure;
for i=1:4
    semilogx(ed(2:end),cdDur(i,:),color=colors{i},LineWidth=2); hold on
end
