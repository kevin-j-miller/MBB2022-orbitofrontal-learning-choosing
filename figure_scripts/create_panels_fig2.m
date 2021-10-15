sse = load(fullfile(files_path, 'postprocessed_data', 'ofc_SSEs.mat'));
p = load('permuted_p_values.mat');
dataset = load(fullfile(files_path, 'postprocessed_data', 'ofc_celldatas_ensemble'));


celldatas = dataset.celldatas;
celldatas = celldatas(~p.exclude_cell);
ensemble = dataset.spike_ensemble;
ensemble{1} = ensemble{1}(~sse.bad_glm, :,:);
ensemble{2} = ensemble{2}(~sse.bad_glm, :,:);
ensemble{3} = ensemble{3}(~sse.bad_glm, :,:);
ensemble{4} = ensemble{4}(~sse.bad_glm, :,:);
clear dataset;

save_path = [pwd,'\figures_raw\'];

%% Compute CPD timecourses for each unit
sse_leftout = sse.sse_leftout; %(:,~p.exclude_cell);
sse_full = sse.sse_full_all; %(:,~p.exclude_cell);
nRegs = 10;
nCells = length(sse_full);

for cell_i = 1:nCells
    for lock_i = 1:4
        
        cpd_timecourse{lock_i, cell_i} = 100*(sse_leftout{lock_i, cell_i} - repmat(sse_full{lock_i, cell_i}', [nRegs, 1])) ...
            ./ sse_leftout{lock_i, cell_i};
        
    end
end


%% Example Cells
% Example outcome value coding
example_ov = 16;
cpd_cell = cpd_timecourse{2, example_ov}';
plot_cpd_demo_outcome(celldatas(example_ov), cpd_cell, sse.bin_mids_by_lock{2});
print_svg('fig2_example_cell_ov')

% Example choice-value difference coding
example_cvd = 114;
cpd_cell = cpd_timecourse{3, example_cvd}';
plot_cpd_demo_choice(celldatas(example_cvd), cpd_cell, sse.bin_mids_by_lock{3});
print_svg('fig2_example_cell_cvd')

% Example chosen value
example_chv = 29;
cpd_cell = cpd_timecourse{4, example_chv}';
plot_cpd_demo_chosen(celldatas(example_chv), cpd_cell, sse.bin_mids_by_lock{4});
print_svg('fig2_example_cell_chv')


