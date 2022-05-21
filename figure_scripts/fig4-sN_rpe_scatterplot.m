%% Load necessary data
ephys_regression_results = load(fullfile(files_path, 'postprocessed_data', 'ephys_regression_results'));
nUnits = length(ephys_regression_results.weights(1,:))
ps = load(fullfile(files_path, 'postprocessed_data', 'unit_p_values'))


lock = 2; % Second time lock is locked to reward delivery


reward_time_weights_cell = ephys_regression_results.weights(lock, :);

lock_weights = [];
for unit_i = 1:length(reward_time_weights_cell)
    lock_weights(unit_i,:,:) = reward_time_weights_cell{unit_i};
end



%% Sanity check: Plot the median abs weight for each regressor.
% Check that the timecourses look like what you expect
abs_weight_timecourse = squeeze(median(abs(lock_weights)));

figure; hold on
for reg_i = 1:11
    plot(ephys_regression_results.bin_mids_by_lock{lock}, ...
        abs_weight_timecourse(:, reg_i) - reg_i)
end

% Index of the reward and outcome value regressors in the list of
% regressors (see construct_regressors_ephys)
ind_reward = 3;
ind_outcome_value = 8; %8;


%% Pick a time bin

% Which timebin should we look at? Bins are 200ms long.
timebin_to_consider = 0.4; % In seconds, from the time of reward.
ind_timebin = find(abs(ephys_regression_results.bin_mids_by_lock{lock} - timebin_to_consider) < 0.01)


%% Make the scatterplot

colors = colors_task;

figure; hold on
line([0,0], [-100, 100], 'color', 'k')
line([-100, 100], [0, 0], 'color', 'k')
line([-100, 100], [100, -100], 'linestyle', '--', 'color', [0.5, 0.5, 0.5])

% Add one to account for the offset regressor (see iti_regression_copd)
xs = lock_weights(:, ind_timebin, ind_reward + 1);
ys = lock_weights(:, ind_timebin, ind_outcome_value + 1);


% Identify significant reward and value units
alpha = 0.01;
ps_reward = ps.p_timecourse{lock}(:, ind_reward, ind_timebin);
ps_value = ps.p_timecourse{lock}(:, ind_outcome_value, ind_timebin);

reward_units = ps_reward < alpha;
value_units = ps_value < alpha;

reward_only = reward_units & ~value_units;
value_only = ~reward_units & value_units;
rpe = reward_units & value_units & (sign(xs) ~= sign(ys));
upQ = reward_units & value_units & (sign(xs) == sign(ys));
neither = ~reward_units & ~value_units;


dot_colors = zeros(nUnits,3);
dot_colors(neither, :) = repmat([0.7, 0.7, 0.7], [sum(neither),1]);
dot_colors(reward_only, :) = repmat(colors(3,:), [sum(reward_only),1]);
dot_colors(value_only, :) = repmat(rew_color, [sum(value_only),1]);
dot_colors(rpe | upQ, :) = repmat(task_green, [sum(rpe | upQ),1]);

% Plot the "neither"s underneath all others
scatter(xs(neither), ys(neither), 50, ...
    dot_colors(neither,:),...
    '.');

scatter(xs(~neither), ys(~neither), 50, ...
    dot_colors(~neither,:),...
    '.');

% Label the plot with text
text(-4.9, -3,   ['Reward Only:    ' num2str(sum(reward_only))], 'color', colors(3,:))
text(-4.9, -3.5, ['Value Only:     ' num2str(sum(value_only))], 'color', rew_color)
text(-4.9, -4,   ['Reward & Value: ' num2str(sum(rpe | upQ))], 'color', task_green)

xlabel({'Regression Weight:', 'Reward'})
ylabel({'Regression Weight:', 'Outcome Value'})

xlim([-5, 5])
ylim([-5, 5])

axis square
set(gca,'fontsize', 20)

%% Do some stats
% Among significant units
disp([num2str(sum(reward_units & value_units)) ' units correlate with both value and reward'])
disp(['of those, ' num2str(sum(rpe)) ' have opposite sign for the two. This is %' num2str(100*sum(rpe) / sum(reward_units & value_units))])
disp(['the p-value (binomial test) for this is ' ...
num2str(1 - binocdf(sum(rpe), sum(reward_units & value_units), 0.5))]);

% Among all units
rpe_sum = sum(sign(xs) ~= sign(ys))
rpe_mean = mean(sign(xs) ~= sign(ys))

disp(['Considering all units, ' ...
    num2str(rpe_sum) ...
    ' have opposite sign for value and reward.'])
    disp(['This is %' ...
    num2str(100*rpe_mean), ...
    ' of the total'])
disp(['the p-value (binomial test) for this is ' ...
num2str(1 - binocdf(rpe_sum, nUnits, 0.5))]);





