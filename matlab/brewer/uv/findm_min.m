function [j,i]=findm_min(A,B,delta)
% function [j,i]=findm(A,B,delta) busca los elementos comunes en A y B admite repeticion en A
% si hay varios en A elige el menor
%
% 
j=[];
i=[];
%h=waitbar(0,'Find M esto puede tardar');

%p=progressbar();
for ii=1:length(B)
   %waitbar(ii/length(B),h);
   %setStatus(p,ii/length(B));
   jj=find(abs(A-B(ii))<delta);
   if length(jj)>1
      [m,jjaux]=min(abs(A(jj)-B(ii)));
      jj=jj(jjaux);
   end
   j=[j;jj];
       
   if ~isempty(jj)
       i=[i;ii.*ones(size(jj))];
   end
         
end 


%close(h);