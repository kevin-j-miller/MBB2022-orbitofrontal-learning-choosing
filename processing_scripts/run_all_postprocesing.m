%% SCRIPTS TO RUN DATA POSTPROCESSING
% Miller, Botvinick, and Brody, 2022

%% Check that the datasets are visible
assert(exist(fullfile(files_path, 'preprocessed_data', 'ofc_learning_choosing_dataset_opto.mat'), 'file') == 2, ...
    'Unable to find opto dataset. Please find "ofc_learning_choosing_dataset_opto.mat", and place it in the Matlab path.')

assert(exist(fullfile(files_path, 'preprocessed_data', 'ofc_learning_choosing_dataset_ephys.mat'), 'file') == 2, ...
    'Unable to find ephys dataset. Please find "ofc_learning_choosing_dataset_opto.mat", and place it in the Matlab path.')


%% Fit behavioral models
% Requires 'ofc_learning_choosing_dataset_ephys' and 'ofc_learning_choosing_dataset_opto'

% Fits the behavioral model

% Creates 'behavioral_model_fits.mat', containing fit parameters for each rat

fit_behavioral_models

%% Bin up ephys
% Requires 'ofc_learning_choosing_dataset_ephys.mat', containing behavioral data and spike-sorted ephys data
% Requires 'behavioral_model_fits.mat', containing fit parameters

% Adds value information to the structures
% Re-organizes structures into one-per-unit rather than one-per-session
% Bins the spiketimes into one big matrix for each time-lock

% Creates 'ofc_celldatas_ensemble.mat', 

bin_organize_ephys_data; 

%% Run regressions
% Requires 'ofc_ephys_preprocessed'. 
% Runs the ephys regression model, computing sum-squared error for each
% unit, bin, and lock.
% Creates 'ofc_SSEs'

run_ephys_regressions; 

%% Run permuted regressions
% Run compute_permuted_sse for each unit
% Requires ofc_ephys_preprocessed
% Creates permuted_sse/permuted_sse_cell_###
% If you run this single-threaded, it will take a long time. 
% I parallelized it using the PNI cluster, 'Spock'

for unit_i = 1:477
    run_permuted_ephys_regression(unit_i)
end

%% Sample permuted populations
% From the permuted celldatas, sample permuted populations
% I did this on Spock too
nFiles = 1e3;
nPerFile = 1e4;
for perm_i = 1:nFiles
    population_perms(perm_i, nPerFile)
end