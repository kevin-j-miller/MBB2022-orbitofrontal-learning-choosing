%% Gather behavioral datasets

opto_data = load('ofc_learning_choosing_dataset_opto.mat');
ephys_data = load('ofc_learning_choosing_dataset_ephys.mat');

% Remove ephys fields from the ephys data
ephys_data_beh_sessions = rmfield(ephys_data.ratdatas, {'spiketimes', 'cell_types','unitchannels', 'to_exclude'});
% Find mapping between data and rats
[~, ~, inds] = unique(vertcat(ephys_data_beh_sessions.ratname), 'rows');
% Merge all sessions from each rat
for rat_i = 1:6
    ephys_data_beh_rats{rat_i} = merge_ratdata_cell(ephys_data_beh_sessions(inds == rat_i));
end

ratdatas_all = [opto_data.stimdata, opto_data.opto_data_cntrl, ephys_data_beh_rats];
ratdata_conditions = [ones(1, length(opto_data.stimdata)), ...
                     2*ones(1, length(opto_data.opto_data_cntrl)),...
                     3*ones(1,length(ephys_data_beh_rats))];



%% Fit the model, generate synthetic datasets
% Fit Model
model_path = fullfile(ofc_learning_choosing_path, 'library', 'behavior_analysis','stan_models','multiagent_model_single.stan');
inc = [1,0,1,0,0,1,1,0];

for rat_i = 1:length(ratdatas_all)
    ratdata = ratdatas_all{rat_i};
    standata = ratdata2standata(ratdata, inc);
    
   results = fit_stan_model(standata, model_path);
    fit_params(rat_i) = results;
end

% Generate synthetic datasets, compare regressions
nBack = 5;
for rat_i = 1:length(ratdatas_all)
    
    p = fit_params(rat_i);
    ratdata = ratdatas_all{rat_i};
    
    params = [p.alphaMB, p.betaMB, p.betaBonus, p.betaPersev, p.betaBias];
    simdata = generate_simulated_data('mb_bonus_persev_bias',params,ratdata);
    
    twostep_glm(ratdata,nBack); legend off
    yl = get(gca,'ylim');
    
    title(['Rat #',num2str(rat_i)],'fontsize',16);
    set(gca,'fontsize',14);
    ylabel({'Same/Other','Regression Weight'},'fontsize',16);
    xlabel('Trials Ago','fontsize',16);
    
    twostep_glm(simdata,nBack); legend off
    title(['Mixture Model Fit to Rat #',num2str(rat_i)],'fontsize',16);
    set(gca,'fontsize',14);
    ylabel({'Same/Other','Regression Weight'},'fontsize',16);
    xlabel('Trials Ago','fontsize',16);
   
end

