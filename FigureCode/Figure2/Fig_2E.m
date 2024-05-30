%% Load Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\PAC_Summary'
load('PAC_BroadbandDat_V1_OF_Moving.mat')

% Define Sham and Inj
sh0in1 = [0; 0; 1; 1; 1; 1; 0; 0; 1];

%% Get Mean Per Rat

% Pyr-Pyr
for i=1:size(p_pyrpyr,1)
    for j=1:size(p_pyrpyr,2)
        asdf(1,j) = ~isempty(pac_pyrpyr{i,j});
    end
    n=sum(asdf);
    for ii=1:n
        temp(ii,:) = p_pyrpyr{i,ii};
    end
    p_mpr_pp(i,:) = mean(temp,1);
    clear temp
end
clear asdf i ii j n

% Rad-Rad
for i=1:size(p_radrad,1)
    for j=1:size(p_radrad,2)
        asdf(1,j) = ~isempty(pac_radrad{i,j});
    end
    n=sum(asdf);
    for ii=1:n
        temp(ii,:) = p_radrad{i,ii};
    end
    p_mpr_rr(i,:) = mean(temp,1);
    clear temp
end
clear asdf i ii j n

%% Get mean Sham vs Inj
iSham = find(sh0in1 == 0); iInj = find(sh0in1 == 1);

for i=1:length(iSham)
    tempsh_pp(i,:) = p_mpr_pp(iSham(i),:);
    tempsh_rr(i,:) = p_mpr_rr(iSham(i),:);
end
p_sham_pp = mean(tempsh_pp); p_sham_rr = mean(tempsh_rr);

for i=1:length(iInj)
    tempinj_pp(i,:) = p_mpr_pp(iInj(i),:);
    tempinj_rr(i,:) = p_mpr_rr(iInj(i),:);
end
p_inj_pp = mean(tempinj_pp); p_inj_rr = mean(tempinj_rr);

%% Plot
p_sh_pp_low = p_sham_pp; p_inj_pp_low = p_inj_pp;
p_sh_rr_low = p_sham_rr; p_inj_rr_low = p_inj_rr;
bEd2 = [bEd (bEd+2*pi)]; bEd2 = unique(bEd2);
bEdeg2 = rad2deg(bEd2);

figure;
subplot(1,2,1); histogram('BinEdges',bEdeg2,'BinCounts',[p_sh_pp_low p_sh_pp_low],'FaceColor','b'); hold on;
histogram('BinEdges',bEdeg2,'BinCounts',[p_inj_pp_low p_inj_pp_low],'FaceColor','r'); 
plot(bEdeg2,cos(deg2rad(bEdeg2(1:end)))*0.002+0.06,'k'); ylim([0.04 0.07]); title('LOW PyrTh PyrGam'); xticks([min(bEdeg2):90:max(bEdeg2)]); xlim([-180 540])

subplot(1,2,2); histogram('BinEdges',bEdeg2,'BinCounts',[p_sh_rr_low p_sh_rr_low],'FaceColor','b'); hold on;
histogram('BinEdges',bEdeg2,'BinCounts',[p_inj_rr_low p_inj_rr_low],'FaceColor','r');
plot(bEdeg2,cos(deg2rad(bEdeg2(1:end)))*0.002+0.06,'k'); ylim([0.04 0.07]); title('LOW RadTh RadGam'); xticks([min(bEdeg2):90:max(bEdeg2)]); xlim([-180 540])
