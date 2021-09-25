function y = sem(x,varargin)
% Returns the standard error of the vector

% function y = sem(x,varargin)
% 
% function simply returns standard error of the mean
%
% INPUTS:
% x           vector or 2D-matrix containing single or double precision numbers
% varargin    if x is a matrix:
%             scalar specifying the dimension over which the SEM should be computed
% 
% History:
% Feb 2013    now automatically computes std over correct dimension for vectors
% Sep 2012    added some functionality from the function ste, available on File Exchange
%             varargin now should be an integer specifying the dimension over which the SD should be computed
% 
% Maik C. Stttgen, October 2011
%% input check
if numel(size(x))>2
  error('sorry, code only applicable for vectors and 2D matrices')
end
%% the works
if isempty(x)
    y = NaN;
    return
end

if isvector(x)
  y = nanstd(x)/sqrt(sum(~isnan(x)));
else
  if nargin<2
    y = nanstd(x,0,1)./sqrt(sum(~isnan(x)));
  else
    y = nanstd(x,0,varargin{1})./sqrt(sum(~isnan(x),varargin{1}));
  end
end  