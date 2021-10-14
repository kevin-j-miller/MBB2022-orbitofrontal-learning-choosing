%% Load the data we need

if ~exist(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits.mat'), 'file')
    % If the model fits do not exist, re-run them
    fig1_fit_models
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
    ratdata = ratdatas_all{opto_rats(rat_i)};
    results = twostep_glm(ratdata, nBack);
    mb_opto(rat_i) = results.mb_ind;
    mf_opto(rat_i) = results.mf_ind;
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim(ylims)
    print_svg(['Fig1_S1_individual_rat_glms/opto', num2str(rat_i)]);
    
    % For synthetic data
    p = fit_params(opto_rats(rat_i));
    params = [p.alphaMB, p.betaMB, p.betaBonus, p.betaPersev, p.betaBias];
    simdata = generate_simulated_data('mb_bonus_persev_bias',params,ratdata);
    twostep_glm(simdata, nBack);
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim(ylims)
    print_svg(['Fig1_S1_individual_rat_glms/opto', num2str(rat_i), '_simdata']);
end

for rat_i = 1:length(sham_rats)
    ratdata = ratdatas_all{sham_rats(rat_i)};
    results = twostep_glm(ratdata);
    
    mb_sham(rat_i) = results.mb_ind;
    mf_sham(rat_i) = results.mf_ind;
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim(ylims)
    print_svg(['Fig1_S1_individual_rat_glms/sham', num2str(rat_i)]);
    
     % For synthetic data
    p = fit_params(sham_rats(rat_i));
    params = [p.alphaMB, p.betaMB, p.betaBonus, p.betaPersev, p.betaBias];
    simdata = generate_simulated_data('mb_bonus_persev_bias',params,ratdata);
    twostep_glm(simdata, nBack);
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim(ylims)
    print_svg(['Fig1_S1_individual_rat_glms/sham', num2str(rat_i), '_simdata']);
end

for rat_i = 1:length(ephys_rats)
    ratdata = ratdatas_all{ephys_rats(rat_i)};
    results = twostep_glm(ratdata);
    
    mb_ephys(rat_i) = results.mb_ind;
    mf_ephys(rat_i) = results.mf_ind;
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim(ylims)
    print_svg(['Fig1_S1_individual_rat_glms/ephys', num2str(rat_i)]);
    
    % For synthetic data
    p = fit_params(ephys_rats(rat_i));
    params = [p.alphaMB, p.betaMB, p.betaBonus, p.betaPersev, p.betaBias];
    simdata = generate_simulated_data('mb_bonus_persev_bias',params,ratdata);
    twostep_glm(simdata, nBack);
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim(ylims)
    print_svg(['Fig1_S1_individual_rat_glms/ephys', num2str(rat_i), '_simdata']);
end


%% Scatterplot of model-based vs. model-free indices
marker_size = 75;
ew = 2;
l = 0.5;

fig = figure; hold on
line([-10, 10], [0, 0], 'color', 'k')
line([0, 0], [-10, 10], 'color', 'k')
line([-10, 10], [-10, 10], 'color', 'k')
scatter(mb_opto, mf_opto, marker_size, 'v', 'markeredgecolor', lighten([0,0,0],l), ...
    'markerfacecolor', 'none',...
    'linewidth', ew)
scatter(mb_sham, mf_sham, marker_size, 'd', 'markeredgecolor', lighten([0,0,0],l), ...
    'markerfacecolor', 'none',...
    'linewidth', ew)
scatter(mb_ephys, mf_ephys, marker_size, 's', 'markeredgecolor', lighten([0,0,0],l), ...
    'markerfacecolor', 'none',...
    'linewidth', ew)



xlim([-1.3, 8])
ylim([-1.3, 8])
axis square
set(gca,'fontsize',14)
xlabel('Planning Index')
ylabel('Model-Free Index')

print_svg('fig1_mbmf_scatter');

%% Scatterplot of fit parameter values
marker_size = 75;
ew = 2;
l = 0.5;
l2 = 0.9;
jit = 0.4;

icons = 'svd';

fig = figure; hold on
line([-10, 10], [0, 0], 'color', 'k')

for dataset_i = 1:3
    params = fit_params(ratdata_conditions == dataset_i);
    icon = icons(dataset_i);
    nRats = length(params);
    jitter = (0:jit/(nRats-1):jit) - jit/2;
    ys = [params.betaMB_norm, params.betaPersev_norm, params.betaBonus_norm, params.betaBias];
    xs = sort(repmat((1:4),[1,nRats]) + repmat(jitter, [1,4]));
    scatter(xs, ys, marker_size, icon, 'markeredgecolor', lighten([0,0,0],l), ...
        'markerfacecolor', 'none',...
        'linewidth', ew)
    
end

means = [mean([fit_params.betaMB_norm]), ...
    mean([fit_params.betaPersev_norm]), ...
    mean([fit_params.betaBonus_norm]), ...
    mean([fit_params.betaBias])];
sems = [sem([fit_params.betaMB_norm]), ...
    sem([fit_params.betaPersev_norm]), ...
    sem([fit_params.betaBonus_norm]), ...
    sem([fit_params.betaBias])];
errorbar(1:4, means, sems, '.', 'color', lighten([0,0,0], l2), 'linewidth', 2)


xlim([0.5, 4.5])
set(gca,'fontsize',14)
xlabel('Behavioral Component')
ylabel('Normalized Mixture Weight')
set(gca,'xticklabel', {'Planning', 'Perseveration', 'Novelty Preference', 'Bias'})


print_svg('fig1_params_scatter')
