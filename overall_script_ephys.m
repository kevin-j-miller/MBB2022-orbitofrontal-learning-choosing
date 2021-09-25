%% ELECTROPHYSIOLOGY ANALYSIS AND FIGURES SCRIPT
% Miller, Botvinick, and Brody, 2020

addpath(genpath(pwd))
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

cpd_driver; 

%% Run permuted regressions
% Run compute_permuted_sse for each unit
% Requires ofc_ephys_preprocessed
% Creates permuted_sse/permuted_sse_cell_###
% I did this on the PNI cluster, 'Spock'

for unit_i = 1:477
    compute_permuted_sse(unit_i)
end

%% Sample permuted populations
% From the permuted celldatas, sample permuted populations
% I did this on Spock too
nFiles = 1e3;
nPerFile = 1e4;
for perm_i = 1:nFiles
    population_perms(perm_i, nPerFile)
end

%% Create figures and stats

% Main text figures
driver_2_example_units
driver_3ac_cpd_timecourses
driver_3b_cpd_scatterplots

% Main text stats
driver_phys_stats

% Supplemental figures
driver_S1_cpd_timecourse_singlemulti % TODO
driver_S2_cpd_scatters_singlemulti % TODO
driver_S3_regressor_correlations