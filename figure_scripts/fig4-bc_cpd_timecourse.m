sse = load(fullfile(files_path, 'postprocessed_data', 'ofc_SSEs.mat'));

% Check fraction excluded
excluded_frac = mean(sse.bad_glm)
nRegs = size(sse.sse_leftout{1,1},1);

%% Compute CPD for all cells in each bin
for lock_i = 1:4
    sse_full = sum([sse.sse_full_all{lock_i, ~sse.bad_glm}],2)';

    temp = cell2mat(reshape(sse.sse_leftout(lock_i, ~sse.bad_glm),1,1,[]));
    sse_leaveout = sum(temp, 3);

    cpd{lock_i} = 100 * (sse_leaveout - repmat(sse_full, [nRegs, 1])) ./ sse_leaveout;
end

%% Compute significant time bins/regressors
% Compute significance threshold
alpha = 0.01;
nBins = 20+20+70+70; % Number of total bins across all time locks
nRegs = 10;
alpha_bonferonni = alpha / (nBins * nRegs);

% aggregate the population permutations to compute permuteation -pvalue

nRegs = 10;

% Assemble the population perms from Spock
nPerms = 0;
num_perms_above_real = cell(1,4);
num_perms_above_real{1} = zeros(nRegs, 20);
num_perms_above_real{2} = zeros(nRegs, 70);
num_perms_above_real{3} = zeros(nRegs, 70);
num_perms_above_real{4} = zeros(nRegs, 20);

filenames = dir(fullfile(files_path, 'postprocessed_data', 'permuted_population_cpds'));
for file_i = 1:length(filenames)
    try
        loaded = load(fullfile(filenames(file_i).folder, filenames(file_i).name));

        for lock_i = 1:4
            num_perms_above_real{lock_i} = num_perms_above_real{lock_i} + loaded.num_perms_above_real{lock_i};
            corrected_cpd_sum{lock_i} = loaded.corrected_cpd{lock_i};
        end

        nPerms = nPerms + loaded.nPerms;
        
    catch
        disp(['Unable to process file ' filenames(file_i).name]);
    end
end

for lock_i = 1:4
    p_pop_timecourse{lock_i} = (num_perms_above_real{lock_i}) / nPerms;
    corrected_cpd{lock_i} = corrected_cpd_sum{lock_i} / nPerms;
end

%% Task variables plot


plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = corrected_cpd{lock_i}(1:end-3,:);
end
plots.colors = colors_task;
plots.err = 0; %prctile(loaded.cpd_pop_perms, 100*sig_thresh);

figs = make_timecourse_plots(plots)

dot_order = [1,2,6,3,5,7,4];

% Add significance indicators
for lock_i = 1:4

    sig_bins = p_pop_timecourse{lock_i}' < alpha_bonferonni;

    subplot(1,4,lock_i)
    for order_i = 1:7
        reg_i = dot_order(order_i);
        ylim([-0.1, 13])
        scatter(sse.bin_mids_by_lock{lock_i}(sig_bins(:,reg_i)), ...
            (13-0.25*order_i)*ones(1,sum(sig_bins(:,reg_i))), '.', 'markeredgecolor', plots.colors(reg_i, :))
    end
end

%% Value variables plot


plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = corrected_cpd{lock_i}(end-2:end,:);
end
plots.colors = colors_val;
plots.err =  0; %prctile(loaded.cpd_pop_perms, 100*sig_thresh);

figs = make_timecourse_plots(plots);

% Add significance indicators
for lock_i = 1:4

    sig_bins = p_pop_timecourse{lock_i}' < alpha_bonferonni;

    subplot(1,4,lock_i)
    ylim([-0.1, 1])
    set(gca,'ytick',[0.5, 1])
    for reg_i = 8:10
        scatter(sse.bin_mids_by_lock{lock_i}(sig_bins(:,reg_i)), ...
            (1-0.03*(reg_i-8))*ones(1,sum(sig_bins(:,reg_i))), '.', 'markeredgecolor', plots.colors(reg_i-7, :))
    end
end