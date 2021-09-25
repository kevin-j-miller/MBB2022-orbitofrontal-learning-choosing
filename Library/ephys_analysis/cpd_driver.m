%% Load Data and define analysis parameters
addpath(genpath(pwd))
loaded = load('ofc_ephys_preprocessed');

celldatas = loaded.celldatas;
ensemble = loaded.ensemble;
bin_mids_by_lock = loaded.bin_mids_by_lock;
clear loaded


%% Compute SSE for each unit and bin
nCells = length(celldatas);
sse_full_all = cell(4, nCells);
sse_leftout = cell(4, nCells);
bad_glm = false(1,nCells);

tic
for lock_i = 1:4
    ensemble_lock = ensemble{lock_i};
    
    parfor cell_i = 1:nCells
        disp(['Running lock ' num2str(lock_i) ', unit ' num2str(cell_i)]);
        
        nTrials = celldatas(cell_i).nTrials;
        
        spike_counts = squeeze(ensemble_lock(cell_i, :, :));
        spike_counts = spike_counts(1:nTrials-1,:);
        to_exclude = any(isnan(spike_counts),2) | celldatas(cell_i).to_exclude(1:end-1)';
        spike_counts(to_exclude,:) = [];
        
        regressors = construct_regressors_ephys(celldatas(cell_i));
        regressors(to_exclude,:) = [];
        
        results = iti_regression_copd(spike_counts, regressors);
        
        sse_full_all{lock_i, cell_i} = results.sse_full;
        sse_leftout{lock_i, cell_i} = results.sse_leftOut;
        
    end
end
toc

save('ofc_SSEs.mat', 'sse_full_all', 'sse_leftout', 'bin_mids_by_lock', 'bad_glm')