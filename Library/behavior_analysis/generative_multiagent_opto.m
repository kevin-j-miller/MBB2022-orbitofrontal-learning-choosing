function modeldata = generative_multiagent_opto(alphaMB_cntrl,betaMB_cntrl,betaBonus,alphaPersev,betaPersev,bias,alpha_stims,beta_stims,task)

% Generate simulated data using a mixture model.  Model contains
% model-based agent, model-free agent, and one-trial-back common-stay,
% uncommon-switch bonuses, and win-stay/lose-switch

if ~isfield(task,'p_congruent')
    pCong = 0.2;
    pIncong = 0.8;
else
    pCong = task.p_congruent;
    pIncong = 1-task.p_congruent;
end

% Determine whether congruent or incongruent is the common transition
if pCong > pIncong
    congCommon = 1;
else
    congCommon = 0;
end

Qmf = [0.5,0.5]; % model-free agent's initial values
Q2mb = [0.5,0.5]; % Initialize q-values to 0.5.  These are *second-step* Q-values
Qbonus = [0.5,0.5];
Q2wsls = [0,0];
Qpersev = [0.5,0.5];
Qbias = [bias, -bias];
alphaMB(1) = alphaMB_cntrl;
alphaMB(2) = 1 - alphaMB_cntrl;
alphaMB(3) = 0;

% Pre-allocate my arrays
nTrials = length(task.rightprobs);
rewards = NaN(nTrials,1);
choices = char(zeros(nTrials,1));
outcomes = char(zeros(nTrials,1));


for trial_i = 1:nTrials
    
    %% Set params for the trial
    switch task.stim_type(trial_i)
        case 'n'
            betaMB = betaMB_cntrl;
        case 'r'
            betaMB = beta_stims(1);
        case 'c'
            betaMB = beta_stims(2);
        case 'b'
            betaMB = beta_stims(3);
    end
    
    if trial_i ~= nTrials
        switch task.stim_type(trial_i+1)
            case 'n'
                alphaMB(1) = alphaMB_cntrl;
                alphaMB(2) = 1 - alphaMB_cntrl;
                alphaMB(3) = 0;
            case 'r'
                alphaMB = alpha_stims(:,1);
            case 'c'
                alphaMB = alpha_stims(:,2);
            case 'b'
                alphaMB = alpha_stims(:,3);
        end
    end
    
    %% Figure out the model's choice given Q-values
    Q1mb(1) = pCong*Q2mb(1) + pIncong*Q2mb(2);
    Q1mb(2) = pCong*Q2mb(2) + pIncong*Q2mb(1);
    
    Q1wsls(1) = congCommon*Q2wsls(1) + ~congCommon*Q2wsls(2);
    Q1wsls(2) = congCommon*Q2wsls(2) + ~congCommon*Q2wsls(1);
    
    Qeff = betaMB*Q1mb + betaBonus*Qbonus + betaPersev*Qpersev + Qbias; % Effective Q-value
    
    actionProbs = exp(Qeff) / sum(exp(Qeff));
    
    if rand <= actionProbs(1)
        choice = 'l';
    else
        choice = 'r';
    end
    
    
    %% Calculate transition and reward
    outcomeCong = rand < pCong;
    Pl = task.leftprobs(trial_i);
    Pr = task.rightprobs(trial_i);
    if choice == 'l'
        if outcomeCong
            outcome = 'l';
            rewardProb = Pl;
        else
            outcome = 'r';
            rewardProb = Pr;
        end
    elseif choice == 'r'
        if outcomeCong
            outcome = 'r';
            rewardProb = Pr;
        else
            outcome = 'l';
            rewardProb = Pl;
        end
    else
        error('invalid choice');
    end
    
    % Determine reward
    reward = rand <= rewardProb;
    
    %% Do the learning
    choice_ind = (choice=='r') + 1; % which side was chosen?
    nonchoice_ind = (choice=='l') + 1;
    
    outcome_ind = (outcome=='r')+1; % 1 for left, 2 for right
    nonoutcome_ind = (outcome=='l')+1; % 1 for left, 2 for right
    
    
    
    Q2mb(outcome_ind) = alphaMB(1)*reward + alphaMB(2)*Q2mb(outcome_ind) + alphaMB(3)*0.5; % Model-Based values
    Q2mb(nonoutcome_ind) = alphaMB(1)*(~reward) + alphaMB(2)*Q2mb(nonoutcome_ind) + alphaMB(3)*0.5;  % Model-Based values
    
    
    % Set up the bonus: +1 for chosen in common, unchosen in uncommon
    if (outcomeCong && congCommon) || (~outcomeCong && ~congCommon)
        outcomeCommon = 1;
    else
        outcomeCommon = 0;
    end
    
    if outcomeCommon
        Qbonus = [0,0];
        Qbonus(choice_ind) = 1;
    else
        Qbonus = [1,1];
        Qbonus(choice_ind) = 0;
    end
    
    % set up persev
    Qpersev(choice_ind) = (1 - alphaPersev) * Qpersev(choice_ind) + alphaPersev;
    Qpersev(nonchoice_ind) = (1 - alphaPersev) * Qpersev(nonchoice_ind);
    
    choices(trial_i) = choice;
    outcomes(trial_i) = outcome;
    rewards(trial_i) = reward;
end

modeldata.rewards = rewards;
modeldata.sides1 = choices;
modeldata.sides2 = outcomes;
modeldata.nTrials = nTrials;
modeldata.p_congruent = pCong;
modeldata.viols = false(size(rewards));
modeldata.leftprobs = task.leftprobs;
modeldata.rightprobs = task.rightprobs;
modeldata.new_sess = task.new_sess;
modeldata.task = 'TwoStep';
modeldata.ratname = 'Synthetic Data';
modeldata.stim_type = task.stim_type;
modeldata.trans_common = (modeldata.p_congruent > 0.5 & modeldata.sides1 == modeldata.sides2) | (modeldata.p_congruent < 0.5 & modeldata.sides1 ~= modeldata.sides2);


end