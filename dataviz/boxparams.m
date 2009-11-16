function [params, outsideValues,index] = boxparams(x,intc)
%  calculate boxplot parameters for data vector x
%  function [params, outside_values,index] = boxparams(x,intc)
%  params = [lowerAdjacentValue lowerQuartile med upperQuartile upperAdjacentValue];
%  output is used by boxplotter
%  added index of outliers
%  added  intecuartile range default 2
% Copyright (c) 1998 by Datatool
% $Revision: 1.00 $

%  get the quartiles
if nargin==1
    intc=2;
end

temp = quantile(x,[.25 .5 .75]);
lowerQuartile = temp(1);
med = temp(2);
upperQuartile = temp(3);
%  get adjacent values
interquartileRange = upperQuartile-lowerQuartile;
limit = upperQuartile+intc*interquartileRange;
index = x<=limit;
upperAdjacentValue = max(x(index));
limit = lowerQuartile-intc*interquartileRange;
index = x>=limit;
lowerAdjacentValue = min(x(index));
%  concatenate the parameters
params = [lowerAdjacentValue lowerQuartile med upperQuartile upperAdjacentValue];

%  get outside values
index = x>upperAdjacentValue|x<lowerAdjacentValue;
outsideValues = x(index);
outsideValues = outsideValues(:)';
index=find(index);