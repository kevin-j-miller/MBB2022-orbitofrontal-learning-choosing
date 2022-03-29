function values = values_multiagent(alphaMB, alphaHabit, betaMB, betaHabit, betaCsus, betaBias,ratdata)

% Likelihood function for a multiagent model in the twostep task.  Includes
% planning, habits, novelty preference, and bias

% Determine whether congruent or incongruent is the common transition
pCong = ratdata.p_congruent;
pIncong = 1-pCong;
if pCong > pIncong
    congCommon = 1;
else
    congCommon = 0;
end

% Initialize all values to 0.5. They will range between 0 and 1.
Q2mb =    [0.5, 0.5]; % These are _second-step_ model-based values. First-step will be computed from them.
Qcsus =   [0.5, 0.5];
Qhabit = [0.5, 0.5];

nTrials = length(ratdata.sides1);


for trial_i = 1:nTrials

    %% Compute values
    % Compute first-step model-based values
    Q1mb(1) = pCong*Q2mb(1) + pIncong*Q2mb(2);
    Q1mb(2) = pCong*Q2mb(2) + pIncong*Q2mb(1);
    % Compute total effective value
    Qeff = betaMB*Q1mb + betaHabit*Qhabit + betaCsus*Qcsus + betaBias; % Effective Q-value

    %% Process the trial
    % Which side was chosen?
    choice = ratdata.sides1(trial_i);
    choice_ind = (choice=='r') + 1;
    nonchoice_ind = (choice=='l') + 1;
    % What was the outcome?
    outcome = ratdata.sides2(trial_i);
    outcome_ind = (outcome=='r') + 1; % 1 for left, 2 for right
    nonoutcome_ind = (outcome=='l') + 1; % 1 for left, 2 for right
    % Was it congruent or incongruent?
    if outcome == choice
        cong = true;
    else
        cong = false;
    end
    % Was it common or uncommon?
    if (congCommon && cong) || (~congCommon && ~cong)
        outcomeCommon = true;
    else
        outcomeCommon = false;
    end
    % Was there a reward?
    reward = ratdata.rewards(trial_i);

    %% Record values for this trial
    % Basic values
    values.Q1mbs(trial_i,:) = Q1mb;
    values.Q2mbs(trial_i,:) = Q2mb;
    values.Qhabits(trial_i,:) = Qhabit;
    values.Qeffs(trial_i,:) = Qeff;

    % Values to look for in ephys
    values.Qmb_outcome(trial_i) = Q2mb(outcome_ind);
    values.Qmb_chosen(trial_i) = Q1mb(choice_ind);
    values.Qeff_chosen(trial_i) = Qeff(choice_ind);
    values.Qmb_choice(trial_i) = diff(Q1mb);


    %% Update Agent Values

    if ~ratdata.viols(trial_i)

        % Model-based
        Q2mb(outcome_ind) = Q2mb(outcome_ind) + alphaMB*(reward - Q2mb(outcome_ind));
        Q2mb(nonoutcome_ind) = Q2mb(nonoutcome_ind) + alphaMB*(~reward - Q2mb(nonoutcome_ind));

        % Habits
        Qhabit(choice_ind) = (1 - alphaHabit)*Qhabit(choice_ind) + alphaHabit;
        Qhabit(nonchoice_ind) = (1 - alphaHabit)*Qhabit(nonchoice_ind);

        % Novelty preference
        Qcsus = [0,0];
        if outcomeCommon
            Qcsus(choice_ind) = 1;
        else
            Qcsus(nonchoice_ind) = 1;
        end

    end



end

end