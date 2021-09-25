function genFun = getGenFun(modelName)

if ~ischar(modelName)
    warning('Model Name must be a string');
    return
end



switch modelName
    case 'mb'
        genFun = @(x,ratdata) generative_multiagent(0,x(1),0,x(2),0,0,0,0,ratdata);
    case 'mf'
        genFun = @(x,ratdata) generative_multiagent(x(1),0,x(2),0,0,0,0,0,ratdata);
    case 'mb_learn'
        genFun = @(x,ratdata) generative_modelBased_learning(x(1),x(2),x(3),ratdata);
    case 'mb_bias'
        genFun = @(x,ratdata) generative_multiagent(0,x(1),0,0,x(2),0,0,0,x(3),ratdata);
    case 'mb_bonus_bias'
        genFun = @(x,ratdata) generative_multiagent(0,x(1),0,0,x(2),x(3),0,0,0,ratdata);
    case 'mb_bonus_wsls_bias'
        genFun = @(x,ratdata) generative_multiagent(0,x(1),0,0,x(2),x(3),x(4),0,x(5),ratdata);
    case 'mb_mf_bonus'
        genFun = @(x,ratdata) generative_multiagent(x(1),0,x(2),x(3),x(4),x(5),0,0,0,ratdata);
    case 'mb_mf_trialwise'
        genFun = @(x,ratdata) generative_multiagent_trialwise(x(1),x(2),x(3),x(4),0,0,0,ratdata);
        case 'mb_mf_nontrialwise'
        genFun = @(x,ratdata) generative_multiagent_nontrialwise(x(1),x(2),x(3),x(4),0,0,0,ratdata);
    case 'mb_mf'
        genFun = @(x,ratdata) generative_multiagent(x(1),x(2),x(3),x(4),0,0,0,0,ratdata);
    case 'mixture'
        genFun = @(x,ratdata) generative_multiagent(0,x(1),0,0,x(2),x(3),x(4),0,x(5),ratdata);
    case 'mf_twoAlpha'
        genFun = @(x,ratdata) generative_mf_twoAlpha(x(1),x(2),x(3),ratdata);
     case 'mb_bonus_persev_bias'
        genFun = @(x,ratdata) generative_multiagent(0,x(1),0,x(2),x(3),0,x(4),x(5),ratdata);
        case 'mb_mf_bonus_persev_bias'
        genFun = @(x,ratdata) generative_multiagent(x(1),x(2),x(3),x(4),x(5),0,x(6),x(7),ratdata);
     case 'daw'
        genFun = @(x,ratdata) generative_Daw_trialwise_onechoice(x(1),x(2),x(3),x(4),x(5),x(6),x(7),ratdata);
         case 'tdL'
        genFun = @(x,ratdata) generative_tdL(x(1),x(2),x(3),x(4),x(5),ratdata);
    case 'mb_bonus_wsls_persev_bias'
        genFun = @(x,ratdata) generative_multiagent(0,x(1),0,0,x(2),x(3),x(4),x(5),x(6),ratdata);
    otherwise
        warning('Invalid Model Function');
        return
end

end