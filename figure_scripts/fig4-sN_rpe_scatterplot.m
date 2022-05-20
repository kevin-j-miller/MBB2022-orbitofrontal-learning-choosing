ephys_regression_results = load(fullfile(files_path, 'postprocessed_data', 'ephys_regression_results'));
nUnits = length(ephys_regression_results.weights(1,:))

% Which timebin should we look at? Bins are 200ms long.
timebin_to_consider = 0.6; % In seconds, from the time of reward.
ind_timebin = find(abs(ephys_regression_results.bin_mids_by_lock{2} - timebin_to_consider) < 0.01)


reward_time_weights_cell = ephys_regression_results.weights(2,:);

for unit_i = 1:length(reward_time_weights_cell)
lock_weights(unit_i,:,:) = reward_time_weights_cell{unit_i};
end



%% Sanity check: Plot the median abs weight for each regressor. 
% Check that the timecourses look like what you expect
abs_weight_timecourse = squeeze(median(abs(lock_weights)))

figure; hold on
for reg_i = 1:11
plot(ephys_regression_results.bin_mids_by_lock{2}, ...
    abs_weight_timecourse(:, reg_i) - reg_i)
end

% Index of the reward and outcome value regressors in the list of
% regressors (see construct_regressors_ephys) plus one because an offset
% tregressor gets added later (see iti_regression_copd)

% Check these against plot above
ind_reward = 4; 
ind_outcome_value = 9; 

bin_size = 0.2; % 200ms timebins

%% Make the scatterplot

figure; hold on
line([0,0], [-100, 100], 'color', 'k')
line([-100, 100], [0, 0], 'color', 'k')
line([-100, 100], [100, -100], 'linestyle', '--', 'color', [0.5, 0.5, 0.5])

% Weights / bin_size to put them in units of sp/s
xs = lock_weights(:, ind_timebin, ind_reward) / bin_size;
ys =     lock_weights(:, ind_timebin, ind_outcome_value) / bin_size;

scatter(xs, ys, ...
    '.');

xlabel({'Regression Weight:', 'Reward (sp/s)'})
ylabel({'Regression Weight:', 'Outcome Value (sp/s)'})

xlim([-20, 20])
ylim([-20, 20])

axis square
set(gca,'fontsize', 20)

%% Do some stats
reward_pos = mean(xs > 0)
value_pos = mean(ys > 0)

rpe_null = reward_pos * (1 - value_pos) + (1 - reward_pos) * value_pos
rpe_true_sum = sum(sign(xs) ~= sign(ys))
rpe_true_mean = mean(sign(xs) ~= sign(ys))

1 - binocdf(rpe_true_sum, nUnits, 0.5)

bottom_left =  sum(xs < 0 & ys < 0)
top_left =     sum(xs < 0 & ys > 0)
bottom_right = sum(xs > 0 & ys < 0)
top_right =    sum(xs > 0 & ys > 0)


