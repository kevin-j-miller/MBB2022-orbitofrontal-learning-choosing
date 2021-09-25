loaded = load('opto_dataset');
addpath(genpath('C:\Users\kevin\Documents\Stan'));

 
%% Run the glm
nBack = 3;
results = twostep_opto_glm(loaded.stimdata, nBack);
results_sham = twostep_opto_glm(loaded.opto_data_cntrl, nBack);
save('opto_glm_results', 'results', 'results_sham')

%% Create figures
driver_4b_opto_scatterplot
driver_4_mb_comparison
driver_4f_by_nBack


%% Create figures that don't depent on glm
driver_4e_simdata
driver_S6_laser_time_histograms


