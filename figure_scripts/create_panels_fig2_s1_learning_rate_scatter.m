%% Learning rate scatterplot for Figure 2-1
% Supports the claim that learning rate for perseveration is slower than
% for reward learning

%% Load Data
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

%%
xs = [fit_params.alphaPersev];
ys = [fit_params.alphaMB];

marker_size = 75;
ew = 2;
l = 0.5;

fig = figure; hold on
line([-10, 10], [0, 0], 'color', 'k')
line([0, 0], [-10, 10], 'color', 'k')
line([-10, 10], [-10, 10], 'color', 'k')
scatter(xs(opto_rats), ys(opto_rats), marker_size, 'v', ...
    'markeredgecolor', lighten([0,0,0],l), ...
    'markerfacecolor', 'none',...
    'linewidth', ew)
scatter(xs(sham_rats), ys(sham_rats), marker_size, 'd', ...
    'markeredgecolor', ...
    lighten([0,0,0],l), ...
    'markerfacecolor', 'none',...
    'linewidth', ew)
scatter(xs(ephys_rats), ys(ephys_rats), marker_size, 's', ...
    'markeredgecolor', lighten([0,0,0],l), ...
    'markerfacecolor', 'none',...
    'linewidth', ew)



xlim([0, 1])
ylim([0, 1])
axis square
set(gca,'fontsize',20)
ylabel('Learning Rate: Model-Based')
xlabel('Learning Rate: Perseveration')

print_svg('fig2-1_learning_rate_scatter');