function modelData = generate_simulated_data(modelName, modelParams, task, sigma, pForced, trialsPerDay)

if isnumeric(task) % We need to generate our own series of probabilities and trial types
    nTrials = task;
    if ~exist('sigma','var')
        sigma = 0.05;
    end
    if ~exist('pForced','var')
    pForced = 0.2;
    end
    
    task = generate_trials(nTrials,sigma,pForced, trialsPerDay);
    
elseif ~isstruct(task) % We're running the generative model on a supplied train of probabilities and trial types
    error('Please supply a task struct or a number of trials');
end

genFun = getGenFun(modelName);

modelData = feval(genFun,modelParams,task);

modelData.modelName = modelName;
modelData.params = modelParams;
modelData.p_congruent = task.p_congruent;
modelData.nTrials = task.nTrials;
modelData.trans_common = (modelData.p_congruent > 0.5 & modelData.sides1 == modelData.sides2) | (modelData.p_congruent < 0.5 & modelData.sides1 ~= modelData.sides2);

end