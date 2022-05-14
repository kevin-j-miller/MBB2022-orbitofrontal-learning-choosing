%% Unit-wise p-values
% Load necessary data
sse = load(fullfile(files_path, 'postprocessed_data', 'ofc_SSEs.mat'));

% Determine number of units, number of trials for each unit
data = load(fullfile(files_path, 'postprocessed_data', 'ofc_celldatas_ensemble'));
nTrials_all = [data.celldatas.nTrials];
nUnits = length(nTrials_all);
clear data;


%% Set up empty data structures
% % P-values for each cell for each regressor, considering all time bins
% p_alltime = NaN(nUnits, nRegs);
% P-values for each cell for each regressor, considering windows +- 0.500ms second around port entry
entry_window = 0.5;
nRegs = 10;
p_entry = NaN(4, nUnits, nRegs);
% P-values for each cell for each regressor for each bin
for lock_i = 1:4
    p_timecourse{lock_i} = NaN(nUnits, nRegs, length(sse.bin_mids_by_lock{lock_i}));
end

%% Loop over cells, populate the structures
fprintf('')
for unit_i = 1:nUnits
    fprintf(1,'\b\b\b\b %3i', unit_i);
        
        % Load permuted SSEs for this cell
        loaded = load(fullfile(files_path, 'postprocessed_data', 'circshift_SSEs', ['circshift_sse_unit_', num2str(unit_i), '.mat']));
        sse_perms_all = loaded.sse_full_all;
        sse_perms_leaveout = loaded.sse_leftout;
        clear loaded

        nTrials = nTrials_all(unit_i);
        sse_alltime_leaveout_perm = NaN(4,nTrials, nRegs);
        sse_alltime_full_perm = NaN(4, nTrials);
        
        for lock_i = 1:4
            cpd_timecourse_perm = NaN(nTrials, nRegs, length(sse.bin_mids_by_lock{lock_i}));
            cpd_entry_perm = NaN(nTrials, nRegs);
            entry_bins = abs(sse.bin_mids_by_lock{lock_i}) <= entry_window;
            
            % Loop over permutations, compute ensemble over permutede datasets
            % of CPD timecourses and CPD for each port entry in each permuted dataset
            for perm_i = 1:nTrials
                % CPD timecourses
                sse_full_perm = repmat(sse_perms_all{lock_i}(perm_i,:), [nRegs, 1]);
                sse_leaveout_perm = squeeze(sse_perms_leaveout{lock_i}(perm_i,:,:));
                cpd_timecourse_perm(perm_i,:,:) = 100*(sse_leaveout_perm - sse_full_perm) ./ sse_leaveout_perm;
                % CPD at port entry
                sse_leaveout_perm_port = sum(sse_leaveout_perm(:,entry_bins),2);
                sse_full_perm_port = sum(sse_full_perm(:,entry_bins),2);
                cpd_entry_perm(perm_i,:) = 100*(sse_leaveout_perm_port - sse_full_perm_port) ./ sse_leaveout_perm_port;
                
            end
            
            % Compute true CPD timecourse, compare it to shuffles, get
            % p-value timecourse
            cpd_timecourse_true = 100*(sse.sse_leftout{lock_i, unit_i} - repmat(sse.sse_full_all{lock_i, unit_i}', [nRegs, 1])) ...
                ./ sse.sse_leftout{lock_i, unit_i};
            differences = cpd_timecourse_perm - repmat(reshape(cpd_timecourse_true,[1,size(cpd_timecourse_true)]), [nTrials,1,1]);
            p_timecourse{lock_i}(unit_i,:,:) = squeeze(mean(differences > 0));
            
            % Compute true CPD at port entry, compare it to shuffles, get
            % port entry p-values
            sse_entry_leaveout = sum(sse.sse_leftout{lock_i, unit_i}(:,entry_bins),2);
            sse_entry_full = sum(sse.sse_full_all{lock_i, unit_i}(entry_bins));
            cpd_entry_true = 100*(sse_entry_leaveout - repmat(sse_entry_full, [nRegs,1])) ./ sse_entry_leaveout;
            differences = cpd_entry_perm - repmat(reshape(cpd_entry_true,[1,size(cpd_entry_true)]), [nTrials,1,1]);
            
            p_entry(lock_i, unit_i,:) = mean(differences > 0);
            

        end

        
end
fprintf('')

%% Sanity checks
assert(~any(isnan(p_timecourse{1}(:))))
assert(~any(isnan(p_entry(:))))

%% Report Stats
alpha = 0.01;
frac_sig_port_by_reg = squeeze(mean(p_entry < alpha, 2));
num_sig_port_by_reg = squeeze(sum(p_entry < alpha, 2));

disp('Fraction of significant units, port by regressor:')
disp(frac_sig_port_by_reg)

disp('Number of significant units, port by regressor:')
disp(num_sig_port_by_reg)


%% Plot Fraction Significant Timecourse
nBins = 20+20+70+70; % Number of total bins across all time locks
nRegs = size(p_timecourse{1},2);

alpha = 0.01;
alpha_bonferonni = alpha / (nBins * nRegs);
pop_thresh = find(1 - binocdf(1:nUnits, nUnits, alpha) < alpha_bonferonni, 1) / nUnits;


% Task variables plot
plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = squeeze(mean(p_timecourse{lock_i}(:,1:end-3,:) < alpha));
end
plots.colors = colors_task;
plots.err = pop_thresh;

plots_task = make_timecourse_plots(plots);

% Value variables plot
plots.xs = sse.bin_mids_by_lock;
for lock_i = 1:4
    plots.ys{lock_i} = squeeze(mean(p_timecourse{lock_i}(:,end-2:end,:) < alpha));
end
plots.colors = colors_val;
plots.err = pop_thresh;

plots_value = make_timecourse_plots(plots);
