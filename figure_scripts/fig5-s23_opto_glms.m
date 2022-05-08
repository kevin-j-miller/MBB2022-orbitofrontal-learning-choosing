%% Load processed data

opto_file = fullfile(files_path, 'postprocessed_data', 'opto_results_glm.mat');

if ~exist(opto_file,'file')
    opto_processing;
end

loaded = load(opto_file);

results = loaded.results;
results_sham = loaded.results_sham;

%% Individual Rats
nBack = 3;
nRats = length(results.glm_fits);

for rat_i = 1:nRats
    for cond = {'control','reward','choice','both'}

        switch cond{1}
            case 'control'

                beta_cr = results.glm_fits(rat_i).beta_cr_cntrl;
                beta_co = results.glm_fits(rat_i).beta_co_cntrl;
                beta_uo = results.glm_fits(rat_i).beta_uo_cntrl;
                beta_ur = results.glm_fits(rat_i).beta_ur_cntrl;
            case 'reward'

                beta_cr = results.glm_fits(rat_i).beta_cr_rew;
                beta_co = results.glm_fits(rat_i).beta_co_rew;
                beta_uo = results.glm_fits(rat_i).beta_uo_rew;
                beta_ur = results.glm_fits(rat_i).beta_ur_rew;
            case 'choice'

                beta_cr = results.glm_fits(rat_i).beta_cr_ch;
                beta_co = results.glm_fits(rat_i).beta_co_ch;
                beta_uo = results.glm_fits(rat_i).beta_uo_ch;
                beta_ur = results.glm_fits(rat_i).beta_ur_ch;
            case 'both'

                beta_cr = results.glm_fits(rat_i).beta_cr_both;
                beta_co = results.glm_fits(rat_i).beta_co_both;
                beta_uo = results.glm_fits(rat_i).beta_uo_both;
                beta_ur = results.glm_fits(rat_i).beta_ur_both;
        end


        figure; hold on;
        line([0, nBack + 1], [0,0], 'color', 'k')

        plot(1:nBack, beta_cr, ...
            '-','Color',blue,...
            'LineWidth',3,'MarkerSize',15);
        plot(1:nBack, beta_co,...
            '-','Color', red,...
            'LineWidth',3,'MarkerSize',15);
        plot(1:nBack, beta_ur, ...
            '--','Color', blue,...
            'LineWidth',3,'MarkerSize',15);
        plot(1:nBack, beta_uo,...
            '--','Color', red,...
            'LineWidth',3,'MarkerSize',15);

        set(gca,'fontsize',20,'xtick',[0:1:5],'ytick',[-2,-1,0,1,2])
        xlabel('Trials Ago'); ylabel({'Same/Other','Regression Weight'})
        xlim([0.9,nBack+0.1]);
        ylim([-1.3, 3])
        set(gca,'Xdir','reverse')
        title(['Rat O', num2str(rat_i), ' ', cond{1}])
        box off
        
        drawnow
        print_svg(['fig5-s2/opto_rat_glm_', num2str(rat_i), '_', cond{1}])

    end
end



%% Summary plot: all opto rats
betas_cntrl = [nan(1, nRats);...
    [results.glm_fits.beta_cr_cntrl];...
    [results.glm_fits.beta_co_cntrl];...
    [results.glm_fits.beta_ur_cntrl];...
    [results.glm_fits.beta_uo_cntrl]]';

betas_rew = [nan(1, nRats);...
    [results.glm_fits.beta_cr_rew];...
    [results.glm_fits.beta_co_rew];...
    [results.glm_fits.beta_ur_rew];...
    [results.glm_fits.beta_uo_rew]]';

betas_ch = [nan(1, nRats);...
    [results.glm_fits.beta_cr_ch];...
    [results.glm_fits.beta_co_ch];...
    [results.glm_fits.beta_ur_ch];...
    [results.glm_fits.beta_uo_ch]]';

betas_both = [nan(1, nRats);...
    [results.glm_fits.beta_cr_both];...
    [results.glm_fits.beta_co_both];...
    [results.glm_fits.beta_ur_both];...
    [results.glm_fits.beta_uo_both]]';



plot_pretty_glms(betas_cntrl, nBack, true); title('Control')
print_svg('fig5-s2_all-rats-cntrl')

plot_pretty_glms(betas_rew, nBack, true); title('Reward')
print_svg('fig5-s2_all-rats-reward')

plot_pretty_glms(betas_ch, nBack, true); title('Choice')
print_svg('fig5-s2_all-rats-choice')

plot_pretty_glms(betas_both, nBack, true); title('Both')
print_svg('fig5-s2_all-rats-both')

