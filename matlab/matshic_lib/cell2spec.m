function [spec,newwl]=cell2spec(f,WL,wlcol)
%function spec=cell2spec(f,WL,wlcol)
% 4 3 2002 julian
% change cell to spec array in case cells are not same length
% wl in nanom. but check to correct if different.
% default in nm
% is used inside absuv
% 29 5 2002 julian error in cell2swpec. last wl of last spectra was in error.

if nargin<2,WL=[];end
uvcol=size(f{1},2);
if nargin<3,wlcol=[];end
if uvcol==2 & isempty(wlcol),wlcol=1;end  % 26 3 2003 julian special for two column files
if isempty(wlcol),wlcol=2;end

if min(WL)>1e3, WL=WL/10;end

b=cat(1,f{:});

ind=find(diff(b(:,wlcol))<0);

ind=[0 ;ind]+1;  % indizes where specs start.
ind(end+1)=size(b,1)+1;

N=diff(ind);  % length of spectra

if all(diff(N)==0),  % all same length
 B=cat(2,f{:});
else  % there are different. Strat filling matrix, which might get bigger all the time. WL is defininf parameter
 B=[];
 for i=1:(length(ind)-1),
  spec=b(ind(i):(ind(i+1)-1),:);
  if isempty(B),
   B=spec;
  else
   wl=spec(:,wlcol);
   WL=B(:,wlcol);
   if isempty(setxor(wl,WL)), % all the same
    B=[B spec];
   else
    newwl=union(wl,WL);
    bb=repmat(nan,length(newwl),size(B,2)+size(spec,2));
    [buf,ai,bi]=intersect(newwl,WL);
    bb(ai,1:size(B,2))=B;
    [buf,ai,bi]=intersect(newwl,wl);
    bb(ai,(size(B,2)+1):end)=spec;
    bb(:,wlcol:uvcol:end)=repmat(newwl,1,length(wlcol:uvcol:size(bb,2)));  % redefine all wl.
    B=bb;    
   end   
  end
 end
end


spec=B;
newwl=B(:,wlcol);
