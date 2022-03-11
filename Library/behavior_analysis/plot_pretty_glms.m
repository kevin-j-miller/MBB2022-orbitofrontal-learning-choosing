function plot_pretty_glms(betas,nBack, gridlines)

if ~exist('gridlines', 'var')
    gridlines = false;
end

B=nanmean(betas);
se = nansem(betas,1);

figure; hold on;
grey = [0.7,0.7,0.7];

% Horizontal grey dottend lines behind the data
if gridlines
    ys = [-2:0.25:2];
    for y = ys
        line([0, nBack + 1], [y,y], 'linestyle','--', 'color', grey)
    end
end

line([0,10],[0,0],'linestyle','-','color','k');

inds = 2:(1+nBack);
errorbar(1:nBack,B(inds),se(inds),'.-','Color', blue,'LineWidth',3,'MarkerSize',15);
inds = (2+nBack):2*nBack+1;
errorbar(1:nBack,B(inds),se(inds),'.-','Color', red,'LineWidth',3,'MarkerSize',15);
inds = (2*nBack+2):3*nBack+1;
errorbar(1:nBack,B(inds),se(inds),'.--','Color', blue,'LineWidth',3,'MarkerSize',15);
inds = (3*nBack+2):4*nBack+1;
errorbar(1:nBack,B(inds),se(inds),'.--','Color', red,'LineWidth',3,'MarkerSize',15);
%errorbar(nBack+1,B(1),stats.se(1),'k.','LineWidth',2,'MarkerSize',15);

set(gca,'fontsize',20,'xtick',[0:1:5],'ytick',[-2,-1,0,1,2])
xlabel('Trials Ago'); ylabel({'Stay/Switch','Regression Weight'})
xlim([0.9,nBack+0.1]);
ylim([-1, 2])
set(gca,'Xdir','reverse')
box off

end