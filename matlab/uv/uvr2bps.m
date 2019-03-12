% uvr2bps function uvr2bps(uvrhist)
% read UVHIST File and copy response  uvr files to Brewer Processig
% Software file names
% uvrdddaa.iii to  UVRYYYYDDD.III
function uvr_data=uvr2bps(filehist)
if nargin==0
     filehist='UV2018HIST.txt';
end
uvr=readtable(filehist,'Format','%2d.%2d.%042d %s','Delimiter', ' ', 'HeaderLines', 0, 'ReadVariableNames', false);
uvr_info=cellfun(@(x) sscanf(x,'uvr%03d%02d.%03d'),uvr.Var4,'UniformOutput',false);
%uvr_info=cell2mat(uvr_info')'
uvr.Var5=cellfun(@(x) sprintf('UVR%04d%03d.%03d',[x(2)+2000,x(1),x(3)]),uvr_info,'UniformOutput',false)
cellfun(@(x,y) copyfile(x,y),uvr.Var4,uvr.Var5)

uvr_data=[];

for F={uvr.Var4{:}}  
    uvr_data=scan_join(uvr_data,load(F{:})); 
end

figure
h=ploty(uvr_data)
clickableLegend(h,uvr.Var4)

figure
ratiol(uvr157,uvr157(:,[1,end]))