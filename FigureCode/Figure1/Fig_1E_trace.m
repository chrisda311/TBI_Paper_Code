%% Get Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Animal5\Day3\OF'
load('Data3k.mat')
tv2 = 1/3000:1/3000:2;

%% USE - FINAL
i = 144001+2000;
figure;
for ch=1:16
    plot(tv2,Data3k(16+ch,i:i+6000-1)-(ch-1)*1e-3);
    hold on;
end
plot([0 0.1],[1e-3 1e-3],'-k','LineWidth',2)
plot([0 0],[0 1e-3],'-k','LineWidth',2)