function [ratdata_evens,ratdata_odds] = split_even_odd(ratdata)

% Splits the data into two structs, one for only even and one for only odd
% sessions

ratdata_sessions = divide_into_sessions(ratdata);

n_sessions = length(ratdata_sessions);
odds = logical(rem(1:n_sessions,2));
evens = ~odds;

ratdata_evens = merge_ratdata_cell(ratdata_sessions(evens));
ratdata_odds = merge_ratdata_cell(ratdata_sessions(odds));

end