function [aux,j,i]=find_delta(A,delta)
% function [j,i]=findm(A,delta) busca los elementos comunes en 
% en A con el intervalo delta
%
% 
j={};
i=[];

aux=unique(A);
for ii=1:length(aux)
   %waitbar(ii/length(B),h);
   %setStatus(p,ii/length(B));
   jj=find(abs(A-aux(ii))<delta);
   j{ii}=jj;
   if ~isempty(jj)
       i=[i;ii.*ones(size(jj))];
   end
         
end 
