%% Load the dataset

opto_data_file = fullfile(files_path, 'preprocessed_data', 'ofc_learning_choosing_dataset_opto.mat');

assert(exist(opto_data_file, 'file') == 2, ...
    'Unable to find opto dataset. Please find "ofc_learning_choosing_dataset_opto.mat", and place it in the Matlab path.')

loaded = load(opto_data_file);

%%

lt_rew = [];
lt_ch = [];
lt_both = [];
lt_ch_pre_c1 = [];

for rat_i = 1:length(loaded.stimdata)

    ratdata = loaded.stimdata{rat_i};
    lt_rew =  [lt_rew;  ratdata.laser_times(ratdata.stim_type == 'r')];
    lt_ch =   [lt_ch;   ratdata.laser_times(ratdata.stim_type == 'c')];
    lt_both = [lt_both; ratdata.laser_times(ratdata.stim_type == 'b')];

    c1s1_to_select = randi(length(ratdata.c1s1_times)); % FIX THIS! I NEED THE REAL TIMES, NOT THIS GUESS
    lt_ch_pre_c1 =   [lt_ch_pre_c1;   ratdata.laser_times(ratdata.stim_type == 'c') - ratdata.c1s1_times(c1s1_to_select)];

end

edges = 0:1:17;

figure;
histogram(lt_both,edges,'normalization','probability','edgecolor','none','facealpha',1,'facecolor',[82, 61, 139] / 255)
set(gca,'fontsize',30,'ytick',[0,0.1,0.2],'yticklabels',{'0%','10%','20%'})
xlabel('Duration of Inhibition (s)','fontsize',30)
ylabel('Fraction of Trials','fontsize',30)
title('Both Periods Inhibition','fontsize',30)
xlim([0,16])
ylim([0,0.2])
box off
print_svg('Fig5-2_laser_durations_both');


figure;
histogram(lt_ch,edges,'normalization','probability','edgecolor','none','facealpha',1, 'facecolor', [31, 119, 82] / 255)
set(gca,'fontsize',30,'ytick',[0,0.15,0.3],'yticklabels',{'0%','15%','30%'})
xlabel('Duration of Inhibition (s)','fontsize',30)
ylabel('Fraction of Trials','fontsize',30)
title('Choice Period Inhibition','fontsize',30)
xlim([0,16])
ylim([0,0.3])
box off
print_svg('Fig5-2_laser_durations_choice');

figure;
histogram(lt_rew,edges,'normalization','probability','edgecolor','none','facealpha',1,'facecolor', [159, 54, 41] / 255)
set(gca,'fontsize',30,'ytick',[0,0.3,0.6],'yticklabels',{'0%','30%','60%'})
xlabel('Duration of Inhibition (s)','fontsize',30)
ylabel('Fraction of Trials','fontsize',30)
title('Outcome Period Inhibition','fontsize',30)
xlim([0,16])
ylim([0,0.7])
box off
print_svg('Fig5-2_laser_durations_outcome');


%% 
n_rats = 6;

counter = 1;
step2_port_times = [];
outcome_port_times = [];
init_port_times = [];
choice_port_times = [];
period_switches = [];

