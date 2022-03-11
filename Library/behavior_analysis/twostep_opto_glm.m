function results = twostep_opto_glm(stimdata, nBack)

nRats = length(stimdata);
model = fullfile(code_path, 'library', 'behavior_analysis', 'stan_models', 'twostep_glm_opto.stan');
if ~exist('nBack','var')
    nBack = 3;
end    

for rat_i = 1:nRats
    
    data_rat = stimdata{rat_i};    
    
    standatas(rat_i).pCong = 0.6*round(data_rat.p_congruent) + 0.2; % Round to exactly 0.2 or 0.8
    standatas(rat_i).nTrials = data_rat.nTrials;
    standatas(rat_i).choices = (data_rat.sides1=='l')+1;
    standatas(rat_i).commons = double(data_rat.trans_common);
    standatas(rat_i).rewards = data_rat.rewards;
    standatas(rat_i).nBack = nBack;
    standatas(rat_i).stims = 1*(data_rat.stim_type == 'r') + 2*(data_rat.stim_type == 'c') + 3*(data_rat.stim_type == 'b');
    standatas(rat_i).stims = [standatas(rat_i).stims;0];
    
end

for rat_i = 1:nRats
    
    wd = fullfile('wd_', datestr(now,'yyyymmdd_HHMMSSFFF'));
    mkdir(wd);

    fit = stan('file', model,...
        'data',standatas(rat_i),...
        'working_dir', wd, ...
        'verbose',false,...
        'method','optimize');
    %fit = stan('file','twostep_glm_opto_nBack_mults.stan','data',standatas{rat_i},'verbose',true,'chains',5,'warmup',200,'iter',500);
    fit.block();
    rmdir(wd, 's')

    glm_fits(rat_i) = extract(fit);
end

for rat_i = 1:nRats
    p = glm_fits(rat_i);
    
    mb_cntrl_by_nBack(rat_i,:) = ((p.beta_cr_cntrl) + (p.beta_uo_cntrl) - (p.beta_ur_cntrl) - (p.beta_co_cntrl));
    mb_rew_by_nBack(rat_i,:)   = ((p.beta_cr_rew)   + (p.beta_uo_rew)   - (p.beta_ur_rew)   - (p.beta_co_rew));
    mb_ch_by_nBack(rat_i,:)    = ((p.beta_cr_ch)    + (p.beta_uo_ch)    - (p.beta_ur_ch)    - (p.beta_co_ch));
    mb_both_by_nBack(rat_i,:)  = ((p.beta_cr_both)  + (p.beta_uo_both)  - (p.beta_ur_both)  - (p.beta_co_both));
    
    mf_cntrl(rat_i) = sum((p.beta_cr_cntrl) - (p.beta_uo_cntrl) + (p.beta_ur_cntrl) - (p.beta_co_cntrl));
    mf_rew(rat_i)   = sum((p.beta_cr_rew)   - (p.beta_uo_rew)   + (p.beta_ur_rew)   - (p.beta_co_rew));
    mf_ch(rat_i)    = sum((p.beta_cr_ch)    - (p.beta_uo_ch)    + (p.beta_ur_ch)    - (p.beta_co_ch));
    mf_both(rat_i)  = sum((p.beta_cr_both)  - (p.beta_uo_both)  + (p.beta_ur_both)  - (p.beta_co_both));
    
    pers_cntrl(rat_i) = sum((p.beta_cr_cntrl) + (p.beta_uo_cntrl) + (p.beta_ur_cntrl) + (p.beta_co_cntrl));
    pers_rew(rat_i)   = sum((p.beta_cr_rew)   + (p.beta_uo_rew)   + (p.beta_ur_rew)   + (p.beta_co_rew));
    pers_ch(rat_i)    = sum((p.beta_cr_ch)    + (p.beta_uo_ch)    + (p.beta_ur_ch)    + (p.beta_co_ch));
    pers_both(rat_i)  = sum((p.beta_cr_both)  + (p.beta_uo_both)  + (p.beta_ur_both)  + (p.beta_co_both));

    np_cntrl(rat_i) = sum((p.beta_ur_cntrl) + (p.beta_uo_cntrl) - (p.beta_cr_cntrl) - (p.beta_co_cntrl));
    np_rew(rat_i)   = sum((p.beta_ur_rew)   + (p.beta_uo_rew)   - (p.beta_cr_rew)   - (p.beta_co_rew));
    np_ch(rat_i)    = sum((p.beta_ur_ch)    + (p.beta_uo_ch)    - (p.beta_cr_ch)    - (p.beta_co_ch));
    np_both(rat_i)  = sum((p.beta_ur_both)  + (p.beta_uo_both)  - (p.beta_cr_both)  - (p.beta_co_both));

end

mb_cntrl = sum(mb_cntrl_by_nBack');
mb_rew = sum(mb_rew_by_nBack');
mb_ch = sum(mb_ch_by_nBack');
mb_both = sum(mb_both_by_nBack');

results.mb_cntrl_by_nBack = mb_cntrl_by_nBack;
results.mb_rew_by_nBack = mb_rew_by_nBack;
results.mb_ch_by_nBack = mb_ch_by_nBack;
results.mb_both_by_nBack = mb_both_by_nBack;

results.mb_cntrl = mb_cntrl;
results.mb_rew = mb_rew;
results.mb_ch = mb_ch;
results.mb_both = mb_both;

results.mf_cntrl = mf_cntrl;
results.mf_rew = mf_rew;
results.mf_ch = mf_ch;
results.mf_both = mf_both;

results.pers_cntrl = pers_cntrl;
results.pers_rew = pers_rew;
results.pers_ch = pers_ch;
results.pers_both = pers_both;

results.np_cntrl = np_cntrl;
results.np_rew = np_rew;
results.np_ch = np_ch;
results.np_both = np_both;


results.glm_fits = glm_fits;
results.nBack = nBack;

end
