function ratdata = add_values_to_ratdata(ratdata)


%% Check the model fits exist
% Re-run them if they do not
if ~exist(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits.mat'), 'file')
    % If the model fits do not exist, re-run them
    fit_behavioral_models
end

loaded = load(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits.mat'));
fit_params = loaded.fit_params;
param_ratnames = loaded.ratdata_ratnames;



%% Find the correct rat
ratname = ratdata.ratname;
params_ind = find(ismember(param_ratnames, ratname));
model_params = fit_params(params_ind);

%% Add trial-by-trial values
values = values_multiagent(model_params.alphaMB, ...
    model_params.alphaPersev,...
    model_params.betaMB, ...
    model_params.betaPersev,...
    model_params.betaBonus, ...
    model_params.betaBias, ...
    ratdata);

% Add them as new fields to the session data structure
ratdata.Q1mbs = values.Q1mbs;
ratdata.Q2mbs = values.Q2mbs;
ratdata.Qeffs = values.Qeffs;
ratdata.Qhabits = values.Qhabits;

ratdata.Qmb_choice = values.Qmb_choice;
ratdata.Qmb_chosen = values.Qmb_chosen;
ratdata.Qeff_chosen = values.Qeff_chosen;
ratdata.Qmb_outcome = values.Qmb_outcome;