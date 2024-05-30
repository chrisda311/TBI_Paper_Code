clc;
clear;
%%
current_folder=pwd;
addpath('.\Functions');
data_root=fullfile([current_folder(1),'Data']);
%%
folders=dir(data_root);
folders=folders([folders.isdir]);
%%
velocity_threshold= 10; % Setting velocity threshold for moving vs. still
%%
analyze_power=true;
%%
analyze_PAC=true;
if analyze_PAC
    channel_phase=12; % Channel for phase
    channel_amplitude=12; % Channel for amplitude
    phase_freq_range=logspace(log10(1),log10(15),40); % Frequencies for the phases to be checked
    amp_freq_range=logspace(log10(20),log10(180),20); % Frequencies for the amplitude to be checked
    phase_freq_width=1; % Width of frequency bins for phase
    amp_freq_width=20; % Width of frequency bins for amplitude
    num_bins=18; % Number of frequency binds
    num_perm_PAC=500; % Number of permutations
    n_down=5; % Second downsampling ratio
end
%%
analyze_entrainment=false;
if analyze_entrainment
    franges = [30;59];
    num_phases=length(franges);
    num_perm_Ent = 500;
    unit_numer=[1;4];
    channel_number=[10;12];
end
%%
analyze_SWR=true;
if analyze_SWR
    parameters.channels= 1:64; % Channels to loop through
    parameters.fs= 3000; % Sampling frequency
    parameters.chunks= 1; % Breaking data into smaller chunks
    parameters.verbose= false; % Display some information
    parameters.save_map=true;
    % Continuous wavelet transform (CWT) parameters
    parameters.wavelet= 'morse'; % Type of wavelet
    parameters.WaveletParameters= [9,120]; % Parameters of wavelet.
    parameters.VoicesPerOctave= 48; % Voices per octave
    parameters.FrequencyLimits= [95,250]; % Frequncy range for CWT analysis
    parameters.gpu= true; % Using gpu for CWT
    parameters.save_map=true;
    % Parameters for detecting and characterizing blobs
    parameters.compare= 'magnitude'; % Use "amplidute" or "power" for comparison
    parameters.center= 'max'; % Use "mean" or "max" as the center
    parameters.unimodal= false; % Making sure detected blobs are unimodal
    % Ripple detection parameters
    parameters.range=[80,250;250,500]; % Cutoff threshold
    parameters.ecdf= [0.993,0.998]; % Frequency range to detect ripples
    parameters.n_cyles= 3; % Number of cycles a ripple must have at the "center" frequency
    parameters.frequency_range_th= 98/100; % Allowable difference between lowest and higher frequncy of a blob
    parameters.std= 2; % Threshold that a blob mean/max needs to be compared to all the data at its central frequency
    parameters.ext= 1e6; % Upper limit allowed for comparison
    parameters.smoothing_window=10;
    % Detecting HFOs
    parameters_SW.lower=8;
    parameters_SW.upper=40;
    parameters_SW.fs=3000;
    parameters_SW.order=2;
