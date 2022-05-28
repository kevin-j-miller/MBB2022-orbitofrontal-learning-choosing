ps = load(fullfile(files_path, 'postprocessed_data', 'unit_p_values'))
sse = load(fullfile(files_path, 'postprocessed_data', 'ephys_regression_results.mat'));

nUnits = size(ps.p_entry,2)



%% Report Stats
alpha = 0.01;
frac_sig_port_by_reg = squeeze(mean(ps.p_entry < alpha, 2));
num_sig_port_by_reg = squeeze(sum(ps.p_entry < alpha, 2));

disp('Fraction of significant units, port by regressor:')
disp(frac_sig_port_by_reg)

disp('Number of significant units, port by regressor:')
disp(num_sig_port_by_reg)


%% Plot Fraction Significant Timecourse
nBins = 20+20+70+70; % Number of total bins across all time locks
nRegs = size(ps.p_timecourse{1},2);

alpha = 0.01;
alpha_bonferonni = alpha / (nBins * nRegs);
pop_thresh = find(1 - binocdf(1:nUnits, nUnits, alpha) < alpha_bonferonni, 1) / nUnits;


% Task variables plot
plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = squeeze(mean(ps.p_timecourse{lock_i}(:,1:end-3,:) < alpha));
end
plots.colors = colors_task;
plots.err = pop_thresh;

plots_task = make_timecourse_plots(plots);

print_svg('fig4-s1_fraction-significant-timecourse-task')

% Value variables plot
plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = squeeze(mean(ps.p_timecourse{lock_i}(:,end-2:end,:) < alpha));
end
plots.colors = colors_val;
plots.err = pop_thresh;

plots_value = make_timecourse_plots(plots);

print_svg('fig4-s1_fraction-significant-timecourse-value')
