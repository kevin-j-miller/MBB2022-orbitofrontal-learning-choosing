
sse = load('ofc_SSEs.mat');

data = load('ofc_ephys_preprocessed');
nTrials_all = [data.celldatas.nTrials];
clear data;

nCells = length(sse.bad_glm);
nRegs = 10;

tic
% Loop over cells, load permuted sse
bad_sse = false(1,nCells);
for cell_i = 1:nCells
    cell_i
    if ~sse.bad_glm(cell_i)
        % Load permuted SSEs, created on the cluster and saved to this
        % folder
        
        sse_perms(cell_i) = get_sse_from_spock(cell_i, nTrials_all(cell_i));
        
        
        % Sanity check the SSEs
        full_sses = sse_perms(cell_i).sse_full_all{:};
        all_sses = [full_sses(:); ...
            sse_perms(cell_i).sse_leftout{1}(:); ...
            sse_perms(cell_i).sse_leftout{2}(:); ...
            sse_perms(cell_i).sse_leftout{3}(:); ...
            sse_perms(cell_i).sse_leftout{4}(:)];
        if any(all_sses > 10e10)
            disp([num2str(cell_i), ' has a bad SSE'])
            bad_sse(cell_i) = true;
        end
    end
    
end
toc

save('ofc_SSEs_perm.mat', 'sse_perms', '-v7.3');

toc