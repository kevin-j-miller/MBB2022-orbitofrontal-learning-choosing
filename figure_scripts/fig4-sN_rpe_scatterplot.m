%% Load necessary data
ephys_regression_results = load(fullfile(files_path, 'postprocessed_data', 'ephys_regression_results'));
nUnits = length(ephys_regression_results.weights(1,:))
ps = load(fullfile(files_path, 'postprocessed_data', 'unit_p_values'))


dataset = load(fullfile(files_path, 'postprocessed_data', 'ofc_celldatas_ensemble'));
celldatas = dataset.celldatas;
clear dataset


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
for timebin_to_consider = [0.2, 0.4, 0.6, 0.8]; % In seconds, from the time of reward.
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
    title(['Time from Reward: ' num2str(1000*timebin_to_consider) 'ms'])

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


    print_svg(['Fig4-sN_rpe-scatter-' num2str(1000*timebin_to_consider)])
end

%% Plot example units
example_ind_rpe = 320%382;
example_ind_upQ = 336;
example_ind_value = 49;

for example_ind = [example_ind_rpe, example_ind_upQ, example_ind_value]


celldata = celldatas(example_ind);
good_trials = ~celldata.bad_timing(:) & ~celldata.to_exclude(:);
Q = celldata.Qmb_outcome';
spiketimes = celldata.spiketimes;
window = [-1,2];
event_colors = [159, 41, 110; ...
    159, 54, 41; ...
    194, 93, 6;] / 255;

% Outcome Value: Rewarded Trials
event_times = cell(0);
event_times{1} = celldata.s2_times(good_trials  & ...
    celldata.rewards == 1 & ...
    Q < prctile(Q, 100*1/3));
event_times{2} = celldata.s2_times(good_trials &...
    celldata.rewards == 1 & ...
    Q > prctile(Q, 100*1/3) & ...
    Q < prctile(Q, 100*2/3));
event_times{3} = celldata.s2_times(good_trials &...
    celldata.rewards == 1 & ...
    Q > prctile(Q, 100*2/3));

[fig_psth_r, axmax_r] = plot_psth(spiketimes, window, event_times, event_colors);
title('Rewarded Trials')
xlabel('Time from Reward')

% Outcome Value: Omission Trials
event_times = cell(0);
event_times{1} = celldata.s2_times(good_trials  & ...
    celldata.rewards == 0 & ...
    Q < prctile(Q, 100*1/3));
event_times{2} = celldata.s2_times(good_trials &...
    celldata.rewards == 0 & ...
    Q > prctile(Q, 100*1/3) & ...
    Q < prctile(Q, 100*2/3));
event_times{3} = celldata.s2_times(good_trials &...
    celldata.rewards == 0 & ...
    Q > prctile(Q, 100*2/3));

[fig_psth_o, axmax_o] = plot_psth(spiketimes, window, event_times, event_colors);
title('Omission Trials')
xlabel('Time from Omission')

figure(fig_psth_r); ylim([0, max(axmax_r, axmax_o)]); print_svg(['Fig4-sN_rpe-unit-' num2str(example_ind) '-r'])
figure(fig_psth_o); ylim([0, max(axmax_r, axmax_o)]);  print_svg(['Fig4-sN_rpe-unit-' num2str(example_ind) '-o'])

end
