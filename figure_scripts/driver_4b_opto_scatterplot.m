loaded = load('opto_glm_results');
results = loaded.results;
results_sham = loaded.results_sham;

%% MB-MF scatterplot
    marker_size = 30;
    l = 0.6;
    lw = 2;
    
fig = figure; hold on
line([-10, 10], [0, 0], 'color', 'k')
line([0, 0], [-10, 10], 'color', 'k')
scatter(results.mb_cntrl, results.mf_cntrl, marker_size, 'v', 'markeredgecolor', 'none', ...
    'markerfacecolor', lighten([0,0,0],l))
scatter(results.mb_rew, results.mf_rew, marker_size, 'v', 'markeredgecolor', 'none', ...
    'markerfacecolor', lighten(rew_color, l))
scatter(results.mb_ch, results.mf_ch, marker_size, 'v', 'markeredgecolor', 'none', ...
    'markerfacecolor', lighten(ch_color,l))
scatter(results.mb_both, results.mf_both, marker_size, 'v', 'markeredgecolor', 'none', ...
    'markerfacecolor', lighten(both_color,l))

add_error_cross(fig, results.mb_rew, results.mf_rew, rew_color, lw)
add_error_cross(fig, results.mb_ch, results.mf_ch, ch_color, lw)
add_error_cross(fig, results.mb_both, results.mf_both, both_color, lw)
add_error_cross(fig, results.mb_cntrl, results.mf_cntrl, [0,0,0], lw)


xlim([-1, 7])
ylim([-1, 7])
axis square
set(gca,...
    'fontsize',14,...
    'xtick', [0,3,6],...
    'ytick', [0,3,6])

xlabel('Planning Index')
ylabel('Model-Free Index')

print('figures_raw/s5_opto_mbmf','-dsvg')

%% Persev 

jit = 0.1;

% Make figure
figure; hold on;
line([0,4],[0,0],'color',[0,0,0])

nRats = 9;
jitter = (0:jit/(nRats-1):jit) - jit/2;

xs = jitter + 1;
ys = results.pers_cntrl;
color = [0,0,0];

scatter(xs,ys,100,'V','markerfacecolor',lighten(color,0.6),'markeredgecolor','none');
errorbar([0,1,5],[0,mean(ys),0],[0,sem(ys),0],'.','color',color,'linewidth',5); % Padding to equal out errorbar tab lengths

xs = jitter + 2;
ys = results.pers_rew;
color = rew_color;

scatter(xs,ys,100,'V','markerfacecolor',lighten(color,0.6),'markeredgecolor','none');
errorbar([0,2,5],[0,mean(ys),0],[0,sem(ys),0],'.','color',color,'linewidth',5); % Padding to equal out errorbar tab lengths

xs = jitter + 3;
ys = results.pers_ch;
color = ch_color;

scatter(xs,ys,100,'V','markerfacecolor',lighten(color,0.6),'markeredgecolor','none');
errorbar([0,3,5],[0,mean(ys),0],[0,sem(ys),0],'.','color',color,'linewidth',5); % Padding to equal out errorbar tab lengths


xs = jitter + 4;
ys = results.pers_both;
color = both_color;

scatter(xs,ys,100,'V','markerfacecolor',lighten(color,0.6),'markeredgecolor','none');
errorbar([0,4,5],[0,mean(ys),0],[0,sem(ys),0],'.','color',color,'linewidth',5); % Padding to equal out errorbar tab lengths

xlim([0.5, 4.5])
ylabel('Effect of previous choices')

set(gca,...
    'fontsize', 14,...
    'ytick', [0, 4, 8], ...
    'xtick', [1,2,3,4], ...
    'xticklabel', {'Control','Reward-Period','Choice-Period','Both-Periods'})

print('figures_raw/s5_opto_pers','-dsvg')