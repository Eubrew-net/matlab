function f=dspchi3(x1,y1,x2,y2,sig1,sig2)
% function f=dspchi3(x1,y1,x2,y2,sig1,sig2)
% f=[x0 x1 x2], x0=b1, x1=b2, x2=a   for b+ax
% calculates slopes for isosceles triangle for brewer dsp.
% sig1 sig2 are uncertainities.
% 5 3 98 julian gives same result as fmins(dspchi2)

if nargin<6,sig2=[];end
if nargin<5,sig1=[];end

if isempty(sig1),sig1=ones(size(x1));end
if isempty(sig2),sig2=ones(size(x2));end


%X=[x1(:) x2(:)];
%Y=[y1(:) y2(:)];
%SIG=[sig1(:) sig2(:)];

S(1)=sum(1./sig1.^2);S(2)=sum(1./sig2.^2);

Sx(1)=sum(x1./sig1.^2);Sx(2)=sum(x2./sig2.^2);

Sy(1)=sum(y1./sig1.^2);Sy(2)=sum(y2./sig2.^2);

Sxx(1)=sum(x1.^2./sig1.^2);Sxx(2)=sum(x2.^2./sig2.^2);

Sxy(1)=sum(x1.*y1./sig1.^2);Sxy(2)=sum(x2.*y2./sig2.^2);


M=[sum(Sxx) Sx(1) -Sx(2);...
   -Sx(1)   -S(1)   0   ;...
   Sx(2)     0   -S(2) ];

C=[Sxy(1)-Sxy(2);-Sy(1);-Sy(2)];
A=M\C; % A(1) is slope, A(2)=b1, A(2)=b2;

f=[A(2) A(3) A(1)];





