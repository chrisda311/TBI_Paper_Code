% Animal 7 - RAM - Shank 3
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Animal7\Day1\RAM'
load('Data30k.mat', 'Data30k')

%% Use
% Plot 16 Chan
i=30000*740.6;
data = Data30k(33:48,i:i+30000*1-1); 
xdata = 1/30000:1/30000:size(data,2)/30000;
offset = 0.00175;
figure;
for i=1:size(data,1)
    plot(xdata,data(i,:)-(i-1)*offset,'k');
    hold on;
end