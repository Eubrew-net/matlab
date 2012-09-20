function col=gris_line(m)
if nargin==1
    ca=gray(m+3);
else
    ca=gray;
end
ca=ca(1:m,:);
%col=[ ca(1:5:end-3,:);ca(end-3:-5:1,:)];
col=[ ca(1:2:end,:)];

set(gcf,'DefaultaxesColorOrder',col);
%set(gcf,'DefaultaxesLineStyleOrder', '.-|:o|-+|:p');
set(gcf,'DefaultaxesLineStyleOrder', '-+|-.|-x|-*|-o|-s|-d|-p|-h|:+|:.|:*|:s|:d|:p|:h');
