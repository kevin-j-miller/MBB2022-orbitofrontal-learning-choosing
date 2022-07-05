%% Load Data
data = load(fullfile(files_path, 'postprocessed_data', 'ofc_celldatas_ensemble'));
ps = load(fullfile(files_path, 'postprocessed_data', 'unit_p_values'));
sse = load(fullfile(files_path, 'postprocessed_data', 'ephys_regression_results.mat'));

nUnits = size(ps.p_entry,2);


celldata_ratnames = cell(length(data.celldatas),1);
[celldata_ratnames{:}] = data.celldatas.ratname;

unique_ratnames = unique(celldata_ratnames);

%% Loop over rats

alpha = 0.01;

for rat_i = 1:length(unique_ratnames)
    ratname = unique_ratnames{rat_i};
    rat_inds = strcmp(celldata_ratnames, ratname);

    % Fraction significant by port
    frac_sig_rat_by_port_by_reg(rat_i,:,:) = squeeze(mean(ps.p_entry(:,rat_inds,:) < alpha, 2));



    %% Plot Fraction Significant Timecourse
    nBins = 20+20+70+70; % Number of total bins across all time locks
    nRegs = size(ps.p_timecourse{1},2);

    alpha = 0.01;
    alpha_bonferonni = alpha / (nBins * nRegs);
    rat_n_units = sum(rat_inds);
    pop_thresh = find(1 - binocdf(1:rat_n_units, rat_n_units, alpha) < alpha_bonferonni, 1) / rat_n_units;


    % Task variables plot
    plots.xs = sse.bin_mids_by_lock;
    for lock_i = 1:4
        plots.ys{lock_i} = squeeze(mean(ps.p_timecourse{lock_i}(rat_inds,1:end-3,:) < alpha));
    end
    plots.colors = colors_task;
    plots.err = pop_thresh;

    plots_task = make_timecourse_plots(plots);
    subplot(1,4,1)
    set(gca,'ytick', [0, 0.2, 0.4, 0.6, 0.8], 'yticklabel', {'0%','20%','40%','60%','80%'})

    print_svg(['fig4-s5_frac_sig-timecourse-by-rat-task-' num2str(rat_i)])

    % Value variables plot
    plots.xs = sse.bin_mids_by_lock;
    for lock_i = 1:4
        plots.ys{lock_i} = squeeze(mean(ps.p_timecourse{lock_i}(rat_inds,end-2:end,:) < alpha));
    end
    plots.colors = colors_val;
    plots.err = pop_thresh;

    plots_value = make_timecourse_plots(plots);
    subplot(1,4,1)
    set(gca,'ytick', [0, 0.1, 0.2, 0.3, 0.4], 'yticklabel', {'0%','10%','20%','30%','40%'})

    print_svg(['fig4-s5_frac_sig-timecourse-by-rat-value-' num2str(rat_i)])

end