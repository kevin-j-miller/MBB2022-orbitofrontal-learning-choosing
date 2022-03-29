function [fig, axmax] = plot_psth(spiketimes, window, event_times, event_colors)

t_binsize = 0.2;
t_bins = (window(1):t_binsize:window(2));
Tbin_mids = t_bins(2:end) - t_binsize/2;

%% Compute mean and sem of spiking rates

for type_i = 1:length(event_times)
    count = 1;
    for event_i = 1:length(event_times{type_i})
        time_lock = event_times{type_i}(event_i);
        if ~isnan(time_lock)
            bins_relative = time_lock + t_bins;
            
            spikes_in_bin = histc(spiketimes, bins_relative);
            ensemble{type_i}(count,:) = spikes_in_bin(1:end-1);
            count = count + 1;
        end
    end
    rates(type_i,:) = mean(ensemble{type_i} / t_binsize);
    err(type_i,:) = sem(ensemble{type_i} / t_binsize);
end

%% Add transparent region for error
lw = 2;
transp = 0.2;
fill_between_lines = @(X,mu,sigma,C) fill( [X fliplr(X)],  [mu+sigma fliplr(mu-sigma)], C , 'facealpha', transp, 'edgecolor','none');


fig = figure; hold on

for type_i = 1:length(event_times)
    fill_between_lines(Tbin_mids, rates(type_i,:), err(type_i,:), event_colors(type_i, :));
end

%% Add bold lines for means
for type_i = 1:length(event_times)
    plot(Tbin_mids, rates(type_i,:), 'linewidth', lw, 'color', event_colors(type_i, :));
end

set(gca,'fontsize',16);
xlabel('Time from Event (s)','fontsize',20);
ylabel('Firing Rate (sp/s)','fontsize',20);

axmax = 1.05*max(rates(:) + err(:)) + 1;
end