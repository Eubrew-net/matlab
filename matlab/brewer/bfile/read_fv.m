function [data_out,data_fit,data,head]=read_fv(fv_file,fplot)
% Lee y procesa los ficheros fv
% 
%   Data_out, data_int salida de FV_fit
%   data, head    datos brutos y cabecera de las medidas
%
%FV_fit ajusta la medida fv a un trapecio simetrico interpolando entre los
%datos. (la parte superior del trapecio se ajusta a una parbola)
%                               <-mx
%                             | 
%                xu(2)->  ++++|++++   <-xd(2)
%                        +    |    +
%                       +     |     +
%                      +      |      +
%                     +       |       +
%      BASE up+++++++ <-xu(1) | xd(1)-> +++++BASE down
%
%  out{ii},data_int{ii} ii=1 zenith, ii=2 azimut
%   out{ii}=[mx{ii},max_{ii},step_mx{ii},rup{ii},rdw{ii},rp{ii},xu{ii},xd{ii},fwhm,p_top{ii},p_b_up{ii},p_b_dw{ii}]
%   [rup,rdw,rp] coef corr (up,dw y parabola)
%   mx= x del maximo de la parabola
%   step_mx step del maximo
%   max_ valor maximo de los datos con el que se normaliza
%   xu= corte de la rama de subida xu(1) en la base xu(2) en la  cima
%   xd= corte de la rama de bajada xd(1) en la base xd(2) en la  cima
%   fwhm= ancho en pasos.
% p_top polinomio de la parabola (ax2+bx+c)
% p_b_up polinomio lineal de la base 1 (ax+b)
% p_b_dw polinomio lineal de la base 2 (ax+b)
% usa dspchi3
% TODO: Semianchura
% TODO: salida en angulos no en pasos
%
%
%
if nargin==1
    fplot=0;
end
[s]=fileread(fv_file);
[fv_path,fv_name,fv_inst]=fileparts(fv_file);
 fv_name=upper(fv_name);
 fecha=sscanf(fv_name,'FV%03d%02d');
 fecha_fv=datenum(fecha(2)+2000,0,fecha(1));
 inst=sscanf(fv_inst,'.%03d');
l=mmstrtok(s,char(10));
meas=[strmatch('Field',l);length(l)];
n_meas=length(meas)-1;
head=zeros(n_meas,6);
data=cell(n_meas,1);
data_out=cell(n_meas,2);
fecha=zeros(n_meas,1);


for i=1:n_meas
% disp('start');    
    try
    %Field of view Scan started at 13:14:07filter: 3CY 5SL  5
    try
      head(i,:)=sscanf(l{meas(i)},'Field of view Scan started at %02d:%02d:%02dfilter: %dCY %dSL  %d')';
    catch
      head(i,:)=sscanf(l{meas(i)},'Field of view Scan started at %02d:%02d:%02d filter: %d CY %d SL  %d NCorr %*d ZCorr %*d ')';
    end    
    data{i}=str2num(cat(2,l{meas(i)+1:meas(i+1)-1}));
    data{i}=[data{i},data{i}(:,5)/max(data{i}(:,5))]; 
    fecha(i)=fecha_fv+head(i,1)/24+head(i,2)/24/60+head(i,3)/24/60/60;
      try
       [out,data_fit{i}]=fv_fit(data{i},[0.9,0.1],fplot);
       if fplot
           xlabel([fv_name,' ',fv_inst,' ',datestr(fecha(i))])
       end
       data_out{i,1}=[fecha(i),inst,1,out{1}];
       data_out{i,2}=[fecha(i),inst,2,out{2}];
      catch
          sprintf('Fit_error: %s',datestr(fecha(i)));                 
%        disp(l{meas(i)});
%        data_out{i,1}=[fecha(i),inst,1,NaN*ones(1,18)];
%        data_out{i,2}=[fecha(i),inst,2,NaN*ones(1,18)];
      end
    catch
        disp(l{meas(i)});
    end
end


% if fplot
% 
%  for idx=1:n_meas
%  [F]= TriScatteredInterp(data{idx}(:,1),data{idx}(:,2),data{idx}(:,6),'natural');
%   figure;
%   plot3(data{idx}(:,1),data{idx}(:,2),data{idx}(:,6),'ko');
%   hold on;
%   xi=-180:5:180;yi=-40:5:40;
%   [qx,qi]=meshgrid(xi,yi);qz=F(qx,qi);mesh(qx,qi,qz);
%  end
% end