function run_permuted_ephys_regression(cell_i)


%% Load Data and define analysis parameters
loaded = load(fullfile(files_path, 'postprocessed_data', 'ofc_celldatas_ensemble.mat'));

celldata = loaded.celldatas(cell_i);
ensemble = loaded.spike_ensemble;

clear loaded


%% Compute shuffled CPD
nTrials = celldata.nTrials;

sse_full_all = cell(1,4);
sse_leftout = cell(1,4);

for lock_i = 1:4
    spike_counts = squeeze(ensemble{lock_i}(cell_i, 1:nTrials-1, :));
    to_exclude = any(isnan(spike_counts),2) | celldata.to_exclude(1:end-1)';
    spike_counts(to_exclude,:) = [];
    
    regressors = construct_regressors_ephys(celldata);
    regressors(to_exclude,:) = [];
    
    for shift_i = 1:nTrials
        disp(['Running unit ', num2str(cell_i), ', lock ', num2str(lock_i), ', shift ', num2str(shift_i)]);

        
        
        spike_counts_shift = circshift(spike_counts, shift_i); % Circularly shift the data
        
        
        results = iti_regression_copd(spike_counts_shift, regressors);
        sse_full_all{lock_i}(shift_i,:) = results.sse_full;
        sse_leftout{lock_i}(shift_i,:,:) = results.sse_leftOut;
        
    end
    
end

save(fullfile(files_path, 'postprocessed_data', ...
        'circshift_SSEs', ...
        ['circshift_sse_unit_' num2str(cell_i), '.mat']),...
    'sse_full_all', 'sse_leftout')

end