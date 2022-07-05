reg_results = load(fullfile(files_path, 'postprocessed_data', 'ephys_regression_results_Qeff.mat'));

% Check fraction excluded
nRegs = size(reg_results.sse_leftout{1,1},1);
nUnits = length(reg_results.bad_glm);

%% Compute CPD for all cells in each bin
for lock_i = 1:4
    sse_full = sum([reg_results.sse_full_all{lock_i, ~reg_results.bad_glm}],2)';

    temp = cell2mat(reshape(reg_results.sse_leftout(lock_i, ~reg_results.bad_glm),1,1,[]));
    sse_leaveout = sum(temp, 3);

    cpd{lock_i} = 100 * (sse_leaveout - repmat(sse_full, [nRegs, 1])) ./ sse_leaveout;
end


window_size = 1;

%% Compute port-entry CPDs for each regressor
for cell_i = 1:nUnits

        for lock_i = 1:4
           
            entry_bins = abs(reg_results.bin_mids_by_lock{lock_i}) <= window_size/2;
           
            sse_entry_leaveout = sum(reg_results.sse_leftout{lock_i, cell_i}(:,entry_bins),2);
            sse_entry_full = sum(reg_results.sse_full_all{lock_i, cell_i}(entry_bins));
            cpd_entry_true(lock_i, cell_i,:) = 100*(sse_entry_leaveout - repmat(sse_entry_full, [nRegs,1])) ./ sse_entry_leaveout; 
       
        end
end

% CPD can be NaN if the heldout SSE is zero. This happens if there are no spikes at all in a bin
bad_cpd = squeeze(any(any(isnan(cpd_entry_true),1),3)); 

%% Task variables timecourse

plots.xs = reg_results.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(1:end-3,:);
end
plots.colors = colors_task;
plots.err = 0;

figs = make_timecourse_plots(plots)

dot_order = [1,2,6,3,5,7,4];

print_svg('fig4-s7_cpd-timecourse-value-Qeff')

%% Value variables timecourse


plots.xs = reg_results.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(end-2:end,:);
end
plots.colors = colors_val;
plots.err =  0;

figs = make_timecourse_plots(plots);

print_svg('fig4-s7_cpd-timecourse-task-Qeff')

%% Scatterplot: Choice Value

ov_at_outcome = cpd_entry_true(2, ~bad_cpd, end-2);
cvd_at_outcome = cpd_entry_true(2, ~bad_cpd, end-1);

xs = ov_at_outcome;
ys = cvd_at_outcome;

axmin = min([0.01; xs(:); ys(:); 10]);
axmax = max([0.01; xs(:); ys(:); 10]);

figure;
line([axmin,axmax],[axmin,axmax],'color','black'); hold on
scatter(xs, ys, 200, '.','markeredgecolor', [0.5, 0.5, 0.5])
set(gca,'fontsize',16,'xscale','log','yscale','log')
set(gca,'xtick',[1e-2,1e-1,1e0,1e1],'xticklabel',{'0.01%','0.1%','1%','10%'});
set(gca,'ytick',[1e-2,1e-1,1e0,1e1],'yticklabel',{'0.01%','0.1%','1%','10%'});
pbaspect([1 1 1])
ylabel({'CPD: Choice Value Difference'},'fontsize',16);
xlabel({'CPD: Outcome Value'},'fontsize',16);
xlim([axmin,axmax]); ylim([axmin,axmax]);
title('Outcome Value vs. Choice Value');

print_svg('fig4-s7_cpd-scatter-choice-Qeff')


%% Scatterplot: Choice Value

ov_at_outcome = cpd_entry_true(2, ~bad_cpd, end-2);
cvd_at_outcome = cpd_entry_true(2, ~bad_cpd, end);

xs = ov_at_outcome;
ys = cvd_at_outcome;

axmin = min([0.01; xs(:); ys(:); 10]);
axmax = max([0.01; xs(:); ys(:); 10]);

figure;
line([axmin,axmax],[axmin,axmax],'color','black'); hold on
scatter(xs, ys, 200, '.','markeredgecolor', [0.5, 0.5, 0.5])
set(gca,'fontsize',16,'xscale','log','yscale','log')
set(gca,'xtick',[1e-2,1e-1,1e0,1e1],'xticklabel',{'0.01%','0.1%','1%','10%'});
set(gca,'ytick',[1e-2,1e-1,1e0,1e1],'yticklabel',{'0.01%','0.1%','1%','10%'});
pbaspect([1 1 1])
ylabel({'CPD: Chosen Value'},'fontsize',16);
xlabel({'CPD: Outcome Value'},'fontsize',16);
xlim([axmin,axmax]); ylim([axmin,axmax]);
title('Outcome Value vs. Chosen Value');

print_svg('fig4-s7_cpd-scatter-chosen-Qeff')

%% Sanity check indices
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