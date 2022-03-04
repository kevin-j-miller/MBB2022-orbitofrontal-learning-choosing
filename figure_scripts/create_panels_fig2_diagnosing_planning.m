%% Load the data we need

if ~exist(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits.mat'), 'file')
    % If the model fits do not exist, re-run them
    fit_behavioral_models
end


loaded = load(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits.mat'));
xval_normLiks = loaded.xval_normLiks;
fit_params = loaded.fit_params;
ratdatas_all = loaded.ratdatas_all;
ratdata_conditions = loaded.ratdata_conditions;

opto_rats = find(ratdata_conditions == 1);
sham_rats = find(ratdata_conditions == 2);
ephys_rats = find(ratdata_conditions == 3);

%% Run behavior regressions
nBack = 5;
example_rat_ind = 13;

for rat_i = 1:length(ratdatas_all)
    ratdata = ratdatas_all(rat_i);
    glm_results(rat_i) = twostep_glm(ratdata, nBack, 0);   

    if rat_i == example_rat_ind
        twostep_glm(ratdata, nBack, 1);
        title('Example Rat')
        
       % print_svg('fig2_glm_example');
    end

end


plot_pretty_glms([glm_results.betas]', nBack)
title('All Rats')

%% Plot Behavior indices
marker_sizes = [40, 40, 60];
ew = 1;
l = 0.5;
l2 = 0.8;
jit = 0.3;
icons = 'vds';


inds = [[glm_results.mb_ind]; ...
    [glm_results.persev_ind]; ...
    [glm_results.csus_ind]; ...
    [glm_results.mf_ind]];

figure; hold on
line([-10, 10], [0, 0], 'color', 'k')

for dataset_i = 1:3
    rats_in_condition = ratdata_conditions == dataset_i;
    ys = inds(:,rats_in_condition);
    icon = icons(dataset_i);
    nRats = sum(rats_in_condition);
    jitter = (0:jit/(nRats-1):jit) - jit/2;
    %ys = [params.betaMB_norm; params.betaPersev_norm; params.betaBonus_norm; params.betaBias];
    xs = sort(repmat((1:4)',[1,nRats]) + repmat(jitter, [4,1]));
    scatter(xs(:), ys(:), marker_sizes(dataset_i), icon, 'markeredgecolor', lighten([0,0,0],l), ...
        'markerfacecolor', 'none',...
        'linewidth', ew)
    
end

errorbar(1:4, mean(inds'), sem(inds'), '.', 'color', lighten([0,0,0], l2), 'linewidth', 2)



xlim([0.5, 4.5])
set(gca,'fontsize',14)
xlabel('')
title('Behavioral Indices')
ylabel('Index Value')
set(gca, 'fontsize', 20, ...
    'xticklabel', {'Planning', 'Perseveration', 'Novelty Preference', 'Model-Free'}, ...
    'xtick', 1:4, ...
    'ytick', [-2, 0, 2, 4, 6, 8])
set(gcf, 'pos', [500, 200, 700, 600])
xtickangle(-45)

print_svg('fig2_glm_indices')


%% Scatterplot of fit parameter values
marker_sizes = [40, 40, 60];
ew = 1;
l = 0.5;
l2 = 0.9;
jit = 0.3;

icons = 'vds';

fig = figure; hold on
line([-10, 10], [0, 0], 'color', 'k')

for dataset_i = 1:3
    params = fit_params(ratdata_conditions == dataset_i);
    icon = icons(dataset_i);
    nRats = length(params);
    jitter = (0:jit/(nRats-1):jit) - jit/2;
    ys = [params.betaMB_norm; params.betaPersev_norm; params.betaBonus_norm; params.betaBias];
    xs = sort(repmat((1:4)',[1,nRats]) + repmat(jitter, [4,1]));
    scatter(xs(:), ys(:), marker_sizes(dataset_i), icon, 'markeredgecolor', lighten([0,0,0],l), ...
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
xlabel('')
title('Weighting Parameters')
ylabel('Normalized Mixture Weight')
set(gca, 'fontsize', 20, ...
    'xticklabel', {'Planning', 'Perseveration', 'Novelty Preference', 'Bias'}, ...
    'xtick', 1:4, ...
    'ytick', [-0.5, 0, 0.5, 1])
set(gcf, 'pos', [500, 500, 700, 600])
xtickangle(-45)

print_svg('fig2_params_scatter')

%% Model comparison scatterplot

jit = 0.03;
jitter = (0:jit:17*jit) - 10*jit;
lw = 1.5;

ref = xval_normLiks(1,:);

figure; hold on
line([-1,20], [0, 0], 'color', 'k');
set(gca,'fontsize',16)

scatter(1 + jitter, xval_normLiks(2,:) - ref, 100, 'x', 'linewidth', lw, 'markeredgecolor', lighten(msred, 0.5))
scatter(2 + jitter, xval_normLiks(3,:) - ref, 100, 'x', 'linewidth', lw, 'markeredgecolor', lighten(msred, 0.5))
scatter(3 + jitter, xval_normLiks(4,:) - ref, 100, 'x', 'linewidth', lw, 'markeredgecolor', lighten(msred, 0.5))
scatter(4 + jitter, xval_normLiks(5,:) - ref, 100, 'x', 'linewidth', lw, 'markeredgecolor', lighten(msred, 0.5))

scatter(5 + jitter, xval_normLiks(6,:) - ref, 100, 'x', 'linewidth', lw, 'markeredgecolor', lighten(task_green, 0.5))
scatter(6 + jitter, xval_normLiks(7,:) - ref, 100, 'x', 'linewidth', lw, 'markeredgecolor', lighten(task_green, 0.5))
scatter(7 + jitter, xval_normLiks(8,:) - ref, 100, 'x', 'linewidth', lw, 'markeredgecolor', lighten(task_green, 0.5))
scatter(8 + jitter, xval_normLiks(9,:) - ref, 100, 'x', 'linewidth', lw, 'markeredgecolor', lighten(task_green, 0.5))

errorbar(1, mean(xval_normLiks(2,:) - ref), sem(xval_normLiks(2,:) - ref), 'color', msred, 'linewidth', 2)
errorbar(2, mean(xval_normLiks(3,:) - ref), sem(xval_normLiks(3,:) - ref), 'color', msred, 'linewidth', 2)
errorbar(3, mean(xval_normLiks(4,:) - ref), sem(xval_normLiks(4,:) - ref), 'color', msred, 'linewidth', 2)
errorbar(4, mean(xval_normLiks(5,:) - ref), sem(xval_normLiks(5,:) - ref), 'color', msred, 'linewidth', 2)

errorbar(5, mean(xval_normLiks(6,:) - ref), sem(xval_normLiks(6,:) - ref), 'color', task_green, 'linewidth', 2)
errorbar(6, mean(xval_normLiks(7,:) - ref), sem(xval_normLiks(7,:) - ref), 'color', task_green, 'linewidth', 2)
errorbar(7, mean(xval_normLiks(8,:) - ref), sem(xval_normLiks(8,:) - ref), 'color', task_green, 'linewidth', 2)
errorbar(8, mean(xval_normLiks(9,:) - ref), sem(xval_normLiks(9,:) - ref), 'color', task_green, 'linewidth', 2)

set(gca,'xtick',1:8,'xticklabel',{
    'Reward-Seeking',...
    'Perseveration', ...
    'Novelty Preference', ...
    'Bias',...
    'TD(0)', ...
    'TD(1)', ...
    'TD(lambda)',...
    'Transition Learning',...
    })
set(gca, 'ytick', [-0.15, -0.1, -0.05, 0], 'yticklabel', {'-15%', '-10%', '-5%', '0%'})
xlim([0.5, 8.5])
ylabel({'Difference in Normalized','Cross-Validated Likelihood'})
title('Change in Quality of Model Fit')
set(gcf, 'pos', [600, 600, 1100, 400])

print_svg('fig2_model_compare')