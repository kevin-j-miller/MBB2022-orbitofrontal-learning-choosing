data = load(fullfile(files_path, 'postprocessed_data', 'ofc_celldatas_ensemble'));
singles = find_singles(data.celldatas);
clear data

ephys_regression_results = load(fullfile(files_path, 'postprocessed_data', 'ephys_regression_results'));

nCells = length(ephys_regression_results.bad_glm);
nRegs = 10;
window_size = 1;

%% Compute port-entry CPDs for each regressor
for cell_i = 1:nCells

        for lock_i = 1:4
           
            entry_bins = abs(ephys_regression_results.bin_mids_by_lock{lock_i}) <= window_size/2;
           
            sse_entry_leaveout = sum(ephys_regression_results.sse_leftout{lock_i, cell_i}(:,entry_bins),2);
            sse_entry_full = sum(ephys_regression_results.sse_full_all{lock_i, cell_i}(entry_bins));
            cpd_entry_true(lock_i, cell_i,:) = 100*(sse_entry_leaveout - repmat(sse_entry_full, [nRegs,1])) ./ sse_entry_leaveout; 
       
        end
end
bad_cpd = squeeze(any(any(isnan(cpd_entry_true),1),3)); % CPD can be NaN if the heldout SSE is zero. This normally happens if there are no spikes at all in a bin

%% Singles
% Figure and stats for outcome value (at outcome) vs. chosen value (at choice)

ov_at_outcome = cpd_entry_true(2, singles & ~bad_cpd, 8);
chv_at_choice = cpd_entry_true(4, singles & ~bad_cpd, 10);

xs = ov_at_outcome;
ys = chv_at_choice;

axmin = min([0.01; xs(:); ys(:); 10]);
axmax = max([0.01; xs(:); ys(:); 10]);

figure;
line([axmin,axmax],[axmin,axmax],'color','black'); hold on
scatter(xs, ys, 200, '.','markeredgecolor', [0.5, 0.5, 0.5])
set(gca,'fontsize',16,'xscale','log','yscale','log')
set(gca,'xtick',[1e-2,1e-1,1e0,1e1],'xticklabel',{'0.01%','0.1%','1%','10%'});
set(gca,'ytick',[1e-2,1e-1,1e0,1e1],'yticklabel',{'0.01%','0.1%','1%','10%'});
pbaspect([1 1 1])
ylabel({'CPD: Chosen Value'},'fontsize',16);
xlabel({'CPD: Outcome Value'},'fontsize',16);
xlim([axmin,axmax]); ylim([axmin,axmax]);
title('Outcome Value vs. Chosen Value');

print_svg('fig4-s2_cpd_scatter_chosen_singles')

disp('Mean CPD ratio, outcome/chosen:')
disp(mean(xs ./ ys))
disp('Median CPD ratio, outcome/chosen:')
disp(median(xs ./ ys))
disp('p-value, signrank test:')
disp(signrank(xs - ys, 0,'method','exact'));


% Figure and stats for outcome value (at outcome) vs. choice value diff (at outcome)

ov_at_outcome = cpd_entry_true(2, singles & ~bad_cpd, 8);
cvd_at_outcome = cpd_entry_true(2, singles & ~bad_cpd, 9);

xs = ov_at_outcome;
ys = cvd_at_outcome;

axmin = min([0.01; xs(:); ys(:); 10]);
axmax = max([0.01; xs(:); ys(:); 10]);

figure;
line([axmin,axmax],[axmin,axmax],'color','black'); hold on
scatter(xs, ys, 200, '.','markeredgecolor', [0.5, 0.5, 0.5])
set(gca,'fontsize',16,'xscale','log','yscale','log')
set(gca,'xtick',[1e-2,1e-1,1e0,1e1],'xticklabel',{'0.01%','0.1%','1%','10%'});
set(gca,'ytick',[1e-2,1e-1,1e0,1e1],'yticklabel',{'0.01%','0.1%','1%','10%'});
pbaspect([1 1 1])
ylabel({'CPD: Choice Value Difference'},'fontsize',16);
xlabel({'COD: Outcome Value'},'fontsize',16);
xlim([axmin,axmax]); ylim([axmin,axmax]);
title('Outcome Value vs. Choice Value');

