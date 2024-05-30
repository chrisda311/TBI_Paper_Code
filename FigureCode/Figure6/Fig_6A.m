%% Load Data
cd 'X:\Chris\R01RatPaper\DataBlocks\SW_Fig'
% cd 'Z:\Chris\R01RatPaper\DataBlocks\SW_Fig'
load('TF_example_data.mat')
addpath(genpath('\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\SWR_Test'))

%%
clc;
clf
cut=(f>=79.8).*(f<501);
cut=logical(cut);
% th_R=1.98497709789081e-05;
% th_FR=1.51611338878865e-05;
before=0.1;
after=0.1;
R_T=[ripples.com_time];
FR_T=[fast_ripples.com_time];
pick_event=25;
t1=starts(pick_event);
t2=stops(pick_event);
pick_RT=[];
for j=1:length(R_T)
    if R_T(j)>t1
        if R_T(j)<t2
            pick_RT=[pick_RT;j];
        end
    end
end
pick_FRT=[];
for j=1:length(FR_T)
    if FR_T(j)>t1
        if FR_T(j)<t2
            pick_FRT=[pick_FRT,j];
        end
    end
end
% pick_FRT=15;
tm=0.5*(t2+t1);
I0=floor((t1)*3000);
J0=floor((t2)*3000);
I=floor((tm-before)*3000);
J=floor((tm+after)*3000);
Z0=z(cut,I0:J0);
Z=z(cut,I:J);
t=I:J;
t=t/3000;
% t=t(1:size(Z,2));
subplot(1,3,2)
contourf(t-t(1) ,f(cut),Z,20,linecolor='none');
if ~isempty(pick_RT)
    hold on
    for j=1:length(pick_RT)
        X=double(ripples(pick_RT(j)).time-t(1) );
        Y=double(ripples(pick_RT(j)).freqs);
        k=boundary(X,Y);
        plot(X(k),Y(k),linewidth=2,color=my_colors('red'))
    end
end
if ~isempty(pick_FRT)
    hold on
    for j=1:length(pick_FRT)
        X=double(fast_ripples(pick_FRT(j)).time-t(1) );
        Y=double(fast_ripples(pick_FRT(j)).freqs);
        k=boundary(X,Y);
        plot(X(k),Y(k),linewidth=2,color=my_colors('red'))
    end
end
xline(t1-t(1),'r--')
xline(t2-t(1),'r--')
subplot(1,3,3)
plot(mean(Z0,2)*1000,f(cut));
signal=current_shank(:,I:J);
signal_viewer(signal, fs=3000,window=1,channels=1:32,subplot=[1,3,1])

%%
sig = signal(:,2:end);
sig(8,:) = (sig(7,:) + sig(9,:)) / 2;
sig(24,:) = (sig(23,:) + sig(25,:)) / 2;

%%

figure;

% Trace
subplot(1,3,1); 
for i=1:size(sig,1)
    if i==18
        plot(1/3000:1/3000:0.2,sig(i,:)-(i-1)*1e-3,'k','LineWidth',1);
    else
        plot(1/3000:1/3000:0.2,sig(i,:)-(i-1)*1e-3,'Color',[0.5 0.5 0.5]);
        hold on;
    end
end
ylim([-0.033 0.001])
plot([0.1 0.1],[0 -0.001],'k','LineWidth',1)
plot([0.1 0.12],[-0.001 -0.001],'k','LineWidth',1)

% Blob
subplot(1,3,2)
contourf(t-t(1) ,f(cut),Z,20,linecolor='none');
if ~isempty(pick_RT)
    hold on
    for j=1:length(pick_RT)
        X=double(ripples(pick_RT(j)).time-t(1) );
        Y=double(ripples(pick_RT(j)).freqs);
        k=boundary(X,Y);
        plot(X(k),Y(k),linewidth=2,color=my_colors('red'))
    end
end
if ~isempty(pick_FRT)
    hold on
    for j=1:length(pick_FRT)
        X=double(fast_ripples(pick_FRT(j)).time-t(1) );
        Y=double(fast_ripples(pick_FRT(j)).freqs);
        k=boundary(X,Y);
        plot(X(k),Y(k),linewidth=2,color=my_colors('red'))
    end
end
xline(t1-t(1),'r--')
xline(t2-t(1),'r--')
ylim([80 500])

% FreqAmp
subplot(1,3,3)
plot(mean(Z0,2)*1000,f(cut),'k');
ylim([80 500])
