
%% Load Data
ephys_regression_results = load(fullfile(files_path, 'postprocessed_data', 'ephys_regression_results'));
dataset = load(fullfile(files_path, 'postprocessed_data', 'ofc_celldatas_ensemble'));

celldatas = dataset.celldatas;
ensemble = dataset.spike_ensemble;
ensemble{1} = ensemble{1}(~ephys_regression_results.bad_glm, :,:);
ensemble{2} = ensemble{2}(~ephys_regression_results.bad_glm, :,:);
ensemble{3} = ensemble{3}(~ephys_regression_results.bad_glm, :,:);
ensemble{4} = ensemble{4}(~ephys_regression_results.bad_glm, :,:);
clear dataset;

nCells = length(celldatas);

%% Compute CPD timecourses for each unit
sse_leftout = ephys_regression_results.sse_leftout;
sse_full = ephys_regression_results.sse_full_all;
nRegs = 10;

for cell_i = 1:nCells
    for lock_i = 1:4
        
        cpd_timecourse{lock_i, cell_i} = 100*(sse_leftout{lock_i, cell_i} - repmat(sse_full{lock_i, cell_i}', [nRegs, 1])) ...
            ./ sse_leftout{lock_i, cell_i};
    end
end


%% Example Cells
% Example outcome value coding
example_ov = 49; 
cpd_cell = cpd_timecourse{2, example_ov}';
plot_cpd_demo_outcome(celldatas(example_ov), cpd_cell, ephys_regression_results.bin_mids_by_lock{2});
print_svg('fig3_example_cell_outcome')

% Example choice-value difference coding
example_cvd = 242;
cpd_cell = cpd_timecourse{3, example_cvd}';
plot_cpd_demo_choice(celldatas(example_cvd), cpd_cell, ephys_regression_results.bin_mids_by_lock{3});
print_svg('fig3_example_cell_choice')

% Example chosen value
example_chv = 78;
cpd_cell = cpd_timecourse{4, example_chv}';
plot_cpd_demo_chosen(celldatas(example_chv), cpd_cell, ephys_regression_results.bin_mids_by_lock{4});
print_svg('fig3_example_cell_chosen')



%% Plot all cells
% Sanity check the plots and help find examples

parfor cell_i = 101:nCells
    
    % Outcome Value @ S2
    cpd_bins = ephys_regression_results.bin_mids_by_lock{2};
    cpd_cell = cpd_timecourse{2, cell_i}';
    plot_cpd_demo_outcome(celldatas(cell_i), cpd_cell, cpd_bins);
    print_png(['fig3-all-units/outcome_', num2str(cell_i)])
    
    % Choice Value @ C1
    cpd_bins = ephys_regression_results.bin_mids_by_lock{3};
    cpd_cell = cpd_timecourse{3, cell_i}';
    plot_cpd_demo_choice(celldatas(cell_i), cpd_cell, cpd_bins);
    print_png(['fig3-all-units/choice_', num2str(cell_i)])

    % Chosen Value @ S1
    cpd_bins = ephys_regression_results.bin_mids_by_lock{4};
    cpd_cell = cpd_timecourse{4, cell_i}';
    plot_cpd_demo_chosen(celldatas(cell_i), cpd_cell, cpd_bins);
    print_png(['fig3-all-units/chosen_', num2str(cell_i)])

end