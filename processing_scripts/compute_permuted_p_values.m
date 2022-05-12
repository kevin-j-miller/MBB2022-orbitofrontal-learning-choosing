%% POPULATION P VALUES
 
nRegs = 10;

% Assemble the population perms from Spock
nPerms = 0;
num_perms_above_real = cell(1,4);
num_perms_above_real{1} = zeros(nRegs, 20);
num_perms_above_real{2} = zeros(nRegs, 70);
num_perms_above_real{3} = zeros(nRegs, 70);
num_perms_above_real{4} = zeros(nRegs, 20);

filenames = dir('population_perms');
for file_i = 1:length(filenames)
    try
        loaded = load(fullfile(filenames(file_i).folder, filenames(file_i).name));

        for lock_i = 1:4
            num_perms_above_real{lock_i} = num_perms_above_real{lock_i} + loaded.num_perms_above_real{lock_i};
        end
        
        nPerms = nPerms + loaded.nPerms;
        
    catch
        disp(['Unable to process file ' filenames(file_i).name]);
    end
end

for lock_i = 1:4
    p_pop_timecourse{lock_i} = num_perms_above_real{lock_i} / nPerms;
end


%% Unit-wise p-values
% Load necessary data
sse = load(fullfile(files_path, 'postprocessed_data', 'ofc_SSEs.mat'));

loaded = load('ofc_SSEs_perm');
sse_perms = loaded.sse_perms;
clear loaded

data = load('ofc_ephys_preprocessed');
nTrials_all = [data.celldatas.nTrials];
clear data;
nCells = length(sse.bad_glm);

% Set up empty data structures
% P-values for each cell for each regressor, considering all time bins
p_alltime = NaN(nCells, nRegs);
% P-values for each cell for each regressor, considering windows +- 0.75 second around port entry
p_entry = NaN(4, nCells, nRegs);
% P-values for each cell for each regressor for each bin
for lock_i = 1:4
    p_timecourse{lock_i} = NaN(nCells, nRegs, length(sse.bin_mids_by_lock{lock_i}));
end

% Loop over cells, populate the structures
for cell_i = 1:nCells
    cell_i
        
        sse_perm = sse_perms(cell_i);
        nTrials = nTrials_all(cell_i);
        sse_alltime_leaveout_perm = NaN(4,nTrials, nRegs);
        sse_alltime_full_perm = NaN(4, nTrials);
        
        for lock_i = 1:4
            cpd_timecourse_perm = NaN(nTrials, nRegs, length(sse.bin_mids_by_lock{lock_i}));
            cpd_entry_perm = NaN(nTrials, nRegs);
            entry_bins = abs(sse.bin_mids_by_lock{lock_i}) <= 0.5;
            
            % Loop over permutations, compute CPD timecourse and CPD for each
            % port entry in each permuted dataset
            for trial_i = 1:nTrials
                % CPD timecourses
                sse_full = repmat(sse_perm.sse_full_all{lock_i}(trial_i,:), [nRegs, 1]);
                sse_leaveout = squeeze(sse_perm.sse_leftout{lock_i}(trial_i,:,:));
                cpd_timecourse_perm(trial_i,:,:) = 100*(sse_leaveout - sse_full) ./ sse_leaveout;
                % CPD at port entry
                sse_entry_leaveout = sum(sse_leaveout(:,entry_bins),2);
                sse_entry_full = sum(sse_full(:,entry_bins),2);
                cpd_entry_perm(trial_i,:) = 100*(sse_entry_leaveout - sse_entry_full) ./ sse_entry_leaveout;
                
            end
            
            % Compute true CPD timecourse, compare it to shuffles, get
            % p-value timecourse
            cpd_timecourse_true = 100*(sse.sse_leftout{lock_i, cell_i} - repmat(sse.sse_full_all{lock_i, cell_i}', [nRegs, 1])) ...
                ./ sse.sse_leftout{lock_i, cell_i};
            differences = cpd_timecourse_perm - repmat(reshape(cpd_timecourse_true,[1,size(cpd_timecourse_true)]), [nTrials,1,1]);
            p_timecourse{lock_i}(cell_i,:,:) = squeeze(mean(differences > 0));
            
            % Compute true CPD at port entry, compare it to chuffles, get
            % port entry p-values
            sse_entry_leaveout = sum(sse.sse_leftout{lock_i, cell_i}(:,entry_bins),2);
            sse_entry_full = sum(sse.sse_full_all{lock_i, cell_i}(entry_bins));
            cpd_entry_true = 100*(sse_entry_leaveout - repmat(sse_entry_full, [nRegs,1])) ./ sse_entry_leaveout;
            differences = cpd_entry_perm - repmat(reshape(cpd_entry_true,[1,size(cpd_entry_true)]), [nTrials,1,1]);
            
            p_entry(lock_i, cell_i,:) = mean(differences > 0);
            
            
            % Compute all-time sse for this lock
            sse_alltime_full_perm(lock_i,:) = sum(sse_perm.sse_full_all{1},2);
            sse_alltime_leaveout_perm(lock_i,:,:) = sum(sse_perm.sse_leftout{1},3);
        end
        
        % Compute all-time CPD for each permuted dataset, considering SSE from each lock
        sse_alltime_leaveout_perm = squeeze(sum(sse_alltime_leaveout_perm));
        sse_alltime_full_perm = sum(sse_alltime_full_perm);
        cpd_alltime_perm = 100*(sse_alltime_leaveout_perm - repmat(sse_alltime_full_perm,[nRegs,1])') ./ sse_alltime_leaveout_perm;
        
        % Compute all-time CPD for true dataset
        sse_alltime_full_true = sum(cell2mat(sse.sse_full_all(:,cell_i)));
        sse_alltime_leaveout_true = sum(cell2mat(sse.sse_leftout(:,cell_i)'),2);
        cpd_alltime_true = 100*(sse_alltime_leaveout_true - sse_alltime_full_true) ./ sse_alltime_leaveout_true;
        
        % Compute p-values for all-time CPD
        p_alltime(cell_i,:) = mean(repmat(cpd_alltime_true',[nTrials,1]) < cpd_alltime_perm)';
        
end

save('permuted_p_values.mat', 'p_pop_timecourse', 'p_alltime', 'p_entry', 'p_timecourse', 'nPerms');






















