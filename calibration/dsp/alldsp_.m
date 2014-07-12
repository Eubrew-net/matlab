function [wl,DSP,DSPstd,fwhm,fwhmstd,backlash,resup]=alldsp_(day,year,brew,lines,minslit,maxslit,usewl,dspp)

% function [wl,DSP,DSPstd,fwhm,fwhmstd,backlash]=alldsp(day,year,brew,lines,minslit,maxslit,usewl,dspp);
% 3 dec 96 julian
% calculates all dsp files available.
% sorts by slits.
% 4 12 96 correct for deadtime; -> calculate counts per sec.
% day can be several days,
% 19 2 97 julian
% 25 4 97 julian. adapt for new format
% 2 5 97 julian Add filter patch for days 114,121,122
% 4 6 97 julian. if usewl exists, then calculate wl from brstps.
% 1 10 97 julian change saving to make real mean of all days per line
% 21 10 97 julian change dsp format back to original. 4 cycles
% 22 10 97 julian backlash=up-down. positive means backlash!
% 14 11 97 julian remove background from lines.-> changes the slitwidth.
% 30 8 99 julian improve input handling
% 11 7 2001 julian add 163 filename format
% 5 9 2007 julian add plot option to dsp



if nargin<3 brew=[];end
if isempty(brew),brew=119;end
if nargin<4,lines=1:13;end
if isempty(lines),lines=1:9;end
if nargin<5,minslit=[];end
if isempty(minslit),minslit=0;end
if nargin<6,maxslit=[];end
if isempty(maxslit),maxslit=5;end

%Revisar
if nargin<7,usewl=[];end

