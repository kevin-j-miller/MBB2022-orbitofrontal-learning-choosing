%% Load processed data

opto_file = fullfile(files_path, 'postprocessed_data', 'opto_results_glm.mat');

if ~exist(opto_file,'file')
    opto_processing;
end

loaded = load(opto_file);

results = loaded.results;
results_sham = loaded.results_sham;



%% Indices on control trials

jit = 0.1;
offset = 0.15;

figure; hold on
line([0,5],[0,0],'color',[0,0,0])

% Opto rats
nRats = length(results.mb_cntrl);
jitter = (0:jit/(nRats-1):jit) - jit/2;

xs = repmat((1:4)',[1,nRats]) + repmat(jitter,[4,1]) - offset;
ys = [results.mb_cntrl; results.pers_cntrl; results.np_cntrl; results.mf_cntrl];

o = scatter(xs,ys,...
    100, 'V', ...
    'markerfacecolor',lighten(grey, 0.6),...
    'markeredgecolor','none');

% Sham rats
nRats = length(results_sham.mb_cntrl);
jitter = (0:jit/(nRats-1):jit) - jit/2;

xs = repmat((1:4)',[1,nRats]) + repmat(jitter,[4,1]) + offset;
ys = [results_sham.mb_cntrl; results_sham.pers_cntrl; results_sham.np_cntrl; results_sham.mf_cntrl];

s = scatter(xs,ys,...
    100, 'd',...
    'markerfacecolor',lighten(grey, 0.6),...
    'markeredgecolor','none');

xlim([0.5, 4.5])
set(gca,'fontsize',14)
xlabel('')
title('Behavioral Indices: Control Trials')
ylabel('Index Value')
set(gca, 'fontsize', 20, ...
    'xticklabel', {'Planning', 'Stay', 'Common-Stay/Uncommon-Switch', 'Win-Stay/Lose-Switch'}, ...
    'xtick', 1:4, ...
    'ytick', [-2, 0, 2, 4, 6, 8])
set(gcf, 'pos', [500, 200, 700, 600])

legend([o(1), s(1)], {'Optogenetics Rats','Sham Rats'})

print_svg('fig5-1_cntrl-trial-indices')

%% Effect of opto on indices

% Effects to plot. Each element is a particular plot
rew_effects = {results.mb_rew - results.mb_cntrl,...
    results.pers_rew - results.pers_cntrl,...
    results.mf_rew - results.mf_cntrl,...
    results.np_rew - results.np_cntrl};
ch_effects = {results.mb_ch - results.mb_cntrl,...
    results.pers_ch - results.pers_cntrl,...
    results.mf_ch - results.mf_cntrl,...
    results.np_ch - results.np_cntrl};
both_effects = {results.mb_both - results.mb_cntrl,...
    results.pers_both - results.pers_cntrl,...
    results.mf_both - results.mf_cntrl,...
    results.np_both - results.np_cntrl};

rew_effects_sham = {results_sham.mb_rew - results_sham.mb_cntrl,...
    results_sham.pers_rew - results_sham.pers_cntrl,...
    results_sham.mf_rew - results_sham.mf_cntrl,...
    results_sham.np_rew - results_sham.np_cntrl};
ch_effects_sham = {results_sham.mb_ch - results_sham.mb_cntrl,...
    results_sham.pers_ch - results_sham.pers_cntrl,...
    results_sham.mf_ch - results_sham.mf_cntrl,...
    results_sham.np_ch - results_sham.np_cntrl};
both_effects_sham = {results_sham.mb_both - results_sham.mb_cntrl,...
    results_sham.pers_both - results_sham.pers_cntrl,...
    results_sham.mf_both - results_sham.mf_cntrl,...
    results_sham.np_both - results_sham.np_cntrl};

texts = {'Planning Index',...
    'Stay Index',...
    'Win-Stay/Lose-Switch Index',...
    'Common-Stay/Uncommon-Switch Index'};

% Jitter and offset to control plotting position
jit = 0.1;
offset = 0.2;
ylims = [-2.1, 2.1];

colors = {rew_color; ch_color; both_color};

for plot_i = 1:4
    rew_effect = rew_effects{plot_i};
    ch_effect = ch_effects{plot_i};
    both_effect = both_effects{plot_i};

    rew_effect_sham = rew_effects_sham{plot_i};
    ch_effect_sham = ch_effects_sham{plot_i};
    both_effect_sham = both_effects_sham{plot_i};



    figure; hold on;
    line([0,4],[0,0],'color',[0,0,0])

    % Add opto rats
    nRats = length(rew_effect);
    jitter = (0:jit/(nRats-1):jit) - jit/2;
    xs = repmat((1:3)',[1,nRats]) + repmat(jitter,[3,1]) - offset;
    ys = [rew_effect; ch_effect; both_effect;];


    for x_i = 1:3
        scatter(xs(x_i,:),ys(x_i,:),100,'V','markerfacecolor',lighten(colors{x_i},0.6),'markeredgecolor','none');
        errorbar([0,x_i-offset,4],[0,mean(ys(x_i,:)),0],[0,sem(ys(x_i,:)),0],'.','color',colors{x_i},'linewidth',5); % Padding to equal out errorbar tab lengths
        p = signrank(ys(x_i,:));
        %text(x_i - 0.3, 1.9,num2str(p,'%0.3f'))
    end

    % Add control rats
    nRats = length(rew_effect_sham);
    jitter = (0:jit/(nRats-1):jit) - jit/2;
    xs = repmat((1:3)',[1,nRats]) + repmat(jitter,[3,1]) + offset;
    ys = [rew_effect_sham; ch_effect_sham; both_effect_sham];


    for x_i = 1:3
        scatter(xs(x_i,:),...
            ys(x_i,:),...
            100,'d',...
            'markerfacecolor', lighten(grey, 0.6),...
            'markeredgecolor','none');
        errorbar([0,x_i+offset,4],...
            [0,mean(ys(x_i,:)),0],...
            [0,sem(ys(x_i,:)),0],...
            '.','color', grey,...
            'linewidth',5); % Padding to equal out errorbar tab lengths
        p = signrank(ys(x_i,:));
        %text(x_i + 0.2, 1.9, num2str(p,'%0.3f'))
    end

    % Add opto-sham ps
    p_rew_over_sham = ranksum(rew_effect,rew_effect_sham);
    p_ch_over_sham = ranksum(ch_effect,ch_effect_sham);
    p_both_over_sham = ranksum(both_effect,both_effect_sham);

    text(1, 2.1, num2str(p_rew_over_sham,'%0.3f'), 'FontName','Calibri')
    text(2, 2.1, num2str(p_ch_over_sham,'%0.3f'), 'FontName','Calibri')
    text(3, 2.1, num2str(p_both_over_sham,'%0.3f'), 'FontName','Calibri')

    % Final figure formatting
    set(gca,'fontsize',14,...
        'xtick',1:3,'xticklabel',{'Inactivate at Reward','Inactivate at Choice','Inactivate at Both'},...
        'ytick',[-2,-1,0,1,2]);
    ylim(ylims); xlim([0.5,3.5])
    title(texts{plot_i})
    ylabel({'Change in Index Value', '(Inactivation - Control)'})

    print_svg(['fig5-1_indices-', num2str(plot_i)])

end
