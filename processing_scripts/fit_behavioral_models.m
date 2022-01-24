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
inc = [1,0,1,0,0,2,1,0];

for rat_i = 1:length(ratdatas_all)
    ratdata = ratdatas_all(rat_i);
    standata = ratdata2standata(ratdata, inc);
    
    fit_params(rat_i) = fit_stan_model(standata);
     
end

%% Model comparison
% Guide to interpreting "inc"
% 1 - Allow MB
% 2 - MF switch. 0 for none, 1 for TD(0), 2 for TD(1), 3 for TD(lambda)
% 3 - Allow Novelty Preference
% 4 - Allow MB win-stay/lose-switch
% 5 - Allow MF win-stay/lose-switch
% 6 - Allow one-back perseveration
% 7 - Allow bias
% 8 - Allow nonzero alphaT (allows updating of transition probability estimates)
xval_model_names = {'Full', '-MB', '-Persev', '-NP', '-bias', '+TD(0)', '+TD(1)','+TD(lambda)','+T'};
variant_incs = {...
    [1,0,1,0,0,2,1,0], ... # Full model
    [0,0,1,0,0,2,1,0], ... # Remove MB
    [1,0,1,0,0,0,1,0],... # Remove Persev
    [1,0,0,0,0,2,1,0], ... # Remove novelty preference
    [1,0,1,0,0,2,0,0],... # Remove bias
    [1,1,1,0,0,2,1,0], ... # Add TD(0)
    [1,2,1,0,0,2,1,0], ... # Add TD(1)
    [1,3,1,0,0,2,1,0], ... # Add TD(lambda)
    [1,0,1,0,0,2,1,1], ... # Add MB transition learning
    [1,0,1,0,0,1,1,0], ... # Persev is one-trial-back
    } ;

for rat_i = 1:length(ratdatas_all)
    for variant_i = [1,3,10]
        inc = variant_incs{variant_i};
        
        ratdata = ratdatas_all(rat_i);
        if ratdata.nSess > 1
            xval_normLiks(variant_i, rat_i) = xval_twostep_stan(ratdata, inc)
        end
    end
end



%% Save fit parameters
save(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits'),...
    'fit_params', 'ratdatas_all', 'ratdata_ratnames', 'ratdata_conditions', 'xval_normLiks', 'xval_model_names');
