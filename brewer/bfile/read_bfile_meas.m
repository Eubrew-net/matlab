% Lee cualquier medida no ciclica del fichero B (sin sumario)
function [dta] = read_bfile_meas(l,meas,nfield,fmt)
%
% imput l :  cellstrng con las medidas ej % s=fileread(bfile); l=mmstrtok(s,char(10));
% meas   : cadena con la medida cyclica  ej: 'ds', 'zs','sl'
% nfield : (opcional) numero de campos de la medida por defecto 17(ds,zs,sl
% fmt    : formato matlab de la cadena de medida
%        : por defecto ds,zs,sl,
%   : fmt=[meas,' %c %d %f %d %d %d %d %d %d %d %d %d %d rat %f %f %f %f'];
% 
% output
% dta  : matriz de las medidas   tamaño   [ n_meas ,n_field]
% TODO: error check
%
% ejemplo leer las medidas fv
% fvformat='fv %02d:%02d:%02d %d az %f%f%f ze %f%f%f'
% fvdata=read_bfile_measure(l,'fv',10,fvformat)

if nargin<=3
    nfield=17;  % medidas ds,zs,sl por defecto
    fmt=[meas,' %c %d %f %d %d %d %d %d %d %d %d %d %d rat %f %f %f %f']; % format of dz/fz Bfile
end


% indice de las medidas
jdta=strmatch(meas,l);
% indice de los sumarios de las medidas en los sumarios
n_meas=length(jdta);

%ndtas=0;
% por defeco numero de campos 
n_field=length(strfind(fmt,'%'))

%inicializacion de variables
dta=NaN*ones(nfield,n_meas);

%ndta=0;
for i=1:n_meas
    dta_=NaN*ones(max(nfield),1); %va a funcionar mientras sean extras
    [dta_r,nr]=sscanf(l{jdta(i)},fmt);
    dta_(1:nr)=dta_r;
    dta(:,i)=dta_;    
end
end