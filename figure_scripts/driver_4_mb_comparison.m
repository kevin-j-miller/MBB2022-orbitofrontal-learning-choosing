loaded = load('opto_glm_results');
results = loaded.results;
results_sham = loaded.results_sham;

%% Comparison plot MB

rew_effect = 100*(results.mb_rew - results.mb_cntrl) ./ results.mb_cntrl;
ch_effect = 100*(results.mb_ch - results.mb_cntrl) ./ results.mb_cntrl;
both_effect = 100*(results.mb_both - results.mb_cntrl) ./ results.mb_cntrl;

rew_effect_sham = 100*(results_sham.mb_rew - results_sham.mb_cntrl) ./ results_sham.mb_cntrl;
ch_effect_sham = 100*(results_sham.mb_ch - results_sham.mb_cntrl) ./ results_sham.mb_cntrl;
both_effect_sham = 100*(results_sham.mb_both - results_sham.mb_cntrl) ./ results_sham.mb_cntrl;

% Jitter and offset to control plotting position
jit = 0.1;
offset = 0.15;

figure; hold on;
line([0,4],[0,0],'color',[0,0,0])

% Add active rats
nRats = length(results.fits_extracted);
jitter = (0:jit/(nRats-1):jit) - jit/2;
xs = repmat((1:3)',[1,nRats]) + repmat(jitter,[3,1]) - offset;
ys = [rew_effect; ch_effect; both_effect;];

rew_color = [159, 54, 41]/255;
ch_color = [31, 119, 82]/255;
both_color = [82, 61, 139]/255;

colors = {rew_color; ch_color; both_color};
ymax = max(ys(:)) + 5;
ymin = min(ys(:)) - 5;


for x_i = 1:3
scatter(xs(x_i,:),ys(x_i,:),100,'V','markerfacecolor',lighten(colors{x_i},0.6),'markeredgecolor','none');
errorbar([0,x_i-offset,4],[0,mean(ys(x_i,:)),0],[0,sem(ys(x_i,:)),0],'.','color',colors{x_i},'linewidth',5); % Padding to equal out errorbar tab lengths
end

% Add control rats
nRats = length(results_sham.fits_extracted);
jitter = (0:jit/(nRats-1):jit) - jit/2;
xs = repmat((1:3)',[1,nRats]) + repmat(jitter,[3,1]) + offset;
ys = [rew_effect_sham; ch_effect_sham; both_effect_sham];

colors = {[100, 100, 100]/255; [100, 100, 100]/255; [100, 100, 100]/255};

for x_i = 1:3
scatter(xs(x_i,:),ys(x_i,:),100,'d','markerfacecolor',lighten(colors{x_i},0.6),'markeredgecolor','none');
errorbar([0,x_i+offset,4],[0,mean(ys(x_i,:)),0],[0,sem(ys(x_i,:)),0],'.','color',colors{x_i},'linewidth',5); % Padding to equal out errorbar tab lengths
end

% Final figure formatting
set(gca,'fontsize',14,'xtick',1:3,'xticklabel',{'Inactivate at Reward','Inactivate at Choice','Inactivate at Both'},'ytick',[-60,-40,-20,0,20],'yticklabel',{'-60%','-40%','-20%','0%','+20%'});
ylim([ymin,ymax]); xlim([0.5,3.5])
ylabel('Change in Model-Based Index','FontSize',20);



%% Get p-values

% p-values within time periods
[~, p_rew] = ttest(rew_effect)
[~, p_ch] = ttest(ch_effect)
[~, p_both] = ttest(both_effect)

[~, p_rew_cntrl] = ttest(rew_effect_sham)
[~, p_ch_cntrl] = ttest(ch_effect_sham)
[~, p_both_cntrl] = ttest(both_effect_sham)

% Between time periods
[~, p_both_over_rew] = ttest(both_effect - rew_effect)
[~, p_rew_over_ch] = ttest(rew_effect - ch_effect)
[~, p_both_over_ch] = ttest(both_effect - ch_effect)

% p-values infected vs uninfected
[~, p_rew_over_cntrl] = ttest2(rew_effect,rew_effect_sham)
[~, p_ch_over_cntrl] = ttest2(ch_effect,ch_effect_sham)
[~, p_both_over_cntrl] = ttest2(both_effect,both_effect_sham)