function [wv_o3,dcf,pwl_i,table_steps]=dcf_comp(file1,file2,icf_file)
dcf1=read_dcf(file1);
dcf2=read_dcf(file2);
icf=read_icf(icf_file);

steps=1:10^4;
wv=2865:5:3635;


for i=1:6
  wv_(i,1,:)=polyval(dcf1(i,:),steps);
  wv_(i,2,:)=polyval(dcf2(i,:),steps);
    
  wv_(find(wv_<=2865))=NaN;
  wv_(find(wv_>3635))=NaN;
  aux=squeeze(wv_(i,1,:));
  jn=find(~isnan(aux));
  aux_x=steps(jn)';
  aux_y=aux(jn);
  i_pwl1(i,:)=polyfit(aux_y,aux_x,2); 
  
  aux=squeeze(wv_(i,2,:));
  jn=find(~isnan(aux));
  aux_x=steps(jn)';aux_y=aux(jn);
  i_pwl2(i,:)=polyfit(aux_y,aux_x,2); 
  
  
  stp_(i,1,:)=polyval(i_pwl1(i,:),wv);
  stp_(i,2,:)=polyval(i_pwl2(i,:),wv);
  
end

dcf(1,:,:)=dcf1;
dcf(2,:,:)=dcf2;
pwl_i(1,:,:)=i_pwl1;
pwl_i(2,:,:)=i_pwl2;

% ozone wavelenghs
ozo_pos=icf(44)+icf(14);
for i=1:6
  wv_o3(1,i)=polyval(dcf1(i,:),ozo_pos);
  wv_o3(2,i)=polyval(dcf2(i,:),ozo_pos);
  st_o3(1,i)=polyval(i_pwl1(i,:),wv_o3(1,i));
  st_o3(2,i)=polyval(i_pwl2(i,:),wv_o3(2,i));   
end

%% tabla
%  Differences between step numbers for wl 2900 to 3600
%Step number for dcf21913.218  minus step number for dc%f28713.218
%  WL   Slit1  Slit2  Slit3  Slit4  Slit5  Slit0
% wv=2865:35:3635
%  WL   Slit0  Slit2  Slit3  Slit4  Slit5  Slit6
table_steps=[wv(1:7:end)',(squeeze(stp_(1:6,1,1:7:end))-squeeze(stp_(1:6,2,1:7:end)))']


% ploteos 
stp_(find(stp_<=0))=NaN;
wv_(find(wv_<=2865))=NaN;
wv_(find(wv_>3635))=NaN;
figure
plot(wv,squeeze(stp_(1:6,1,:))-squeeze(stp_(1:6,2,:)));
title({['steps _\delta',num2str(diff(round(st_o3)))],...
       ['wv _\delta= ',num2str(diff(wv_o3))]});     
xlabel('Amstrong')
ylabel('Steps');
figure
plot(steps,squeeze(wv_(1:6,1,:))-squeeze(wv_(1:6,2,:)))
ylabel('Amstrong')
xlabel('Steps');
legend(cellstr(num2str([1:6]')))

function [pwl,dcf]=read_dcf(file)
dcf=textread(file,'%f',18); % only ozone
%5474 CLOSE 8:OPEN DD$+NO$+"\"+DCF$+"."+NO$ FOR INPUT AS 8
%5476 FOR I=1 TO 6:FOR J=1 TO 3:INPUT#8,DC(I,J):DC(0,J)=DC(6,J):NEXT:NEXT
%5478 FOR I=1 TO 6:FOR J=1 TO 3:INPUT#8,NDC(I,J):NDC(0,J)=NDC(6,J):NEXT:NEXT

% to matlab polinomials
dcf_=[dcf(end-2:end);dcf(1:end-3)]; % la 0 es la 6
pwl=reshape(dcf_,3,6);
pwl=flipud(pwl)';


