function fig = plot_cpd_demo_chosen(celldata, cpds, cpd_bins)

window = [-1.2,1.2];

event_colors = [41, 152, 159;...
    31, 119,  82;...
    83, 159, 41] / 255;



good_trials = ~celldata.bad_timing(:) & ~celldata.to_exclude(:);

Q = celldata.Q_chosen';


spiketimes = celldata.spiketimes;

%% Raster
event_times{1} = celldata.s1_times(good_trials);
fig_raster = plot_raster(spiketimes, window, event_times, [0.5, 0.5, 0.5]);

%% PSTH Outcome Value
event_times = cell(0);
event_times{1} = celldata.s1_times(good_trials  & ...
                                   Q < prctile(Q, 100*1/3));
event_times{2} = celldata.s1_times(good_trials &...
                                   Q > prctile(Q, 100*1/3) & ...
                                   Q < prctile(Q, 100*2/3));
event_times{3} = celldata.s1_times(good_trials &...
                                   Q > prctile(Q, 100*2/3));

[fig_psth_q, axmax_q] = plot_psth(spiketimes, window, event_times, event_colors);

%% PSTH Choice
event_times = cell(0);
event_times{1} = celldata.s1_times(good_trials  & ...
                                   celldata.sides1=='r');
event_times{2} = celldata.s1_times(good_trials &...
    celldata.sides1 == 'l');

[fig_psth_c, axmax_c] = plot_psth(spiketimes, window, event_times, event_colors([true false true],:));



%% CPD
colors_task = [31, 119, 82;... % Choice Port (t)
    159, 54, 41; ... % Outcome Port
    39, 212, 243; ... % Reward
    83, 159, 41; ... % Choice Port (t+1)
    194, 93, 6; ... % Rew x Outcome Port
    159, 41, 110; ... % Choice Port x Outcome Port
    41, 152, 159] / 255; % Rew X Choice port
colors_val = [ 159, 41, 110;... % Outcome Value
   83, 159, 41;  % Choice Value
    41, 152, 159] / 255; % Chosen Value


fig_cpd = figure; hold on
plot(cpd_bins, cpds(:,4), 'linewidth', 2, 'color', colors_task(1,:)); % CPD choice
plot(cpd_bins, cpds(:,10), 'linewidth', 2, 'color', colors_val(3,:)); % CPD chosen value

%% Assemble Figure
axmax = max([axmax_q, axmax_c]);

fig = figure;
set(fig, 'pos', [650, 100, 500, 700])

h(1)=subplot(4,1,1);
ylabel('Trials')
ylim([0, celldata.nTrials])
xlim([-1,1])
set(gca, 'fontsize', 14)

h(2)=subplot(4,1,2);
ylim([0, axmax])
xlim([-1,1])
set(gca, 'fontsize', 14)
ylabel('Rate (sp/s)')

h(3)=subplot(4,1,3);
ylim([0, axmax])
xlim([-1,1])
set(gca, 'fontsize', 14)

ylabel('Rate (sp/s)')

h(4)=subplot(4,1,4);
xlim([-1,1])
set(gca, 'fontsize', 14)
xlabel('Time from Port Entry (s)')
ylabel('CPD')

copyobj(allchild(get(fig_raster,'CurrentAxes')),h(1));
copyobj(allchild(get(fig_psth_q,'CurrentAxes')),h(2));
copyobj(allchild(get(fig_psth_c,'CurrentAxes')),h(3));
copyobj(allchild(get(fig_cpd,'CurrentAxes')),h(4));
    
close([fig_raster, fig_psth_q, fig_psth_c, fig_cpd])

end