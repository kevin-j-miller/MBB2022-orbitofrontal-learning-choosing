function results = get_sse_from_spock(cell_i, nTrials)

fldr = 'C:\Users\kevin\Documents\Princeton\code_for_twostep_physopto_paper\permuted_sse_from_spock\';

%% Check to see if an all-together file is available
filename = [fldr, 'permuted_sse_cell_', num2str(cell_i), '.mat'];
if exist(filename, 'file')
    results = load(filename);
else
%% Assemble from bits
missing = [];
for trial_i = 1:nTrials
    filename = [fldr, 'permuted_sse_cell_', num2str(cell_i), '_shuffle_', num2str(trial_i), '.mat'];
    if exist(filename, 'file')
    loaded = load(filename);
    for lock_i = 1:4
        results.sse_full_all{lock_i}(trial_i,:) = loaded.sse_full_all{lock_i};
        results.sse_leftout{lock_i}(trial_i,:,:) = loaded.sse_leftout{lock_i};
    end
    else
        missing = [missing, trial_i];
    end
    
end

if ~isempty(missing)
    error(['Missing trials for unit ' num2str(cell_i) ': ' num2str(missing)]);

end     

end