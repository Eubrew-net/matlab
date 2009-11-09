% readsr recursivo
% function SR=reabl_sr(path)

function SR=reabl_sr(path)
SR=[]
s=dir(path)
for i=1:length(s)
    dt=readb_(s(i).name);
    if ~isempty(sr)
         SR=[SR;sr];
    end;
end