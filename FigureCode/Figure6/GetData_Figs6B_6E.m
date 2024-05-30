%% Get Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\SW_Fig'
load('Merged_Verified.mat')
load('prym_key.mat')

%% Get % Ripples while still
clearvars -except Moving TF animal_key channel_key condition_key day_key f fs sham_key prym_key amp dur A freqOfRip pRipStill
clc;
%
clear key;
key{1}=(sham_key==1).*(day_key==1).*(condition_key==1).*(prym_key==1);
key{2}=(sham_key==1).*(day_key==1).*(condition_key==2).*(prym_key==1);
key{3}=(sham_key==0).*(day_key==1).*(condition_key==1).*(prym_key==1);
key{4}=(sham_key==0).*(day_key==1).*(condition_key==2).*(prym_key==1);
key{5}=(sham_key==1).*(condition_key==1);
key{6}=(sham_key==0).*(condition_key==1);
%
colors{1}=my_colors('blue');
colors{2}=my_colors('cyan');
colors{3}=my_colors('red');
colors{4}=my_colors('orange');
colors{5}=my_colors('blue');
colors{6}=my_colors('red');
%
labels={'Sham-OF','Sham-RAM','Injured-OF','Injured-RAM','Sham','Injured'};
%
Fontname='arial';
Fontsize=12;
lw=2;
%
X=[1,1.5,2.25,2.75 4,4.5];
for i=1:6
    temp_key=logical(key{i});
    temp=Moving(temp_key)==1;
    data=sum(temp)/length(temp);
    pRipStill{i,1} = (1-data)*100;
    bar(X(i),(1-data)*100,0.25,FaceColor=colors{i});
    hold on
end
set(gca,'XTick',X)
set(gca,'XTickLabel',labels);
ylabel('Sharp-wave events when still [%]')
set(gca,fontsize=Fontsize,fontname=Fontname,linewidth=lw)
box off;

%% Get SWR Event Freq While Still
clearvars -except Moving TF animal_key channel_key condition_key day_key f fs sham_key prym_key amp dur A freqOfRip
load('T_end.mat')
load('Moving_ratio.mat')
clc;

%
clear key
sham_animals=[1,2,7,8];
inj_animals=[3,4,5,6,9];
clear Y;
L=length(sham_animals);
for i=1:L
    I=sham_animals(i);
    key=(animal_key==I).*(day_key==1).*(condition_key==1).*(prym_key==1);
    % n_channels=length(unique(channel_key(logical(key))));
    Y{1,i}=sum(key)/time_end(I,1,1)/(1-moving_ratio(I,1,1));    
    key=(animal_key==I).*(day_key==1).*(condition_key==2).*(prym_key==1);
    % n_channels=length(unique(channel_key(logical(key))));
    Y{2,i}=sum(key)/time_end(I,1,2)/(1-moving_ratio(I,1,2));
    Y{5,i}=Y{1,i};
    key=(animal_key==I).*(day_key==2).*(condition_key==1).*(prym_key==1);
    % n_channels=length(unique(channel_key(logical(key))));
    Y{5,i+L}=sum(key)/time_end(I,2,1)/(1-moving_ratio(I,2,1));   
    key=(animal_key==I).*(day_key==3).*(condition_key==1).*(prym_key==1);
    % n_channels=length(unique(channel_key(logical(key))));
    Y{5,i+2*L}=sum(key)/time_end(I,3,1)/(1-moving_ratio(I,3,1));
end

L=length(inj_animals);
for i=1:L
    I=inj_animals(i);
    key=(animal_key==I).*(day_key==1).*(condition_key==1).*(prym_key==1);
    % n_channels=length(unique(channel_key(logical(key))));   
    Y{3,i}=sum(key)/time_end(I,1,1)/(1-moving_ratio(I,1,1));   
    key=(animal_key==I).*(day_key==1).*(condition_key==2).*(prym_key==1);
    % n_channels=length(unique(channel_key(logical(key))));
    Y{4,i}=sum(key)/time_end(I,1,2)/(1-moving_ratio(I,1,2));
    Y{6,i}=Y{3,i};
    key=(animal_key==I).*(day_key==2).*(condition_key==1).*(prym_key==1);
    % n_channels=length(unique(channel_key(logical(key))));
    Y{6,i+L}=sum(key)/time_end(I,2,1)/(1-moving_ratio(I,2,1)); 
    key=(animal_key==I).*(day_key==3).*(condition_key==1).*(prym_key==1);
    % n_channels=length(unique(channel_key(logical(key))));
    Y{6,i+2*L}=sum(key)/time_end(I,3,1)/(1-moving_ratio(I,3,1));
end

%
colors{1}=my_colors('blue');
colors{2}=my_colors('cyan');
colors{3}=my_colors('red');
colors{4}=my_colors('orange');
colors{5}=my_colors('blue');
colors{6}=my_colors('red');
%
labels={'Sham-OF','Sham-RAM','Injured-OF','Injured-RAM','Sham','Injured'};
%
Fontname='arial';
Fontsize=12;
lw=2;
%
X=[1,1.5,2.25,2.75 4,4.5];
for i=1:6
    data=[Y{i,:}];
    freqOfRip{i,1} = data;
    data_mean=mean(data);
    data_std=std(data);
    bar(X(i),data_mean,0.25,FaceColor=colors{i});    
    hold on
    errorbar(X(i),data_mean,data_std,color='k')
end
set(gca,'XTick',X)
set(gca,'XTickLabel',labels);
ylabel('# Sharp-wave events when still[1/s]')
set(gca,fontsize=Fontsize,fontname=Fontname,linewidth=lw)
box off;

