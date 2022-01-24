function genFun = getGenFun(modelName)

if ~ischar(modelName)
    warning('Model Name must be a string');
    return
end



switch modelName
     case 'mb_bonus_persev_bias'
        genFun = @(x,ratdata) generative_multiagent(x(1),x(2),x(3),x(4),x(5), x(6),ratdata);
    otherwise
        warning('Invalid Model Function');
        return
end

end