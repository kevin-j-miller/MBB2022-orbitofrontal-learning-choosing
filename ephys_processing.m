%% ELECTROPHYSIOLOGY ANALYSIS AND FIGURES SCRIPT
% Miller, Botvinick, and Brody, 2020

addpath(genpath(pwd))

%% Check that the datasets are visible
assert(exist('ofc_learning_choosing_dataset_opto.mat', 'file') == 2, ...
    'Unable to find opto dataset. Please find "ofc_learning_choosing_dataset_opto.mat", and place it in the Matlab path.')

assert(exist('ofc_learning_choosing_dataset_ephys.mat', 'file') == 2, ...
    'Unable to find ephys dataset. Please find "ofc_learning_choosing_dataset_opto.mat", and place it in the Matlab path.')


%% Preprocess
% Requires 'physdata_corrected', containing behavioral data and spike-sorted ephys data

% Fits the behavioral model, adds value information to the structures
% Re-organizes structures into one-per-unit rather than one-per-session
% Bins the spiketimes into one big matrix for each time-lock

% Creates 'ofc_ephys-preprocessed.mat', 

preprocess_ephys_data; 

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
