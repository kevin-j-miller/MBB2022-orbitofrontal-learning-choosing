data = load('ofc_ephys_preprocessed.mat');
singles = find_singles(data.celldatas);
clear data

sse = load('ofc_SSEs');
% Check fraction excluded
nRegs = size(sse.sse_leftout{1,1},1);

%% Plots for singles

% Re-organize
for lock_i = 1:4
    sse_full = sum([sse.sse_full_all{lock_i, singles}],2)';
    
    temp = cell2mat(reshape(sse.sse_leftout(lock_i, singles),1,1,[]));
    sse_leaveout = sum(temp, 3);
    
    cpd{lock_i} = 100 * (sse_leaveout - repmat(sse_full, [nRegs, 1])) ./ sse_leaveout;
end

% Task variables plot
plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(1:end-3,:);
end
plots.colors = colors_task;
plots.err = 0;

figs_single_task = make_timecourse_plots(plots);

% Value variables plot
plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(end-2:end,:);
end
plots.colors = colors_val;
plots.err = 0;

figs_single_val = make_timecourse_plots(plots);



%% Plots for multis

% Re-organize
for lock_i = 1:4
    sse_full = sum([sse.sse_full_all{lock_i, ~singles}],2)';
    
    temp = cell2mat(reshape(sse.sse_leftout(lock_i, ~singles),1,1,[]));
    sse_leaveout = sum(temp, 3);
    
    cpd{lock_i} = 100 * (sse_leaveout - repmat(sse_full, [nRegs, 1])) ./ sse_leaveout;
end

% Task variables plot
plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(1:end-3,:);
end
plots.colors = colors_task;
plots.err = 0;

figs_multi_task = make_timecourse_plots(plots);

% Value variables plot
plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(end-2:end,:);
end
plots.colors = colors_val;
plots.err = 0;

figs_multi_val = make_timecourse_plots(plots);


%% Save

for lock_i = 1:4
    figure(figs_single_task(lock_i))
    print([pwd,'\figures_raw\s1_cpd_single_task_', num2str(lock_i), '.svg'],'-dsvg')
    
    figure(figs_single_val(lock_i))
    print([pwd,'\figures_raw\s1_cpd_single_value_', num2str(lock_i), '.svg'],'-dsvg')
    
    figure(figs_multi_task(lock_i))
    print([pwd,'\figures_raw\s1_cpd_multi_task_', num2str(lock_i), '.svg'],'-dsvg')
    
    figure(figs_multi_val(lock_i))
    print([pwd,'\figures_raw\s1_cpd_multi_value_', num2str(lock_i), '.svg'],'-dsvg')
end
close all