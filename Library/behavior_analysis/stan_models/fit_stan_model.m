function params = fit_stan_model(standata)

model_file = fullfile(code_path, 'library', 'behavior_analysis','stan_models','multiagent_model_single.stan');


% Stop fitting when at least criterion fits are within epsilon normalized
% likelihood of the best fit
criterion = 3;
epsilon = 0.0001;

done = false;
tries = 0;
fit_i = 1;
while ~done
    tries = tries + 1;
    
    
    if tries > 20 && fit_i ==1
        error('Unable to fit model. Tried 20 times and received an error each time')
    end
    
    
    try
        
    pause(rand); % Pause for random fraction of a second to make extra sure we're not in the same millisecond as another process
    wd = ['working_folders/',datestr(now,'yyyymmdd_HHMMSSFFF')];
    mkdir(wd);
        
<<<<<<< HEAD
        fit = stan('file', model_file, 'data', standata, 'working_dir', wd, 'verbose', false, 'method', 'optimize');
=======
        fit = stan('file', modelname, 'data', standata, 'working_dir', working_dir, 'verbose', true, 'method', 'optimize');
>>>>>>> d2723f57b452bf30aa463f9500af6d421d486df9
        fit.block;
        
        rmdir(wd,'s')
        
        params_fit = fit.extract;
        
        if ~isempty(params_fit)
            params_all_fits(fit_i) = params_fit;
            normLik_fit = exp(params_fit.log_probs / standata.nTrials);
            normLiks_fit(fit_i) = normLik_fit;
            best_normLik = max(normLiks_fit);
            done = sum(abs(normLiks_fit - best_normLik) < epsilon) >= criterion || length(normLiks_fit) > 30;
            fit_i = fit_i + 1;
        end
        
    catch err
        fprintf([err.identifier, '\n', err.message,'\n']);
        if exist(wd, 'file')
        rmdir(working_dir,'s')
        end
    end
    
end


[normLik_best, best_ind] = max(normLiks_fit);
params = params_all_fits(best_ind);
params.normLik = normLik_best;

end