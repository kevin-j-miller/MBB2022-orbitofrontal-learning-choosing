%% Check that opto processing has been done
assert(exist('opto_glm_results.mat', 'file') == 2, ...
    'Unable to find opto_glm_results. Please run opto_processing.m or find "opto_glm_results.mat", and place it in the Matlab path')

%% Create figures
driver_4b_opto_scatterplot
driver_4_mb_comparison
driver_4f_by_nBack


%% Create figures that don't depent on glm
driver_4e_simdata
driver_S6_laser_time_histograms


