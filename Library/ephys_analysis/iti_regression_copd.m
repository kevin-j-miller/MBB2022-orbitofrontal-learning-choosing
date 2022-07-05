function results = iti_regression_copd(spike_counts, regressors, family)

if ~exist('model','var')
    family = 'poisson';
end

nBins = size(spike_counts,2);
nRegs = size(regressors,2);

% Set up a very broad chain of regularizers to try
lambdas = [0, 1e-10, 1e-9, 1e-8, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 1e-3, 1e-2, 1e-1, 1];

[weights,dev_full] = do_regression(regressors, spike_counts);

for leave_out_i = 1:nRegs
    
    regressors_leftOut = regressors; regressors_leftOut(:,leave_out_i) = [];
    [~,devs_leftOut(leave_out_i,:)] = do_regression(regressors_leftOut,spike_counts);
    
end

for bin_i = 1:nBins
    for reg_i = 1:nRegs
        copd_sub = 100*(devs_leftOut(reg_i,bin_i) - dev_full(bin_i)) / devs_leftOut(reg_i, bin_i);
        copd(bin_i,reg_i) = copd_sub;
    end
end

results.sse_full = dev_full;
results.sse_leftOut = devs_leftOut;
results.copd = copd;
results.weights = weights;

    function [weights, devs] = do_regression(regressors, spike_counts)
        
        xs = [ones(size(regressors,1),1), regressors]; % add offset regressor
        
        weights = zeros(nBins, size(regressors,2) + 1); % preallocate weights
        devs = zeros(nBins,1); % preallocate deviances
        
        for bin_i2 = 1:nBins
            
            ys = spike_counts(:,bin_i2);
            
            % If there's not even a single spike, glmnet will fail in its
            % mex file and crash Matlab. Head this off here.
            if all(ys == 0)
                weights(bin_i2,:) = 0; % All weights should be zero
                devs(bin_i2) = 0; % Deviance is zero
                continue
            end
            
            % Set up glmnet options. Pick our lambdas manually to be sure of a broad range
            options = glmnetSet(); options.lambda = lambdas;
            % Do the fit with glmnet.
            fit = glmnet(xs, ys, family, options);
            
            dev_by_lambda = (1-fit.dev) * fit.nulldev;
            [best_dev, best_ind] = min(dev_by_lambda);
            
            % Record weights and devs
            weights(bin_i2,:) = fit.beta(:,best_ind);
            devs(bin_i2,:) = best_dev;
            
        end
        
    end

end