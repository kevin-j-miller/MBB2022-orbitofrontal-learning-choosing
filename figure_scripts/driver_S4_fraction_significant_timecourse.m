p = load('permuted_p_values.mat');
sse = load('ofc_SSEs.mat');

%% Significance timecourse
nBins = 20+20+70+70; % Number of total bins across all time locks
nRegs = size(p.p_timecourse{1},2);
nCells = 477;

alpha = 0.01;
alpha_bonferonni = alpha / (nBins * nRegs);
pop_thresh = find(1 - binocdf(1:nCells, nCells, alpha) < alpha_bonferonni, 1) / nCells;


% Task variables plot
plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = squeeze(mean(p.p_timecourse{lock_i}(:,1:end-3,:) < alpha));
end
plots.colors = colors_task;
plots.err = pop_thresh;

plots_task = make_timecourse_plots(plots);

% Value variables plot
plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = squeeze(mean(p.p_timecourse{lock_i}(:,end-2:end,:) < alpha));
end
plots.colors = colors_val;
plots.err = pop_thresh;

plots_value = make_timecourse_plots(plots);

for lock_i = 1:4
    figure(plots_task(lock_i))
    print([pwd,'\figures_raw\fraction_significant_task_', num2str(lock_i), '.svg'],'-dsvg')
    figure(plots_value(lock_i))
    print([pwd,'\figures_raw\fraction_significant_value_', num2str(lock_i), '.svg'],'-dsvg')
end
close all
