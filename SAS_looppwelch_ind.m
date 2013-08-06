function [PxxMatrix,Pxx, F] = SAS_looppwelch_ind(segment,sensors,sampling_rate)

%% INFO

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function takes as input a matrix of %
% time series data (segment) in the format %
% rows => channels, cols => timepoints, a  % 
% group of channel numbers (sensors), and  %
% the rate at which the data were sampled. %
% It returns the mean PSD across all the   %
% channels in 'sensors', Pxx, as well as a %
% matrix containing individual electrode   %
% PSDs as columns, PxxMatrix               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% UPDATE 2/6/13

% FOR SAS:  the DESIRED_FREQUENCY is set to 
% 500Hz, and an error is returned if 
% that's not the case.  There is no downsampling. 

% UPDATE 2/4/13

% PxxMatrix is now also multiplied by f_bin. 

% UPDATE 2/1/13

% In addition to returning an averaged power spectrum, Pxx, the function
% now also returns a matrix whose columns correspond to the power spectra
% of the different electrodes in the 'sensors' argument.  For example, if
% you're looking at a region with 3-electrodes, the PxxMatrix output
% will be a 3-column matrix, and Pxx is just the mean across columns of
% this matrix. 

% UPDATE 1/28/13

% For now the averaged pwelch outputs will be 
% multiplied by the bin width (F(2)-F(1))
% in this step instead of in analyzePower. 



% UPDATE 1/10/13

% Some variables are now initialized beforehand, 
% and the psd matrix is now initialized to zeros 
% outside of the main loop so that it doesn't
% change size every iteration--this should make
% it run faster. 

% Created 1/7/13 by Marcus Way

% This differs from the old looppwelchmas functions in that
% it takes the sampling frequency as an argument
% and downsamples 500Hz by a factor of 2.  This 
% eliminates the need for separate looppwelch functions
% for 250Hz and 500 Hz data.  It is important that calls
% to this function include the sampling frequency argument.

% NOTE: the averaged output of pwelch is  NOT multiplied by the
% frequency resolution, or 125/513 here--that's done in analyzePower

%% Code

% Initializations 

NFFT                = 1024;                             % Number of Fourier Transforms in pwelch
WINDOW              = hanning(1024);                    % Window used by pwelch
DESIRED_FREQUENCY   = 500;                              % Frequency to which to downsample if necessary
len_pxx             = ceil((NFFT+1)/2);                 % Length of the pwelch psd estimate output
PxxMatrix           = zeros(len_pxx, length(sensors));  % Pre-allocate psd matrix for speed


% Only accept a sampling rate of 250 or 500Hz, otherwise
% report an error
if sampling_rate ~= DESIRED_FREQUENCY
    error('Expected a sampling rate of 500');
end



for i=1:length(sensors)
    
    data = segment(sensors(i),1:end); % selects timeseries for particular channel

    % Store each channel's PSD as a column in PSD matrix
    [PxxMatrix(:,i),F]=pwelch(data,WINDOW,[],NFFT,DESIRED_FREQUENCY); 
    
end;

% Average across columns for the final Pxx value
Pxx = mean(PxxMatrix,2);

% Multiply outputs by the bin width
f_bin     = F(2)-F(1);       % This quantity, f_bin, is our frequency resolution
Pxx       = Pxx*f_bin;       % Pxx is now a power *spectrum* instead of a power spectral density
PxxMatrix = PxxMatrix*f_bin; % Pxx matrix stores power spectra for all electrodes in 'sensors'