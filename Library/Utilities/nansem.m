function stderr = nansem(vector,dim)
% Returns the standard error of the vector

if ~exist('dim','var')
    [~, dim] = max(size(vector));
end

if size(vector,1) > 1
    N = size(vector,1);
else
    N = length(vector);
end

stderr = nanstd(vector,0,dim) / sqrt(N);

end