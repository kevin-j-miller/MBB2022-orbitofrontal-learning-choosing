function fig = plot_raster(spiketimes, window, event_times, event_colors)


fig = figure; hold on
y = 1;

for event_type = 1:length(event_times)
    ys = [];
    xs = [];
    for event_i = 1:length(event_times{event_type})
        time_lock = event_times{event_type}(event_i);
        spikes_nearby = spiketimes(spiketimes > time_lock + window(1) & spiketimes < time_lock + window(2)) - time_lock;
        xs = [xs, spikes_nearby];
        ys = [ys, y*ones(1,length(spikes_nearby))];
        y = y+1;
    end
    scatter(xs, ys, 2, '.', 'markeredgecolor', event_colors(event_type,:));
end



set(gca,'fontsize',16);
ylim([0, y])
xlim([min(window), max(window)])
xlabel('Time from Event (s)','fontsize',20);
ylabel('Trials','fontsize',20);


end