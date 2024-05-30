%% Load Data
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\PAC_Summary'
load('PAC_Dat_V1_OF_Moving.mat')

ph = params.phase_freq_range + params.phase_freq_width/2;
amp = params.amp_freq_range + params.amp_freq_width/2;
sh0in1 = [0; 0; 1; 1; 1; 1; 0; 0; 1];

%% Get Mean Per Rat

% PyramidalTheta-PyramidalGamma
for i=1:size(pac_pyrpyr,1)
    for j=1:size(pac_pyrpyr,2)
        asdf(1,j) = ~isempty(pac_pyrpyr{i,j});
    end
    n = sum(asdf);
    for ii=1:n
        mpr(:,:,ii) = pac_pyrpyr{i,ii};
    end
    pacmpr_pyrpyr(i,1) = {mean(mpr,3)};
    clear mpr asdf n
end

% RadiatumTheta-RadiatumGamma
for i=1:size(pac_radrad,1)
    for j=1:size(pac_radrad,2)
        asdf(1,j) = ~isempty(pac_radrad{i,j});
    end
    n = sum(asdf);
    for ii=1:n
        mpr(:,:,ii) = pac_radrad{i,ii};
    end
    pacmpr_radrad(i,1) = {mean(mpr,3)};
    clear mpr asdf n
end

clear i ii j

%% Mean Across Sham and Inj

isham = find(sh0in1==0);
for i=1:length(isham)
    temp_pp(:,:,i) = pacmpr_pyrpyr{isham(i),1};
    temp_rr(:,:,i) = pacmpr_radrad{isham(i),1};
end
shamPACpp = mean(temp_pp,3); shamPACrr = mean(temp_rr,3);
clear temp_pp temp_rr i

iinj = find(sh0in1==1);
for i=1:length(iinj)
    temp_pp(:,:,i) = pacmpr_pyrpyr{iinj(i),1};
    temp_rr(:,:,i) = pacmpr_radrad{iinj(i),1};
end
injPACpp = mean(temp_pp,3); injPACrr = mean(temp_rr,3);
clear temp_pp temp_rr i

mmShInjpp = [min([min(min(shamPACpp)) min(min(injPACpp))]) max([max(max(shamPACpp)) max(max(injPACpp))])];
mmShInjrr = [min([min(min(shamPACrr)) min(min(injPACrr))]) max([max(max(shamPACrr)) max(max(injPACrr))])];

diffShInjpp = shamPACpp-injPACpp; mmdifShInpp = [-max(max(abs(diffShInjpp))) max(max(abs(diffShInjpp)))];
diffShInjrr = shamPACrr-injPACrr; mmdifShInrr = [-max(max(abs(diffShInjrr))) max(max(abs(diffShInjrr)))];

%% Plot

pltlim2 = [min(min([mmShInjpp; mmShInjrr])) max(max([mmShInjpp; mmShInjrr]))];
diffpltlim2 = [-max(abs([mmdifShInpp mmdifShInrr])) max(abs([mmdifShInpp mmdifShInrr]))];

figure;
subplot(2,2,1); contourf(ph,amp,shamPACpp',20,'EdgeAlpha',0); set(gca,'yscale','log'); yticks([30 60 120 190]); ylim([30 190]); xlim([1.5 15.5]); xticks(2:2:14); clim([pltlim2]); title('Sham PP'); colorbar
subplot(2,2,2); contourf(ph,amp,injPACpp',20,'EdgeAlpha',0); set(gca,'yscale','log'); yticks([30 60 120 190]); ylim([30 190]); xlim([1.5 15.5]); xticks(2:2:14); clim([pltlim2]); title('Injured PP'); colorbar
subplot(2,2,3); contourf(ph,amp,shamPACrr',20,'EdgeAlpha',0); set(gca,'yscale','log'); yticks([30 60 120 190]); ylim([30 190]); xlim([1.5 15.5]); xticks(2:2:14); clim([pltlim2]); title('Sham RR'); colorbar
subplot(2,2,4); contourf(ph,amp,injPACrr',20,'EdgeAlpha',0); set(gca,'yscale','log'); yticks([30 60 120 190]); ylim([30 190]); xlim([1.5 15.5]); xticks(2:2:14); clim([pltlim2]); title('Injured RR'); colorbar

figure;
subplot(2,1,1); contourf(ph,amp,diffShInjpp',20,'EdgeAlpha',0); set(gca,'yscale','log'); yticks([30 60 120 190]); ylim([30 190]); xlim([1.5 15.5]); xticks(2:2:14); clim(diffpltlim2); colormap('jet'); title('Sh-Inj PP'); colorbar
subplot(2,1,2); contourf(ph,amp,diffShInjrr',20,'EdgeAlpha',0); set(gca,'yscale','log'); yticks([30 60 120 190]); ylim([30 190]); xlim([1.5 15.5]); xticks(2:2:14); clim(diffpltlim2); colormap('jet'); title('Sh-Inj RR'); colorbar
