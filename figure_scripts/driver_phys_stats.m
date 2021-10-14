p = load('permuted_p_values.mat');

%% Total number of units
disp('Total number of units:')
disp(sum(~p.exclude_cell))

%% Significance at port entry
alpha = 0.01;
% Report number and fraction of cells significant for each value variable
% at each port entry event
disp('Number of units significant for each regressor at each port entry event:')
disp(squeeze(sum(p.p_entry(:,~p.exclude_cell, :) < alpha,2))')
disp('Fraction of units significant for each regressor at each port entry event:')
disp(squeeze(mean(p.p_entry(:,~p.exclude_cell, :) < alpha,2))')

%% Significance all-time
alpha = 0.01;
% Report number and fraction of cells significant for each value variable
% at each port entry event
disp('Number of units significant for each regressor over all time bins:')
disp(sum(p.p_alltime(~p.exclude_cell, :) < alpha)')
disp('Fraction of units significant for each regressor over all time bins:')
disp(mean(p.p_alltime(~p.exclude_cell, :) < alpha)')
