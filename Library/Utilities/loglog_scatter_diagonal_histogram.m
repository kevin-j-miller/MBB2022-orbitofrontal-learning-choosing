function loglog_scatter_diagonal_histogram(xs,ys,axmin, axmax)


% Histogram
dists = 1/sqrt(2) * 1/log(axmax/axmin) * (log(xs ./ ys));

xtick = 1/sqrt(2) * 1/log(axmax/axmin) * (log([1/100, 1/90, 1/80, 1/70, 1/60, 1/50, 1/40, 1/30, 1/20, 1/10, ...
                                               1/9, 1/8, 1/7, 1/6, 1/5, 1/4, 1/3, 1/2, 1/1,...
                                               2,3,4,5,6,7,8,9,10,...
                                               20, 30, 40, 50, 60, 70, 80, 90, 100]));
xticklabels = {'1:100','','','','','','','','','1:10',...
    '','','','','','','','','1:1',...
    '','','','','','','','','10:1',...
    '','','','','','','','','100:1'};

figure; hold on
h = histogram(dists,'edgecolor','none');
line([0,0],[0,1e5],'color',[0,0,0],'linewidth',3);
xlim([-1/sqrt(2), 1/sqrt(2)]);
ylim([0, 1.05*max(h.Values)]);
box off
set(gca,'xtick', xtick, 'xticklabels', xticklabels,'yticklabels',[]);

end