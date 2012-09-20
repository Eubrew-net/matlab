function [wv_o3,dcf,pwl_i]=dcf_plot(file1,icf_file)
dcf1=read_dcf(file1);
icf=read_icf(icf_file);

steps=1:10^4;
wv=2865:5:3635;
stp_=[];
i_pwl1=[];
wv_=[];
for i=1:6
  stp_(i,:)=polyval(dcf1(i,:),steps);  
  i_pwl1(i,:)=polyfit(aux_y,aux_x,2);    
  stp_(i,:)=polyval(i_pwl1(i,:),wv);
  % check with julian
  [stp_j(i,:),pp(i,:)]=brstps2(wv,i-1,[],file1);
  wv_j(i,:)=brstps2(steps,i-1,1,file1);
  % very different
  
end
% julian vectorizado
stp_n=steps2wl(wv,file1);

% ozone wavelenghs
ozo_pos=icf(44)+icf(14);
% ozone_os
for i=1:6
  wv_o3(1,i)=polyval(dcf1(i,:),ozo_pos);
  st_o3(1,i)=steps2wl(
end
% umkher waveleng



function [pwl,dcf]=read_dcf(file)
dcf=textread(file,'%f',18); % only ozone
%5474 CLOSE 8:OPEN DD$+NO$+"\"+DCF$+"."+NO$ FOR INPUT AS 8
%5476 FOR I=1 TO 6:FOR J=1 TO 3:INPUT#8,DC(I,J):DC(0,J)=DC(6,J):NEXT:NEXT
%5478 FOR I=1 TO 6:FOR J=1 TO 3:INPUT#8,NDC(I,J):NDC(0,J)=NDC(6,J):NEXT:NEXT

% to matlab polinomials
dcf_=[dcf(end-2:end);dcf(1:end-3)]; % la 0 es la 6
pwl=reshape(dcf_,3,6);
pwl=flipud(pwl)';

%%
% calculates wl and steps from file fname
% if back is not there, input wl and calculates step
% if back exists, calculates wl from steps.
% sl=0 is slit 0
function [f,pp]=brstps2(wl,sl,back,fname);
  f=liesfile(fname,0,1);
% % f=reshape(f,3,12);
     if sl==0,sl=6;end
     pp=f((sl-1)*3+[3 2 1]);  % only for slit 1
     if isempty(back),
         a=pp(1);b=pp(2);c=pp(3)-wl(:);
         bb=(b.*b-4*a.*c)./(4*a.*a);
         bb=bb.^0.5;
         x1=-b./(2*a)+bb;
         x2=x1-2*bb;  % this is the one we want
         f=x2;
     else
         f=polyval(pp,wl(:));
     end

% julian normalizada     
function X2=steps2wl(wv,fname)
  dcf1=read_dcf(fname)';
  wv_=repmat(wv(:),1,6);
  A=dcf1(1,:);B=dcf1(2,:);C=matadd(dcf1(3,:),-wv_);
  BB=matadd(B.*B,-4*matmul(A,C));
  BB=matdiv(BB,4*A.*A);
  BB=BB.^0.5;
  X1=matadd(-B./(2*A),BB);
  X2=X1-2*BB;  % this is the one we want

  
