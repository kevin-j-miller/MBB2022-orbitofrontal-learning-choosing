function params = fit_stan_model(standata, modelname)

% Stop fitting when at least criterion fits are within epsilon normalized
% likelihood of the best fit
criterion = 3;
epsilon = 0.0001;

done = false;
fit_i = 1;
while ~done
    try
        if ~exist('working_dirs','dir')
            mkdir('working_dirs')
        end
        working_dir = ['working_dirs/stan_working_dir_' datestr(now,'YYYYMMDD_hhmmss_FFF')];
        mkdir(working_dir);
        
        fit = stan('file', modelname, 'data', standata, 'working_dir', working_dir, 'verbose', true, 'method', 'optimize');
        fit.block;
    catch err
        fprintf([err.identifier, '\n', err.message,'\n']);
    end
    
    params_fit = fit.extract;
    
    if ~isempty(params_fit)
        params_all_fits(fit_i) = params_fit;
        normLik_fit = exp(params_fit.log_probs / standata.nTrials);
        normLiks_fit(fit_i) = normLik_fit;
        best_normLik = max(normLiks_fit);
        done = sum(abs(normLiks_fit - best_normLik) < epsilon) >= criterion || length(normLiks_fit) > 30;
        fit_i = fit_i + 1;
    end
    
end

[normLik_best, best_ind] = max(normLiks_fit);
params = params_all_fits(best_ind);
params.normLik = normLik_best;

end