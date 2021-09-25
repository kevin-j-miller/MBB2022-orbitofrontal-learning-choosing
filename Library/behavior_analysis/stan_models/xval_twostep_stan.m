function normLik = xval_twostep_stan(data_rat,inc)

    model_file = 'analysis_code/stan_models/multiagent_model_single_xval.stan';

    data_rat = remove_viols(data_rat);

    [data_even,data_odd] = split_even_odd(data_rat);
    
    standata_even.pCong = 0.6*round(data_rat.p_congruent) + 0.2; % Round to exactly 0.2 or 0.8
    standata_even.nTrials = data_even.nTrials;
    standata_even.choices = (data_even.sides1=='l')+1;
    standata_even.outcomes = (data_even.sides2=='l')+1;
    standata_even.rewards = data_even.rewards;
    standata_even.nTrials_test = data_odd.nTrials;
    standata_even.choices_test = (data_odd.sides1=='l')+1;
    standata_even.outcomes_test = (data_odd.sides2=='l')+1;
    standata_even.rewards_test = data_odd.rewards;
    
    standata_odd.pCong = 0.6*round(data_rat.p_congruent) + 0.2; % Round to exactly 0.2 or 0.8
    standata_odd.nTrials = data_odd.nTrials;
    standata_odd.choices = (data_odd.sides1=='l')+1;
    standata_odd.outcomes = (data_odd.sides2=='l')+1;
    standata_odd.rewards = data_odd.rewards;
    standata_odd.nTrials_test = data_even.nTrials;
    standata_odd.choices_test = (data_even.sides1=='l')+1;
    standata_odd.outcomes_test = (data_even.sides2=='l')+1;
    standata_odd.rewards_test = data_even.rewards;
    
    standata_odd.inc = inc;
    standata_even.inc = inc;


    pause(rand); % Pause for random fraction of a second to make extra sure we're not in the same millisecond as another process
    wd = ['working_folders/',datestr(now,'yyyymmdd_HHMMSSFFF')];
    mkdir(wd);
    
    fit_even = stan('file',model_file,'data',standata_even,'verbose',false,'method','optimize','working_dir',wd);
    fit_even.block();
    fit_even_extracted = extract(fit_even);
    
    fit_odd = stan('file',model_file,'data',standata_odd,'verbose',false,'method','optimize','working_dir',wd);
    fit_odd.block();
    fit_odd_extracted = extract(fit_odd);
    
    rmdir(wd,'s');
    
    xval_ll = fit_even_extracted.xval_ll + fit_odd_extracted.xval_ll;
    
    normLik = exp(xval_ll / data_rat.nTrials);
    
end