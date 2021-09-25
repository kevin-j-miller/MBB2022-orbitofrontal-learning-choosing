%% Load behavioral datasets
loaded = load('opto_dataset');
dataset_opto = loaded.stimdata;
dataset_sham = loaded.opto_data_cntrl;

loaded = load('behavioral_model_fits_physdata','model_params', 'ratnames', 'phys_sessions_by_rat');
dataset_ephys = loaded.phys_sessions_by_rat;

%% Run behavior regressions
for rat_i = 1:length(dataset_opto)
    results = twostep_glm(dataset_opto{rat_i});
    mb_opto(rat_i) = results.mb_ind;
    mf_opto(rat_i) = results.mf_ind;
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim([-1.5, 3])
    print(['figures_raw/individual_rat_glms/opto_', num2str(rat_i)], '-dsvg')
end

for rat_i = 1:length(dataset_sham)
    results = twostep_glm(dataset_sham{rat_i});
    mb_sham(rat_i) = results.mb_ind;
    mf_sham(rat_i) = results.mf_ind;
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim([-1.5, 3])
    print(['figures_raw/individual_rat_glms/sham_', num2str(rat_i)], '-dsvg')
end

for rat_i = 1:length(dataset_ephys)
    results = twostep_glm(dataset_ephys(rat_i));
    mb_ephys(rat_i) = results.mb_ind;
    mf_ephys(rat_i) = results.mf_ind;
    legend off
    set(gca,'Xdir','reverse')
    box off
    ylim([-1.5, 3])
    print(['figures_raw/individual_rat_glms/ephys_', num2str(rat_i)], '-dsvg')
end

close all

%% Scatterplot for fig 1
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

print('figures_raw/fig1_mbmf_scatter', '-dsvg')

close all

%% Model fitting scatterplot
model_params_ephys = loaded.model_params;

model_path = 'analysis_code/stan_models\multiagent_model_single.stan';
inc = [1,0,1,0,0,1,1,0];
addpath(genpath('C:\Users\kevin\Documents\Software\Stan'))

for rat_i = 1:9
    ratdata = dataset_opto{rat_i};
    standata = ratdata2standata(ratdata, inc);
    
    disp(['Fitting reduced model, rat #',num2str(rat_i)]);
    wd = ['working_folder_',datestr(now,'yyyymmdd_HHMMSSFFF')];
    mkdir(wd);
    fit = stan('file',model_path,'data',standata,'verbose',false,'method','optimize','working_dir',wd);
    fit.block;
    fits_extracted = extract(fit);
    model_params_opto(rat_i) = fits_extracted;
    rmdir(wd,'s');

end

for rat_i = 1:4
    ratdata = dataset_sham{rat_i};
    standata = ratdata2standata(ratdata, inc);
    
    disp(['Fitting reduced model, rat #',num2str(rat_i)]);
    wd = ['working_folder_',datestr(now,'yyyymmdd_HHMMSSFFF')];
    mkdir(wd);
    fit = stan('file',model_path,'data',standata,'verbose',false,'method','optimize','working_dir',wd);
    fit.block;
    fits_extracted = extract(fit);
    model_params_sham(rat_i) = fits_extracted;
    rmdir(wd,'s');

end

%% Make the parameter fits scatterplot
marker_size = 75;
ew = 2;
l = 0.5;
l2 = 0.9;
jit = 0.4;

params_all = {model_params_ephys, model_params_opto, model_params_sham};
icons = 'svd';

fig = figure; hold on
line([-10, 10], [0, 0], 'color', 'k')

for dataset_i = 1:3
    params = params_all{dataset_i};
    icon = icons(dataset_i);
    nRats = length(params);
    jitter = (0:jit/(nRats-1):jit) - jit/2;
    ys = [params.betaMB_norm, params.betaPersev_norm, params.betaBonus_norm, params.betaBias];
    xs = sort(repmat((1:4),[1,nRats]) + repmat(jitter, [1,4]));
scatter(xs, ys, marker_size, icon, 'markeredgecolor', lighten([0,0,0],l), ...
    'markerfacecolor', 'none',...
    'linewidth', ew)

end

params_all = [model_params_ephys, model_params_opto, model_params_sham];
means = [mean([params_all.betaMB_norm]), ...
    mean([params_all.betaPersev_norm]), ...
    mean([params_all.betaBonus_norm]), ...
    mean([params_all.betaBias])];
sems = [sem([params_all.betaMB_norm]), ...
    sem([params_all.betaPersev_norm]), ...
    sem([params_all.betaBonus_norm]), ...
    sem([params_all.betaBias])];
errorbar(1:4, means, sems, '.', 'color', lighten([0,0,0], l2), 'linewidth', 2)


xlim([0.5, 4.5])
set(gca,'fontsize',14)
xlabel('Behavioral Component')
ylabel('Normalized Mixture Weight')
set(gca,'xticklabel', {'Planning', 'Perseveration', 'Novelty Preference', 'Bias'})
print('figures_raw/fig1_params_scatter', '-dsvg')

close all
