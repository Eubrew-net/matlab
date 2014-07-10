function [A,header]=liesfile(filename,n,col);

% [A,header]=liesfile(filename,n,col)
%
% liest vom File filename (incl. Path!) die Matrix A ein;
% dabei werden n führende Textzeilen ignoriert.
% ' ' als Trennungszeichen zugelassen -- ',' NICHT zugelassen!
% col is 2 by default.
% 7 6 2012, JG new header is now cell array
% 17 10 2013 JG, need to make faster; is slow for unknown reason for some files...

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
   if n>0,header={fgetl(fid)};end   % 7 6 2012 new cell
   for i=2:n,
    buf=fgetl(fid);
%    header=char(header,buf);
     header{end+1}=buf;
%  header(size(header,1)+1,:)=[buf zeros(1,100-size(buf,2))];
 end
 %a=fscanf(fid,'%g %g',[col inf]);
 a=fscanf(fid,'%f');
 N=length(a);
 m=N/col;
 if rem(m,1)~=0,
    N=fix(m)*col; 
 end
 A=reshape(a(1:N),col,fix(m))';
 fclose(fid);
%else
%A=-9999;
else
   A=[];
   header='';
end


