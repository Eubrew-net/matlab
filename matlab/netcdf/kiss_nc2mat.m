function out=kiss_nc2mat(m)
%%% This function is to read/convert the netcdf data into matlab format
finfo=ncinfo(m);
var_no=length(finfo.Variables); %%% No. of varibilies
for i=1:var_no
    var=finfo.Variables(i).Name;
    data=ncread(m,var);
    out.(var)=data; 
end
    