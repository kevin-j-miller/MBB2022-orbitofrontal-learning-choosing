function regressors = construct_regressors_twostep(data,nBack,type)

% Makes regressors for a GLM on choice, transition, and outcome
% Fits 4n+1 parameters

if ~exist('nBack','var')
nBack = 5; % How many trials into the past to look
end

if nBack==0
regressors = [];
return
end

% Placeholder regressors.  Convention is side (Left/Right), transision
% (Congruent/Incongruent), outcome (Reward/Unreward)
reg_lcu = zeros(1,nBack);
reg_lcr = zeros(1,nBack);
reg_liu = zeros(1,nBack);
reg_lir = zeros(1,nBack);
reg_rcu = zeros(1,nBack);
reg_rcr = zeros(1,nBack);
reg_riu = zeros(1,nBack);
reg_rir = zeros(1,nBack);


% Remove violation trials

data = remove_viols(data);


nChoices = length(data.sides1);
%congruent_task = data.p_congruent > 0.5;

regressors = zeros(nChoices,4*nBack);



for choice_i = 1:nChoices
    choice = data.sides1(choice_i);

    transition = data.trans_common(choice_i);
    outcome = data.rewards(choice_i);

    % populate the regressors
    reg_cu = reg_rcu - reg_lcu;
    reg_cr = reg_rcr - reg_lcr;
    reg_iu = reg_riu - reg_liu;
    reg_ir = reg_rir - reg_lir;
    
    regressors(choice_i,:) = [reg_cr,reg_cu,reg_ir,reg_iu];
    
    % Zero all the flags
    lcu = 0;
    lcr = 0;
    liu = 0;
    lir = 0;
    rcu = 0;
    rcr = 0;
    riu = 0;
    rir = 0;
    
    if choice == 'l' % Went left
        if transition == 1 % Common
            if outcome % Rewarded
                lcr = 1;
            else
                lcu = 1;
            end
        else %incongruent
            if outcome
                lir = 1;
            else
                liu = 1;
            end
        end
    else % Went right
        if transition == 1 % Uncommon
            if outcome % Rewarded
                rcr = 1;
            else
                rcu = 1;
            end
        else %incongruent
            if outcome
                rir = 1;
            else
                riu = 1;
            end
        end
    end
    
    reg_lcu = [lcu,reg_lcu(1:end-1)];
    reg_lcr = [lcr,reg_lcr(1:end-1)];
    reg_liu = [liu,reg_liu(1:end-1)];
    reg_lir = [lir,reg_lir(1:end-1)];
    reg_rcu = [rcu,reg_rcu(1:end-1)];
    reg_rcr = [rcr,reg_rcr(1:end-1)];
    reg_riu = [riu,reg_riu(1:end-1)];
    reg_rir = [rir,reg_rir(1:end-1)];

end