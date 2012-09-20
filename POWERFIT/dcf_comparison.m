function dcf_comparison(pwl1,pwl2)

wv=2900:5:3250;
figure;
steps1=wl2steps(wv,pwl1);
steps2=wl2steps(wv,pwl2);
plot(wv,steps1-steps2);
hline([-10,10]);

figure;
step=0:100:12000;
wv1=steps2wl(step,pwl1');
wv2=steps2wl(step,pwl2')

plot(wv1(:,3),wv1-wv2)
hline([-10,10])

% julian normalizada     
function STEPS=wl2steps(wv,dcf1)
  %dcf1=read_dcf(fname)';
  wv_=repmat(wv(:),1,6);
  A=dcf1(1,:);B=dcf1(2,:);C=matadd(dcf1(3,:),-wv_);
  BB=matadd(B.*B,-4*matmul(A,C));
  BB=matdiv(BB,4*A.*A);
  BB=BB.^0.5;
  X1=matadd(-B./(2*A),BB);
  STEPS=X1-2*BB;  % this is the one we want

function WL=steps2wl(steps,dcf1)
  %steps must be a vector
  %dcf1=read_dcf(fname);
  WL=polyvac(dcf1',steps);

function [pwl,dcf]=read_dcf(file)
dcf=textread(file,'%f',18); % only ozone
%5474 CLOSE 8:OPEN DD$+NO$+"\"+DCF$+"."+NO$ FOR INPUT AS 8
%5476 FOR I=1 TO 6:FOR J=1 TO 3:INPUT#8,DC(I,J):DC(0,J)=DC(6,J):NEXT:NEXT
%5478 FOR I=1 TO 6:FOR J=1 TO 3:INPUT#8,NDC(I,J):NDC(0,J)=NDC(6,J):NEXT:NEXT

% to matlab polinomials
dcf_=[dcf(end-2:end);dcf(1:end-3)]; % la 0 es la 6
pwl=reshape(dcf_,3,6);
pwl=flipud(pwl)';

