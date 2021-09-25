function no_viol_data = remove_viols(ratdata)

% Takes in a ratdata object for the twostep task, returns a ratdata with
% all violation trials stripped out as if they'd never happened

if isempty(ratdata)
    no_viol_data = ratdata;
    return
end

no_viols = ~ratdata.viols & ratdata.sides2~='v';

fnames = fieldnames(ratdata);
copy_fields = {'ratname','task','p_congruent','nSess','cell_types','channels','spiketimes', 'swr_times', 'sessiondate'};
for fname_i = 1:length(fnames)
    
    fname = fnames{fname_i};
    fvals = ratdata.(fname);
    
    if any(cellfun(@(x) strcmp(x,fname),copy_fields))
        % It's a label-type field, just copy it
             no_viol_data.(fname) = fvals;
    elseif length(fvals) == ratdata.nTrials
        % It's a trial-wise field.  Trim the viol trials
        no_viol_data.(fname) = fvals(no_viols);
    elseif strcmp(fname,'nTrials')
        no_viol_data.(fname) = sum(no_viols);
    elseif strcmp(fname,'spiketimes')
    elseif isempty(fvals)
        no_viol_data.(fname) = [];
    else
        warning(['Do not know how to trim viols from field ', fname]);
        
        
    end
    
end

% 
% no_viol_data.sides1 = ratdata.sides1(no_viols);
% no_viol_data.sides2 = ratdata.sides2(no_viols);
% no_viol_data.rewards = ratdata.rewards(no_viols);
% no_viol_data.leftprobs = ratdata.leftprobs(no_viols);
% no_viol_data.rightprobs = ratdata.rightprobs(no_viols);
% no_viol_data.ratname = ratdata.ratname;
% no_viol_data.viols = ratdata.viols(no_viols);
% no_viol_data.p_congruent = ratdata.p_congruent;
% no_viol_data.task = ratdata.task;
% no_viol_data.nTrials = ratdata.nTrials - sum(~no_viols);




assert(sum(no_viol_data.viols)==0);
assert(isRatdata(no_viol_data));


end