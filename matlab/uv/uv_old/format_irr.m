%escribe las irr
%function format_irr(irx,lamp,di)
function format_irr(irx,lamp,di)
if nargin==1
    filelamp=irx;
    [irx,lamp,di]=loadlamp(irx);
else
    filelamp=sprintf('LAMP%03d.irx',lamp);
end
f=fopen(filelamp,'wt');
fprintf(f,'LAMP%04d\n',lamp);
fprintf(f,'%f\n',di);
fprintf(f,'%.0f          %.6f\n',irx');
fclose(f);