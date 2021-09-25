function figs = make_timecourse_plots(in)


lw = 3;
p_small = [20, 20, 300, 420];
p_big = [20, 20, 500, 420];

ymax = 1.05*max(max(([in.ys{:}])));

figs(1) = figure; 
subplot(1,4,1); hold on
set(gca,'colororder',in.colors);
set(gcf,'position',p_small);
area([in.xs{1}(1), in.xs{1}(end)], [in.err, in.err], 'FaceColor',[0.75,0.75,0.75],'edgecolor','none');
plot(in.xs{1}, in.ys{1},'linewidth',lw); 
pbaspect([1 2 1])
ylim([0,ymax]); xlim([-2,2])
xlabel('Time from Poke (s)','fontsize',16);
title('Step 2 Init (pre-ITI)','fontsize',20);
set(gca,'fontsize',20)

%figs(2) = figure; 
subplot(1,4,2); hold on
set(gca,'colororder',in.colors);
set(gcf,'position',p_big);
area([in.xs{2}(1), in.xs{2}(end)], [in.err, in.err], 'FaceColor',[0.75,0.75,0.75],'edgecolor','none');
plot(in.xs{2}, in.ys{2},'linewidth',lw); 
pbaspect([1 1 1])
ylim([0,ymax]); xlim([-2,6])
xlabel('Time from Poke (s)','fontsize',16);
title('Reward Port (pre-ITI)','fontsize',20);
set(gca,'fontsize',20)

%figs(3) = figure; 
subplot(1,4,3); hold on
set(gca,'colororder',in.colors);
set(gcf,'position',p_big);
area([in.xs{3}(1), in.xs{3}(end)], [in.err, in.err],'FaceColor',[0.75,0.75,0.75],'edgecolor','none');
plot(in.xs{3}, in.ys{3},'linewidth',lw); 
pbaspect([1 1 1])
ylim([0,ymax]); xlim([-6,2])
xlabel('Time from Poke (s)','fontsize',16);
title('Trial Initiation (post-ITI)','fontsize',20);
set(gca,'fontsize',20)

%figs(4) = figure; 
subplot(1,4,4); hold on
set(gca,'colororder',in.colors);
set(gcf,'position',p_small);
area([in.xs{4}(1), in.xs{4}(end)], [in.err, in.err],'FaceColor',[0.75,0.75,0.75],'edgecolor','none');
plot(in.xs{4}, in.ys{4},'linewidth',lw); 
pbaspect([1 2 1])
ylim([0,ymax]); xlim([-2,2])
xlabel('Time from Poke (s)','fontsize',16);
title('Choice Port (post-ITI)','fontsize',20);
set(gca,'fontsize',20)
