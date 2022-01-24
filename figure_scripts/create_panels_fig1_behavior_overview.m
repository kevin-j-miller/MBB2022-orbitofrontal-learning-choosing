
if ~exist(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits.mat'), 'file')
    % If the model fits do not exist, re-run them
    fit_behavioral_models
end

loaded = load(fullfile(files_path, 'postprocessed_data', 'behavioral_model_fits.mat'));
fit_params = loaded.fit_params;
ratdatas_all = loaded.ratdatas_all;

%% Plot behavior example
example_rat_ind = 10;
example_session_ind = 5;
example_data = divide_into_sessions(ratdatas_all(example_rat_ind));
example_session = example_data{example_session_ind};
plot_smoothed_ts(example_session, 15);
set(gca,'FontSize',20,'YTick',[0,0.5,1],'xtick',[0,250,500, 750])
set(gcf,'pos',[100, 100, 800, 300])
xlim([0,example_session.nTrials]); 
legend off
print_svg('fig1_example_session')

%% Plot learning curves
clear learning_curves
nRats = length(ratdatas_all);
for rat_i = 1:nRats
    ratdata = ratdatas_all(rat_i);
    if ratdata.nTrials >= 2000
    results = plot_learning_curve(ratdatas_all(rat_i), false);
    learning_curves(rat_i,:) = results.learning_curve;
    end
end

figure; hold on
plot(learning_curves','color',lighten(dgreen,0.5));
plot(mean(learning_curves),'color',dgreen,'linewidth',3);
set(gca,'fontsize',20,'ytick',[0,0.5,1]); xlim([1,15]); ylim([0,1])
xlabel('Trials from reward probability flip')
ylabel('Fraction choices to better side')
print_svg('fig1_learning_curves')