for rat_i = 1:n_rats

    loaded = load(fullfile(files_path, 'preprocessed_data', 'opto_peh', ['opto_peh_rat_' num2str(rat_i)]));
    peh = loaded.peh;

    n_sessions = length(peh);



    for sess_i = 1:n_sessions

        sess_peh = peh{sess_i};

        % Each element of peh corresponds to a pair of adjacent trials. Opto will
        % sometimes happen in the ITI between these pairs (it'll never happen in
        % the ITI between trials that are not pairs)
        n_trial_doubles = length(sess_peh);

        for trial_i = 1:n_trial_doubles

            %% Find port entry times

            trial_states = sess_peh(trial_i).states;

            % Fine the time of init port entry 1
            if ~isempty(trial_states.nose_in_center_2l)
                step2_port_times(counter) = trial_states.nose_in_center_2l(end,1);
            elseif ~isempty(trial_states.nose_in_center_2r)
                step2_port_times(counter) = trial_states.nose_in_center_2r(end,2);
            end
            % Find the time of outcome port entry 1
            % This is the end of the second-step "choice state", whichever applies to
            % this trial
            if ~isempty(trial_states.choice_state_2l)
                outcome_port_times(counter) = trial_states.choice_state_2l(end,2);
            elseif ~isempty(trial_states.choice_state_2r)
                outcome_port_times(counter) = trial_states.choice_state_2r(end,2);
            end

            % Time of initiation of the second trial
            % This is the beginning of the first nose-in-center state
            init_port_times(counter) = trial_states.nose_in_center_1_2nd(1,1);

            % Find the time of choice port entry 2
            % This is the end of the choice state
            choice_port_times(counter) = trial_states.choice_state_1_2nd(1,2);

            %% Find "outcome period" end / "choice period" beginning
            % This happens in the "cleanup state"
            period_switches(counter) = trial_states.cleanup_state(1);

            counter = counter + 1;

        end
    end
end

outcome_post_step2 = outcome_port_times - step2_port_times;
switch_post_step2 = period_switches - step2_port_times;

switch_post_outcome = period_switches - outcome_port_times;
choice_post_outcome = choice_port_times - outcome_port_times;

outcome_pre_init = outcome_port_times - init_port_times;
switch_pre_init = period_switches - init_port_times;
choice_post_init = choice_port_times - init_port_times;

outcome_pre_choice = outcome_port_times - choice_port_times;
switch_pre_choice = period_switches - choice_port_times;

%% Make plots

edges = -60:0.01:60;

% Locked to step2 port
p_outcome_period = histcounts(outcome_post_step2, edges,'normalization','cdf');
p_outcome_period(edges < 0) = 0;

figure;
image(edges, ones(length(edges),1), p_outcome_period,'CDataMapping','scaled')

cb = colorbar('xtick',[0, 0.5, 1],'xticklabel',{'0%','50%','100%'});
set(cb,'ylim', [0,1])

for color_i = 1:100
    mymap(color_i,:) = lighten(rew_color,color_i/100);
end
colormap(mymap)

set(gca,'ytick',[], 'fontsize', 14, 'clim', [0,1])

title('Probability of Being in Outcome Period')
xlabel('Time from Step 2 Port (s)')
xlim([-2,2])

set(gcf, 'pos', [100, 100, 500, 120])
print_svg('fig5-2b_outcome_period_prob_step2')

% Locked to outcome port
p_outcome_period = 1 - histcounts(switch_post_outcome, edges,'normalization','cdf');
p_outcome_period(edges < 0) = 0;

figure;
image(edges, ones(length(edges),1), p_outcome_period,'CDataMapping','scaled')

cb = colorbar('xtick',[0, 0.5, 1],'xticklabel',{'0%','50%','100%'});
set(cb,'ylim', [0,1])

for color_i = 1:100
    mymap(color_i,:) = lighten(rew_color,color_i/100);
end
colormap(mymap)

set(gca,'ytick',[], 'fontsize', 14, 'clim', [0,1])

title('Probability of Being in Outcome Period')
xlabel('Time from Outcome Port (s)')
xlim([-2,6])

p_choice_period = histcounts(switch_post_outcome,edges,'normalization','cdf');
p_choice_period = p_choice_period - histcounts(choice_post_outcome, edges, 'normalization', 'cdf');

set(gcf, 'pos', [100, 100, 500, 120])
print_svg('fig5-2b_outcome_period_prob_outcome')

figure;
image(edges, ones(length(edges),1), p_choice_period,'CDataMapping','scaled')

cb = colorbar('xtick',[0, 0.5, 1],'xticklabel',{'0%','50%','100%'});
set(cb,'ylim', [0,1])
for color_i = 1:100
    mymap(color_i,:) = lighten(ch_color, color_i/100);
