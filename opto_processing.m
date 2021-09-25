%% Check that we can find the dataset
assert(exist('ofc_learning_choosing_dataset_opto.mat', 'file') == 2, ...
    'Unable to find opto dataset. Please find "ofc_learning_choosing_dataset_opto.mat", and place it in the Matlab path.')

%% Check that we can find MatlabStan
assert(exist('stan', 'file') == 2, ...
    'Unable to find Stan. Please ensure that MatlabStan is properly installed. See https://mc-stan.org/users/interfaces/matlab-stan')

%% Load the dataset
loaded = load('ofc_learning_choosing_dataset_opto.mat');
 
%% Run the glm
nBack = 3;
results = twostep_opto_glm(loaded.stimdata, nBack);
results_sham = twostep_opto_glm(loaded.opto_data_cntrl, nBack);
save('files\opto_glm_results', 'results', 'results_sham')


