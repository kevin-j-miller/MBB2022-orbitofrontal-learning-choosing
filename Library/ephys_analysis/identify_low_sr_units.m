dataset = load('ofc_ephys_preprocessed');
celldatas = dataset.celldatas;
ensemble = dataset.ensemble;

for cell_i = 1:length(celldatas)
for lock_i = 1:4
lowest_fr_lock(lock_i) = min(squeeze(nanmean(ensemble{lock_i}(cell_i,:,:),2))) * 5;
end
lowest_fr(cell_i) = min(lowest_fr_lock);
end

low_fr = lowest_fr < 1.2;
sum(~low_fr)
save('low_fr.mat', 'low_fr');