print_svg('fig4-s2_cpd_scatter_choice_singles')


disp('Mean CPD ratio, outcome/choice:')
disp(mean(xs ./ ys))
disp('Median CPD ratio, outcome/choice:')
disp(median(xs ./ ys))
disp('p-value, signrank test:')
disp(signrank(xs - ys, 0,'method','exact'));


%% Multis
% Figure and stats for outcome value (at outcome) vs. chosen value (at choice)

ov_at_outcome = cpd_entry_true(2, ~singles & ~bad_cpd, 8);
chv_at_choice = cpd_entry_true(4, ~singles & ~bad_cpd, 10);

xs = ov_at_outcome;
ys = chv_at_choice;

axmin = min([0.01; xs(:); ys(:); 10]);
axmax = max([0.01; xs(:); ys(:); 10]);

figure;
line([axmin,axmax],[axmin,axmax],'color','black'); hold on
scatter(xs, ys, 200, '.','markeredgecolor', [0.5, 0.5, 0.5])
set(gca,'fontsize',16,'xscale','log','yscale','log')
set(gca,'xtick',[1e-2,1e-1,1e0,1e1],'xticklabel',{'0.01%','0.1%','1%','10%'});
set(gca,'ytick',[1e-2,1e-1,1e0,1e1],'yticklabel',{'0.01%','0.1%','1%','10%'});
pbaspect([1 1 1])
ylabel({'CPD: Chosen Value'},'fontsize',16);
xlabel({'CPD: Outcome Value'},'fontsize',16);
xlim([axmin,axmax]); ylim([axmin,axmax]);
title('Outcome Value vs. Chosen Value');

print_svg('fig4-s2_cpd_scatter_chosen_multis')

disp('Mean CPD ratio, outcome/chosen:')
disp(mean(xs ./ ys))
disp('Median CPD ratio, outcome/chosen:')
disp(median(xs ./ ys))
disp('p-value, signrank test:')
disp(signrank(xs - ys, 0,'method','exact'));


% Figure and stats for outcome value (at outcome) vs. choice value diff (at outcome)

ov_at_outcome = cpd_entry_true(2, ~singles & ~bad_cpd, 8);
cvd_at_outcome = cpd_entry_true(2, ~singles & ~bad_cpd, 9);

xs = ov_at_outcome;
ys = cvd_at_outcome;

axmin = min([0.01; xs(:); ys(:); 10]);
axmax = max([0.01; xs(:); ys(:); 10]);

figure;
line([axmin,axmax],[axmin,axmax],'color','black'); hold on
scatter(xs, ys, 200, '.','markeredgecolor', [0.5, 0.5, 0.5])
set(gca,'fontsize',16,'xscale','log','yscale','log')
set(gca,'xtick',[1e-2,1e-1,1e0,1e1],'xticklabel',{'0.01%','0.1%','1%','10%'});
set(gca,'ytick',[1e-2,1e-1,1e0,1e1],'yticklabel',{'0.01%','0.1%','1%','10%'});
pbaspect([1 1 1])
ylabel({'CPD: Choice Value Difference'},'fontsize',16);
xlabel({'COD: Outcome Value'},'fontsize',16);
xlim([axmin,axmax]); ylim([axmin,axmax]);
title('Outcome Value vs. Choice Value');

print_svg('fig4-s2_cpd_scatter_choice_multis')


disp('Mean CPD ratio, outcome/choice:')
disp(mean(xs ./ ys))
disp('Median CPD ratio, outcome/choice:')
disp(median(xs ./ ys))
disp('p-value, signrank test:')
disp(signrank(xs - ys, 0,'method','exact'));