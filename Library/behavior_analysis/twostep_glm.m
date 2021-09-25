function results = twostep_glm(ratdata,nBack,doPlot)

if ~exist('doPlot','var')
    doPlot = true;
end

if ~exist('nBack','var')
    nBack = 5;
end

if isRatdata(ratdata)
    ratdata = remove_viols(ratdata);
    regs = construct_regressors_twostep(ratdata,nBack,'two');
    choices = ratdata.sides1 == 'r';
elseif isHumdata(ratdata)
    regs = construct_regressors_human(ratdata,nBack);
    choices = ratdata.choice1 == 2;
    ratdata.ratname = 'Human Subj';
else
    warning('Unknown data type. Unable to run Twostep GLM')
     fail_gracefully
     return
end

if nansum(regs) == 0 % If there's a problem with regs - this usually means the ratdata is an empty ratdata
    % Fail gracefully
    fail_gracefully
    return
end

[B,dev,stats] = glmfit(regs,choices,'binomial');
stats.dev = dev;


pFitted = glmval(B,regs,'logit');
liks = pFitted;
liks(~choices) = 1-liks(~choices);

if doPlot

figure; hold on;
line([0, nBack + 1], [0,0], 'color', 'k')
inds = 2:(1+nBack);
errorbar(1:nBack,B(inds),stats.se(inds),'.-','Color',[0,50,190]/255,'LineWidth',3,'MarkerSize',15); hold on;
inds = (2+nBack):2*nBack+1;
errorbar(1:nBack,B(inds),stats.se(inds),'.-','Color',[192,0,0]/255,'LineWidth',3,'MarkerSize',15);
inds = (2*nBack+2):3*nBack+1;
errorbar(1:nBack,B(inds),stats.se(inds),'.--','Color',[0,50,190]/255,'LineWidth',3,'MarkerSize',15);
inds = (3*nBack+2):4*nBack+1;
errorbar(1:nBack,B(inds),stats.se(inds),'.--','Color',[192,0,0]/255,'LineWidth',3,'MarkerSize',15);
%errorbar(nBack+1,B(1),stats.se(1),'k.','LineWidth',2,'MarkerSize',15);
set(gca,'FontSize',14)
legend({'Common - Rewarded','Common - Unrewarded','Uncommon - Rewarded','Uncommon - Unrewarded','Bias'},'Fontsize',17);
title([ratdata.ratname],'Fontsize',16);
ylabel('Regression Weights','Fontsize',20);
xlabel('Trials Ago','Fontsize',20);
xlim([0.9,nBack+0.1]);

end

LL = sum(log(liks));


% Get MF, MB indeces
com_rew = B(2:nBack+1);
com_unr = B(nBack+2:2*nBack+1);
unc_rew = B(2*nBack+2:3*nBack+1);
unc_unr = B(3*nBack+2:4*nBack+1);

results.mb_ind = sum(com_rew) - sum(com_unr) + sum(unc_unr) - sum(unc_rew);
results.mf_ind = sum(com_rew) - sum(com_unr) - sum(unc_unr) + sum(unc_rew);
results.persev_ind = sum(com_rew) + sum(com_unr) + sum(unc_unr) + sum(unc_rew);
results.csus_ind = sum(com_rew) + sum(com_unr) - sum(unc_unr) - sum(unc_rew);


results.mb_ind1 = com_rew(1) - com_unr(1) + unc_unr(1) - unc_rew(1);
results.mf_ind1 = com_rew(1) - com_unr(1) - unc_unr(1) + unc_rew(1);
results.persev_ind1 = com_rew(1) + com_unr(1) + unc_unr(1) + unc_rew(1);
results.csus_ind1 = com_rew(1) + com_unr(1) - unc_unr(1) - unc_rew(1);


results.betas = B;
results.nBack = nBack;
results.liks = liks;
results.LL = LL;
results.bic = LL - (1/2)*sum(B~=0)*log(length(liks));
results.llpt =  LL / length(liks);
results.normLik = exp(results.llpt);
results.nFreeParams = sum(B~=0);
results.fit = results;

    function fail_gracefully
        
        
    warning('Problem running the twostep glm');
    results.mb_ind = NaN;
    results.mf_ind = NaN;
    results.persev_ind = NaN;
    results.csus_ind = NaN;
    results.betas = NaN;
    results.nBack = nBack;
    results.liks = NaN;
    results.LL = NaN;
    results.llpt = NaN;
    results.bic = NaN;
    
    
    end

end