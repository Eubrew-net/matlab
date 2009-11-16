function f=powerfit(x0,x,y,per288,per48);
% function f=powerfit(x0,x,y,per288,per48);
% 25 2 97 julian
% use this function for powerfit with least squares.
% use in fsolve, which solves F(x)=0
% therefore return residuals.
% x0 are variables to fit, x and y the data points.


if nargin<5, per48=[];end
if nargin<4 per288=[];end
%if isempty(per48),per48=48;end
%if isempty(per288),per288=288;end


n=length(x0);

ycalc=0;
for i=1:n-4, %n-2
   ycalc=ycalc+x0(i)*x.^(i-1);
end
%ycalc=ycalc;
if ~isempty(per288),ycalc=ycalc+x0(n-3)*sin((x/per288)*2*pi)+x0(n-2)*cos((x/per288)*2*pi);
else
   x0(n-3:n-2)=0;end

if ~isempty(per48),ycalc=ycalc+x0(n-1)*sin((x/per48)*2*pi)+x0(n)*cos((x/per48)*2*pi);
else
   x0(n-1:n)=0;end


%ycalc=ycalc+x0(n-1)*sin((x/288)*2*pi)+x0(n)*cos((x/288)*2*pi);
%ycalc=ycalc+x0(n-1)*sin((x/48)*2*pi)+x0(n)*cos((x/48)*2*pi);

f=y-ycalc;

