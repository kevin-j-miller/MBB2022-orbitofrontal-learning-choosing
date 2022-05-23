loaded = load(fullfile(files_path, 'postprocessed_data','behavioral_model_fits'));

for rat_i = 1:6
[regressors, names] = construct_regressors_ephys(loaded.ratdatas(rat_i));
corrs(rat_i,:,:) = corrcoef(regressors).^2;
end

figure; imagesc(squeeze(mean(corrs)))
colorbar
caxis([0,1])
set(gca,'yticklabel', names)
axis square

print_svg('Fig3-s2_regressor-correlations')