end
colormap(mymap)
set(gca,'ytick',[], 'fontsize', 14, 'clim', [0,1])
title('Probability of Being in Choice Period')
xlabel('Time from Outcome Port (s)')
xlim([-2,6])

set(gcf, 'pos', [100, 100, 500, 120])
print_svg('fig5-2b_choice_period_prob_outcome')

% Locked to init port
p_outcome_period = 1 - histcounts(switch_pre_init, edges,'normalization','cdf');
p_outcome_period = p_outcome_period - (1 - histcounts(outcome_pre_init, edges,'normalization','cdf'));

figure;
image(edges, ones(length(edges),1), p_outcome_period,'CDataMapping','scaled')

cb = colorbar('xtick',[0, 0.5, 1],'xticklabel',{'0%','50%','100%'});
set(cb,'ylim', [0,1])

for color_i = 1:100
    mymap(color_i,:) = lighten(rew_color,color_i/100);
end
colormap(mymap)

set(gca,'ytick',[], 'fontsize', 14, 'clim', [0,1])

title('Probability of Being in Outcome Period')
xlabel('Time from Initiation Port (s)')
xlim([-6,2])


set(gcf, 'pos', [100, 100, 500, 120])
print_svg('fig5-2b_outcome_period_prob_init')

p_choice_period = histcounts(switch_pre_init,edges,'normalization','cdf');
p_choice_period = p_choice_period - histcounts(choice_post_init, edges,'normalization','cdf');
figure;
image(edges, ones(length(edges),1), p_choice_period,'CDataMapping','scaled')

cb = colorbar('xtick',[0, 0.5, 1],'xticklabel',{'0%','50%','100%'});
set(cb,'ylim', [0,1])
for color_i = 1:100
    mymap(color_i,:) = lighten(ch_color, color_i/100);
end
colormap(mymap)
set(gca,'ytick',[], 'fontsize', 14, 'clim', [0,1])
title('Probability of Being in Choice Period')
xlabel('Time from Initiation Port (s)')
xlim([-6,2])


set(gcf, 'pos', [100, 100, 500, 120])
print_svg('fig5-4b_choice_period_prob_init')

% Locked to choice port
p_outcome_period = 1 - histcounts(switch_pre_choice, edges,'normalization','cdf');
p_outcome_period = p_outcome_period - (1 - histcounts(outcome_pre_choice, edges,'normalization','cdf'));

figure;
image(edges, ones(length(edges),1), p_outcome_period,'CDataMapping','scaled')

cb = colorbar('xtick',[0, 0.5, 1],'xticklabel',{'0%','50%','100%'});
set(cb,'ylim', [0,1])

for color_i = 1:100
    mymap(color_i,:) = lighten(rew_color,color_i/100);
end
colormap(mymap)

set(gca,'ytick',[], 'fontsize', 14, 'clim', [0,1])

title('Probability of Being in Outcome Period')
xlabel('Time from Choice Port (s)')
xlim([-2,2])

set(gcf, 'pos', [100, 100, 500, 120])
print_svg('fig5-4b_outcome_period_prob_choice')


p_choice_period = histcounts(switch_pre_choice,edges,'normalization','cdf');
p_choice_period(edges > 0) = 0;

figure;
image(edges, ones(length(edges),1), p_choice_period,'CDataMapping','scaled')

cb = colorbar('xtick',[0, 0.5, 1],'xticklabel',{'0%','50%','100%'});
set(cb,'ylim', [0,1])
for color_i = 1:100
    mymap(color_i,:) = lighten(ch_color, color_i/100);
end
colormap(mymap)
set(gca,'ytick',[], 'fontsize', 14, 'clim', [0,1])
title('Probability of Being in Choice Period')
xlabel('Time from Choice Port (s)')
xlim([-2,2])

set(gcf, 'pos', [100, 100, 500, 120])
print_svg('fig5-2b_choice_period_prob_choice')