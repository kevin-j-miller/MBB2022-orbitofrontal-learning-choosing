reg_results = load(fullfile(files_path, 'postprocessed_data', 'ephys_regression_results_Qeff.mat'));

% Check fraction excluded
nRegs = size(reg_results.sse_leftout{1,1},1);

%% Compute CPD for all cells in each bin
for lock_i = 1:4
    sse_full = sum([reg_results.sse_full_all{lock_i, ~reg_results.bad_glm}],2)';

    temp = cell2mat(reshape(reg_results.sse_leftout(lock_i, ~reg_results.bad_glm),1,1,[]));
    sse_leaveout = sum(temp, 3);

    cpd{lock_i} = 100 * (sse_leaveout - repmat(sse_full, [nRegs, 1])) ./ sse_leaveout;
end

%% Task variables plot

plots.xs = reg_results.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(1:end-3,:);
end
plots.colors = colors_task;
plots.err = 0;

figs = make_timecourse_plots(plots)

dot_order = [1,2,6,3,5,7,4];

print_svg('fig4-sN_cpd-timecourse-value-Qeff')

%% Value variables plot


plots.xs = reg_results.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(end-2:end,:);
end
plots.colors = colors_val;
plots.err =  0;

figs = make_timecourse_plots(plots);

print_svg('fig4-sN_cpd-timecourse-task-Qeff')

%% Weights scatterplot
ephys_regression_results = load(fullfile(files_path, 'postprocessed_data', 'ephys_regression_results'));

lock = 2;
reward_time_weights_cell = ephys_regression_results.weights(lock, :);

lock_weights = [];
for unit_i = 1:length(reward_time_weights_cell)
    lock_weights(unit_i,:,:) = reward_time_weights_cell{unit_i};
end

% Sanity check: Plot the median abs weight for each regressor.
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