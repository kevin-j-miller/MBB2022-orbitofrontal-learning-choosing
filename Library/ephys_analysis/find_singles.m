function singles = find_singles(celldatas)

    for cell_i = 1:length(celldatas)
        
        singles(cell_i) = ~isempty(strfind(celldatas(cell_i).cell_types,'SINGLE'));
        
    end


end