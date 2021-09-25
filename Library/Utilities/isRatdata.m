function tf = isRatdata(possible_ratdata)

% Takes a structure and tells you if it's a valid ratdata or not
tf = true; % start the indicator at true - turn it false if the possible_ratdata fails any of the tests


tf = tf && isfield(possible_ratdata,'sides1') && isfield(possible_ratdata,'sides2') ...
    && isfield(possible_ratdata,'viols') && isfield(possible_ratdata,'rewards') && ...
    isfield(possible_ratdata,'ratname') && isfield(possible_ratdata,'rightprobs') && ...
    isfield(possible_ratdata,'leftprobs') && isfield(possible_ratdata,'p_congruent') && ...
    isfield(possible_ratdata,'task');




end