function s = logmeanexp(x, dim)
% Returns log(sum(exp(x),dim)) while avoiding numerical underflow.
% Default is dim = 1 (columns).
% Written by Mo Chen (mochen@ie.cuhk.edu.hk). March 2009.
% Edited by Kevin Miller Jan 2013 to check if log(sum(exp())) would be an
% acceptable solution, since it's faster

if nargin == 1, 
    % Determine which dimension sum will use
    dim = find(size(x)~=1,1);
    if isempty(dim), dim = 1; end
end

 if all(sum(abs(x) > 10^-10)) && all(sum(abs(x)) < 10^5)
     s = log(sum(exp(x),dim));
 else
     
    
     % subtract the largest in each column
 [y, i] = max(x,[],dim);
 dims = ones(1,ndims(x));
 dims(dim) = size(x,dim);
 x = x - repmat(y, dims);
 s = y + log(mean(exp(x),dim));
 i = find(~isfinite(y));
 if ~isempty(i)
   s(i) = y(i);
 end
    
end
end