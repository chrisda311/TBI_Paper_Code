clearvars -except Moving TF animal_key channel_key condition_key day_key f fs sham_key prym_key
clc;
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\SW_Fig'
load('Merged_Verified.mat')
load('prym_key.mat')

%%
sham_animals=[1,2,7,8];
inj_animals=[3,4,5,6,9];
clear Y key;
L=length(sham_animals);
for i=1:L
    I=sham_animals(i);

    key=(animal_key==I).*(day_key==1).*(condition_key==1).*(prym_key==1);
    Y{1,i} = 1 - (sum(Moving(logical(key))) / sum(key));

    key=(animal_key==I).*(day_key==1).*(condition_key==2).*(prym_key==1);
    Y{2,i} = 1 - (sum(Moving(logical(key))) / sum(key));
end

L=length(inj_animals);
for i=1:L
    I=inj_animals(i);

    key=(animal_key==I).*(day_key==1).*(condition_key==1).*(prym_key==1);
    Y{3,i} = 1 - (sum(Moving(logical(key))) / sum(key));
    
    key=(animal_key==I).*(day_key==1).*(condition_key==2).*(prym_key==1);
    Y{4,i} = 1 - (sum(Moving(logical(key))) / sum(key));
end

Y_key = {'ShamFamD1'; 'ShamNovD1'; 'InjFamD1'; 'InjNovD1'};

%% Define Plot Parameters
% Colors
colors{1}=my_colors('blue');
colors{2}=my_colors('cyan');
colors{3}=my_colors('red');
colors{4}=my_colors('orange');
% Labels
labels={'Sham-OF','Sham-RAM','Injured-OF','Injured-RAM'};
% Font
Fontname='arial';
Fontsize=12;
lw=2;

%% Plot SWR Event Rate While Still
figure;
X=[1,1.5,2.25,2.75];
for i=1:4
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
