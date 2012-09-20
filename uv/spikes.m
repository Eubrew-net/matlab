function [sensoutcorr,indspikes,cols]=spikes(wl,sensout,einsatz,ref)
%function Sensoutcorr=spikes(wl,sensout,einsatz,ref) finds spikes relative to ref. spectrum.
% returns corrected file
% 28 8 98 julian
% finds spikes relative to ref. spectrum.
% returns corrected file

if nargin<4,ref=[];end

if isempty(ref),  % contains ref spectrum. and wlref
 load ref24498 
else
 load(ref);
end
indspikes=[];
cols=[];
sensoutcorr=sensout;

for i=1:length(einsatz),  % remove start to prevent erronerous errors.
 sensout(wl<=einsatz(i)+20,:)=nan;  % was nan
end

[ind,indref]=find2(wl,wlref);
wl=wl(ind);
sensout=sensout(ind,:);
ref=ref(indref);
ref2=repmat(ref,1,size(sensout,2));

ratio=sensout./repmat(ref,1,size(sensout,2));
dratio=diff(ratio);

dratio(isnan(dratio))=0;

% compare each column with itself. find of similar matrices compares elementwise
% find bigger zero and smaller zero

[a1,col1]=find((dratio)>5*repmat(std(dratio),size(dratio,1),1));  % should always be pairs of errors.
[a2,col2]=find((dratio)<-5*repmat(std(dratio),size(dratio,1),1));  % should always be pairs of errors.

plus=ones(size(a1));minus=-ones(size(a2));
a=[a1;a2];col=[col1;col2];[a,i]=sort(a);col=col(i);
plusminus=[plus;minus];plusminus=plusminus(i);

if isempty(a),return;end   % No spikes

% richtige spikes are:
ind=diff(col)==0 & diff(a)==1 & diff(plusminus)~=0;

%ind=find(diff(a)==1)+1;
indspikes=a(ind)+1; % return second indices that are spikes.
cols=col(ind);

for i=1:length(cols),
  % warning(sprintf('Spike found at wl=%4.0f in nb=%02.0f',wl(indspikes(i)),cols(i)));
   xx=5;
  if indspikes(i)+5 > size(sensoutcorr,1) xx=size(sensoutcorr,1)-indspikes(i)-1; end;
  ind=[indspikes(i)-5:indspikes(i)-1 indspikes(i)+1:indspikes(i)+xx];
  [pp,xx,nn]=polyfit(wl(ind),ratio(ind,cols(i)),2);
  sensoutcorr(indspikes(i),cols(i))=polyval(pp,wl(indspikes(i)),xx,nn)*ref2(indspikes(i),cols(i));
end

