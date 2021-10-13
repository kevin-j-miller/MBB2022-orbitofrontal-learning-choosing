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
    elseif strcmp(fname,'params') || ...
            strcmp(fname, 'modelName')
        % It's a field we want to just copy
        no_viol_data.(fname) = fvals;
    elseif isempty(fvals)
        % It's an empty field. It can stay empty.
        no_viol_data.(fname) = [];
    else
        warning(['Do not know how to trim viols from field ', fname]);
        
        
    end
    
end

assert(sum(no_viol_data.viols)==0);
assert(isRatdata(no_viol_data));

end