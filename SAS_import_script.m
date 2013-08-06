function SAS_import_script(varargin)

%% Information

% This is a function that takes a subject number, or a list of 
% subject numbers separated by commas, as input. For each subject 
% specified, that subject's EEG matfile (output from Net Station's 
% export to Matlab function), and divides the EEG time series therein 
% into eyes open and eyes closed data, saving individual .mat files for
% each condition.  

% IMPORTANT DETAILS:
% Subject's file name should follow format: SAS_####.fhp.flp.s.cr.ref.mat
% The cell array variable containing the EEG data within this file
% should be named SAS_####.fhpflpscrrefmat.  This should be the only
% variable in file that starts with SAS prefix. 


%% Code

%loop through the subjects
for j = 1:nargin
    
 %make a variable for the subject's ID number (from argument)   
 subID = varargin{j};
  
 %load corresponding .mat file   
 matlabFile = ['SAS_', num2str(subID), '.fhp.flp.s.cr.ref.mat'];

 %make a variable that stores the name of this subject's cell array data
 arrayData = load(matlabFile,'SAS*');
 
 %the columns are in order: E0, EC.  Take the single columns and
 %assign a variable to them
 eyesOpenData = [arrayData{1,1}];
 eyesClosedData = [arrayData{1,2}];
   
 %make file names for the single columns
 eyesOpenFileName = ['SAS_', num2str(subID), 'eo'];
 eyesClosedFileName = ['SAS_',num2str(subID),'ec'];
   
 %save the files
 save(eyesOpenFileName, 'eyesOpenData');
 save(eyesClosedFileName, 'eyesClosedData');
   
end