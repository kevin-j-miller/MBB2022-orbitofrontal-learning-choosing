reg_results = load(fullfile(files_path, 'postprocessed_data', 'ephys_regression_results_noOxR.mat'));

% Check fraction excluded
nRegs = size(reg_results.sse_leftout{1,1},1);
nCells = length(reg_results.bad_glm);

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
plots.colors(5,:) = []; % This is the color for RxO, which is left out for this figure
plots.err = 0;

figs = make_timecourse_plots(plots)

print_svg('fig4-s6_cpd-timecourse-task')


%% Value variables plot


plots.xs = reg_results.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(end-2:end,:);
end
plots.colors = colors_val;
plots.err =  0;

figs = make_timecourse_plots(plots);

print_svg('fig4-s6_cpd-timecourse-value')

%%

window_size = 1;

% Compute port-entry CPDs for each regressor
for cell_i = 1:nCells

        for lock_i = 1:4
           
            entry_bins = abs(reg_results.bin_mids_by_lock{lock_i}) <= window_size/2;
           
            sse_entry_leaveout = sum(reg_results.sse_leftout{lock_i, cell_i}(:,entry_bins),2);
            sse_entry_full = sum(reg_results.sse_full_all{lock_i, cell_i}(entry_bins));
            cpd_entry_true(lock_i, cell_i,:) = 100*(sse_entry_leaveout - repmat(sse_entry_full, [nRegs,1])) ./ sse_entry_leaveout; 
       
        end
end

% CPD can be NaN if the heldout SSE is zero. This happens if there are no spikes at all in a bin
bad_cpd = squeeze(any(any(isnan(cpd_entry_true),1),3)); 



%% Figure and stats for outcome value (at outcome) vs. choice value diff (at outcome)

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

print_svg('fig4-s6_cpd-scatter')


disp('Mean CPD ratio, outcome/choice:')
disp(mean(xs ./ ys))
disp('Median CPD ratio, outcome/choice:')
disp(median(xs ./ ys))
disp('p-value, signrank test:')
disp(signrank(xs - ys, 0,'method','exact'));