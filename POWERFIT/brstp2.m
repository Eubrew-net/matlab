function f=brstps2(wl,sl,back,fname);
% function f=brstps2(wl,sl,back,fname);
% 6 5 97 julian
% calculates wl and steps from file fname
% if back is not there, input wl and calculates step
% if back exists, calculates wl from steps.
% sl=0 is slit 0
%fname='c:\brewer\dsp\dspmaymt.119';
%fname='c:\brewer\dsp\dc12897m.119';
%fname='c:\brewer\dsp\dc15797m.119';
% 12 8 98 julian Now uses powfiu7 and different constants for calculation!!! funktioniert

if nargin<4,fname=[];end
if isempty(fname),
    fname='c:\brewer\dsp\oct97\dc29597m.119';
    fname='\brewer\dsp\test.119';
end

if nargin<3,back=[];end

%ff=liesfile(fname,0,4);
try
    load(fname,'-mat') % is now constants mat file.
    % contains slitein,slitpos,pwl,pstps

    if ~isempty(back),  % calculate wl from stps
        f=polyval(pstps,wl(:)); % calculate wl at reference slit (slit 3). here wl are steps
        dwl=0;
        for i=1:5,
            dwl=powerwl(slitpos,f+dwl);dwl=dwl(:,sl+1);
        end
        f=f+dwl;
    else
        dwl=powerwl(slitpos,wl(:));
        dwl=dwl(:,sl+1);
        f=polyval(pwl,wl(:)-dwl);
    end

    %if ~isempty(back),
    % for i=1:5,
    %  dwl=polyval(pwl,f+dwl);
    % end
    %end

    %f=f+dwl;

    f=reshape(f,size(wl));

catch  % very probably normal file.
    f=liesfile(fname,0,1);
    % f=reshape(f,3,12);
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
end

