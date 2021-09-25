
loaded = load('opto_glm_results');
results = loaded.results;
results_sham = loaded.results_sham;

%% Plot by nBack
nBack = 3;
offset = 0.02;
transform = @(x) log(x+offset);
transform_inverse = @(x) exp(x) - offset;


figure; hold on;
line([0,10],transform([0,0]),'color',[0,0,0])

data = results.mb_cntrl_by_nBack;
xs = 1:nBack;
ys = transform(mean(data)); 
ub = transform(mean(data) + sem(data));
lb = transform(mean(data) - sem(data));
above = ub - ys; below = ys - lb;

errorbar(xs, ys, below, above, 'color','k','LineWidth',2.5);

data = results.mb_rew_by_nBack;
xs = 1:nBack;
ys = transform(mean(data)); 
ub = transform(mean(data) + sem(data));
lb = transform(mean(data) - sem(data));
above = ub - ys; below = ys - lb;

errorbar(xs, ys, below, above,'color',rew_color,'LineWidth',2.5);


yticks = transform([0:0.1:1, (1:10)+1]);
ylim([min(lb) + 0.1*min(lb), transform(6.4)])
xlim([0.5,nBack + 0.5]); set(gca,'fontsize',20, 'ytick', yticks,'yticklabels',{'0','0.1','','0.3','','','','','','','1.0','','3.0','','','',''})
xlabel('Trials Ago','fontsize',20); ylabel('Contribution to Planning Index','fontsize',20);
set(gca,'Xdir','reverse')


[h,p] = ttest(results.mb_cntrl_by_nBack - results.mb_rew_by_nBack)