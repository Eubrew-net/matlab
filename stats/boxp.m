%boxplot con outliers
function [parm,out,idxout]=boxp(A,names,intc)
    if nargin<3
        intc=2;
    end
    [parm,out,idxout]=boxparams(A,intc);
    if nargin==1
     boxplotter(parm,out)
    else
      boxplotter(parm,out,names)
  end