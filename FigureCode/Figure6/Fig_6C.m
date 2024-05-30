%% Get Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\SW_Fig'
load('SWR_EventRate_WhileStill.mat')

%% Define Plot Parameters
% Colors
colors{1}=my_colors('blue');
colors{2}=my_colors('cyan');
colors{3}=my_colors('red');
colors{4}=my_colors('orange');
colors{5}=my_colors('blue');
colors{6}=my_colors('red');
% Labels
labels={'Sham-OF','Sham-RAM','Injured-OF','Injured-RAM','Sham','Injured'};
% Font
Fontname='arial';
Fontsize=12;
lw=2;

%% Plot SWR Event Rate While Still
figure;
X=[1,1.5,2.25,2.75 4,4.5];
for i=1:6
    data=[Y{i,:}];
    data_mean=mean(data);
%     data_std=std(data);
    data_se=std(data) / sqrt(length(data));
    bar(X(i),data_mean,0.25,FaceColor=colors{i});    
    hold on
%     errorbar(X(i),data_mean,data_std,color='k')
    errorbar(X(i),data_mean,data_se,color='k')
end
set(gca,'XTick',X)
set(gca,'XTickLabel',labels);
ylabel('# Sharp-wave events when still[1/s]')
set(gca,fontsize=Fontsize,fontname=Fontname,linewidth=lw)
box off;
