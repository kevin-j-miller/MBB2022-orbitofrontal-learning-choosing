sse = load('ofc_SSEs.mat');
p = load('permuted_p_values.mat');

dataset = load('ofc_ephys_preprocessed');
celldatas = dataset.celldatas;
celldatas = celldatas(~p.exclude_cell);
ensemble = dataset.ensemble;
ensemble{1} = ensemble{1}(~sse.bad_glm, :,:);
ensemble{2} = ensemble{2}(~sse.bad_glm, :,:);
ensemble{3} = ensemble{3}(~sse.bad_glm, :,:);
ensemble{4} = ensemble{4}(~sse.bad_glm, :,:);
clear dataset;

save_path = [pwd,'\figures_raw\'];

%% Example Cells
% Example outcome value coding
example_ov = 16;
cpd_cell = cpd_timecourse{2, example_ov}';
fig = plot_cpd_demo_outcome(celldatas(example_ov), cpd_cell, sse.bin_mids_by_lock{2});
print(fig, [save_path,'\example_cell_ov.svg'],'-dsvg')

% Example choice-value difference coding
example_cvd = 114;
cpd_cell = cpd_timecourse{3, example_cvd}';
fig = plot_cpd_demo_choice(celldatas(example_cvd), cpd_cell, sse.bin_mids_by_lock{3});
print(fig, [save_path,'\example_cell_cvd.svg'],'-dsvg')

% Example chosen value
example_chv = 29;
cpd_cell = cpd_timecourse{4, example_chv}';
fig = plot_cpd_demo_chosen(celldatas(example_chv), cpd_cell, sse.bin_mids_by_lock{4});
print(fig, [save_path,'\example_cell_chv.svg'],'-dsvg')


%% Compute CPD timecourses for each unit
sse_leftout = sse.sse_leftout(:,~p.exclude_cell);
sse_full = sse.sse_full_all(:,~p.exclude_cell);
nRegs = 10;

for cell_i = 1:nCells
    for lock_i = 1:4
        
        cpd_timecourse{lock_i, cell_i} = 100*(sse_leftout{lock_i, cell_i} - repmat(sse_full{lock_i, cell_i}', [nRegs, 1])) ...
            ./ sse_leftout{lock_i, cell_i};
        
        
    end
    beauty_score_ov(cell_i) = mean(cpd_timecourse{2, cell_i}(8,:));
    beauty_score_cvd(cell_i) = mean(cpd_timecourse{3, cell_i}(4, (abs(sse.bin_mids_by_lock{3}) < 1)));
    beauty_score_chv(cell_i) = mean(cpd_timecourse{4, cell_i}(10,(abs(sse.bin_mids_by_lock{4}) < 1)));
end

%% Plot all cells, to sanity check the plots and find examples

% Outcome Value @ S2
[~, sorted_cells_ov] = sort(-1*beauty_score_ov); %p.p_entry(2, ~p.exclude_cell, 8)); %-1*beauty_score_ov);
celldatas_reordered_ov = celldatas(sorted_cells_ov); % Reorder thm outside the parfor, so that each parallel job can tak only the data it needs

% Choice Value @ S2
[s, sorted_cells_cvd] = sort(-1*beauty_score_cvd); %sort(p.p_entry(lock_i,:,reg_i));
celldatas_reordered_cvd = celldatas(sorted_cells_cvd);

% Chosen Value @ S1
[~, sorted_cells_chv] = sort(-1*beauty_score_chv);
celldatas_reordered_chv = celldatas(sorted_cells_chv);

cpd_bins = sse.bin_mids_by_lock{2};
parfor p_i = 1:nCells
    
    cpd_cell = cpd_timecourse{2, sorted_cells_ov(p_i)}';
    figs = plot_cpd_demo_outcome(celldatas_reordered_ov(p_i), cpd_cell, cpd_bins);
    
    figure(figs(1));
    print([save_path,'\psths_ordered_ov\example_cells_ov_', num2str(p_i), '.png'],'-dpng')
    
    close(figs);
    
end

cpd_bins = sse.bin_mids_by_lock{3};
parfor p_i = 1:10
    
    cpd_cell = cpd_timecourse{3, sorted_cells_cvd(p_i)}';
    figs = plot_cpd_demo_choice(celldatas_reordered_cvd(p_i), cpd_cell, cpd_bins);
    
    xlim([-1,1]);
    print([save_path,'\psths_ordered_cvd\example_cells_cvd_', num2str(p_i), '.png'],'-dpng')
    close(figs(1))
end

cpd_bins = sse.bin_mids_by_lock{4};
parfor p_i = 1:nCells
    
    cpd_cell = cpd_timecourse{4, sorted_cells_chv(p_i)}';
    figs = plot_cpd_demo_chosen(celldatas_reordered_chv(p_i), cpd_cell, cpd_bins);    
    print([save_path,'\psths_ordered_chv\example_cells_chv_', num2str(p_i), '.png'],'-dpng')
    close(figs(1));
    
end