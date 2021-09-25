loaded = load('physdata_corrected.mat')


%% Fit the model
model_path = 'analysis_code/stan_models\multiagent_model_single.stan';
inc = [1,0,1,0,0,1,1,0];
addpath(genpath('C:\Users\kevin\Documents\Software\Stan'))

% Make a phys-free ratdatas, so it's mergable
ratdatas = rmfield(loaded.ratdatas, {'spiketimes', 'cell_types','unitchannels', 'to_exclude'});
% Find mapping between data and rats
[ratnames, ~, inds] = unique(vertcat(ratdatas.ratname), 'rows');


for rat_i = 1:6
    ratdata = merge_ratdata_cell(ratdatas(inds == rat_i));
    standata = ratdata2standata(ratdata, inc);
    
    disp(['Fitting reduced model, rat #',num2str(rat_i)]);
    wd = ['working_folder_',datestr(now,'yyyymmdd_HHMMSSFFF')];
    mkdir(wd);
    fit = stan('file',model_path,'data',standata,'verbose',false,'method','optimize','working_dir',wd);
    fit.block;
    fits_extracted = extract(fit);
    model_params(rat_i) = fits_extracted;
    rmdir(wd,'s');
    
    rp = model_params(rat_i);
    values = values_multiagent(0, rp.alphaMB, 0, rp.betaMB, rp.betaBonus, 0, ...
        rp.betaPersev, rp.betaBias, ratdata);
    
    ratdata.Q1mbs = values.Q1mbs;
    ratdata.Q2mbs = values.Q2mbs;
    ratdata.Qeff = values.Qeff;
    phys_sessions_by_rat(rat_i) = ratdata;

end

save('behavioral_model_fits_physdata','model_params', 'ratnames', 'phys_sessions_by_rat')

%% Re-organize the data into celldatas
celldatas = [];

for sess_i = 1:length(loaded.ratdatas)
    sessdata = loaded.ratdatas(sess_i);
    
    for cell_i = 1:length(sessdata.spiketimes)
        
        celldata = sessdata;
        celldata.spiketimes = sessdata.spiketimes{cell_i};
        celldata.cell_types = sessdata.cell_types{cell_i};
        celldata.unitchannels = sessdata.unitchannels(cell_i);
        celldata.to_exclude = sessdata.to_exclude(cell_i,:);
        
        assert(all(celldata.bad_timing == ...
            any(isnan([celldata.c1_times, celldata.s1_times, celldata.c2_times, celldata.s2_times]),2)), ...
            'There is a problem with timing')

        
        celldatas = [celldatas, celldata];
        
    end
    
    
end



%% Add value to celldatas

[ratnames, ~, inds] = unique(vertcat(celldatas.ratname), 'rows');

for cell_i = 1:length(celldatas)
    
    
    rp = model_params(inds(cell_i));
    
    values = values_multiagent(0, rp.alphaMB, 0, rp.betaMB, rp.betaBonus, 0, ...
        rp.betaPersev, rp.betaBias, celldatas(cell_i));
    
    celldatas(cell_i).Q_outcome = values.Q_outcome;
    celldatas(cell_i).Q_chosen = values.Q_chosen;
    celldatas(cell_i).Q_choice = values.Q_choice;
    
    celldatas(cell_i).Q1mbs = values.Q1mbs;
    celldatas(cell_i).Q2mbs = values.Q2mbs;
    celldatas(cell_i).Qeff = values.Qeff;
    
end


%% Generate and save ensemble of spike counts

% Timing parameters. How big of a bin? How big of a window around each port
% entry?
binsize = 0.2;
t_ranges{1} = [-2, 2];
t_ranges{2} = [-2, 12.1];
t_ranges{3} = [-12.1, 2];
t_ranges{4} = [-2, 2];

for lock_i = 1:4
    bins_by_lock{lock_i} = (0:binsize:diff(t_ranges{lock_i})) + t_ranges{lock_i}(1);
    bin_mids_by_lock{lock_i} = bins_by_lock{lock_i}(1:end-1) + diff(bins_by_lock{lock_i});
end

% prepare empty data structures
nCells = length(celldatas);
sse_full_all = cell(1,4);
sse_leftOut = cell(1,7);
for reg_i = 1:8
    sse_leftOut{reg_i} = cell(1,4);
end

% Set up empty ensemble matrix. For each timelock, this will be nTrials
% by nBins, and contain spike counts. 
for lock_i = 1:4
    ensemble{lock_i} = NaN(nCells, max([celldatas.nTrials]), length(bin_mids_by_lock{lock_i}));
end

% Compute spike count matrix
for cell_i = 1:nCells
    tic
    celldata = celldatas(cell_i);
    spiketimes = celldata.spiketimes;
    % Loop over trials, adding spike counts to the matrix
    for trial_i = 1:(celldata.nTrials - 1)
        
        if ~celldata.bad_timing(trial_i) && ~celldata.to_exclude(trial_i) % Skip trials with bad timing or artifacts
            time_locks = [celldata.c2_times(trial_i), celldata.s2_times(trial_i), celldata.c1_times(trial_i + 1), celldata.s1_times(trial_i + 1)];
            
            for lock_i = 1:length(time_locks)
                bins = bins_by_lock{lock_i};
                time_lock = time_locks(lock_i);
                bins_lock = time_lock + bins;
                hist_results = histc(spiketimes, bins_lock);
                spikes = hist_results(1:end-1);
                ensemble{lock_i}(cell_i,trial_i,:) = spikes(:);
            end
            
        end
    end
    toc
end

%% Save preprocessed data
save('ofc_ephys_preprocessed', 'celldatas', 'ensemble', 'bin_mids_by_lock', 't_ranges', 'binsize');