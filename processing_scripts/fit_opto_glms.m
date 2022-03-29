%% Check that we can find the dataset
opto_data_file = fullfile(files_path, 'preprocessed_data', 'ofc_learning_choosing_dataset_opto.mat');

assert(exist(opto_data_file, 'file') == 2, ...
    'Unable to find opto dataset. Please find "ofc_learning_choosing_dataset_opto.mat", and place it in the Matlab path.')

%% Check that we can find MatlabStan
assert(exist('stan', 'file') == 2, ...
    'Unable to find Stan. Please ensure that MatlabStan is properly installed. See https://mc-stan.org/users/interfaces/matlab-stan')

%% Load the dataset
loaded = load(opto_data_file);
 
%% Run the glm
nBack = 3;
results = twostep_opto_glm(loaded.stimdata, nBack);
results_sham = twostep_opto_glm(loaded.opto_data_cntrl, nBack);

% Save output
output_file = fullfile(files_path, 'postprocessed_data', 'opto_results_glm.mat');
save(output_file, 'results', 'results_sham')


