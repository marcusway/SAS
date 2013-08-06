%% INFO


% This is a script that takes all of the subjects with individual 
% PSDs output from doPWELCH, and then looks at the frequency range
% specified by LOWER_LIM and UPPER_LIM.  For each region in each subject,
% it takes each electrode of interest, normalizes its PSD by dividing the
% value in each bin by the total power in our band of interest.  It then
% averages the normalized electrode PSDs together and outputs the new,
% averaged PSD for our region of interest to a single column in a file
% specific to the region and condition (ex: ADHD_norm_freq_eoLF)

%% Clear everything
close all 
clear all 
clc

%% INITIALIZATIONS 

% Study-specific constants
SAMPLING_RATE   = 500;  % Sampling rate used in doPWELCH 
LOWER_LIM       = 1;    % Bottom of our frequency range of interest
UPPER_LIM       = 30;   % Top
NFFT            = 1024; % Size of the window for pwelch
REGIONS         = {'LF','RF','LP','RP','O'}; 
CONDITIONS      = {'eo','ec'}; % eyes open and eyes closed 
FILE_PREFIX     = 'SAS_norm_freq';

% Generate array of all frequencies according to our sampling rate and NFFT
f = 0:SAMPLING_RATE/NFFT:SAMPLING_RATE/2;
% Find the indices in f that correspond to the frequencies in
% our band of interest. 
pow_range = f > LOWER_LIM & f < UPPER_LIM; 

%Make a list of all the subjects we want:
subDir = dir('1*'); % all the subject directories start with a '1'
subjects = cell(1, length(subDir));
for i = 1:length(subDir)
   subjects{i} = subDir(i).name; 
end

%% MAIN LOOP

    for condition = 1:length(CONDITIONS)
    
        for region = 1:length(REGIONS)
            filename = [FILE_PREFIX '_' CONDITIONS{condition} REGIONS{region} '.csv'];
            outfile = fopen(filename,'w');
            subs_with_data = {};
            data = [];
            
            for subject = 1:length(subjects)
                
                % NOTE:  This would run faster if I preallocated the data
                % and norm matrices, but this would require that calculate
                % the number of subjects with data for each condition
                % beforehand.  Something to consider, but would require a
                % little rearranging. 
                
                try % If the subject file exists, open and analyze it
                    load(fullfile(subjects{subject},[subjects{subject},'_matfiles'],[subjects{subject},'_ind_electrode_psds'],[subjects{subject},'_PSD',CONDITIONS{condition},REGIONS{region}]),'Pxx_matrix');
                    norm=[];
                catch error % If not, catch the error, warn the user, skip to the next file
                    disp(['No ' CONDITIONS{condition},' segment for subject ', subjects{subject}]);
                    continue;
                end
                
                for col = 1:size(Pxx_matrix,2)
                    
                    % Normalize each electrode's power spectrum
                    curr_electrode = Pxx_matrix(:,col);
                    total_power = sum(curr_electrode(pow_range));
                    norm = [norm curr_electrode/total_power];
                end
                
                % Average across normalized power spectra across 
                % channels in the region
                avg_norm = mean(norm,2);
                data = [data; avg_norm(pow_range)'];
                
                % Note that this subject had data for this condition
                % (only subjects who have data for the given condition
                % will be recorded in the corresponding spreadsheets).
                subs_with_data{end+1} =  subjects{subject};
                
            end 
            
            % keep the user informed
            disp(['File:', filename,' Num subjects: ' num2str(length(subs_with_data))]);
            
            myFreqs = f(pow_range);
            write_with_headers(data, outfile, myFreqs, subs_with_data, 'sID');
            
            end
            fclose(outfile);
    end
