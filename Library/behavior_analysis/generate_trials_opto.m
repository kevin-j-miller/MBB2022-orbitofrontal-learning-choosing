function task = generate_trials_opto(n_trials)

n_trials_per_sess = 500;

% Pre-allocate
task.new_sess = zeros(n_trials, 1);
task.rightprobs = zeros(n_trials, 1);
task.leftprobs = zeros(n_trials, 1);
task.stim_type = zeros(n_trials, 1);

for trial_i = 1:n_trials

    % Should this be the first trial in a new session?
    if mod(trial_i, n_trials_per_sess) == 1
        new_sess = 1;
    else
        new_sess = 0;
    end

    % If this is the first trial in a new session, re-randomize reward
    % probabilities
    if new_sess == 1
        right_prob = (rand<0.5)*0.6 + 0.2; % 50/50 chance of 20% or 80%
        left_prob = 1 - right_prob;
    end

    % Decide which stim condition this will be in. 7% chance each of 'r',
    % 'c', or 'b' (reward-period, choice-period, both). 79% chance of 'n'
    % (no stim)
    opto_rand = rand;
    if opto_rand < 0.7
        stim_type = 'r';
    elseif opto_rand < 0.14
        stim_type = 'c';
    elseif opto_rand < 0.21
        stim_type = 'b';
    else
        stim_type = 'n';
    end

    % Add variables to the task struct
    task.new_sess(trial_i) = new_sess;
    task.rightprobs(trial_i) = right_prob;
    task.leftprobs(trial_i) = left_prob;
    task.stim_type(trial_i) = stim_type;

end



end