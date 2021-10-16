%% Gather behavioral datasets
addpath(genpath(code_path))

opto_data = load(fullfile(files_path, 'preprocessed_data', 'ofc_learning_choosing_dataset_opto.mat'));
ephys_data = load(fullfile(files_path, 'preprocessed_data', 'ofc_learning_choosing_dataset_ephys.mat'));

% Remove ephys fields from the ephys data
ephys_data_beh_sessions = remove_ephys_fields(ephys_data.ratdatas);
% Find mapping between data and rats
[~, ~, inds] = unique(vertcat(ephys_data_beh_sessions.ratname), 'rows');
% Merge all sessions from each rat
for rat_i = 1:6
    ephys_data_beh_rats(rat_i) = merge_ratdata_cell(ephys_data_beh_sessions(inds == rat_i), 1);
end

% Get a structure with one field for each rat, containing all the
% behavioral data from that rat
ratdatas_all = [cell2mat(opto_data.stimdata), cell2mat(opto_data.opto_data_cntrl), ephys_data_beh_rats];

% Get cell of the rat names
ratdata_ratnames = cell(length(ratdatas_all),1);
[ratdata_ratnames{:}] = ratdatas_all.ratname;

% Get array of the rat conditions
ratdata_conditions = [ones(1, length(opto_data.stimdata)), ...
                     2*ones(1, length(opto_data.opto_data_cntrl)),...
                     3*ones(1,length(ephys_data_beh_rats))];



%% Fit the behavioral model to data from each rat
% Fit Model
model_path = fullfile(code_path, 'library', 'behavior_analysis','stan_models','multiagent_model_single.stan');
inc = [1,0,1,0,0,1,1,0];

for rat_i = 1:length(ratdatas_all)
    ratdata = ratdatas_all(rat_i);
    standata = ratdata2standata(ratdata, inc);
    
   results = fit_stan_model(standata, model_path);
    fit_params(rat_i) = results;
end

%% Save fit parameters
save(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits'),...
    'fit_params', 'ratdatas_all', 'ratdata_ratnames', 'ratdata_conditions');
