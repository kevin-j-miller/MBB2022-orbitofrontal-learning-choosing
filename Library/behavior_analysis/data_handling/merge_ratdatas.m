function ratdata_merged = merge_ratdatas(ratdata1, ratdata2,phys,metaRat)
% Takes two seperate ratdata structures and concatenates the data

% If either is empty, return the other
if isempty(ratdata1) && isempty(ratdata2)
    ratdata_merged = {};
    return
elseif isempty(ratdata1)
    ratdata_merged = ratdata2;
    return
elseif isempty(ratdata2)
    ratdata_merged = ratdata1;
    return
end

% If the ratdatas aren't the same form, we can't merge them
if ~isequal(fieldnames(ratdata1), fieldnames(ratdata2))
    warning('The ratdata structures do not have the same fields - merging might cause trouble')
end

if isfield(ratdata1,'rewards')
% If either of the ratdatas is empty, we just return the other one
if isempty(ratdata1.rewards)
    ratdata_merged = ratdata2;
    return
elseif isempty(ratdata2.rewards)
    ratdata_merged = ratdata1;
    return
end
end

fnames = fieldnames(ratdata1);


% If the phys flag is not set, we don't want to do a phys merge
if ~exist('phys','var')
    phys = false;
else
    phys_offset = 1e5; % Time difference we'll impose between first and second ratdata, to keep times from interfering
end

% if the metarat flag isn't set, we don't want to relax the single-rat
% assumption
if ~exist('metaRat','var')
    metaRat = false;
end

for fname_i = 1:length(fnames)
    
    fname = fnames{fname_i};
    vals1 = ratdata1.(fname);
    vals2 = ratdata2.(fname);
    
    if strcmp(fname,'task')
        
        if ~isequal(vals1,vals2)
            error('cannot merge ratdatas from different tasks')
        end
        ratdata_merged.task = vals1;
        
    elseif strcmp(fname,'ratname')
        if any(vals1~=vals2) && ~metaRat
            error('merging ratdata from different rats')
        end
        ratdata_merged.ratname = vals1;
        
    elseif strcmp(fname, 'nTrials')
        ratdata_merged.(fname) = vals1 + vals2;
    
    elseif strcmp(fname, 'nSess')
        ratdata_merged.(fname) = (vals1 + vals2);
        
    elseif strcmp(fname, 'sessiondate')
        ratdata_merged.(fname) = [vals1;vals2];
        
    elseif strcmp(fname, 'p_congruent') && (abs(vals1-vals2) < 0.2 || metaRat)
        ratdata_merged.(fname) = (vals1 + vals2)/2;
    
    elseif ~phys && (contains(fname,'times') || ...
                              strcmp(fname, 'swr_scores') || ...
                              strcmp(fname, 'cell_types') || ...
                              strcmp(fname, 'channels'))
                          
        ratdata_merged.(fname) = [];
        
    elseif phys && ~isempty(strfind(fname,'times')) % we want to do a phys merge, and these are times of something
        % We need to set the second session times way ahead of the first
        % session ones, so there's no interference
        if ~exist('offset','var')
            offset = max(vals1) + phys_offset;
        end
         vals_final = [vals1(:);offset+vals2(:)];
        ratdata_merged.(fname) = vals_final;
    
    elseif strcmp(fname,'Qmf') || strcmp(fname,'Q2mbs') || strcmp(fname,'Qeff')
        vals_final = [vals1; vals2];
        ratdata_merged.(fname) = vals_final;
        
    elseif length(vals1) == ratdata1.nTrials % This is a field we should merge
        
        vals_final = [vals1(:);vals2(:)];
        ratdata_merged.(fname) = vals_final;
    elseif  isequalwithequalnans(vals1,vals2) % This is a field we should not merge
        
        ratdata_merged.(fname) = vals1;
        
    else
        
        error(['Problem Merging Field ', fname])
    end
end