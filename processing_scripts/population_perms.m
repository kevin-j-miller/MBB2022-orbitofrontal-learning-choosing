function population_perms(job_id)

%% Package populatin permutations

tic
disp('loading')
sse = load('ofc_SSEs.mat');
loaded = load('ofc_SSEs_perm');
sse_perms = loaded.sse_perms;
clear loaded
disp('loading complete!')
toc

% Assemble populations by taking a random permutation from each cell
nCells = 477;
nRegs = 10;
nPerms = 1e2;

for lock_i = 1:4
    
    nBins = length(sse.bin_mids_by_lock{lock_i});
    cpd_pop_perm = NaN(nPerms, nRegs, nBins);
    sse_pop_perm_full_cell = NaN(nCells, nBins);
    sse_pop_perm_leaveout_cell = NaN(nCells, nRegs, nBins);
    for perm_i = 1:nPerms
       disp(['Lock ', num2str(lock_i), ' perm ', num2str(perm_i), '/', num2str(nPerms)]);
        for cell_i = 1:nCells
            
            nTrials = size(sse_perms(cell_i).sse_full_all{1}, 1);
            
            perm_to_take = randi(nTrials);
            sse_pop_perm_full_cell(cell_i,:) = sse_perms(cell_i).sse_full_all{lock_i}(perm_to_take,:);
            sse_pop_perm_leaveout_cell(cell_i,:,:) = sse_perms(cell_i).sse_leftout{lock_i}(perm_to_take,:,:);
            
        end
        
        sse_pop_perm_full = (sum(sse_pop_perm_full_cell,1));
        sse_pop_perm_leaveout = squeeze(sum(sse_pop_perm_leaveout_cell,1));
        
        cpd_pop_perm(perm_i,:,:) = 100*(sse_pop_perm_leaveout - repmat(sse_pop_perm_full, [nRegs, 1])) ./ sse_pop_perm_leaveout;
       
        
        
    end
    
    sse_full = sum([sse.sse_full_all{lock_i, :}],2)';
    temp = cell2mat(reshape(sse.sse_leftout(lock_i, :),1,1,[]));
    sse_leaveout = sum(temp, 3);
    cpd_true = 100 * (sse_leaveout - repmat(sse_full, [nRegs, 1])) ./ sse_leaveout;
    
    differences = repmat(reshape(cpd_true, [1,size(cpd_true)]), [nPerms,1,1]) - cpd_pop_perm;
    
    num_perms_above_real{lock_i} = squeeze(sum(differences < 0));
    
end
toc

save(['population_perms/population_perms_' num2str(job_id)], 'num_perms_above_real', 'nPerms')

end