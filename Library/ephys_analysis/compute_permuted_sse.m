function compute_permuted_sse(cell_i)

loaded = load('ofc_ephys_preprocessed');

celldata = loaded.celldatas(cell_i);
ensemble = loaded.ensemble;
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
    
    for shuffle_i = 1:nTrials
        tic
        
        
        spike_counts_shift = circshift(spike_counts, shuffle_i); % Circularly shift the data
        
        
        results = iti_regression_copd(spike_counts_shift, regressors);
        sse_full_all{lock_i}(shuffle_i,:) = results.sse_full;
        sse_leftout{lock_i}(shuffle_i,:,:) = results.sse_leftOut;
        
    end
    
    
    toc
    
    
end

save(['permuted_sse/permuted_sse_cell_' num2str(cell_i)], 'sse_full_all', 'sse_leftout')

end