%% Get Freq-Amp
clearvars -except Moving TF animal_key channel_key condition_key day_key f fs sham_key prym_key amp dur A freqOfRip
clc;
%
clear key;
key{1}=(sham_key==1).*(day_key==1).*(condition_key==1).*(prym_key==1);
key{2}=(sham_key==1).*(day_key==1).*(condition_key==2).*(prym_key==1);
key{3}=(sham_key==0).*(day_key==1).*(condition_key==1).*(prym_key==1);
key{4}=(sham_key==0).*(day_key==1).*(condition_key==2).*(prym_key==1);
key{5}=(sham_key==1).*(condition_key==1).*(prym_key==1);
key{6}=(sham_key==0).*(condition_key==1).*(prym_key==1);
%
colors{1}=my_colors('blue');
colors{2}=my_colors('cyan');
colors{3}=my_colors('red');
colors{4}=my_colors('orange');
colors{5}=my_colors('blue');
colors{6}=my_colors('red');
%
labels={'Sham-OF','Sham-RAM','Injured-OF','Injured-RAM','Sham','Injured'};
%
Fontname='arial';
Fontsize=12;
lw=2;
%
cutoff=(f>=78).*(f<=505);
cutoff=logical(cutoff);
F=f(cutoff);
m=32;
FF=linspace(min(F),max(F),m);

%
for i=1:4
    disp(i)
    temp_key=logical(key{i});
    test={TF(temp_key==1).map};
    clear Y
    for j=1:length(test)
        check=test{j};
        check=check(cutoff,:);
        Y(j,:)=mean(check,2)*1e3;
    end
    plot(F,mean(Y,1),color=colors{i},LineWidth=2);
    hold on
end

xlabel('Frequency [Hz]')
ylabel('Amplitude [mV]')
Leg=legend(labels{1:4});
Leg.Box='off';
Leg.Location='northwest';
set(gca,fontsize=Fontsize,fontname=Fontname,linewidth=lw)
box off;

%% Get Amps
clear key;
key{1}=(sham_key==1).*(day_key==1).*(condition_key==1).*(prym_key==1);
key{2}=(sham_key==1).*(day_key==1).*(condition_key==2).*(prym_key==1);
key{3}=(sham_key==0).*(day_key==1).*(condition_key==1).*(prym_key==1);
key{4}=(sham_key==0).*(day_key==1).*(condition_key==2).*(prym_key==1);
key{5}=(sham_key==1).*(condition_key==1).*(prym_key==1);
key{6}=(sham_key==0).*(condition_key==1).*(prym_key==1);
%
colors{1}=my_colors('blue');
colors{2}=my_colors('cyan');
colors{3}=my_colors('red');
colors{4}=my_colors('orange');
colors{5}=my_colors('blue');
colors{6}=my_colors('red');
%
labels={'Sham-OF','Sham-RAM','Injured-OF','Injured-RAM','Sham','Injured'};
%
Fontname='arial';
Fontsize=12;
lw=2;
%
cutoff=(f>=78).*(f<=505);
% cutoff=(f>=160).*(f<=200);
cutoff=logical(cutoff);
F=f(cutoff);
for i=1:4
    disp(i)
    temp_key=logical(key{i});
    test={TF(temp_key==1).map};
    data=zeros(length(test),1);
    for j=1:length(test)
        check=test{j};
        check=check(cutoff,:);
        data(j)=max(check(:));
        [ii,jj]=find(check==data(j));
        f_data(j)=F(ii);
    end
    data=double(data)*1000;
    [yy,xx]=ecdf((data));
    semilogx(xx,yy,color=colors{i},LineWidth=2);    
    hold on
end
% set(gca,'XTick',X)
% set(gca,'XTickLabel',labels);
xlabel('Amplitude [mV]')
ylabel('ECDF')
Leg=legend(labels{1:4});
Leg.Box='off';
set(gca,fontsize=Fontsize,fontname=Fontname,linewidth=lw)
box off;
% exportgraphics(gca,'./Figures/Amplitude_Day1_CDF.pdf','Resolution',300,'ContentType','vector');

%% Get Dur
%
clearvars -except Moving TF animal_key channel_key condition_key day_key f fs sham_key prym_key amp dur A freqOfRip
clc;
%
clear key;
key{1}=(sham_key==1).*(day_key==1).*(condition_key==1).*(prym_key==1);
key{2}=(sham_key==1).*(day_key==1).*(condition_key==2).*(prym_key==1);
key{3}=(sham_key==0).*(day_key==1).*(condition_key==1).*(prym_key==1);
key{4}=(sham_key==0).*(day_key==1).*(condition_key==2).*(prym_key==1);
key{5}=(sham_key==1).*(condition_key==1).*(prym_key==1);
key{6}=(sham_key==0).*(condition_key==1).*(prym_key==1);
%
colors{1}=my_colors('blue');
colors{2}=my_colors('cyan');
colors{3}=my_colors('red');
colors{4}=my_colors('orange');
colors{5}=my_colors('blue');
colors{6}=my_colors('red');
%
labels={'Sham-OF','Sham-RAM','Injured-OF','Injured-RAM','Sham','Injured'};
%
Fontname='arial';
Fontsize=12;
lw=2;
%

%
for i=1:4
    disp(i)
    temp_key=logical(key{i});
    test={TF(temp_key==1).map};
    data=zeros(length(test),1);
    for j=1:length(test)
        check=test{j};
        data(j)=size(check,2)/fs;
    end
    data=double(data)*1000;
    dur{i,1} = data;
    [yy,xx]=ecdf((data));
    semilogx(xx,yy,color=colors{i},LineWidth=2);
    hold on
end
