function [A,header]=liesfile(filename,n,col);

% [A,header]=liesfile(filename,n,col)
%
% liest vom File filename (incl. Path!) die Matrix A ein;
% dabei werden n führende Textzeilen ignoriert.
% ' ' als Trennungszeichen zugelassen -- ',' NICHT zugelassen!
% col is 2 by default.

%h=['skipline.exe ' filename ' ' int2str(n)];
%dos([h '|']);
%load temp_xx.dat;
%A=temp_xx;
%delete temp_xx.dat;
%end

if nargin<3,col=2;end
 header='';
[fid,m]=fopen(filename,'rt');
if isempty(m),
   if n>0,header=fgets(fid);end
   for i=2:n,
    buf=fgets(fid);
    header=char(header,buf);
%  header(size(header,1)+1,:)=[buf zeros(1,100-size(buf,2))];
 end
 a=fscanf(fid,'%g %g',[col inf]);
 A=a';
 fclose(fid);
%else
%A=-9999;
else
   A=[];
   header='';
end


