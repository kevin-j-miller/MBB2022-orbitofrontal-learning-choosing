function plot_smoothed_ts(data,smoothing)
% function to plot smoothed behavioral data from the two-step task
if ~exist('smoothing','var')
    smoothing = 10;
end

choices = double(data.sides1=='r');
smoothed_choices = smooth(choices,smoothing);

leftprobs = smooth(data.leftprobs,5);
rightprobs = smooth(data.rightprobs,5);

xs = 1:length(choices);

x_inc = 0;
lw = 3.5;
figure; hold on;
plot(xs,smoothed_choices,'Color',dgreen,'linewidth',lw);
plot(xs-x_inc,leftprobs,'Color',mspurple,'linewidth',lw);
plot(xs+x_inc,rightprobs,'Color',msorange,'linewidth',lw);
ylim([-0.05,1.05]);

end
