function status=savefmt(fname,a,header,fmt,app);
% function status=savefmt(fname,a,header,fmt,app)
% 25 match 97
% writes to matrix a to fname using fmt.
% if fmt not present, is equal to '%12.5e'

if nargin<2, disp('supply at least 2 variables');return;end
if nargin<3,header='';end
if nargin<4,fmt=' %15.5E';end
if isempty(fmt),fmt=' %15.5E';end
if nargin<5,app='wt';end

status=1;

%if strcmp(fmt,' %15.5E'),
if (toknb(fmt)==1) & size(a,2)>1,
 j=[];
 col=size(a,2);
 for i=1:col, j=[j fmt]; end
else j=fmt;
end
 j=[j '\n'];



a(isnan(a))=0;

fid=fopen(fname,app);
if fid>0,
 if ~isempty(header),
     if isstr(header),
       fprintf(fid,'%s\n',header);
 elseif iscell(header)
     for i=1:length(header)
       fprintf(fid,'%s\n',header{i});
     end
 end
 end
 if ~isempty(a),fprintf(fid,j,a');end % 14 8 2006 julian new to remove empty lines...
%sprintf(j,a')
 fclose(fid);
else
 status=-1;
 warning(sprintf('Not able to open file <%s> for writing',fname));
end

