%% Get Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\SW_Fig'
load('Merged_Verified.mat')
load('prym_key.mat')

%%
key{1}=(sham_key==1).*(day_key==1).*(condition_key==1).*(prym_key==1);
key{2}=(sham_key==1).*(day_key==1).*(condition_key==2).*(prym_key==1);
key{3}=(sham_key==0).*(day_key==1).*(condition_key==1).*(prym_key==1);
key{4}=(sham_key==0).*(day_key==1).*(condition_key==2).*(prym_key==1);
key{5}=(sham_key==1).*(condition_key==1).*(prym_key==1);
key{6}=(sham_key==0).*(condition_key==1).*(prym_key==1);
%%
colors{1}=my_colors('blue');
colors{2}=my_colors('cyan');
colors{3}=my_colors('red');
colors{4}=my_colors('orange');
colors{5}=my_colors('blue');
colors{6}=my_colors('red');
%%
labels={'Sham-OF','Sham-RAM','Injured-OF','Injured-RAM','Sham','Injured'};
%%
Fontname='arial';
Fontsize=12;
lw=2;
%%
cutoff=(f>=78).*(f<=505);
cutoff=logical(cutoff);
F=f(cutoff);
m=32;
FF=linspace(min(F),max(F),m);
%%
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
