%% PWD
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\PowerSummary'

%% Better format for Electrode Locations
% Get Electrode Localization Information
cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper'
ElectrodeLocalization

% Electrode Locations in the OF and RAM
for i=1:9
    
    % Gets true chan # (each shank starts at 1 so this corrects that)
    if rem(i,2) == 1 % If it's a 4 shank animal   
        chfact = [0 16 32 48]; chfact = repmat(chfact,3,1);
    elseif rem(i,2) == 0 % If it's a 2 shank animal
        chfact = [0 32 NaN NaN]; chfact = repmat(chfact,3,1);
    end

    % Pulls channels for each shank and converts to CSC # (see above)
    for ii=1:3
        LocInEnv(i,1).OF(:,:,ii) = eLoc.a(i).d(ii).c(1).l + chfact;
        LocInEnv(i,1).RAM(:,:,ii) = eLoc.a(i).d(ii).c(2).l + chfact;
    end
end

clearvars -except LocInEnv

%% Get Power Spectra
for a=1:9 % Animal Number
    for d=1:3 % Day
        % Gets Power Spect from desired channels in the OF
        cd(['\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Animal' num2str(a) '\Day' num2str(d) '\OF'])
        load('final_cwt_power.mat')
        for loc=1:3
            for sh=1:4
                if ~isnan(LocInEnv(a).OF(loc,sh,d))
                    psmov10(a,1).OF(loc,sh,d) = {double(channel(LocInEnv(a).OF(loc,sh,d)).power_more(1,:))};
                    psstill10(a,1).OF(loc,sh,d) = {double(channel(LocInEnv(a).OF(loc,sh,d)).power_less(1,:))};
                else
                    psmov10(a,1).OF(loc,sh,d) = {nan(1,length(f))};
                    psstill10(a,1).OF(loc,sh,d) = {nan(1,length(f))};
                end
            end
        end
        % Gets Power Spect from desired channels in the RAM
        cd(['\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\Animal' num2str(a) '\Day' num2str(d) '\RAM'])
        load('final_cwt_power.mat')
        for loc=1:3
            for sh=1:4
                if ~isnan(LocInEnv(a).RAM(loc,sh,d))
                    psmov10(a,1).RAM(loc,sh,d) = {double(channel(LocInEnv(a).RAM(loc,sh,d)).power_more(1,:))};
                    psstill10(a,1).RAM(loc,sh,d) = {double(channel(LocInEnv(a).RAM(loc,sh,d)).power_less(1,:))};
                else
                    psmov10(a,1).RAM(loc,sh,d) = {nan(1,length(f))};
                    psstill10(a,1).RAM(loc,sh,d) = {nan(1,length(f))};
                end
            end
        end

    end
end

clearvars -except psmov10 psstill10 f LocInEnv

cd '\\dendrite.med.upenn.edu\synodataii\Chris\R01RatPaper\DataBlocks\PowerSummary'

