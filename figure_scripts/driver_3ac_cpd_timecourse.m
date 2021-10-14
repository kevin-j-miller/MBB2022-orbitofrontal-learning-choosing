sse = load('ofc_SSEs.mat');
p = load('permuted_p_values.mat');

% Check fraction excluded
excluded_frac = mean(sse.bad_glm)
nRegs = size(sse.sse_leftout{1,1},1);

% Compute CPD for all cells in each bin
for lock_i = 1:4
    sse_full = sum([sse.sse_full_all{lock_i, ~sse.bad_glm}],2)';
    
    temp = cell2mat(reshape(sse.sse_leftout(lock_i, ~sse.bad_glm),1,1,[]));
    sse_leaveout = sum(temp, 3);
    
    cpd{lock_i} = 100 * (sse_leaveout - repmat(sse_full, [nRegs, 1])) ./ sse_leaveout;
end

%% Compute significance threshold
alpha = 0.01;

nBins = 20+20+70+70; % Number of total bins across all time locks
nRegs = size(p.p_timecourse{1},2);
alpha_bonferonni = alpha / (nBins * nRegs);


%% Task variables plot


plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(1:end-3,:);
end
plots.colors = colors_task;
plots.err = 0;

figs = make_timecourse_plots(plots)

dot_order = [1,2,6,3,5,7,4];

% Add significance indicators
for lock_i = 1:4
    
sig_bins = p.p_pop_timecourse{lock_i}' < alpha_bonferonni;

figure(figs(lock_i))
for order_i = 1:7
    reg_i = dot_order(order_i);
    ylim([0, 14])
scatter(sse.bin_mids_by_lock{lock_i}(sig_bins(:,reg_i)), (14-0.25*order_i)*ones(1,sum(sig_bins(:,reg_i))), '.', 'markeredgecolor', colors_task(reg_i, :))
end
    print([pwd,'\figures_raw\cpd_task_', num2str(lock_i), '.svg'],'-dsvg')
end

%% Value variables plot


plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = cpd{lock_i}(end-2:end,:);
end
plots.colors = colors_val;
plots.err = 0;

figs = make_timecourse_plots(plots);

% Add significance indicators
for lock_i = 1:4
    
sig_bins = p.p_pop_timecourse{lock_i}' < alpha_bonferonni;

figure(figs(lock_i))
ylim([0.14, 1.23])
set(gca,'ytick',[0.5, 1])
for reg_i = 8:10
scatter(sse.bin_mids_by_lock{lock_i}(sig_bins(:,reg_i)), (1.2-0.03*(reg_i-8))*ones(1,sum(sig_bins(:,reg_i))), '.', 'markeredgecolor', colors_val(reg_i-7, :))
end
print([pwd,'\figures_raw\cpd_value_', num2str(lock_i), '.svg'],'-dsvg')
end