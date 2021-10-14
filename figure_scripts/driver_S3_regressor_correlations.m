loaded = load('behavioral_model_fits_physdata', 'phys_sessions_by_rat');


for rat_i = 1:6
[regressors, names] = construct_regressors_ephys(loaded.phys_sessions_by_rat(rat_i));
corrs(rat_i,:,:) = corrcoef(regressors).^2;
end

figure; imagesc(squeeze(mean(corrs)))
colorbar
caxis([0,1])
set(gca,'yticklabel', names)
axis square
