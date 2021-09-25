%% Gather behavioral datasets
addpath(genpath(pwd))

opto_data = load('opto_dataset');
ephys_data = load('physdata_corrected.mat');

% Remove ephys fields from the ephys data
ephys_data_beh_sessions = rmfield(ephys_data.ratdatas, {'spiketimes', 'cell_types','unitchannels', 'to_exclude'});
% Find mapping between data and rats
[~, ~, inds] = unique(vertcat(ephys_data_beh_sessions.ratname), 'rows');
% Merge all sessions from each rat
for rat_i = 1:6
    ephys_data_beh_rats{rat_i} = merge_ratdata_cell(ephys_data_beh_sessions(inds == rat_i));
end

ratdatas_all = [ephys_data_beh_rats, opto_data.stimdata, opto_data.opto_data_cntrl];
ratdata_conditions = [ones(1, length(ephys_data_beh_rats)), ...
                     2*ones(1, length(opto_data.stimdata)),...
                     3*ones(1,length(opto_data.opto_data_cntrl))];


clear ephys_data
%% Fit the model, generate synthetic datasets
% Fit Model
model_path = 'analysis_code/stan_models\multiagent_model_single.stan';
inc = [1,0,1,0,0,1,1,0];
addpath(genpath('C:\Users\kevin\Documents\Software\Stan'))

for rat_i = 1:length(ratdatas_all)
    ratdata = ratdatas_all{rat_i};
    standata = ratdata2standata(ratdata, inc);
    
   results = fit_stan_model(standata, model_path);
    fit_params(rat_i) = results;
end

% Generate synthetic datasets, compare regressions
ratnames_for_plot = {'E1','E2','E3','E4','E5','E6',...
    'O1','O2','O3','O4','O5','O6','O7','O8','O9',...
    'S1','S2','S3','S4'};

nBack = 5;
for rat_i = 1:length(ratdatas_all)
    
    p = fit_params(rat_i);
    ratdata = ratdatas_all{rat_i};
    
    params = [p.alphaMB, p.betaMB, p.betaBonus, p.betaPersev, p.betaBias];
    simdata = generate_simulated_data('mb_bonus_persev_bias',params,ratdata);
    
    twostep_glm(ratdata,nBack); legend off
    f1 = gcf;
    y1 = get(gca,'ylim');
    
    title(['Rat ',ratnames_for_plot{rat_i}],'fontsize',35);
    set(gca,'fontsize',20);
    ylabel({'Stay/Switch','Regression Weight'},'fontsize',25);
    xlabel('Trials Ago','fontsize',25);
    
    twostep_glm(simdata,nBack); legend off
    f2 = gcf;
    y2 = get(gca,'ylim');
    
    title(['Model Fit to Rat ',ratnames_for_plot{rat_i}],'fontsize',35);
    set(gca,'fontsize',20);
    ylabel({'Stay/Switch','Regression Weight'},'fontsize',25);
    xlabel('Trials Ago','fontsize',25);
   
    ylims = [min([y1, y2]), max([y1, y2])];
    figure(f1)
    ylim(ylims)
    figure(f2)
    ylim(ylims)
    
    % Save Figs
    saveas(f1, ['figures_raw/s1/glm_rat_', num2str(rat_i),'.png'])
    saveas(f2, ['figures_raw/s1/glm_model_', num2str(rat_i),'.png'])
    close(f1)
    close(f2)
end

