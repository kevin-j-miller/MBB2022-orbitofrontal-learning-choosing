function population_perms(job_id)

nUnits = 477;
nRegs = 10;
nPerms = 1e5;

%% Package population permutations

tic
disp('loading')
sse = load(fullfile(files_path, 'postprocessed_data', 'ofc_SSEs.mat'));
for unit_i = 1:nUnits
     sse_perms(unit_i) = load(fullfile(files_path, 'postprocessed_data', 'circshift_SSEs', ['circshift_sse_unit_', num2str(unit_i), '.mat']));
end
disp('loading complete!')
toc

% Assemble populations by taking a random permutation from each cell

for lock_i = 1:4
    disp(['Lock ' , num2str(lock_i)])

    nBins = length(sse.bin_mids_by_lock{lock_i});
    cpd_pop_perm = NaN(nPerms, nRegs, nBins);
    cpd_pop_perms = [];
    sse_pop_perm_full_cell = NaN(nUnits, nBins);
    sse_pop_perm_leaveout_cell = NaN(nUnits, nRegs, nBins);
    
    fprintf(1,' Perm %3i', 0);

    for perm_i = 1:nPerms
       fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b Perm %5i', perm_i);
       %disp(['Lock ', num2str(lock_i), ' perm ', num2str(perm_i), '/', num2str(nPerms)]);
        for unit_i = 1:nUnits
            
            nTrials = size(sse_perms(unit_i).sse_full_all{1}, 1);
            
            perm_to_take = randi(nTrials);
            sse_pop_perm_full_cell(unit_i,:) = sse_perms(unit_i).sse_full_all{lock_i}(perm_to_take,:);
            sse_pop_perm_leaveout_cell(unit_i,:,:) = sse_perms(unit_i).sse_leftout{lock_i}(perm_to_take,:,:);
            
        end
        
        sse_pop_perm_full = (sum(sse_pop_perm_full_cell,1));
        sse_pop_perm_leaveout = squeeze(sum(sse_pop_perm_leaveout_cell,1));
        
        cpd_pop_perm(perm_i,:,:) = 100*(sse_pop_perm_leaveout - repmat(sse_pop_perm_full, [nRegs, 1])) ./ sse_pop_perm_leaveout;
       
        
        
    end
fprintf(1,'\n');
    
    sse_full = sum([sse.sse_full_all{lock_i, :}],2)';
    temp = cell2mat(reshape(sse.sse_leftout(lock_i, :),1,1,[]));
    sse_leaveout = sum(temp, 3);
    cpd_true = 100 * (sse_leaveout - repmat(sse_full, [nRegs, 1])) ./ sse_leaveout;
    
    differences = repmat(reshape(cpd_true, [1,size(cpd_true)]), [nPerms,1,1]) - cpd_pop_perm;
    
    num_perms_above_real{lock_i} = squeeze(sum(differences < 0));
    cpd_pop_perms = [cpd_pop_perms, cpd_pop_perm(:)];
end
toc

for lock_i = 1:4
    p_pop_timecourse{lock_i} = num_perms_above_real{lock_i} / nPerms;
end

save(fullfile(files_path, 'postprocessed_data', 'permuted_population_cpds', ...
     ['permuted_population_cpds_' num2str(job_id)]), ...
     'num_perms_above_real', 'nPerms', 'cpd_pop_perms')

end