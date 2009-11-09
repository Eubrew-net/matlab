function [sls,slm,slt]=sltemp_l(path,config);
[path_,files]=fileparts(path);
filenames=dir(path)
sls=[];
slm=[];
slt=[];
for i=1: size(filenames,1) 
  file=filenames(i).name
  try
  if nargin>1    
   [sls_,slm_,slt_]=sl_2002(fullfile(path_,file),config);
  else
   [sls_,slm_,slt_]=sl_2002(fullfile(path_,file));
  end
  sls=[sls;sls_];
  slm=[slm;slm_];
  slt=[slt;slt_];
  catch
    l=lasterror;
    disp(l.message);
end

end  



try
    for i=1:5
        [parm,out,idxout]=boxp(slt(:,5+i));
        slt(idxout,:)=[];
    end

    hp=plotyy(slt(:,1),slt(:,6:end-2),slt(:,1),slt(:,4));
    datetick(hp(1));
    datetick(hp(2));
    
    figure;
    plot(slt(:,4),slt(:,6:end-2),'.');
    [h,t]=rline
catch
    disp('error');
end