end
%% Looping through folders
for i=1:size(folders,1)
    animal_name=folders(i).name;
    % Going through the folders for each animal
    if startsWith(animal_name,'Animal1')
        disp(animal_name)
        data_path=fullfile(data_root,animal_name);
        day_folders=dir(data_path);
        day_folders=day_folders([day_folders.isdir]);
        for j=1:size(day_folders,1)
            day_name=day_folders(j).name;
            % Going through each day of recording for each animal
            if startsWith(day_name,'Day1')
                disp(day_name)
                data_path=fullfile(data_root,animal_name,day_name);
                condition_folders=dir(data_path);
                condition_folders=condition_folders([condition_folders.isdir]);
                for k=1:size(condition_folders,1)
                    condition_name=condition_folders(k).name;
                    % Going through each condition (Familiar/Novel) for
                    % each animal
                    if ~startsWith(condition_name,'.')
                        disp(condition_name);
                        data_path=fullfile(data_root,animal_name,day_name,condition_name);
                        data=load(fullfile(data_root,animal_name,day_name,condition_name,'Data3k.mat')); % Loading the downsampled recording for each animal-day-condition
                        fs=data.fs;
                        data=data.Data3k;
                        velocity=load(fullfile(data_root,animal_name,day_name,condition_name,'InstVelocity_3k.mat')).velocity3k; % Loading the instantaneous velocity for each animal-day-condition
                        if analyze_power
                            disp('Power analysis')
                            results=cwt_power_analysis(data,fs,velocity,velocity_threshold);
                            path_to_save=fullfile(data_root,animal_name,day_name,condition_name,'cwt_power_analysis_test');
                            save(path_to_save,'results','velocity_threshold','-v7.3');
                        end
                        if analyze_PAC
                            disp('PAC analysis')
                            data_phase=data(channel_phase,:);
                            data_amplitude=data(channel_amplitude,:);
                            [MI_more,MI_sh_more,p_more,p_sh_more,MVL_more,MVL_sh_more,MA_more,MA_sh_more,MI_less,MI_sh_less,p_less,p_sh_less,MVL_less,MVL_sh_less,MA_less,MA_sh_less] = PAC_analysis( ...
                                data_phase,data_amplitude,fs,phase_freq_range,phase_freq_width,amp_freq_range,amp_freq_width,num_bins,num_perm_PAC,velocity,velocity_threshold,n_down);
                            path_to_save=fullfile(data_root,animal_name,day_name,condition_name,'PAC_analysis_test');
                            save(path_to_save,'MI_more','MI_sh_more','p_more','p_sh_more','MVL_more','MVL_sh_more','MA_more','MA_sh_more','MI_less','MI_sh_less','p_less','p_sh_less','MVL_less','MVL_sh_less','MA_less','MA_sh_less','velocity_threshold','-v7.3');
                        end
                        if analyze_entrainment
                            disp('Entrainment analysis')
                            Units=load(fullfile(data_root,animal_name,day_name,condition_name,'Units.mat')).spike_times;
                            for i_unit=unit_numer
                                current_unit=Units(i_unit);
                                signal=data(channel_number(i_unit),:);
                                [MVL_more,MVL_less,mAng_more,mAng_less,entBinned_more,entBinned_less,MI_more,MI_less,MVL_more_sh,MVL_less_sh,mAng_more_sh,mAng_less_sh,entBinned_more_sh,entBinned_less_sh,MI_more_sh,MI_less_sh]=entrainment_analysis( ...
                                    signal,current_unit,fs,franges,velocity,velocity_threshold);
                                path_to_save=fullfile(data_root,animal_name,day_name,condition_name,sprintf('Ent_Unit_%0.0f_Channel_%0.0f',i_unit,channel_number(i_unit)));
                                save(path_to_save,'MVL_more','MVL_less','mAng_more','mAng_less','entBinned_more','entBinned_less','MI_more','MI_less','MVL_more_sh','MVL_less_sh','mAng_more_sh','mAng_less_sh','entBinned_more_sh','entBinned_less_sh','MI_more_sh','MI_less_sh','franges','velocity_threshold','-v7.3');
                            end
                        end
                        if analyze_SWR
                            disp('SWR analysis')
                            [results,results_map]= HFO_detector_sm(data,parameters); % Calling HFO detector function
                            path_to_save=fullfile(data_root,animal_name,day_name,condition_name,'HFOs_events_test');
                            save(path_to_save,'results','-v7.3');
                            path_to_save=fullfile(data_root,animal_name,day_name,condition_name,'HFOs_maps_test');
                            save(path_to_save,'results_map','-v7.3');
                            SW=sharp_wave_detector(samples,parameters_SW);
                            path_to_save=fullfile(data_root,animal_name,day_name,condition_name,'Sharp_waves_test');
                            save(path_to_save,'SW','-v7.3');
                        end
                    end
                end
            end
        end
    end
end
