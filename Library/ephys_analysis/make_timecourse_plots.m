function figs = make_timecourse_plots(in)


lw = 3;
p_small = [20, 20, 300, 420];
p_big = [20, 20, 500, 420];

colors = in.colors;

ymax = 1.05*max(max(([in.ys{:}])));

figs(1) = figure; 
subplot(1,4,1); hold on
set(gca,'colororder', colors);
set(gcf,'position',p_small);
area([in.xs{1}(1), in.xs{1}(end)], [in.err, in.err], 'FaceColor',[0.75,0.75,0.75],'edgecolor','none');
for y_i = 1:size(in.ys{1},1)
    plot(in.xs{1}, in.ys{1}(y_i,:), 'linewidth',lw, 'color', colors(y_i,:)); 
end
pbaspect([1 2 1])
ylim([0,ymax]); xlim([-2,2])
xlabel('Time from Poke (s)','fontsize',16);
title('Step 2 Init (pre-ITI)','fontsize',20);
set(gca,'fontsize',20)
set(gca,'FontName','Calibri');

%figs(2) = figure; 
subplot(1,4,2); hold on
set(gca,'colororder', colors);
set(gcf,'position',p_big);
area([in.xs{2}(1), in.xs{2}(end)], [in.err, in.err], 'FaceColor',[0.75,0.75,0.75],'edgecolor','none');
for y_i = 1:size(in.ys{2},1)
    plot(in.xs{2}, in.ys{2}(y_i,:), 'linewidth',lw, 'color', colors(y_i,:)); 
end
pbaspect([1 1 1])
ylim([0,ymax]); xlim([-2,6])
xlabel('Time from Poke (s)','fontsize',16);
title('Reward Port (pre-ITI)','fontsize',20);
set(gca,'fontsize',20)
set(gca,'FontName','Calibri');

%figs(3) = figure; 
subplot(1,4,3); hold on
set(gca,'colororder', colors);
set(gcf,'position',p_big);
area([in.xs{3}(1), in.xs{3}(end)], [in.err, in.err],'FaceColor',[0.75,0.75,0.75],'edgecolor','none');
for y_i = 1:size(in.ys{3},1)
    plot(in.xs{3}, in.ys{3}(y_i,:), 'linewidth',lw, 'color', colors(y_i,:)); 
end
pbaspect([1 1 1])
ylim([0,ymax]); xlim([-6,2])
xlabel('Time from Poke (s)','fontsize',16);
title('Trial Initiation (post-ITI)','fontsize',20);
set(gca,'fontsize',20)
set(gca,'FontName','Calibri');

%figs(4) = figure; 
subplot(1,4,4); hold on
set(gca,'colororder', colors);
set(gcf,'position',p_small);
area([in.xs{4}(1), in.xs{4}(end)], [in.err, in.err],'FaceColor',[0.75,0.75,0.75],'edgecolor','none');
for y_i = 1:size(in.ys{4},1)
    plot(in.xs{4}, in.ys{4}(y_i,:), 'linewidth',lw, 'color', colors(y_i,:)); 
end
pbaspect([1 2 1])
ylim([0,ymax]); xlim([-2,2])
xlabel('Time from Poke (s)','fontsize',16);
title('Choice Port (post-ITI)','fontsize',20);
set(gca,'fontsize',20)
set(gca,'FontName','Calibri');

set(gcf, 'pos', [50, 500, 1800, 400])