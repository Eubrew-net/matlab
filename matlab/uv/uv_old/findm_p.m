function [j,i]=findm_p(A,B,delta)
% jj=find((A-B(ii))<delta);
% function [j,i]=findm(A,B,delta) busca los elementos comunes en A y B admite repeticion en A
%
% 
j=[];
i=[];
%h=waitbar(0,'Find M esto puede tardar');
tic;
%p=progressbar();
for ii=1:length(B)
   %waitbar(ii/length(B),h);
   %setStatus(p,ii/length(B));
   jj=find((A-B(ii))<delta);
   j=[j;jj];
   if ~isempty(jj)
       i=[i;ii.*ones(size(jj))];
   end
         
end 
toc
%close(h);