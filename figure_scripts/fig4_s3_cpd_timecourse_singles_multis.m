data = load(fullfile(files_path, 'postprocessed_data', 'ofc_celldatas_ensemble'));
singles = find_singles(data.celldatas);
clear data

ephys_regression_results = load(fullfile(files_path, 'postprocessed_data', 'ephys_regression_results'));
nRegs = size(sse.sse_leftout{1,1},1);

%% Plots for singles

% Re-organize
for lock_i = 1:4
    sse_full = sum([ephys_regression_results.sse_full_all{lock_i, singles}],2)';
    
    temp = cell2mat(reshape(ephys_regression_results.sse_leftout(lock_i, singles),1,1,[]));
    sse_leaveout = sum(temp, 3);
    
    cpd{lock_i} = 100 * (sse_leaveout - repmat(sse_full, [nRegs, 1])) ./ sse_leaveout;
end

% Task variables plot
plots.xs = ephys_regression_results.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(1:end-3,:);
end
plots.colors = colors_task;
plots.err = 0;

figs_single_task = make_timecourse_plots(plots);
print_svg('fig4-s3_cpd_timecourse_task_singles')


% Value variables plot
plots.xs = ephys_regression_results.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(end-2:end,:);
end
plots.colors = colors_val;
plots.err = 0;

figs_single_val = make_timecourse_plots(plots);

print_svg('fig4-s3_cpd_timecourse_value_singles')



%% Plots for multis

% Re-organize
for lock_i = 1:4
    sse_full = sum([ephys_regression_results.sse_full_all{lock_i, ~singles}],2)';
    
    temp = cell2mat(reshape(ephys_regression_results.sse_leftout(lock_i, ~singles),1,1,[]));
    sse_leaveout = sum(temp, 3);
    
    cpd{lock_i} = 100 * (sse_leaveout - repmat(sse_full, [nRegs, 1])) ./ sse_leaveout;
end

% Task variables plot
plots.xs = ephys_regression_results.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(1:end-3,:);
end
plots.colors = colors_task;
plots.err = 0;

make_timecourse_plots(plots);
print_svg('fig4-s3_cpd_timecourse_task_multis')

% Value variables plot
plots.xs = ephys_regression_results.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(end-2:end,:);
end
plots.colors = colors_val;
plots.err = 0;

make_timecourse_plots(plots);
print_svg('fig4-s3_cpd_timecourse_value_multis')
