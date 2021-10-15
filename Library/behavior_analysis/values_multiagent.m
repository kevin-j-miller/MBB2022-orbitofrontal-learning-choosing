function values = values_multiagent(alphaMF,alphaMB,betaMF,betaMB,betaBonus,betaWsls,betaPersev,bias,ratdata)

% Likelihood function for a multiagent model in the twostep task.  Includes
% model-based, model-free, and "bonus" agents

% Check that parameters are in bounds
if alphaMF < 0 || alphaMF > 1 ||alphaMB < 0 || alphaMB > 1 || betaMF < 0 || betaMB < 0
    LL = NaN;
    warning('One or more parameters passed to likelihood_multiagent were out of bounds');
    return
end

% Determine whether congruent or incongruent is the common transition
pCong = ratdata.p_congruent;
pIncong = 1-pCong;
if pCong > pIncong
    congCommon = 1;
else
    congCommon = 0;
end

Qmf = [0.5,0.5]; % model-free agent's initial values
Q2mb = [0.5,0.5]; % Initialize q-values to 0.5.  These are *second-step* Q-values
Qbonus = [0.5,0.5];
Q2wsls = [0,0];
Qbias = [bias,-bias];
Qpersev = [0,0];

nTrials = length(ratdata.sides1);


for trial_i = 1:nTrials
    
    %% Compute values
    % Figure out model's choice probs
    Q1mb(1) = pCong*Q2mb(1) + pIncong*Q2mb(2);
    Q1mb(2) = pCong*Q2mb(2) + pIncong*Q2mb(1);
    Q1wsls(1) = congCommon*Q2wsls(1) + ~congCommon*Q2wsls(2);
    Q1wsls(2) = congCommon*Q2wsls(2) + ~congCommon*Q2wsls(1);
    Qeff = betaMB*Q1mb + betaMF*Qmf + betaBonus*Qbonus + betaWsls*Q1wsls + betaPersev*Qpersev + Qbias; % Effective Q-value
    
    % Which side was chosen?
    choice = ratdata.sides1(trial_i);
    choice_ind = (choice=='r') + 1; 
    nonchoice_ind = (choice=='l') + 1;
    % Was the transition congruent or incongruent?
    outcome = ratdata.sides2(trial_i);    
    outcome_ind = (outcome=='r')+1; % 1 for left, 2 for right
    nonoutcome_ind = (outcome=='l')+1; % 1 for left, 2 for right
    % Was there a reward?
    reward = ratdata.rewards(trial_i);
    
    % Basic values
    Qmfs(trial_i,:) = Qmf;
    Q1mbs(trial_i,:) = Q1mb;
    Q2mbs(trial_i,:) = Q2mb;
    Qbonuss(trial_i,:) = Qbonus;
    Q2wslss(trial_i,:) = Q2wsls;
    Qbiass(trial_i,:) = Qbias;
    Qpersevs(trial_i,:) = Qpersev;
    Qeffs(trial_i,:) = Qeff;
    
    % Values to look for in ephys
    Q_outcome(trial_i) = Q2mb(outcome_ind);
    Q_chosen(trial_i) = Q1mb(choice_ind);
    Q_choice(trial_i) = diff(Q1mbs(trial_i,:));
    
    
    %% Update Q-values
    
    if ~ratdata.viols(trial_i)
        
        
        
        Q2mb(outcome_ind) = Q2mb(outcome_ind) + alphaMB*(reward - Q2mb(outcome_ind)); % Model-Based values
        Qmf(choice_ind) = Qmf(choice_ind) + alphaMF*(reward - Qmf(choice_ind)); % Model-Free values
        
        % Do the learning for nonchosen side
        Q2mb(nonoutcome_ind) = Q2mb(nonoutcome_ind) + alphaMB*(~reward - Q2mb(nonoutcome_ind)); % Model-Based values
        Qmf(nonchoice_ind) = Qmf(nonchoice_ind) + alphaMF*(~reward - Qmf(nonchoice_ind)); % Model-Free values
        
        % set up persev
        Qpersev(choice_ind) = 1;
        Qpersev(nonchoice_ind) = 0;
        
        % Set up win-stay, lose-switch
        if reward
            Q2wsls = [0,0];
            Q2wsls(outcome_ind) = 1;
        else
            Q2wsls = [1,1];
            Q2wsls(outcome_ind) = 0;
        end
        
        if outcome == choice
            cong = true;
        else
            cong = false;
        end
        % Was the transition common or uncommon
        if (congCommon && cong) || (~congCommon && ~cong)
            outcomeCommon = true;
        else
            outcomeCommon = false;
        end
        
        if outcomeCommon
            Qbonus = [0,0];
            Qbonus(choice_ind) = 1;
        else
            Qbonus = [1,1];
            Qbonus(choice_ind) = 0;
        end
        
    end
    
    
    
end

values.Q_outcome = Q_outcome;
values.Q_chosen = Q_chosen;
values.Q_choice = Q_choice;
values.Qeff = Qeffs;
values.Q1mbs = Q1mbs;
values.Q2mbs = Q2mbs;
values.Qbonus = Qbonuss;
values.Qwslss = Q2wsls;
values.Qbias = Qbiass;
values.Qpersev = Qpersevs;
values.Qmf = Qmfs;
end