%% Load the dataset

opto_data_file = fullfile(files_path, 'preprocessed_data', 'ofc_learning_choosing_dataset_opto.mat');

assert(exist(opto_data_file, 'file') == 2, ...
    'Unable to find opto dataset. Please find "ofc_learning_choosing_dataset_opto.mat", and place it in the Matlab path.')

loaded = load(opto_data_file);

%%

lt_rew = [];
lt_ch = [];
lt_both = [];

for rat_i = 1:length(loaded.stimdata)
    
    ratdata = loaded.stimdata{rat_i};
    lt_rew =  [lt_rew;  ratdata.laser_times(ratdata.stim_type == 'r')];
    lt_ch =   [lt_ch;   ratdata.laser_times(ratdata.stim_type == 'c')];
    lt_both = [lt_both; ratdata.laser_times(ratdata.stim_type == 'b')];
    
end

edges = 0:2:16;

figure;
histogram(lt_both,edges,'normalization','probability','edgecolor','none','facealpha',1,'facecolor',[82, 61, 139] / 255)
set(gca,'fontsize',30,'ytick',[0,0.3,0.6],'yticklabels',{'0%','30%','60%'})
xlabel('Duration of Inhibition (s)','fontsize',30)
ylabel('Fraction of Trials','fontsize',30)
title('Both Periods Inhibition','fontsize',30)
xlim([0,16])
ylim([0,0.7])
box off
print_svg('Fig5-4_laser_durations_both');


figure;
histogram(lt_ch,edges,'normalization','probability','edgecolor','none','facealpha',1, 'facecolor', [31, 119, 82] / 255)
set(gca,'fontsize',30,'ytick',[0,0.3,0.6],'yticklabels',{'0%','30%','60%'})
xlabel('Duration of Inhibition (s)','fontsize',30)
ylabel('Fraction of Trials','fontsize',30)
title('Choice Period Inhibition','fontsize',30)
xlim([0,16])
ylim([0,0.7])
box off
print_svg('Fig5-4_laser_durations_choice');

figure;
histogram(lt_rew,edges,'normalization','probability','edgecolor','none','facealpha',1,'facecolor', [159, 54, 41] / 255)
set(gca,'fontsize',30,'ytick',[0,0.3,0.6],'yticklabels',{'0%','30%','60%'})
xlabel('Duration of Inhibition (s)','fontsize',30)
ylabel('Fraction of Trials','fontsize',30)
title('Outcome Period Inhibition','fontsize',30)
xlim([0,16])
ylim([0,0.7])
box off
print_svg('Fig5-4_laser_durations_outcome');
