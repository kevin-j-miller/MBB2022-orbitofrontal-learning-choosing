%% Gather behavioral datasets

opto_data = load('opto_dataset');
ephys_data = load('physdata_corrected.mat');

% Remove ephys fields from the ephys data
ephys_data_beh_sessions = rmfield(ephys_data.ratdatas, {'spiketimes', 'cell_types','unitchannels', 'to_exclude'});
% Find mapping between data and rats
[~, ~, inds] = unique(vertcat(ephys_data_beh_sessions.ratname), 'rows');

% Merge all sessions from each rat
% Remove M093 because he only has one session
for rat_i = [1,2,3,4]
    ephys_data_beh_rats{rat_i} = merge_ratdata_cell(ephys_data_beh_sessions(inds == rat_i));
end




% Assemble the data into one nice package
ratdatas_all = [ephys_data_beh_rats, opto_data.stimdata, opto_data.opto_data_cntrl];
ratdata_conditions = [ones(1, length(ephys_data_beh_rats)), ...
    2*ones(1, length(opto_data.stimdata)),...
    3*ones(1,length(opto_data.opto_data_cntrl))];
nRats = length(ratdatas_all);

% Clear these to give back the RAM
clear opto_data
clear ephys_data

%% Model Comparison
inc_default  = [1,0,1,0,0,1,1,0];

inc_no_plan   = [0,0,1,0,0,1,1,0];
inc_no_persev = [1,0,1,0,0,0,1,0];
inc_no_csus   = [1,0,0,0,0,1,1,0];
inc_no_bias   = [1,0,1,0,0,1,0,0];

inc_add_mf       = [1,1,1,0,0,1,1,0];
inc_add_tlearn   = [1,0,1,0,0,1,1,1];

model_path = 'analysis_code/stan_models\multiagent_model_single.stan';
addpath(genpath('C:\Users\kevin\Documents\Software\Stan'))

for rat_i = 1:nRats
    disp(['Running rat #', num2str(rat_i), ' of ' ,num2str(nRats)]);
    normLik_default(rat_i) = xval_twostep_stan(ratdatas_all{rat_i}, inc_default);
    
    normLik_no_plan(rat_i) = xval_twostep_stan(ratdatas_all{rat_i}, inc_no_plan);
    normLik_no_persev(rat_i) = xval_twostep_stan(ratdatas_all{rat_i}, inc_no_persev);
    normLik_no_csus(rat_i) = xval_twostep_stan(ratdatas_all{rat_i}, inc_no_csus);
    normLik_no_bias(rat_i) = xval_twostep_stan(ratdatas_all{rat_i}, inc_no_bias);
    
    normLik_add_mf(rat_i) = xval_twostep_stan(ratdatas_all{rat_i}, inc_add_mf);
    normLik_add_tlearn(rat_i) = xval_twostep_stan(ratdatas_all{rat_i}, inc_add_tlearn);
    
end

%% Make a nice plot

jitter_width = 0.4;
x_jit = (0:jitter_width/(nRats-1):jitter_width) - jitter_width/2;

normLiks = {normLik_no_plan, normLik_no_persev, normLik_no_csus, normLik_no_bias,...
    normLik_add_mf, normLik_add_tlearn};
colors = [repmat(msred,[4,1]);...
    repmat(mslblue,[2,1])];

figure; hold on
line([0,20], [0, 0], 'color','black')
for compare_i = 1:6
    
    xs = compare_i + x_jit;
    ys = 100*(normLiks{compare_i} - normLik_default);
    
    scatter(xs, ys, 'x', ...
        'sizedata',50,...
        'markeredgecolor',lighten(colors(compare_i,:),0.5),...
        'linewidth', 2);
    
    errorbar(compare_i, mean(ys), sem(ys), '.',...
        'linewidth', 3, ...
        'color', colors(compare_i,:))
end

xlim([0,7])

set(gca,'fontsize',16,'ytick',[-10,-5,0],'yticklabel',{'-10%','-5%','0%'}); ylim([-12,3]);
set(gca,'xtick',1:6,'xticklabel',{'Plan','Persev','Nov. Pref.','Bias','MF','T-Learn'});
ylabel('Change in Norm. Xval. Likelihood','Fontsize',16);
title('Change in Quality of Fit','fontsize',20);
















