%% Load the datasets
% Behavioral data, preprocessed to include all port entry times
% Created by Sarah Jo Venditto on 2022-06-23
loaded = load(fullfile(files_path, 'preprocessed_data', 'ephys_behavioral_data_with_poketimes.mat'));
sessdatas = loaded.rawdata;

% Params from the timer section of the TwoStep6Halo protocol
drink_timer = 5;
softdrink_time = 1;
unreward_time = 1;

% Ephys dataset, including spike times
loaded = load(fullfile(files_path, 'preprocessed_data', 'ofc_learning_choosing_dataset_ephys.mat'));
ephys_data = loaded.ratdatas;
clear loaded

% Set up empty ensemble matrix. There are just two bins (outcome period and
% choice period)
spike_ensemble = NaN(477, max([ephys_data.nTrials]), 2); %[nUnits, nTrials, nBins]
unit_i = 1;
n_datasets = length(sessdatas);


fprintf(1,'Units done: %3i\n', 0);

for data_i = 1:n_datasets
    
    sessdata = sessdatas{data_i};

    if sum(sessdata.new_sess) > 1
        sessdata_divided = divide_into_sessions(sessdata);
        for sess_sub_i = 1:length(sessdata_divided)
            if sessdata_divided{sess_sub_i}.nTrials == ephys_data(data_i).nTrials
                sessdata = sessdata_divided{sess_sub_i};
            end
        end
    end
    assert(sessdata.nTrials == ephys_data(data_i).nTrials, 'Behavioral and ephys datasets do not have the same trial count. Something is wrong!')

    %% First figure out the time periods, as defined in the opto experiment
    % If these ephys rats had instead been opto rats, when would the laser
    % shutter have opened and closed?
    outcome_period_begin = NaN(1, sessdata.nTrials);
    outcome_period_end = NaN(1, sessdata.nTrials);
    choice_period_end = NaN(1, sessdata.nTrials);

    for trial_i = 1:sessdata.nTrials
        
        % Skip violation trials
        if sessdata.viols(trial_i) || sessdata.sides2(trial_i) == 'v'
            continue
        end

        poke_times = sessdata.poke_times{trial_i};

        poke_ids = sessdata.poke_ids{trial_i};

        % Find the first top-center poke
        top_center_poke = strfind(poke_ids', 'c');
        top_center_poke = top_center_poke(1);

        % Find the first choice poke following the top-center poke
        % (this is when choice-period opto turns off)
        choice_pokes = [strfind(poke_ids', 'l'), strfind(poke_ids', 'r')];
        choice_pokes(choice_pokes < top_center_poke) = [];
        first_choice_poke = min(choice_pokes);

        choice_period_end(trial_i) = poke_times(first_choice_poke,1);

        % Find the first bottom-center poke after the choice poke
        bottom_center = strfind(poke_ids', 'C');
        bottom_center(bottom_center < first_choice_poke) = [];
        bottom_center = min(bottom_center);

        % Find the first reward poke following the bottom-center poke
        % (this is when outcome-period opto turns on)
        outcome = upper(sessdata.sides2(trial_i));
        outcome_pokes = strfind(poke_ids', outcome);
        early_outcome_pokes = poke_times(outcome_pokes,1) < sessdata.c2_times(trial_i);
        outcome_pokes(early_outcome_pokes) = [];
        first_outcome_poke = min(outcome_pokes);

        outcome_period_begin(trial_i) = poke_times(first_outcome_poke,1);

        % Find the end of softdrink. This is when outcome-period opto turns off and
        % choice-period opto turns on
        outcome_port_entry_times = poke_times(outcome_pokes,1);
        outcome_port_exit_times = poke_times(outcome_pokes,2);

        if sessdata.rewards(trial_i) == 0
            % On unrewarded trials, this happens after unreward_time seconds have passed
            outcome_period_end(trial_i) = outcome_port_entry_times(1) + unreward_time;
        elseif sessdata.rewards(trial_i) == 1
            % On rewarded trials, this happens after the shorter of
            %  1) drink_timer seconds after the first outcome port poke
            %  2) The rat leaves the outcome port for a continuous stretch of more
            %     than softdrink_timer seconds

            % First check the softdrink time (rat leaves for softdrink_time seconds
            % without returning)


            exit_i = 1;
            % Each iteration checks a particular port exit. If there isn't a
            % re-entrance within softdrink_time of this exit, it triggers the end
            % of the period
            while isnan(outcome_period_end(trial_i))
                softdrink_over = outcome_port_exit_times(exit_i) + softdrink_time;
                % A re-entrance counts if it's after the time of the exit, but
                % before softdrink_over has passed.
                if ~any(outcome_port_entry_times(exit_i+1:end) < softdrink_over)
                    outcome_period_end(trial_i) = softdrink_over;
                end
                exit_i = exit_i + 1;
            end

            % Then check drink_timer -- if this happens earlier then it's the
            % outcome_period_end instead.
            outcome_period_end(trial_i) = min(outcome_period_end(trial_i), outcome_period_begin(trial_i) + drink_timer);

        end

    end

    % Check everything looks right
    assert(~any(outcome_period_begin > outcome_period_end))
    assert(~any(outcome_period_end(1:end-1) > choice_period_end(2:end)))

    %% Next run the ephys regressions
    ephys_sessdata = ephys_data(data_i);
    ephys_sessdata = add_values_to_ratdata(ephys_sessdata);

    for sess_unit_i = 1:length(ephys_sessdata.spiketimes)
        fprintf(1,'\b\b\b\b %3i', unit_i);
        
        unit_spiketimes = ephys_sessdata.spiketimes{sess_unit_i};
        spike_rates_outcome = NaN(ephys_sessdata.nTrials - 1,1);
        spike_rates_choice = NaN(ephys_sessdata.nTrials - 1,1);

        % Each iteration computes the spike rate during outcome-period and
        % choice-period for a single unit from this session
        for trial_i = 1:(sessdata.nTrials-1)

            outcome_period_spikes = outcome_period_begin(trial_i) < unit_spiketimes & ...
                unit_spiketimes < outcome_period_end(trial_i);

            choice_period_spikes = outcome_period_end(trial_i) < unit_spiketimes & ...
                unit_spiketimes < choice_period_end(trial_i+1);

            spike_rates_outcome(trial_i) = sum(outcome_period_spikes) / (outcome_period_end(trial_i) - outcome_period_begin(trial_i));
            spike_rates_choice(trial_i) = sum(choice_period_spikes) / (choice_period_end(trial_i+1) - outcome_period_end(trial_i));

        end

        % Regression for outcome period
        to_exclude = isnan(spike_rates_outcome) | ephys_sessdata.to_exclude(sess_unit_i,1:end-1)';
        spike_rates_outcome(to_exclude,:) = [];
        
        regressors = construct_regressors_ephys(ephys_sessdata);
        regressors(to_exclude,:) = [];
        
        regression_results_outcome(unit_i) = iti_regression_copd(spike_rates_outcome, regressors, 'linear');

        % Regression for choice period
        to_exclude = isnan(spike_rates_choice) | ephys_sessdata.to_exclude(sess_unit_i,1:end-1)';
        spike_rates_choice(to_exclude,:) = [];
        
        regressors = construct_regressors_ephys(ephys_sessdata);
        regressors(to_exclude,:) = [];
        
        regression_results_choice(unit_i) = iti_regression_copd(spike_rates_choice, regressors, 'linear');

        unit_i = unit_i + 1;

    end

end
fprintf(1,'\n');

%% Make Plots
ind_outcome_val = 8;
ind_choice_val = 9;
ind_chosen_val = 10;

for unit_i = 1:477
    outcome_period_cpds(unit_i,:) = regression_results_outcome(unit_i).copd;
    choice_period_cpds(unit_i,:) = regression_results_choice(unit_i).copd;
end

good_cpds = all(outcome_period_cpds > 0,2) & all(choice_period_cpds > 0,2)

xs = outcome_period_cpds(good_cpds, ind_outcome_val);
ys = outcome_period_cpds(good_cpds, ind_choice_val);

axmin = 1e-5;
axmax = 1e2;

figure;
line([axmin,axmax],[axmin,axmax],'color','black'); hold on
scatter(xs, ys, 200, '.','markeredgecolor', [0.5, 0.5, 0.5])
%scatter(xs(~singles), ys(~singles), 200, '.','markeredgecolor', msred)
set(gca,'fontsize',16,'xscale','log','yscale','log')
set(gca,'xtick',[1e-4, 1e-3, 1e-2,1e-1,1e0,1e1],'xticklabel',{'0.0001%', '0.001%', '0.01%', '0.1%', '1%', '10%'});
set(gca,'ytick',[1e-4, 1e-3, 1e-2,1e-1,1e0,1e1],'yticklabel',{'0.0001%', '0.001%', '0.01%', '0.1%', '1%', '10%'});
pbaspect([1 1 1])
ylabel({'CPD: Choice Value'},'fontsize',16);
xlabel({'CPD: Outcome Value'},'fontsize',16);
xlim([axmin,axmax]); ylim([axmin,axmax]);
title('Outcome Value vs. Choice Value');

loglog_scatter_diagonal_histogram(xs, ys, axmin, axmax)



xs = outcome_period_cpds(good_cpds, ind_outcome_val);
ys = choice_period_cpds(good_cpds, ind_chosen_val);

axmin = min([0.01; xs(:); ys(:); 10]);
axmax = max([0.01; xs(:); ys(:); 10]);

figure;
line([axmin,axmax],[axmin,axmax],'color','black'); hold on
scatter(xs, ys, 200, '.','markeredgecolor', [0.5, 0.5, 0.5])
%scatter(xs(~singles), ys(~singles), 200, '.','markeredgecolor', msred)
set(gca,'fontsize',16,'xscale','log','yscale','log')
set(gca,'xtick',[1e-2,1e-1,1e0,1e1],'xticklabel',{'0.01%','0.1%','1%','10%'});
set(gca,'ytick',[1e-2,1e-1,1e0,1e1],'yticklabel',{'0.01%','0.1%','1%','10%'});
pbaspect([1 1 1])
ylabel({'CPD: Chosen Value'},'fontsize',16);
xlabel({'CPD: Outcome Value'},'fontsize',16);
xlim([axmin,axmax]); ylim([axmin,axmax]);
title('Outcome Value vs. Chosen Value');

loglog_scatter_diagonal_histogram(xs, ys, axmin, axmax)
