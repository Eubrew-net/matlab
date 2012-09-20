% Lee cualquier medida ciclica + sumario del fichero B
function [dtas,dta,timedta,timedtasum ] = read_bfile_cycle(l,meas,ncy,nfield,fmt,fmtsum)
% imput l :  cellstrng con las medidas ej % s=fileread(bfile); l=mmstrtok(s,char(10));
% meas   : cadena con la medida cyclica  ej: 'ds', 'zs','sl'
% ncy    : numero de ciclos que se repite para ds =5 para zs=7
% nfield : (opcional) numero de campos de la medida por defecto 17(ds,zs,sl
% fmt    : formato matlab de la cadena de medida
%        : por defecto ds,zs,sl,
%   : fmt=[meas,' %c %d %f %d %d %d %d %d %d %d %d %d %d rat %f %f %f %f'];
% fmts   : formato del sumario
%        : por defecto ds, zs ,sl
% fmtsum=['summary %d:%d:%d %c%c%c %f/ %f %f %f %f %c%c %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f']; % summary format
%
% output
% dtas : matriz de los sumarios           [ m_meas , n_field_sumarios]
% dta  : matriz de las medidas   tamaño   [ n_meas * ncy ,n_field]
% timesum : tiempo de los sumarios dim [n_meas,2]  
%          timesum=[fecha matlab ,indice de la medida]]
% timedta: tiempo de las medidas   dim  [n_meas*ncy,3]  
%           timedta=[fecha matlab, indice de la medida, nº de la medida]
% ------------------------------------------------------------------------- 
% ejemplo leer las medidas fz (a diferencia de ds no almazena slit0)
% fmt_fz=['fz',' %c %d %f %d %d %d %d %d %d %d %d %d rat %f %f %f %f']; 
% format of fz and dz 
% fmtsum_fz=['summary %d:%d:%d %c%c%c %f/ %f %f %f %f %c%c %f %f %f %f %f 
%                  %f %f %f %f %f %f %f %f %f %f %f %f']; % summary format
%  ncy=4; cuatro ciclos
%  nfield=[12,16]; % la primera medida de sol no produce ratios
%  [fzsum,fzdata,fzsum_time,fzdata_time]= 
%                 read_bfile_cycle(l,'fz',4,[12,16],fmt_fz,fmtsum_fz);
% TODO: error check
%
if nargin<=3
    nfield=17;  % medidas ds,zs,sl por defecto
    fmt=[meas,' %c %d %f %d %d %d %d %d %d %d %d %d %d rat %f %f %f %f']; % format ds
    fmtsum=['summary %d:%d:%d %c%c%c %f/ %f %f %f %f %c%c %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f']; % summary format
end

% indice de todos los sumarios
jsum=strmatch('summary',l);
% indice de las medidas
jdta=strmatch(meas,l);
% indice de los sumarios de las medidas en los sumarios
i_meas=find(~cellfun('isempty',strfind(l(jsum),meas)));
% indice de de los sumarios de las medidas en L
i_m=jsum(i_meas);
% numero de medidas
n_meas=length(i_meas);

%ndtas=0;
% por defeco numero de campos del sumario
n_sum_field=length(strfind(fmtsum,'%'));

%inicializacion de variables
dta=NaN*ones(max(nfield),n_meas*ncy);
dtas=NaN*ones(n_sum_field,n_meas);
timedta=NaN*ones(n_meas*ncy,3);
timedtasum=NaN*ones(n_meas,2);
%ndta=0;
for i=1:n_meas
    
    dtasum=sscanf(l{i_m(i)},fmtsum);
    type=char(dtasum(12:13)');
    month=char(dtasum(4:7)');
    fecha=datenum(sprintf(' %02d/%s/%02d',dtasum(7),month,dtasum(8)));
    hora=dtasum(1)/24+dtasum(2)/24/60+dtasum(3)/24/60/60;
    if strmatch(meas,type)
        %ndtas=ndtas+1;%jdtasum(ndtas)=i_m(i);
        dta_idx=find(jdta-i_m(i)<0 & jdta-i_m(i)>=-ncy);
        %jdta(dta_idx);
        if length(dta_idx)==ncy
            %timedtasum fecha,indice
            timedtasum(i,:)=[fecha+hora,jsum(i)];
            dtas(:,i)=dtasum;
            for ii=1:ncy
                [dta_r,nr]=sscanf(l{jdta(dta_idx(ii))},fmt);
                dta_=NaN*ones(max(nfield),1); %va a funcionar mientras sean extras
                
                if any(nr==nfield)
                    idx= ncy*(i-1)+ii;
                    dta_(1:nr)=dta_r;
                    dta(:,idx)=dta_;
                    hora=dta_(3)/60/24;
                    timedta(idx,:)=[fecha+hora,jdta(dta_idx(ii)),ncy*10+ii];
                end
            end
        end
        
        
    end
end
end