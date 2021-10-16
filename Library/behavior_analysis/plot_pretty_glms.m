function plot_pretty_glms(betas,nBack)

B=nanmean(betas);
se = nansem(betas,1);

figure; hold on;
grey = [0.7,0.7,0.7];

line([0,10],[0,0],'linestyle','-','color','k');

inds = 2:(1+nBack);
errorbar(1:nBack,B(inds),se(inds),'.-','Color',[0,50,190]/255,'LineWidth',3,'MarkerSize',15);
inds = (2+nBack):2*nBack+1;
errorbar(1:nBack,B(inds),se(inds),'.-','Color',[192,0,0]/255,'LineWidth',3,'MarkerSize',15);
inds = (2*nBack+2):3*nBack+1;
errorbar(1:nBack,B(inds),se(inds),'.--','Color',[0,50,190]/255,'LineWidth',3,'MarkerSize',15);
inds = (3*nBack+2):4*nBack+1;
errorbar(1:nBack,B(inds),se(inds),'.--','Color',[192,0,0]/255,'LineWidth',3,'MarkerSize',15);
%errorbar(nBack+1,B(1),stats.se(1),'k.','LineWidth',2,'MarkerSize',15);
set(gca,'FontSize',14)
set(gca,'fontsize',30,'xtick',[0:1:5],'ytick',[-2,-1,0,1,2])
xlabel('Trials Ago','fontsize',30); ylabel({'Same/Other','Regression Weight'},'fontsize',30)
xlim([0.9,nBack+0.1]);
set(gca,'Xdir','reverse')

end