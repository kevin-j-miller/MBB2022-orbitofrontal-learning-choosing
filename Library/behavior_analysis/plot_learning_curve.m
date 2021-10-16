function results = plot_learning_curve(ratdata, do_plot)

%% Function to plot % better choices as a function of trials-from-flip for an individual rat

% Find the flips

flip_inds = find(diff(ratdata.leftprobs) ~= 0);
better_choices = [ratdata.better_choices; nan(100,1)];

for tff_i = 1:100 % Tff: "trial from flip"
learning_curve(tff_i) = nanmean(better_choices(flip_inds+tff_i));
end

if do_plot
figure; plot(learning_curve)
end

results.learning_curve = learning_curve;

end