function [m,s,outl,index]=outliers_bp(data,LIM)
%calcula la media y la sigma de los datos quitando los que estan fuera de 3s bo
%function [m,s,outl,index]=outliers_bp(data,LIM)
% 
index=[];
data=data(find(~isnan(data)));
if nargin==1
    LIM=2.5
end
[param,outl,index]=boxparams(data,LIM);


data(index)=[];
m=mean(data);
s=std(data);

function [params, outsideValues,index] = boxparams(x,LIM)
%  calculate boxplot parameters for data vector x
% LIM intercquartile range
%  function [params, outside_values] = boxparams(x)
%  params = [lowerAdjacentValue lowerQuartile med upperQuartile upperAdjacentValue];
%  output is used by boxplotter
% 
% Copyright (c) 1998 by Datatool
% $Revision: 1.00 $
%
%  get the quartiles
if nargin==1
    LIM=2.5
end
temp = quantile(x,[.25 .5 .75]);
lowerQuartile = temp(1);
med = temp(2);
upperQuartile = temp(3);
%  get adjacent values
interquartileRange = upperQuartile-lowerQuartile;
limit = upperQuartile+LIM*interquartileRange;
index = x<=limit;
upperAdjacentValue = max(x(index));
limit = lowerQuartile-LIM*interquartileRange;
index = x>=limit;
lowerAdjacentValue = min(x(index));
%  concatenate the parameters
params = [lowerAdjacentValue lowerQuartile med upperQuartile upperAdjacentValue];

%  get outside values
index = x>upperAdjacentValue|x<lowerAdjacentValue;
outsideValues = x(index);
outsideValues = outsideValues(:)';
index=find(index);