if nargin<8,dspp=[];end
if isempty(dspp),
    dspp=['d:\brewer\dsp\' sprintf('%03d',brew) '\'];
end
if ~ischar(brew),
    brew=sprintf('.%03d',brew);
end


maxlines=max(lines);


dsp_arrU=zeros(maxlines,6);   % contains data for Up scan
dsp_arrD=zeros(maxlines,6);   % for DOWN scan
DSP=zeros(maxlines,6);        % mean up/dw scan
wl=zeros(maxlines,1);         % wavelength
DSPstd=zeros(maxlines,6);     % std up/dw scan
fwhm=zeros(maxlines,6);       % mean up/dw scab
fwhmstd=zeros(maxlines,6);    % std up/dw scan
backlash=zeros(maxlines,6);   % difference Up/Dw scan
resup=zeros(maxlines,6);      % resolution


if year>=2000,y2=year-2000;year=y2+100;
elseif year>1900,y2=year-1900;year=y2;end



for slits=minslit:maxslit,

    figcnt=0;linecnt=-1;

    frachgline=0;  %% use for 10098 dispersion


    for lnes=lines,

        daycnt=0;clear temp*

        for days=day,

            daystr=sprintf('%03d',days);
            filename=sprintf('W%d%d%03d%02d%s',lnes,slits,days,year,brew);
            [a,s]=liesfile(fullfile(dspp,filename),1,2);
            s=char(s);


            if isempty(a),
               % disp(['file ' dspp filename ' does not exist']);
            else
%                 disp(['now:' filename]);
                
                daycnt=daycnt+1;
                if (rem(linecnt,6)==0),figure;linecnt=0;end
                if linecnt==-1,linecnt=0;end
                linecnt=linecnt+1;
                wl(lnes)=str2num(s(1,:));
                %if rem(linecnt,8)==0,figure;figcnt=1;linecnt=0;end
                subplot(2,3,linecnt);
                %figure(1);
                if ~isempty(usewl),
                    a(:,1)=brstps2(a(:,1),slits,1,usewl);
                end % calculate wl usewl is filename


                a(:,2)=a(:,2)-min(a(:,2)); % remove background 9 3 98 wrong! put into dsp 30 3 98 ok_new
                %% dsp
                %[dsp_arrU(lnes,slits+1),dsp_arrD(lnes,slits+1),fwhmbuf(lnes,slits+1),resup(lnes,slits+1)]=dsp(a,s,0.2,0.8,1);
                % sin plot
                [dsp_arrU(lnes,slits+1),dsp_arrD(lnes,slits+1),tempfw,resup(lnes,slits+1)]=dsp(a,s,0.2,0.8,1);
                title({[filename], [s(1:end-1),' ',num2str(slits),' ',num2str(lnes)]}); 

                temp(daycnt,:)=[dsp_arrU(lnes,slits+1),dsp_arrD(lnes,slits+1)];
                %tempb(daycnt)=fwhmbuf(lnes,slits+1);
                tempb(daycnt,:)=tempfw;
                tempc(daycnt)=dsp_arrU(lnes,slits+1)-dsp_arrD(lnes,slits+1); % backlash

                %xlabel(filename);
                %title(sprintf(['%5.3f [' char(197) ']'],wl(lnes)),'fontsize',9);

            end % if
       
        if daycnt~=0,
            names{lnes,slits+1}=filename;
            fwhm(lnes,slits+1)=mean(tempb(:));
            fwhmstd(lnes,slits+1)=std(tempb(:));
            DSP(lnes,slits+1)=mean(temp(:,1));
            DSPstd(lnes,slits+1)=std(temp(:));
            backlash(lnes,slits+1)=mean(tempc(:));
        end
       end  % days
    end
end

ind=(wl==0);
wl(ind)=[];
DSP(ind,:)=[];
DSPstd(ind,:)=[];
fwhm(ind,:)=[];
fwhmstd(ind,:)=[];
backlash(ind,:)=[];

[wl,i]=sort(wl);
DSP=DSP(i,:);
DSPstd=DSPstd(i,:);
fwhm=fwhm(i,:);
fwhmstd=fwhmstd(i,:);
backlash=backlash(i,:);
%names=names{i,:};----X REVISAR

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



function [x_up,x_dwn,fwhm,resup]=dsp(a,s,cutmin,cutmax,pl);

% function [x_up,x_down,fwhm]=dsp(a,s,cutmin,cutmax,pl);
% 2 12 96 julian
% calculates disperison constants for brewer 119
% day is julian day.
% a and s obtained from alldsp.

% 4 12 96 corrects for deadtime, and converts to cnts per sec.
% 2 5 97 julian add symmetric conditioning
% 7 10 97 julian discover error in backward scan.
% 17 10 97 julian add %changes in point adding...
% 11 12 97 julian Add test for not complete line.
% 19 12 97 julian change how dspchi is called up.
% 5 3 98 julian new dspchi3 withour fmins is much faster now.

resup=0;
if nargin<2,s='';end
if nargin<5,pl=[];end
if isempty(pl),pl=0;end  % default no plot
if nargin<3,cutmin=[];end
if isempty(cutmin),cutmin=0.2;end
if nargin<4,cutmax=[];end
if isempty(cutmax),cutmax=0.8;end



indmax=find(a(:,1)==max(a(:,1)));indmax=indmax(1);
up=a(1:indmax,2);
%down=a(indmax+1:size(a,1),2);down=down(size(down,1):-1:1);
if indmax<length(a)
    down=a(size(a,1):-1:(indmax+1),2);
else
    down=up;
end
steps=a(1:indmax,1);  % get steps
cnts=[up down];
[maxcnts,indmax]=max(cnts);  % get max value and position.
ind1=find((cnts(:,1)<(cutmax*maxcnts(1))) & (cnts(:,1)>(cutmin*maxcnts(1))));
ind2=find((cnts(:,2)<(cutmax*maxcnts(2))) & (cnts(:,2)>(cutmin*maxcnts(2))));

% remove background here: 9 3 98 julian
%indback1=find(cnts(:,1)<(cutmin*maxcnts(1)));
%indback2=find(cnts(:,2)<(cutmin*maxcnts(1)));
%if ~isempty(indback1),cnts(:,1)=cnts(:,1)-mean(cnts(indback1,1));end
%if ~isempty(indback2),cnts(:,2)=cnts(:,2)-mean(cnts(indback2,2)); end


bufa=ind1(ind1<indmax(1));   %pup1=polyfit(steps(bufa),cnts(bufa,1),1)
bufb=ind1(ind1>indmax(1));   %pup2=polyfit(steps(bufb),cnts(bufb,1),1)
if length(bufa)<2 | length(bufb)<2 %| length(bufa)>6 | length(bufb)>6,
    warning('DSP: Not enough or too many points on either side of the maximum of the line');
    x_up=0;%steps(indmax(1));
    x_dwn=0;%steps(indmax(2));
    fwhm=nan;
    return
end

if length(bufa)~=length(bufb), % try to find one more point closest to cut
    if length(bufa)>length(bufb),
        iminus=min([max(bufb)+1 length(steps)]);  % get two new points around cut. changed 12 11 97
        iplus=max([min(bufb)-1 1]);
        if (abs(cnts(iminus,1)-cutmin*maxcnts(1))/(cutmin*maxcnts(1)))<(abs(cnts(iplus,1)-cutmax*maxcnts(1))/(cutmax*maxcnts(1))),
            bufb=[bufb;iminus];
        else
            bufb=[iplus;bufb];
        end
    else
        iminus=max([min(bufa)-1 1]);
        iplus=min([max(bufa)+1 length(steps)]);
        if (abs(cnts(iminus,1)-cutmin*maxcnts(1))/(cutmin*maxcnts(1)))<(abs(cnts(iplus,1)-cutmax*maxcnts(1))/(cutmax*maxcnts(1))),
            bufa=[iminus; bufa];
        else
            bufa=[bufa; iplus];
        end
    end
    ind1=[bufa;bufb];
end
%pup=fmins('dspchi2',[1e3 1e3 1],[],[],steps(bufa),cnts(bufa,1),steps(bufb),cnts(bufb,1))
pup=dspchi3(steps(bufa),cnts(bufa,1),steps(bufb),cnts(bufb,1)); % 5 3 98 julian

resupa=(polyval([pup(3) pup(1)],steps(bufa))-cnts(bufa,1))/maxcnts(1);
resupb=(polyval([-pup(3) pup(2)],steps(bufb))-cnts(bufb,1))/maxcnts(1);


%(jul(2)-jul(1))/(2*jul(3))
bufa=ind2(ind2<indmax(2));    %pdwn1=polyfit(steps(buf),cnts(buf,2),1);
bufb=ind2(ind2>indmax(2));    %pdwn2=polyfit(steps(buf),cnts(buf,2),1);
if length(bufa)<2 | length(bufb)<2,
    warning('DSP: Not enough points on either side of the maximum of the line');
    x_up=0;%steps(indmax(1));
    x_dwn=0;%steps(indmax(2));
    fwhm=nan;
    return
end

if length(bufa)~=length(bufb), % try to find one more point closest to cut
    if length(bufa)>length(bufb),
        iminus=min([max(bufb)+1 length(steps)]);  % get two new points around cut.
        iplus=max([min(bufb)-1 1]);
        if (abs(cnts(iminus,2)-cutmin*maxcnts(2))/(cutmin*maxcnts(2)))<(abs(cnts(iplus,2)-cutmax*maxcnts(2))/(cutmax*maxcnts(2))),
            bufb=[bufb;iminus];
        else
            bufb=[iplus;bufb];
        end
    else
        iminus=max([min(bufa)-1 1]);
        iplus=min([max(bufa)+1 length(steps)]);
        if (abs(cnts(iminus,2)-cutmin*maxcnts(2))/(cutmin*maxcnts(2)))<(abs(cnts(iplus,2)-cutmax*maxcnts(2))/(cutmax*maxcnts(2))),
            bufa=[iminus; bufa];
        else
            bufa=[bufa; iplus];
        end
    end
    ind2=[bufb;bufa];
end
%pdwn=fmins('dspchi2',[1e3 1e3 1],[],[],steps(bufa),cnts(bufa,2),steps(bufb),cnts(bufb,2));
pdwn=dspchi3(steps(bufa),cnts(bufa,2),steps(bufb),cnts(bufb,2)); % 5 3 98 julian

resdwna=(polyval([pdwn(3) pdwn(1)],steps(bufa))-cnts(bufa,2))/maxcnts(2);
resdwnb=(polyval([-pdwn(3) pdwn(2)],steps(bufb))-cnts(bufb,2))/maxcnts(2);

x_up=(pup(2)-pup(1))/(2*pup(3));
x_dwn=(pdwn(2)-pdwn(1))/(2*pdwn(3));

fwhm=(pup(2)+pup(1)-maxcnts(1))/pup(3);
%fwhm=2*(x_up-(maxcnts(1)/2-pup(1))/pup(3));% 6 6 97 julian gives same results!!!

fwhm_up=(pup(2)+pup(1)-(pup(1)+pup(3)*x_up))/pup(3); % 19 8 97 julian fwhm from ideal triangle
fwhm_dw=(pdwn(2)+pdwn(1)-(pdwn(1)+pdwn(3)*x_dwn))/pdwn(3); % 19 8 97 julian fwhm from ideal triangle
fwhm=[fwhm_up,fwhm_dw];
%(pup(1)+pup(3)*x_up)


% OR:
% calculate intersection of fitted lines.
%x_up=(pup2(2)-pup1(2))/(pup1(1)-pup2(1))
%x_dwn=(pdwn2(2)-pdwn1(2))/(pdwn1(1)-pdwn2(1))


% get data for plotting
%x_up=steps(ind1);x_dwn=steps(ind2);
%y_up1=polyval(pup1,x_up);y_dwn1=polyval(pdwn1,x_dwn);


% 21 8 2000: Julian plot differences to linefit
%subplot(2,1,1);
if pl
    %figure;
    plot(steps,cnts(:,1),'r',steps,cnts(:,2),'b',steps(ind1),cnts(ind1,1),'rx',steps(ind2),cnts(ind2,2),'bo',[x_up;x_up],[0;maxcnts(1)*1.2],'r',[x_dwn;x_dwn],[0;maxcnts(2)*1.2],'b');
    %ax=axis;
    %subplot(2,1,2);
    %plot(steps(ind1),[resupa;resupb],'rx',steps(ind2),[resdwna;resdwnb],'bx');
    %axis;axis([ax(1:2) ans(3:4)]);
    %subplot(2,1,1);

    g=text(steps(indmax(1))+30,maxcnts(1),sprintf('%5.2f',x_up));set(g,'color','red','fontsize',9);
    g=text(steps(indmax(2))+30,maxcnts(2)*0.8,sprintf('%5.2f',x_dwn));set(g,'color','blue','fontsize',9);
    g=text(steps(indmax(2))-100,maxcnts(2)*1.1,sprintf('FWHM:%3.2f',fwhm(1)));set(g,'color','red','fontsize',9);
    g=text(steps(indmax(2))-100,maxcnts(2)*0.9,sprintf('FWHM:%3.2f',fwhm(2)));set(g,'color','blue','fontsize',9);
    %buf=axis;axis([steps(indmax(1))-200 steps(indmax(1))+200 buf(3:4)]);

    %title(filename);
    xlabel('steps');
    %ylabel('photons per sec');
    title(s);
    %ylabel(sprintf('%f',sum(abs([resupa;resupb]))));
end

resup=sum(abs([resupa;resupb]));



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





