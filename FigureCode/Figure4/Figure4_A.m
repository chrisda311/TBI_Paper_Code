% Animal 7 - RAM - Shank 3
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Animal7\Day1\RAM'
load('Data30k.mat', 'Data30k')

%% Use - 2 sec trace
nsec = 2;
x = 1/30000:1/30000:nsec;
i = 360001;
figure;
plot(x,Data30k(33,i:(i+nsec*30000-1)),'k'); hold on;
plot([0 0.25],[-2e-3 -2e-3],'k','LineWidth',2) % 250ms bar
plot([0 0],[-2e-3 -1e-3],'k','LineWidth',2) % 1mV bar
ylim([-1e-2 1e-2]); title(['i = ' num2str(i) '  1mV  250ms']);