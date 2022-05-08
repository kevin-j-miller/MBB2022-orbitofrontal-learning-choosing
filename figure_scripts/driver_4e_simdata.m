%% Check that we can find the dataset
opto_data_file = fullfile(files_path, 'preprocessed_data', 'ofc_learning_choosing_dataset_opto.mat');

assert(exist(opto_data_file, 'file') == 2, ...
    'Unable to find opto dataset. Please find "ofc_learning_choosing_dataset_opto.mat", and place it in the Matlab path.')

%% Fit model to stimdatas, get params for simdata
load(opto_data_file)

model = fullfile(code_path, 'library', 'behavior_analysis', 'stan_models', 'multiagent_model_single.stan');
inc = [1,0,1,0,0,1,1,0];
%inc = [1,0,1,0,0,2,1,0];

nRats = length(stimdata);
    
for rat_i = 1:length(stimdata)
    ratdata = stimdata{rat_i};
    standata = ratdata2standata(ratdata, inc);
    
    disp(['Fitting reduced model, rat #',num2str(rat_i)]);
    wd = ['working_folders/',datestr(now,'yyyymmdd_HHMMSSFFF')];
    mkdir(wd);
    fit = stan('file',model,'data',standata,'verbose',false,'method','optimize','working_dir',wd);
    fit.block;
    fits_extracted = extract(fit);
    fit_params_noAlphaPersev(rat_i) = fits_extracted;
    rmdir(wd,'s');
end

%% Load fit parameters from behavioral model
loaded = load(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits'));
% conditions == 1 are the opto rats
fit_params = loaded.fit_params(loaded.ratdata_conditions == 1);

% Load behavioral data, so that we can run synthetic dataset with the same
% trial types
loaded = load(fullfile(files_path, 'preprocessed_data', 'ofc_learning_choosing_dataset_opto.mat'));
stimdata = loaded.stimdata;
nRats = length(stimdata);

%% Generate synthetic datasets manipulating parameters on opto trials
nBack = 3;
effect_mult = 0.2;

rew_color = [159, 54, 41]/255;
ch_color = [31, 119, 82]/255;
both_color = [82, 61, 139]/255;

for rat_i = 1:nRats
    
    %p = fit_params(rat_i);

    p.alphaMB = mean([fit_params.alphaMB]);
    p.betaMB = mean([fit_params.betaMB]);
    p.alphaPersev = mean([fit_params.alphaPersev]);
    p.betaPersev = mean([fit_params.betaPersev]);
    p.betaBonus = mean([fit_params.betaBonus]);
    p.betaBias = mean([fit_params.betaBias]);

    task = stimdata{rat_i};
    
    alphas_noeffect = [    p.alphaMB,      p.alphaMB,       p.alphaMB;...
                       1 - p.alphaMB,  1 - p.alphaMB,   1 - p.alphaMB;...
                                   0,              0,              0];
                     
    alphas_remember_effect = alphas_noeffect;
    alphas_remember_effect(1,[1,3]) = p.alphaMB; 
    alphas_remember_effect(2,[1,3]) = (1-p.alphaMB)*effect_mult;
    alphas_remember_effect(3,[1,3]) = 1 - sum(alphas_remember_effect(1:2,1));
                               
    alphas_learn_effect = alphas_noeffect;
    alphas_learn_effect(1,[1,3]) = p.alphaMB*effect_mult; 
    alphas_learn_effect(2,[1,3]) = (1-p.alphaMB);
    alphas_learn_effect(3,[1,3]) = 1 - sum(alphas_remember_effect(1:2,1));
    
    betas_no_effect = [p.betaMB, p.betaMB, p.betaMB];
    betas_effect = effect_mult * betas_no_effect;
    
    simdatas_beta_effect{rat_i} = generative_multiagent_opto(p.alphaMB, p.betaMB, p.betaBonus, p.alphaPersev, p.betaPersev, p.betaBias, ...
        alphas_noeffect, betas_effect, task);

    simdatas_alpha_remember_effect{rat_i} = generative_multiagent_opto(p.alphaMB, p.betaMB, p.betaBonus, p.alphaPersev, p.betaPersev, p.betaBias, ...
        alphas_remember_effect, betas_no_effect, task);
    
    simdatas_alpha_learn_effect{rat_i} = generative_multiagent_opto(p.alphaMB, p.betaMB, p.betaBonus, p.alphaPersev, p.betaPersev, p.betaBias, ...
        alphas_learn_effect, betas_no_effect, task);
    
end

simdatas = {simdatas_beta_effect,simdatas_alpha_remember_effect, simdatas_alpha_learn_effect};
    
% warping for warped figure
offset = 0.02;
transform = @(x) log(x+offset);
transform_inverse = @(x) exp(x) - offset;

for data_i = 1:3
    simdata = simdatas{data_i};

results = twostep_opto_glm(simdata,nBack);
cntrl_by_nBack = results.mb_cntrl_by_nBack;
rew_by_nBack = results.mb_rew_by_nBack;

figure; hold on;
line([0,10],transform([0,0]),'color',[0,0,0])

data = cntrl_by_nBack;
xs = 1:nBack;
ys = transform(mean(data)); 
ub = transform(mean(data) + sem(data));
lb = transform(mean(data) - sem(data));
above = ub - ys; below = ys - lb;
errorbar(xs, ys, below, above, 'color','k','LineWidth',2.5);

data = rew_by_nBack;
xs = 1:nBack;
ys = transform(mean(data)); 
ub = transform(mean(data) + sem(data));
lb = transform(mean(data) - sem(data));
above = ub - ys; below = ys - lb;
errorbar(xs, ys, below, above,'color',rew_color,'LineWidth',2.5);


yticks = transform([0:0.1:1, (1:10)+1]);
ylim(transform([-offset, 6.4]))
xlim([0.5,nBack + 0.5]); set(gca,'fontsize',20, 'ytick', yticks,'yticklabels',{'0','0.1','','0.3','','','','','','','1.0','','3.0','','','',''})
xlabel('Trials Ago','fontsize',20); ylabel('Contribution to Planning Index','fontsize',20);
set(gca,'Xdir','reverse')

[~,p_values] = ttest(cntrl_by_nBack - rew_by_nBack)


drawnow
end

