function standata = ratdata2standata(ratdata,inc)

    ratdata = remove_viols(ratdata);

    standata.pCong = 0.6*round(ratdata.p_congruent) + 0.2; % Round to exactly 0.2 or 0.8
    standata.nTrials = ratdata.nTrials;
    standata.choices = (ratdata.sides1=='l')+1;
    standata.outcomes = (ratdata.sides2=='l')+1;
    standata.commons = ratdata.trans_common;

    standata.rewards = ratdata.rewards;
    
    if exist('inc','var')
    
    standata.inc = inc;
    
    end
    
    if isfield(ratdata,'stim_type')
    standata.stims = 1*(ratdata.stim_type == 'r') + 2*(ratdata.stim_type == 'c') + 3*(ratdata.stim_type == 'b');
    standata.stims = [standata.stims;0];

    end
end