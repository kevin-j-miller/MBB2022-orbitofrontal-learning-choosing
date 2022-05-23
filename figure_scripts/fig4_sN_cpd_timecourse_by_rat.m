%% Load ephys data, to check which indices go with each rat
data = load(fullfile(files_path, 'postprocessed_data', 'ofc_celldatas_ensemble'));
singles = find_singles(data.celldatas);

celldata_ratnames = cell(length(data.celldatas),1);
[celldata_ratnames{:}] = data.celldatas.ratname;

unique_ratnames = unique(celldata_ratnames);

%% Load SSEs

ephys_regression_results = load(fullfile(files_path, 'postprocessed_data', 'ephys_regression_results'));
% Check fraction excluded
nRegs = size(ephys_regression_results.sse_leftout{1,1},1);

%% Make the plots for each rat
for rat_i = 1:length(unique_ratnames)
    ratname = unique_ratnames{rat_i};
    rat_inds = strcmp(celldata_ratnames, ratname);


    % CPDS for just this rat
    for lock_i = 1:4
        sse_full = sum([ephys_regression_results.sse_full_all{lock_i, rat_inds}],2)';

        temp = cell2mat(reshape(ephys_regression_results.sse_leftout(lock_i, rat_inds),1,1,[]));
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
    print_svg(['fig4-sN_cpd-timecourse-by-rat-task-' num2str(rat_i)])


    % Value variables plot
    plots.xs = ephys_regression_results.bin_mids_by_lock;
    for lock_i = 1:4
        plots.ys{lock_i} = cpd{lock_i}(end-2:end,:);
    end
    plots.colors = colors_val;
    plots.err = 0;

    figs_single_val = make_timecourse_plots(plots);

    print_svg(['fig4-sN_cpd-timecourse-by-rat-value-' num2str(rat_i)])

    nSingles(rat_i) = sum(singles & rat_inds');
    nMultis(rat_i) = sum(~singles & rat_inds');
end

disp('Number of singles for each rat:')
disp(nSingles)
disp('Number of multis for each rat:')
disp(nMultis)
