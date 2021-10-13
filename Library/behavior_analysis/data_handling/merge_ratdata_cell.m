function merged_ratdatas = merge_ratdata_cell(ratdata_cell,phys,metaRat)

if ~exist('phys','var')
    phys = 0;
end
if ~exist('metaRat','var')
    metaRat = 0;
end

% Takes a cell of ratdatas, merges them into one big ratdata
if isempty(ratdata_cell)
    merged_ratdatas = {};
    return
elseif length(ratdata_cell) == 1
    if iscell(ratdata_cell)
    merged_ratdatas = ratdata_cell{1};
    elseif isstruct(ratdata_cell)
        merged_ratdatas = ratdata_cell(1);
    else
        error('Unable to parse ratdata');
    
    end
    return
else
    merged_tail = merge_ratdata_cell(ratdata_cell(2:end),phys, metaRat);
    if iscell(ratdata_cell)
    merged_ratdatas = merge_ratdatas(ratdata_cell{1},merged_tail,phys, metaRat);
    elseif isstruct(ratdata_cell)
        merged_ratdatas = merge_ratdatas(ratdata_cell(1),merged_tail,phys, metaRat);
    else
        error('Unable to parse ratdata');
    
    end
    
end
    

end