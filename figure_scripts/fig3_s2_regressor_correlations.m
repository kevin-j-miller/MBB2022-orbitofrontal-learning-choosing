% The file saved by the model fitter has datasets aggregated by rat
loaded = load(fullfile(files_path, 'postprocessed_data','behavioral_model_fits'));

%
for rat_i = 1:length(loaded.ratdatas_all)
    ratdata = loaded.ratdatas_all(rat_i);

    % Compute the trial-by-trial model-derived values for this session,
    % using the parameters
    params = loaded.fit_params(rat_i);
    values = values_multiagent(params.alphaMB, ...
        params.alphaPersev,...
        params.betaMB, ...
        params.betaPersev,...
        params.betaBonus, ...
        params.betaBias, ...
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

    [regressors, names] = construct_regressors_ephys(ratdata);
    corrs(rat_i,:,:) = corrcoef(regressors).^2;
end

figure; imagesc(squeeze(mean(corrs)))
colorbar
caxis([0,1])
set(gca,'yticklabel', names)
axis square

print_svg('Fig3-s2_regressor-correlations')