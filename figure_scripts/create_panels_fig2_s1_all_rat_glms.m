
if ~exist(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits.mat'), 'file')
    % If the model fits do not exist, re-run them
    fig1_fit_models
end

if ~exist(fullfile(files_path, 'figure_panels', 'Fig2_S1_individual_rat_glms'), 'dir')
    mkdir(fullfile(files_path, 'figure_panels', 'Fig2_S1_individual_rat_glms'))
end

loaded = load(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits.mat'));
fit_params = loaded.fit_params;
ratdatas_all = loaded.ratdatas_all;
ratdata_conditions = loaded.ratdata_conditions;

opto_rats = find(ratdata_conditions == 1);
sham_rats = find(ratdata_conditions == 2);
ephys_rats = find(ratdata_conditions == 3);

%% Run behavior regressions
nBack = 5;
ylims = [-1.5, 3];
for rat_i = 1:length(opto_rats)
    % For the actual data
    ratdata = ratdatas_all(opto_rats(rat_i));
    results = twostep_glm(ratdata, nBack);
    mb_opto(rat_i) = results.mb_ind;
    mf_opto(rat_i) = results.mf_ind;
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim(ylims)
    print_svg(['Fig2_S1_individual_rat_glms/opto', num2str(rat_i)]);
    
    % For synthetic data
    p = fit_params(opto_rats(rat_i));
    params = [p.alphaMB, p.betaMB, p.betaBonus, p.betaPersev, p.betaBias];
    simdata = generate_simulated_data('mb_bonus_persev_bias',params,ratdata);
    twostep_glm(simdata, nBack);
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim(ylims)
    print_svg(['Fig2_S1_individual_rat_glms/opto', num2str(rat_i), '_simdata']);
end

for rat_i = 1:length(sham_rats)
    ratdata = ratdatas_all(sham_rats(rat_i));
    results = twostep_glm(ratdata);
    
    mb_sham(rat_i) = results.mb_ind;
    mf_sham(rat_i) = results.mf_ind;
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim(ylims)
    print_svg(['Fig2_S1_individual_rat_glms/sham', num2str(rat_i)]);
    
     % For synthetic data
    p = fit_params(sham_rats(rat_i));
    params = [p.alphaMB, p.betaMB, p.betaBonus, p.betaPersev, p.betaBias];
    simdata = generate_simulated_data('mb_bonus_persev_bias',params,ratdata);
    twostep_glm(simdata, nBack);
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim(ylims)
    print_svg(['Fig2_S1_individual_rat_glms/sham', num2str(rat_i), '_simdata']);
end

for rat_i = 1:length(ephys_rats)
    ratdata = ratdatas_all(ephys_rats(rat_i));
    results = twostep_glm(ratdata);
    
    mb_ephys(rat_i) = results.mb_ind;
    mf_ephys(rat_i) = results.mf_ind;
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim(ylims)
    print_svg(['Fig2_S1_individual_rat_glms/ephys', num2str(rat_i)]);
    
    % For synthetic data
    p = fit_params(ephys_rats(rat_i));
    params = [p.alphaMB, p.betaMB, p.betaBonus, p.betaPersev, p.betaBias];
    simdata = generate_simulated_data('mb_bonus_persev_bias',params,ratdata);
    twostep_glm(simdata, nBack);
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim(ylims)
    print_svg(['Fig2_S1_individual_rat_glms/ephys', num2str(rat_i), '_simdata']);
end
