function plot_smoothed_ts(data,smoothing)
% function to plot smoothed behavioral data from the two-step task
if ~exist('smoothing','var')
    smoothing = 15;
end

choices = double(data.sides1=='r');
smoothed_choices = smooth(choices,smoothing);

leftprobs = smooth(data.leftprobs,7);
rightprobs = smooth(data.rightprobs,7);

xs = 1:length(choices);

x_inc = 0;
lw = 3.5;
figure; hold on;
plot(xs,smoothed_choices,'Color',task_green,'linewidth',lw);
plot(xs-x_inc,leftprobs,'Color', task_purple,'linewidth',lw);
plot(xs+x_inc,rightprobs,'Color',task_orange,'linewidth',lw);
ylim([-0.05,1.05]);

end