%% Separate Sham vs Injured
% KEY:
% psmov10(#Animal#).OF(#Location#,#Shank#,#Day#)

% Index of sham and injured animals
sh0in1 = [0; 0; 1; 1; 1; 1; 0; 0; 1];

% Separate Sham and Injured Power Spectra
iSham = find(sh0in1 == 0);
for i=1:sum(sh0in1==0)
    psmov10Sh(i,1).OF = psmov10(iSham(i,1)).OF; psstill10Sh(i,1).OF = psstill10(iSham(i,1)).OF;
    psmov10Sh(i,1).RAM = psmov10(iSham(i,1)).RAM; psstill10Sh(i,1).RAM = psstill10(iSham(i,1)).RAM;
end
iInj = find(sh0in1 == 1);
for i=1:sum(sh0in1==1)
    psmov10Inj(i,1).OF = psmov10(iInj(i,1)).OF; psstill10Inj(i,1).OF = psstill10(iInj(i,1)).OF;
    psmov10Inj(i,1).RAM = psmov10(iInj(i,1)).RAM; psstill10Inj(i,1).RAM = psstill10(iInj(i,1)).RAM;
end

clear psmov10 psstill10 i sh0in1

%% Get All Days All Animals OF Only (Sham/Inj, Pyr/Rad, Still/Moving)
% Key:
% psmov10(#Animal#).OF(#Location#,#Shank#,#Day#)

% Sham Pyramidal Cell Layer
adpsall.sh_pyr_still = []; adpsall.sh_pyr_movin = []; adpsall.sh_pyr_IDs = [];
for i=1:size(psstill10Sh,1)
    tempA_Still = squeeze(psstill10Sh(i).OF(1,:,:))';
    tempA_Mov = squeeze(psmov10Sh(i).OF(1,:,:))';
    countA = 1;
    for d=1:3
        for sh=1:4
            if ~isnan(tempA_Still{d,sh}(1))
                adpsall.sh_pyr_still = [adpsall.sh_pyr_still; tempA_Still{d,sh}];
                adpsall.sh_pyr_movin = [adpsall.sh_pyr_movin; tempA_Mov{d,sh}];
                adpsall.sh_pyr_IDs = [adpsall.sh_pyr_IDs; iSham(i)];
                countA = countA + 1;
            end
        end
    end
end
% Sham Radiatum
adpsall.sh_rad_still = []; adpsall.sh_rad_movin = []; adpsall.sh_rad_IDs = [];
for i=1:size(psstill10Sh,1)
    tempA_Still = squeeze(psstill10Sh(i).OF(2,:,:))';
    tempA_Mov = squeeze(psmov10Sh(i).OF(2,:,:))';
    countA = 1;
    for d=1:3
        for sh=1:4
            if ~isnan(tempA_Still{d,sh}(1))
                adpsall.sh_rad_still = [adpsall.sh_rad_still; tempA_Still{d,sh}];
                adpsall.sh_rad_movin = [adpsall.sh_rad_movin; tempA_Mov{d,sh}];
                adpsall.sh_rad_IDs = [adpsall.sh_rad_IDs; iSham(i)];
                countA = countA + 1;
            end
        end
    end
end

% Injured Pyramidal Cell Layer
adpsall.inj_pyr_still = []; adpsall.inj_pyr_movin = []; adpsall.inj_pyr_IDs = [];
for i=1:size(psstill10Inj,1)
    tempA_Still = squeeze(psstill10Inj(i).OF(1,:,:))';
    tempA_Mov = squeeze(psmov10Inj(i).OF(1,:,:))';
    countA = 1;
    for d=1:3
        for sh=1:4
            if ~isnan(tempA_Still{d,sh}(1))
                adpsall.inj_pyr_still = [adpsall.inj_pyr_still; tempA_Still{d,sh}];
                adpsall.inj_pyr_movin = [adpsall.inj_pyr_movin; tempA_Mov{d,sh}];
                adpsall.inj_pyr_IDs = [adpsall.inj_pyr_IDs; iInj(i)];
                countA = countA + 1;
            end
        end
    end
end
% Injured Radiatum
adpsall.inj_rad_still = []; adpsall.inj_rad_movin = []; adpsall.inj_rad_IDs = [];
for i=1:size(psstill10Inj,1)
    tempA_Still = squeeze(psstill10Inj(i).OF(2,:,:))';
    tempA_Mov = squeeze(psmov10Inj(i).OF(2,:,:))';
    countA = 1;
    for d=1:3
        for sh=1:4
            if ~isnan(tempA_Still{d,sh}(1))
                adpsall.inj_rad_still = [adpsall.inj_rad_still; tempA_Still{d,sh}];
                adpsall.inj_rad_movin = [adpsall.inj_rad_movin; tempA_Mov{d,sh}];
                adpsall.inj_rad_IDs = [adpsall.inj_rad_IDs; iInj(i)];
                countA = countA + 1;
            end
        end
    end
end

clear countA d i sh tempA_Still tempA_Mov

%% Get Mean and StDev for All Days Pyr/Rad

% SHAM
for i=1:length(iSham)
    % Pyramidal Cell Layer
    adpsmpr.sh_pyr_still.me(i,:) = mean(adpsall.sh_pyr_still(adpsall.sh_pyr_IDs==iSham(i),:),1); % adpsmpr.sh_pyr_still.sd(i,:) = std(adpsall.sh_pyr_still(adpsall.sh_pyr_IDs==iSham(i),:),1);
    adpsmpr.sh_pyr_movin.me(i,:) = mean(adpsall.sh_pyr_movin(adpsall.sh_pyr_IDs==iSham(i),:),1); % adpsmpr.sh_pyr_movin.sd(i,:) = std(adpsall.sh_pyr_movin(adpsall.sh_pyr_IDs==iSham(i),:),1);
    adpsmpr.sh_pyr_IDs(i,:) = iSham(i);
    % Radiatum
    adpsmpr.sh_rad_still.me(i,:) = mean(adpsall.sh_rad_still(adpsall.sh_rad_IDs==iSham(i),:),1); % adpsmpr.sh_rad_still.sd(i,:) = std(adpsall.sh_rad_still(adpsall.sh_rad_IDs==iSham(i),:),1);
    adpsmpr.sh_rad_movin.me(i,:) = mean(adpsall.sh_rad_movin(adpsall.sh_rad_IDs==iSham(i),:),1); % adpsmpr.sh_rad_movin.sd(i,:) = std(adpsall.sh_rad_movin(adpsall.sh_rad_IDs==iSham(i),:),1);
    adpsmpr.sh_rad_IDs(i,:) = iSham(i);
end

% INJURED
for i=1:length(iInj)
    % Pyramidal Cell Layer
    adpsmpr.inj_pyr_still.me(i,:) = mean(adpsall.inj_pyr_still(adpsall.inj_pyr_IDs==iInj(i),:),1); % adpsmpr.inj_pyr_still.sd(i,:) = std(adpsall.inj_pyr_still(adpsall.inj_pyr_IDs==iInj(i),:),1);
    adpsmpr.inj_pyr_movin.me(i,:) = mean(adpsall.inj_pyr_movin(adpsall.inj_pyr_IDs==iInj(i),:),1); % adpsmpr.inj_pyr_movin.sd(i,:) = std(adpsall.inj_pyr_movin(adpsall.inj_pyr_IDs==iInj(i),:),1);
    adpsmpr.inj_pyr_IDs(i,:) = iInj(i);
    % Radiatum
    adpsmpr.inj_rad_still.me(i,:) = mean(adpsall.inj_rad_still(adpsall.inj_rad_IDs==iInj(i),:),1); % adpsmpr.inj_rad_still.sd(i,:) = std(adpsall.inj_rad_still(adpsall.inj_rad_IDs==iInj(i),:),1); % This doesn't work because the 1st animal only is in radiatum once, so we can't get a stdev with one set of values
    adpsmpr.inj_rad_movin.me(i,:) = mean(adpsall.inj_rad_movin(adpsall.inj_rad_IDs==iInj(i),:),1); % adpsmpr.inj_rad_movin.sd(i,:) = std(adpsall.inj_rad_movin(adpsall.inj_rad_IDs==iInj(i),:),1);
    adpsmpr.inj_rad_IDs(i,:) = iInj(i);
end

clear i

%% Get Means Across Sham & Injured

% ALL DAYS - ALL
adpsall.me.sh_pyr_still = mean(adpsall.sh_pyr_still); adpsall.sd.sh_pyr_still = std(adpsall.sh_pyr_still);
adpsall.me.sh_pyr_movin = mean(adpsall.sh_pyr_movin); adpsall.sd.sh_pyr_movin = std(adpsall.sh_pyr_movin);
adpsall.me.sh_rad_still = mean(adpsall.sh_rad_still); adpsall.sd.sh_rad_still = std(adpsall.sh_rad_still);
adpsall.me.sh_rad_movin = mean(adpsall.sh_rad_movin); adpsall.sd.sh_rad_movin = std(adpsall.sh_rad_movin);
adpsall.me.inj_pyr_still = mean(adpsall.inj_pyr_still); adpsall.sd.inj_pyr_still = std(adpsall.inj_pyr_still);
adpsall.me.inj_pyr_movin = mean(adpsall.inj_pyr_movin); adpsall.sd.inj_pyr_movin = std(adpsall.inj_pyr_movin);
adpsall.me.inj_rad_still = mean(adpsall.inj_rad_still); adpsall.sd.inj_rad_still = std(adpsall.inj_rad_still);
adpsall.me.inj_rad_movin = mean(adpsall.inj_rad_movin); adpsall.sd.inj_rad_movin = std(adpsall.inj_rad_movin);
% ALL DAYS - MEAN PER RAT
adpsmpr.me.sh_pyr_still = mean(adpsmpr.sh_pyr_still.me); adpsmpr.sd.sh_pyr_still = std(adpsmpr.sh_pyr_still.me);
adpsmpr.me.sh_pyr_movin = mean(adpsmpr.sh_pyr_movin.me); adpsmpr.sd.sh_pyr_movin = std(adpsmpr.sh_pyr_movin.me);
adpsmpr.me.sh_rad_still = mean(adpsmpr.sh_rad_still.me); adpsmpr.sd.sh_rad_still = std(adpsmpr.sh_rad_still.me);
adpsmpr.me.sh_rad_movin = mean(adpsmpr.sh_rad_movin.me); adpsmpr.sd.sh_rad_movin = std(adpsmpr.sh_rad_movin.me);
adpsmpr.me.inj_pyr_still = mean(adpsmpr.inj_pyr_still.me); adpsmpr.sd.inj_pyr_still = std(adpsmpr.inj_pyr_still.me);
adpsmpr.me.inj_pyr_movin = mean(adpsmpr.inj_pyr_movin.me); adpsmpr.sd.inj_pyr_movin = std(adpsmpr.inj_pyr_movin.me);
adpsmpr.me.inj_rad_still = mean(adpsmpr.inj_rad_still.me); adpsmpr.sd.inj_rad_still = std(adpsmpr.inj_rad_still.me);
adpsmpr.me.inj_rad_movin = mean(adpsmpr.inj_rad_movin.me); adpsmpr.sd.inj_rad_movin = std(adpsmpr.inj_rad_movin.me);

%% Check Normality - Point By Point

% Test Normality - kstest - returns 0 if normal and 1 if not normal
for i=1:length(f)
    % All Days All - None are normal
    nc.adall.sh_pyr_still(1,i) = kstest(adpsall.sh_pyr_still(:,i));
    nc.adall.sh_pyr_movin(1,i) = kstest(adpsall.sh_pyr_movin(:,i));
    nc.adall.sh_rad_still(1,i) = kstest(adpsall.sh_rad_still(:,i));
    nc.adall.sh_rad_movin(1,i) = kstest(adpsall.sh_rad_movin(:,i));
    nc.adall.inj_pyr_still(1,i) = kstest(adpsall.inj_pyr_still(:,i));
    nc.adall.inj_pyr_movin(1,i) = kstest(adpsall.inj_pyr_movin(:,i));
    nc.adall.inj_rad_still(1,i) = kstest(adpsall.inj_rad_still(:,i));
    nc.adall.inj_rad_movin(1,i) = kstest(adpsall.inj_rad_movin(:,i));
    % All Days Mean/Rat - All are normal
    nc.admpr.sh_pyr_still(1,i) = kstest(adpsmpr.sh_pyr_still.me(:,i));
    nc.admpr.sh_pyr_movin(1,i) = kstest(adpsmpr.sh_pyr_movin.me(:,i));
    nc.admpr.sh_rad_still(1,i) = kstest(adpsmpr.sh_rad_still.me(:,i));
    nc.admpr.sh_rad_movin(1,i) = kstest(adpsmpr.sh_rad_movin.me(:,i));
    nc.admpr.inj_pyr_still(1,i) = kstest(adpsmpr.inj_pyr_still.me(:,i));
    nc.admpr.inj_pyr_movin(1,i) = kstest(adpsmpr.inj_pyr_movin.me(:,i));
    nc.admpr.inj_rad_still(1,i) = kstest(adpsmpr.inj_rad_still.me(:,i));
    nc.admpr.inj_rad_movin(1,i) = kstest(adpsmpr.inj_rad_movin.me(:,i));
end

clear i

%% Run Stats on Mean/Rat Data - Point by Point

% Mean/Rat
for i=1:length(f)
    % All Days
    [h,p] = ttest2(adpsmpr.sh_pyr_still.me(:,i),adpsmpr.inj_pyr_still.me(:,i));
    tt.admpr_SvI.sh_pyr_still(1,i) = h; tt.admpr_SvI.sh_pyr_still(2,i) = p;
    [h,p] = ttest2(adpsmpr.sh_pyr_movin.me(:,i),adpsmpr.inj_pyr_movin.me(:,i));
    tt.admpr_SvI.sh_pyr_movin(1,i) = h; tt.admpr_SvI.sh_pyr_movin(2,i) = p;
    [h,p] = ttest2(adpsmpr.sh_rad_still.me(:,i),adpsmpr.inj_rad_still.me(:,i));
    tt.admpr_SvI.sh_rad_still(1,i) = h; tt.admpr_SvI.sh_rad_still(2,i) = p;
    [h,p] = ttest2(adpsmpr.sh_rad_movin.me(:,i),adpsmpr.inj_rad_movin.me(:,i));
    tt.admpr_SvI.sh_rad_movin(1,i) = h; tt.admpr_SvI.sh_rad_movin(2,i) = p;
end

%% Use from 1.5-300Hz
% When you subtract the sd from the mean for inj rats (pyr layer) there are
% a couple values that are negative that prevent you from plotting. To
% avoid this use only values over 1.5 Hz.

% New freq values for plotting
fplt = f(f>=1.5);

% Get mean and sd data for plotting
spme = adpsmpr.me.sh_pyr_movin(f>=1.5);
spsd = adpsmpr.sd.sh_pyr_movin(f>=1.5);
ipme = adpsmpr.me.inj_pyr_movin(f>=1.5);
ipsd = adpsmpr.sd.inj_pyr_movin(f>=1.5);
srme = adpsmpr.me.sh_rad_movin(f>=1.5);
srsd = adpsmpr.sd.sh_rad_movin(f>=1.5);
irme = adpsmpr.me.inj_rad_movin(f>=1.5);
irsd = adpsmpr.sd.inj_rad_movin(f>=1.5);

%% Plot
figure;
subplot(2,1,1); loglog(fplt,spme,'b'); hold on;
spfill = fill([fplt; flipud(fplt)],[spme+spsd fliplr(spme-spsd)],'b'); set(spfill,'facealpha',.3); set(spfill,'edgealpha',0);
loglog(fplt,ipme,'r'); hold on;
sifill = fill([fplt; flipud(fplt)],[ipme+ipsd fliplr(ipme-ipsd)],'r'); set(sifill,'facealpha',.3); set(sifill,'edgealpha',0);
xlim([1 300]); ylim([1e-11 1e-7]); title('Pyr Layer Moving')
asdf = find(diff(tt.admpr_SvI.sh_pyr_movin(1,:)) ~= 0);
plot([f(asdf(1)+1) f(asdf(2))],[8e-8 8e-8],'-k','LineWidth',3)
sigfillp = fill([f(asdf(1)+1) f(asdf(2)) f(asdf(2)) f(asdf(1)+1)],[1e-11 1e-11 1e-7 1e-7],'k'); set(sigfillp,'facealpha',.3); set(sigfillp,'edgealpha',0);
xline(5); xline(10); xline(30); xline(59);
subplot(2,1,2); loglog(fplt,srme,'b'); hold on;
spfill = fill([fplt; flipud(fplt)],[srme+srsd fliplr(srme-srsd)],'b'); set(spfill,'facealpha',.3); set(spfill,'edgealpha',0);
loglog(fplt,irme,'r'); hold on;
sifill = fill([fplt; flipud(fplt)],[irme+irsd fliplr(irme-irsd)],'r'); set(sifill,'facealpha',.3); set(sifill,'edgealpha',0);
xlim([1 300]); ylim([1e-11 1e-7]); title('Radiatum Moving')
qwer = find(diff(tt.admpr_SvI.sh_rad_movin(1,:)) ~= 0); qwer2 = reshape(qwer,2,[]);
for i=1:size(qwer2,2)
    sigfillp2 = fill([f(qwer2(1,i)+1) f(qwer2(2,i)) f(qwer2(2,i)) f(qwer2(1,i)+1)],[1e-11 1e-11 1e-7 1e-7],'k'); set(sigfillp2,'facealpha',.3); set(sigfillp2,'edgealpha',0);
    plot([f(qwer2(1,i)+1) f(qwer2(2,i))],[8e-8 8e-8],'-k','LineWidth',3)
end
xline(5); xline(10); xline(30); xline(59);

%% Area Under Curve THETA - ALL DAYs

% [~,ilow] = min(abs(double(f)-5)) % 297
% [~,ihigh] = min(abs(double(f)-10)) % 261
% double(f(297)) % 5.0229
% double(f(261)) % 10.0458

% SHAM
for i=1:length(iSham)
    thpow.admpr.sh_pyr_still(i,:) = trapz(flipud(double(f(261:279))),adpsmpr.sh_pyr_still.me(i,261:279));
    thpow.admpr.sh_pyr_movin(i,:) = trapz(flipud(double(f(261:279))),adpsmpr.sh_pyr_movin.me(i,261:279));
    thpow.admpr.sh_rad_still(i,:) = trapz(flipud(double(f(261:279))),adpsmpr.sh_rad_still.me(i,261:279));
    thpow.admpr.sh_rad_movin(i,:) = trapz(flipud(double(f(261:279))),adpsmpr.sh_rad_movin.me(i,261:279));
end
% INJURED
for i=1:length(iInj)
    thpow.admpr.inj_pyr_still(i,:) = trapz(flipud(double(f(261:279))),adpsmpr.inj_pyr_still.me(i,261:279));
    thpow.admpr.inj_pyr_movin(i,:) = trapz(flipud(double(f(261:279))),adpsmpr.inj_pyr_movin.me(i,261:279));
    thpow.admpr.inj_rad_still(i,:) = trapz(flipud(double(f(261:279))),adpsmpr.inj_rad_still.me(i,261:279));
    thpow.admpr.inj_rad_movin(i,:) = trapz(flipud(double(f(261:279))),adpsmpr.inj_rad_movin.me(i,261:279));
end

% % Normal Scale
% figure;
% subplot(2,2,1); scatter(ones(length(iSham)),thpow.admpr.sh_pyr_still,'filled','b'); hold on
% scatter(2*ones(length(iInj)),thpow.admpr.inj_pyr_still,'filled','r'); title('Pyr Layer Still Lin'); xlim([0 3])
% subplot(2,2,2); scatter(ones(length(iSham)),thpow.admpr.sh_pyr_movin,'filled','b'); hold on
% scatter(2*ones(length(iInj)),thpow.admpr.inj_pyr_movin,'filled','r'); title('Pyr Layer Moving Lin'); xlim([0 3])
% subplot(2,2,3); scatter(ones(length(iSham)),thpow.admpr.sh_rad_still,'filled','b'); hold on
% scatter(2*ones(length(iInj)),thpow.admpr.inj_rad_still,'filled','r'); title('Radiatum Still Lin'); xlim([0 3])
% subplot(2,2,4); scatter(ones(length(iSham)),thpow.admpr.sh_rad_movin,'filled','b'); hold on
% scatter(2*ones(length(iInj)),thpow.admpr.inj_rad_movin,'filled','r'); title('Radiatum Moving Lin'); xlim([0 3])
% 
% % Log Scale
% figure;
% subplot(2,2,1); scatter(ones(length(iSham)),log10(thpow.admpr.sh_pyr_still),'filled','b'); hold on
% scatter(2*ones(length(iInj)),log10(thpow.admpr.inj_pyr_still),'filled','r'); title('Pyr Layer Still Log'); xlim([0 3])
% subplot(2,2,2); scatter(ones(length(iSham)),log10(thpow.admpr.sh_pyr_movin),'filled','b'); hold on
% scatter(2*ones(length(iInj)),log10(thpow.admpr.inj_pyr_movin),'filled','r'); title('Pyr Layer Moving Log'); xlim([0 3])
% subplot(2,2,3); scatter(ones(length(iSham)),log10(thpow.admpr.sh_rad_still),'filled','b'); hold on
% scatter(2*ones(length(iInj)),log10(thpow.admpr.inj_rad_still),'filled','r'); title('Radiatum Still Log'); xlim([0 3])
% subplot(2,2,4); scatter(ones(length(iSham)),log10(thpow.admpr.sh_rad_movin),'filled','b'); hold on
% scatter(2*ones(length(iInj)),log10(thpow.admpr.inj_rad_movin),'filled','r'); title('Radiatum Moving Log'); xlim([0 3])

clear i

%% For prism - lin & log power THETA
linThPow.shPyr = thpow.admpr.sh_pyr_movin;
linThPow.shRad = thpow.admpr.sh_rad_movin;
linThPow.injPyr = thpow.admpr.inj_pyr_movin;
linThPow.InjRad = thpow.admpr.inj_rad_movin;

lgThPow.shPyr = log10(thpow.admpr.sh_pyr_movin);
lgThPow.shRad = log10(thpow.admpr.sh_rad_movin);
lgThPow.injPyr = log10(thpow.admpr.inj_pyr_movin);
lgThPow.InjRad = log10(thpow.admpr.inj_rad_movin);

%% Run Stats Theta - ALL DAYs

% % Test Normality - kstest - returns 0 if normal and 1 if not normal - ALL ARE NORMAL
% kstest(thpow.admpr.sh_pyr_still)
% kstest(thpow.admpr.sh_pyr_movin)
% kstest(thpow.admpr.sh_rad_still)
% kstest(thpow.admpr.sh_rad_movin)
% kstest(thpow.admpr.inj_pyr_still)
% kstest(thpow.admpr.inj_pyr_movin)
% kstest(thpow.admpr.inj_rad_still)
% kstest(thpow.admpr.inj_rad_movin)

admprthetaPow = {thpow.admpr.sh_pyr_still thpow.admpr.sh_pyr_movin thpow.admpr.sh_rad_still thpow.admpr.sh_rad_movin...
    thpow.admpr.inj_pyr_still thpow.admpr.inj_pyr_movin thpow.admpr.inj_rad_still thpow.admpr.inj_rad_movin};
admprthetaPow_KEY = {'sh pyr still' 'sh pyr movin' 'sh rad still' 'sh rad movin' 'inj pyr still' 'inj pyr movin' 'inj rad still' 'inj rad movin'};

for i=1:length(admprthetaPow_KEY)
    for ii=1:length(admprthetaPow_KEY)
        [h,p] = ttest2(admprthetaPow{i},admprthetaPow{ii});
        h_admprthetaPow(i,ii) = h;
        p_admprthetaPow(i,ii) = p;
    end
end

clear i ii ax h p

p_admprthetaPow(2,6) %ShPyrMov vs InjPyrMov
p_admprthetaPow(4,8) %ShPyrMov vs InjPyrMov

%% Area Under Curve GAMMA - ALL DAYs
% PULLS GAMMA POWER (30-59Hz)
% [~,ilow] = min(abs(double(f)-30)) % 204
% [~,ihigh] = min(abs(double(f)-59)) % 169
% double(f(204)) % 30.1035
% double(f(169)) % 59.0588

% SHAM
for i=1:length(iSham)
    gampow.admpr.sh_pyr_still(i,:) = trapz(flipud(double(f(169:204))),adpsmpr.sh_pyr_still.me(i,169:204));
    gampow.admpr.sh_pyr_movin(i,:) = trapz(flipud(double(f(169:204))),adpsmpr.sh_pyr_movin.me(i,169:204));
    gampow.admpr.sh_rad_still(i,:) = trapz(flipud(double(f(169:204))),adpsmpr.sh_rad_still.me(i,169:204));
    gampow.admpr.sh_rad_movin(i,:) = trapz(flipud(double(f(169:204))),adpsmpr.sh_rad_movin.me(i,169:204));
end
% INJURED
for i=1:length(iInj)
    gampow.admpr.inj_pyr_still(i,:) = trapz(flipud(double(f(169:204))),adpsmpr.inj_pyr_still.me(i,169:204));
    gampow.admpr.inj_pyr_movin(i,:) = trapz(flipud(double(f(169:204))),adpsmpr.inj_pyr_movin.me(i,169:204));
    gampow.admpr.inj_rad_still(i,:) = trapz(flipud(double(f(169:204))),adpsmpr.inj_rad_still.me(i,169:204));
    gampow.admpr.inj_rad_movin(i,:) = trapz(flipud(double(f(169:204))),adpsmpr.inj_rad_movin.me(i,169:204));
end

% % Normal Scale
% figure;
% subplot(2,2,1); scatter(ones(length(iSham)),gampow.admpr.sh_pyr_still,'filled','b'); hold on
% scatter(2*ones(length(iInj)),gampow.admpr.inj_pyr_still,'filled','r'); title('GAM Pyr Layer Still Lin'); xlim([0 3])
% subplot(2,2,2); scatter(ones(length(iSham)),gampow.admpr.sh_pyr_movin,'filled','b'); hold on
% scatter(2*ones(length(iInj)),gampow.admpr.inj_pyr_movin,'filled','r'); title('GAM Pyr Layer Moving Lin'); xlim([0 3])
% subplot(2,2,3); scatter(ones(length(iSham)),gampow.admpr.sh_rad_still,'filled','b'); hold on
% scatter(2*ones(length(iInj)),gampow.admpr.inj_rad_still,'filled','r'); title('GAM Radiatum Still Lin'); xlim([0 3])
% subplot(2,2,4); scatter(ones(length(iSham)),gampow.admpr.sh_rad_movin,'filled','b'); hold on
% scatter(2*ones(length(iInj)),gampow.admpr.inj_rad_movin,'filled','r'); title('GAM Radiatum Moving Lin'); xlim([0 3])
% 
% % Log Scale
% figure;
% subplot(2,2,1); scatter(ones(length(iSham)),log10(gampow.admpr.sh_pyr_still),'filled','b'); hold on
% scatter(2*ones(length(iInj)),log10(gampow.admpr.inj_pyr_still),'filled','r'); title('GAM Pyr Layer Still Log'); xlim([0 3])
% subplot(2,2,2); scatter(ones(length(iSham)),log10(gampow.admpr.sh_pyr_movin),'filled','b'); hold on
% scatter(2*ones(length(iInj)),log10(gampow.admpr.inj_pyr_movin),'filled','r'); title('GAM Pyr Layer Moving Log'); xlim([0 3])
% subplot(2,2,3); scatter(ones(length(iSham)),log10(gampow.admpr.sh_rad_still),'filled','b'); hold on
% scatter(2*ones(length(iInj)),log10(gampow.admpr.inj_rad_still),'filled','r'); title('GAM Radiatum Still Log'); xlim([0 3])
% subplot(2,2,4); scatter(ones(length(iSham)),log10(gampow.admpr.sh_rad_movin),'filled','b'); hold on
% scatter(2*ones(length(iInj)),log10(gampow.admpr.inj_rad_movin),'filled','r'); title('GAM Radiatum Moving Log'); xlim([0 3])

clear i

%% For prism - lin & log power GAMMA
linGamPow.shPyr = gampow.admpr.sh_pyr_movin;
linGamPow.shRad = gampow.admpr.sh_rad_movin;
linGamPow.injPyr = gampow.admpr.inj_pyr_movin;
linGamPow.InjRad = gampow.admpr.inj_rad_movin;

lgGamPow.shPyr = log10(gampow.admpr.sh_pyr_movin);
lgGamPow.shRad = log10(gampow.admpr.sh_rad_movin);
lgGamPow.injPyr = log10(gampow.admpr.inj_pyr_movin);
lgGamPow.InjRad = log10(gampow.admpr.inj_rad_movin);

%% Run Stats Gamma - ALL DAYs

% % Test Normality - kstest - returns 0 if normal and 1 if not normal - ALL ARE NORMAL
% kstest(gampow.admpr.sh_pyr_still)
% kstest(gampow.admpr.sh_pyr_movin)
% kstest(gampow.admpr.sh_rad_still)
% kstest(gampow.admpr.sh_rad_movin)
% kstest(gampow.admpr.inj_pyr_still)
% kstest(gampow.admpr.inj_pyr_movin)
% kstest(gampow.admpr.inj_rad_still)
% kstest(gampow.admpr.inj_rad_movin)

admprgammaPow = {gampow.admpr.sh_pyr_still gampow.admpr.sh_pyr_movin gampow.admpr.sh_rad_still gampow.admpr.sh_rad_movin...
    gampow.admpr.inj_pyr_still gampow.admpr.inj_pyr_movin gampow.admpr.inj_rad_still gampow.admpr.inj_rad_movin};
admprgammaPow_KEY = {'sh pyr still G' 'sh pyr movin G' 'sh rad still G' 'sh rad movin G' 'inj pyr still G' 'inj pyr movin G' 'inj rad still G' 'inj rad movin G'};

for i=1:length(admprgammaPow_KEY)
    for ii=1:length(admprgammaPow_KEY)
        [h,p] = ttest2(admprgammaPow{i},admprgammaPow{ii});
        h_admprgammaPow(i,ii) = h;
        p_admprgammaPow(i,ii) = p;
    end
end

clear i ii ax h p

p_admprgammaPow(2,6) %ShPyrMov vs InjPyrMov
p_admprgammaPow(4,8) %ShPyrMov vs InjPyrMov