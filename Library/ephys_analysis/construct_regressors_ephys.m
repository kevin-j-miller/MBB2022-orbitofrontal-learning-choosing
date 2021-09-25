function [regressors, reg_names] = construct_regressors_ephys(ratdata)


side_chosen_all = 1 + (ratdata.sides1 == 'r');
side_received_all = 1 + (ratdata.sides2 == 'r');
reward_all = 1 + (ratdata.rewards' == 1);


v_left_all = ratdata.Q1mbs(:,1)';

for trial_i = 1:ratdata.nTrials
    v_chosen_all(trial_i) = ratdata.Q1mbs(trial_i,side_chosen_all(trial_i));
    v_received_all(trial_i) = ratdata.Q2mbs(trial_i,side_received_all(trial_i));
end


v_received_pre = v_received_all(1:end-1)';
reward_pre = reward_all(1:end-1)';
side_received_pre = side_received_all(1:end-1);
side_chosen_pre = side_chosen_all(1:end-1);
side_chosen_post = side_chosen_all(2:end);
v_left_post = v_left_all(2:end)';
v_chosen_post = v_chosen_all(2:end)';
pe = reward_pre - v_received_pre;

r_x_o_pre = reward_pre == side_received_pre;
c_x_o_pre = side_chosen_pre == side_received_pre;
r_x_c_pre = reward_pre == side_chosen_pre;

regressors = [side_chosen_pre, side_received_pre,  reward_pre, side_chosen_post,...
    r_x_o_pre, c_x_o_pre, r_x_c_pre, ...
    v_received_pre, v_left_post, v_chosen_post];
reg_names = {'Choice (t)', 'Outcome Port (t)', 'Reward (t)', 'Choice (t+1)',...
    'Rew x Outcome Port (t)', 'Choice Port X Outcome Port (t)', 'Rew x Choice Port (t)', ...
    'Outcome Port Value(t)','Choice Value (t+1)','Chosen Value (t+1)'};

end