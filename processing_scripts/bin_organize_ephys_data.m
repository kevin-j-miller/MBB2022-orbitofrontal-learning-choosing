%% Load the dataset
loaded = load(fullfile(files_path, 'preprocessed_data', 'ofc_learning_choosing_dataset_ephys.mat'));
ephys_data = loaded.ratdatas;
clear loaded

%% Check the model fits exist
% Re-run them if they do not
if ~exist(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits.mat'), 'file')
    % If the model fits do not exist, re-run them
    fit_behavioral_models
end

loaded = load(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits.mat'));
fit_params = loaded.fit_params;
param_ratnames = loaded.ratdata_ratnames;


%% Re-organize the data into celldatas
celldatas = [];
nSess = length(ephys_data);

fprintf('Adding value information to dataset \n');
for sess_i = 1:nSess
    % Pick the data from a particular behavioral session
    sessdata = ephys_data(sess_i);
    
    % Find the parameters of the behavioral model for the rat that ran this
    % session
    ratname = sessdata.ratname;
    params_ind = find(ismember(param_ratnames, ratname));
    model_params = fit_params(params_ind);
    
    % Compute the trial-by-trial model-derived values for this session,
    % using the parameters
    values = values_multiagent(model_params.alphaMB, ...
        model_params.alphaPersev,...
        model_params.betaMB, ...
        model_params.betaPersev,...
        model_params.betaBonus, ...
        model_params.betaBias, ...
        sessdata);
    
    % Add them as new fields to the session data structure
    sessdata.Q1mbs = values.Q1mbs;
    sessdata.Q2mbs = values.Q2mbs;
    sessdata.Qeffs = values.Qeffs;
    sessdata.Qhabits = values.Qhabits;

    sessdata.Qmb_choice = values.Qmb_choice;
    sessdata.Qmb_chosen = values.Qmb_chosen;
    sessdata.Qeff_chosen = values.Qeff_chosen;
    sessdata.Qmb_outcome = values.Qmb_outcome;
    
    % Divide the session data up into separate structures for each recorded
    % unit
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

% Set up empty ensemble matrix. For each timelock, this will be nTrials
% by nBins, and contain spike counts. 
for lock_i = 1:4
    spike_ensemble{lock_i} = NaN(nUnits, max([celldatas.nTrials]), length(bin_mids_by_lock{lock_i}));
end

% Compute spike count matrix
nUnits = length(celldatas);
fprintf(['Computing Binned Spike Count Ensemble for ', num2str(nUnits), ' units\n']);
fprintf(1,'Units done: %3i\n', 0);
for unit_i = 1:nUnits
    fprintf(1,'\b\b\b\b %3i', unit_i);
    
    celldata = celldatas(unit_i);
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
                spike_ensemble{lock_i}(unit_i,trial_i,:) = spikes(:);
            end
            
        end
    end
    
end
fprintf(1,'\n');

%% Save postprocessed data

save(fullfile(files_path, 'postprocessed_data', 'ofc_celldatas_ensemble'),...
    'celldatas', 'spike_ensemble', 'bin_mids_by_lock', 't_ranges', 'binsize');