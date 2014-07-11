function [WL,DWLM,DWL]=matshic(datestart,dateend,site,inst,debu,pl)
%function [wl,dwlm,dwl]=matshic(datestart,dateend,site,inst,debu,pl)
% site - string defining site location (lat, long, name)
% inst - acronym for instrument
% debug =0 - no debug info
% debug =1 - show info in console
% debug =2 - Show all debug info & estimate new Res criteria in figure window
% pl=1, plots dwl in figure
% readme:
%%%%%%%%%%%%%%%%%%%%%%
% matshic.cfg is on the matlab path, and contains the default parameters for matshic
% the site location file contains in the first line the site name, the second line=lat, third line=long (positive going east)
% the instrument file contains optional information to overwrite the default matshic.cfg file:
%         rescrit   [qflag, rescrit]
%         dwlrange=x with  [x(1) : x(2) : x(3)]
%         wlout=x  with   [x(1) : x(2) : x(3)]
%         formatin 0=ascii, 1 = matshic
%         formatout 0=ascii, 1 = matshic
%         pathin     % root path: <pathin>/uvdata/yyyy/<inst>
%         pathout    % root path: <pathout>/uvanalys/yyyy/<inst>
%         debug      % 0, no debug info, 1 show all console info,   2 figure with debug information to optimise rescrit
%         singleslit xxx nm   % use only this single slit at this wavelength, instead of the variable slit
%         noinstspec 0= default, calculate also instrument spec, 1 = do not calculate it
% file format matshic:
% daily input file with name convention mat_uvdddyyyy.<inst>
%  mat_uvdddyyyy.<inst> with wl , spec, tm : tm should be in matlab time
% slit function file: location in pathout (root)
%  <inst>.sli with structure slit
%   slit.wl is wavelength of slit function , e.g. -2:0.01:2 nm
%   slit.slit_wl is wavelengths at which the slit function is given, e.g. 300 nm , 350 nm, 500 nm
%   slit.data is matrix (wl x slit_wl), and contains the slit function files
%%%%%%%%%%%%%%%%%%%%%%

% 8 4 2013 JG make function and compatible with STRELA
% 12 4 2013 JG add res criterium.Important to have correct slit function
% default crit=0.02 for shic
% dwl is shift of ET to agree with spec
% 25 4 2013 JG, adapt for our corona directory structure (using shicrivm''')
% debu=0, no debug information
% debu=1 , plots figures of wlshifts for checking best criterium...

% 3 11 2013 JG make it vector
% 22 1 2014 JG, make it userfriendly...
% 22 1 2014 add config file for parameters
% 22 1 2014 add metadata
% 28 1 2014 jg add header to files
% 28 1 2014, JG make also daily mat file with all data
% 6 2 2014 JG, add variable slit based on Luca's script
% 12 2 2014 JG add debug info, and invariable to override debug from inst file.
% 26 2 2014 JG add mat file readin
% 27 2 2014 JG release to LE  2.0
% 3 3 2014, JG add changes and corect bugs
% 5 3 2014 JG, matshic returns nans in spec when matshic_shiftspec crashes...
%5 4 2014 JG add plot of dwl as option
% 11 4 2014 JG make fast option (for >315 nm)
% 30 4 2014 JG add time option and make time available in output file
% 2 6 2014 jg change output path to uvanalys/...
% 12 6 2014 JG, add o3 loop and et option in inst. cgf 
% 19 6 2014 JG, change matshic_shiftspec and convvarslit due to extrapolation problems
% 8 7 2014 JG, make slit variables more tolerant for dimensions...
% 9 7 2014 JG change falt_spec to remove nan values
% 10 7 2014 JG, if ascii sli file, then take it
% 11 7 2014 JG make time vector tolerant
%11 7 2014, make single brewer compatible

jump=1;  % use every 10 scans
outcnt=0;

if nargin<4,error('Not enough parameters');end
if nargin<5,debu=[];end
if nargin<6,pl=[];end
if isempty(pl),pl=0;end

global MATSHIC

MATSHIC.varslit=0;  % default is not variable slit

VER=3.12;
DATE='11 July 2014';
HEADER={sprintf('%%Wavelength shift & Convolution algorithm matSHIC, Ver %.2f (%s)',VER,DATE)};
HEADER{end+1}=sprintf('%%Processing %s',datestr(now));
HEADER{end+1}=sprintf('%%Developed by Julian Gröbner and Luca Egli');
HEADER{end+1}='%%Physikalisch-Meteorologisches Observatorium Davos, World Radiation Center (PMOD/WRC)';
HEADER{end+1}=sprintf('%%Processing instrument %s',inst);



MATSHIC=readcfg(site,inst);   % read config parameters for matshic

MATSHIC.inst=inst;

%PP='\\corona\calib/uv/';

% 14 11 2013 JG : Here are default Parameters for SHIC 
%rescrit={325,[0.25 0.6]};   % for jrc  using dwl_res
%rescrit={325,[2.2 2.2]};   % for jrc  using qflag
%RESCRIT=[2.2 1];   % qflag and res

RESCRIT=MATSHIC.rescrit;   % 22 1 2014 JG new

%REFET='kp320a3l.et';
%REFET='MHP_COKITH.dat';   % 5 11 2013 JG makes quite a different dwl below 310 nm!!! explains all differences with shicrivm
REFET=MATSHIC.ET;  % 22 1 2014 JG new

%fwhm=1; % default nominal slit function
fwhm_nom=MATSHIC.fwhmout;
%DD=16;
DD=MATSHIC.DD;
%dwll=-1:0.005:1;   % shift by -1 to 1 nm, every 0.1 nm
dwll=MATSHIC.dwlrange(1):MATSHIC.dwlrange(2):MATSHIC.dwlrange(3);

if isempty(debu),
debu=MATSHIC.debug;
end


if isempty(dateend),dateend=datestart;end

%pp=[PP 'shicrivm'];   % to be adapted for Strela, ...
%ppout=[PP 'qasume/matshic'];  % to be adapted for other PCs ...
ppin=MATSHIC.pathin;
ppout=MATSHIC.pathout;

buf=datevec(datestart);
yr=buf(1);

%load here new ET
%et_spec = load('MHP_COKITH.dat','ascii');

%load here traditional ET (important to divide by 1000)
try
et_spec = load(REFET,'ascii');   % still in this matshic directory
catch
    error('Extraterrestrial file %s not found!',REFET);
end
et_spec(:,2) = et_spec(:,2)./1000;

% load here instrument slit function
if MATSHIC.fileformatin, % matlab format for slit and mat files,
    slitfname=sprintf('%s/%s.sli',ppout,inst);
try
 buf= load(slitfname,'-mat');    % contains variable slit
 slit=buf.slit;  % contains three fields, wl, data, and slit_wl (at which wl the slits are given...)
 slit.slit_wl=slit.slit_wl(:)';  % 8 7 2014 JG
 slit.wl=slit.wl(:);
 if size(slit.wl,1)~=size(slit.data,1) | size(slit.slit_wl,2)~=size(slit.data,2),
     slit.data=slit.data';  % 8 7 2014, JG assume it needs to be transposed...
 end
 if MATSHIC.singleslit>0 & size(slit.data,2)>1,   % only use one slit, but more are given,
       slit=[slit.wl gridslit(slit,MATSHIC.singleslit)];    % grid slit to single wavelength   
 elseif size(slit.data,2)>1   % variable slit
     MATSHIC.varslit=1;
     slit.slitint=gridslit(slit,et_spec(:,1));    % grid slit to et spectrum
 else
     slit=[slit.wl slit.data];
 end
 slitfname=slitfname;
 wlcenter=nan;   % not defined for variable slit
 fwhm=nan;
catch
   error(sprintf('Error with mat slit file %s.',slitfname));
end
else  % load default shicrivm slit file
    slitfname2=sprintf('%s/%s.sli',ppin,inst);
   slit = liesfile(slitfname2,1);
  if isempty(slit),
      error(sprintf('SHICRivm Slit Function file %s not found!',slitfname2));
      
  end
  slitfname=slitfname2;
  MATSHIC.varslit=0;
end

 HEADER{end+1}=sprintf('%%Slit file used for the wavelength shift algorithm: %s',slitfname);
  
     if ~MATSHIC.varslit,   % only for constant slit
        [wlcenter,fwhm]=slitfit(slit,0,0); % isoceles triangle fit
        slit(:,1)=slit(:,1)-wlcenter;
        HEADER{end+1}=sprintf('%%Center of Slit is %4.3f nm and FWHM=%3.2f nm using isoceles triangle fit (Brewer)',wlcenter,fwhm);
        if debu>1,
          % figure;plot(slit(:,1),slit(:,2));title(wlcenter);
           disp(sprintf('%s : Center WL=%4.3f nm FWHM=%4.3f nm',inst,wlcenter,fwhm));
        end
     end
    
 if ~MATSHIC.varslit,  P=csapi(slit(:,1),slit(:,2));
 else
     P=nan;
 end


% nominal slit
slinom=brslit(fwhm_nom,[],1);



HEADER{end+1}=sprintf('%%Extraterrestrial reference file %s',MATSHIC.ET);
HEADER_conv=HEADER;   % same header
HEADER_conv{end+1}=sprintf('%%Nominal triangle output slit FWHM=%.2f nm',fwhm_nom);

HEADER{end+1}=sprintf('%%Wavelength shift test range %5.3f:%5.3f:%5.3f nm',MATSHIC.dwlrange);
HEADER{end+1}=sprintf('%%Wavelength shift averaging interval %3.f nm',DD);

%path of input data
datea=datenum(datestart);
dateb=datenum(dateend);

n_HEADER=length(HEADER);
n_HEADER_conv=length(HEADER_conv);

for i=datea:dateb; % choose here the spectra to be calculated
    [doy,b,b,yr]=julianday(i);
    if MATSHIC.fast<0, % was set to one and reset from previous day,
        MATSHIC.fast=1;
    end
    if ~MATSHIC.fileformatin,  % standard shicrivm file format (ascii)
        mydir=sprintf('%s/uvdata/%04d/%s/',ppin,yr,inst);
        fname=sprintf('%s/%03d*.%s',mydir,doy,inst);
        
        d=dir(fname);
        Nfiles=length(d);
        % if length(d)>0 | debu,disp(sprintf('Processing %s : %d spectra',datestr(i),length(d)));end
        if MATSHIC.fast,
            for uu=1:Nfiles,
        hhmm=sscanf(d(uu).name,'%*3d%2d%2d');
        fast_tm(uu)=i+hhmm(1)/24+hhmm(2)/24/60;
            end
            [fast_sza,fast_m]=brewersza(fast_tm,[],[],MATSHIC.lat,-MATSHIC.long);
            fast_j=find(fast_m==min(fast_m));  % use local noon

        end
    else  % here load matfile
        fname=sprintf('%s/uvdata/%04d/%s/mat_uv%03d%04d.%s',ppin,yr,inst,doy,yr,inst);
        fmat=load(fname,'-mat');
        Nfiles=size(fmat.spec,2);
        if ~isfield(fmat,'tm'),  % 30 4 2014 tolerant with time field
            if isfield(fmat,'time'),
                fmat.tm=fmat.time;
            else
                [b,b,fmat.tm]=szainfo(doy,yr,MATSHIC.lat,-MATSHIC.long);
                fmat.tm=datenum(yr,1,doy,0,fmat.tm,0);
              if debu,disp(sprintf('No Time Vector, using local noon: %s',datestr(fmat.tm)));end
            end
        end
        if all(fmat.tm(:)<=24), %hour decimal, 11 7 2014 jg
            fmat.tm=datenum(yr,1,doy,fmat.tm,0,0);
        elseif all(fmat.tm(:)<=1440),  % min dec
            fmat.tm=datenum(yr,1,doy,0,fmat.tm,0);
        end    
        if size(fmat.tm,2)==1,  % vector
            fmat.tm=fmat.tm(:)';   % make row
        end
        % 11 4 2014 JG here make fast option if necessary:
        if MATSHIC.fast,   % make it faster...
            fast_tm=fmat.tm(1,:);
            [fast_sza,fast_m]=brewersza(fast_tm,[],[],MATSHIC.lat,-MATSHIC.long);
            fast_j=find(fast_m==min(fast_m));  % use local noon
            
        end
    end
if MATSHIC.fileformatout,
        matfilename=sprintf('%s/uvanalys/%04d/%s/matshic_%03d%04d.%s',ppout,yr,inst,doy,yr,inst); % 2 6 2014 jg, save to uvanalys
end
if  debu,disp(sprintf('Processing %s : %d spectra',datestr(i),Nfiles));end
    
    mat=[];
    mat.MATSHIC=MATSHIC;
    mat.slit.slit=slit;
    mat.slit.centerwl=wlcenter;
    mat.slit.fwhm=fwhm;
    mat.slitnom.slit=slinom;
    mat.slitnom.fwhm=fwhm_nom;
    mat.slitnom.centerwl=0;
    filecnt=0; % check how many runs were succsssful
    if pl,
        colors=jet(Nfiles);
    end
    for j=1:jump:Nfiles
        try
            HEADER(n_HEADER+1:end)=[];  % clear header lines each time
            HEADER_conv(n_HEADER_conv+1:end)=[];  % clear header lines each time
            
       if MATSHIC.fileformatin,  % time is in matlab format
          tm=fmat.tm(1,j);
          if max(tm)<=24, % given in hour decimals,
            tm=datenum(yr,1,doy,tm,0,0);
          elseif max(tm)<=1440,
            tm=datenum(yr,1,doy,tm/60,0,0);
          end
       else
        hhmm=sscanf(d(j).name,'%*3d%2d%2d');
        tm=i+hhmm(1)/24+hhmm(2)/24/60;
       end
   mat.time(j)=tm;  % for matlab file
        [sza,m]=brewersza(tm,[],[],MATSHIC.lat,-MATSHIC.long);   % make it negative, as brewersza has longitude positive going west
        HEADER{end+1}=sprintf('%%Site location %s, lat=%7.3f, long=%7.3f E',MATSHIC.site,MATSHIC.lat,MATSHIC.long);
        HEADER_conv{end+1}=HEADER{end};
        
       if ~MATSHIC.fileformatin,
        fname=sprintf('%s%s',mydir,d(j).name);
   mat.fname{j}=fname;
        HEADER{end+1}=sprintf('%%Processing file %s',fname);
        spec=liesfile([fname],1,3);   % might need to be made more robust 
          tm=spec(:,3); % 2 5 2014 JG new
          if max(tm)<=24, % given in hour decimals,
            tm=datenum(yr,1,doy,tm,0,0);
          elseif max(tm)<=1440,
            tm=datenum(yr,1,doy,tm/60,0,0);
          end
        fmat.tm(:,j)=tm(:); % 2 5 2014 JG save third column as matlab time (default is in hours.
else
   mat.fname{j}=sprintf('%s:spectrum Nb %d',fname,j);
        HEADER{end+1}=sprintf('%%Processing file %s: spectrum %d',fname,j);
       spec=double([fmat.wl(:) fmat.spec(:,j)]);  % 7 3 2014, error if data is in single precision
    %   [buf,dwl]=wlrefrac(spec(:,1));spec(:,1)=spec(:,1)-2*dwl;

end
        HEADER_conv{end+1}=HEADER{end};
        
        if debu, disp('-----------');disp(sprintf('%s : scan Nb:%d/%d',fname,j,Nfiles));end
        

        spec(spec(:,1)==0,:)=[];
        % here starts the wl-shift routine
 mat.specraw{j}=spec;       
 mat.timeraw{j}=fmat.tm(:,j);  % 30 4 2014 save time information
        ETCWL=spec(:,1);
        DIFFWL=median(diff(ETCWL));
        
      if debu,  t0=tic; end   % get ozone
      if MATSHIC.fast>0,  % here do it only once
          if ~MATSHIC.fileformatin
                     fname=sprintf('%s%s',mydir,d(fast_j).name);
         spec=liesfile([fname],1,3);   % might need to be made more robust ... 2 columns for psr, and 3 for avos

          else
          spec=double([fmat.wl(:) fmat.spec(:,fast_j)]);
          end
      [ETC,mat,HEADER]=prepareETC(spec,slit,et_spec,fast_tm(fast_j),fast_sza(fast_j),fast_m(fast_j),mat,HEADER,debu,fast_j,dwll,P);  
      MATSHIC.fast=-1;  % clear it after first time
      elseif MATSHIC.fast==0,
          [ETC,mat,HEADER,o3]=prepareETC(spec,slit,et_spec,tm,sza,m,mat,HEADER,debu,j,dwll,P);
          if fix(o3)==0,
              [ETC,mat,HEADER,o3]=prepareETC(spec,slit,et_spec,tm,sza,m,mat,HEADER,debu,j,dwll,P,[310 340]);
          end
      end
      
        res=repmat(spec(:,2),1,size(ETC,2))./ETC;
        
        res(res==0)=nan;
        
        
        if 0   % 5 11 2013 jg does not improve significantly jrc 3 sep 2013
        % remove very smooth function
        n=fix(5./DIFFWL);
        respoly=conv2(ones(1,n),1,res,'same')/n;
        res=res./respoly;
        end
        
        if 1, % 5 11 2013 jg
        n=fix(1/DIFFWL);   % 1 nm smoothing best for jrc, 3 sep 2013
        if n==1,n=2;end
        
        padded=repmat(res(end,:),n,1);
        ressmooth=conv2(ones(1,n),1,[res;padded],'same')/n;
        res=res-ressmooth(1:end-n,:);
        end
        % make running mean of DD nm
        n=fix(DD/DIFFWL);
        % need to pad res with values at the end of the spectrum
        padded=repmat(res(end,:),n,1);
        resavg=conv2(ones(1,n),1,[res;padded],'same')/n;
        resavg=resavg(1:end-n,:);  % 12 2 2014, JG remove padded values again
        resavg(isnan(resavg))=0;
        resstd=conv2(ones(1,n),1,sqrt((res-resavg).^2),'same');
        
         [dwl_res,q]=min(resstd,[],2);
         dwl_shift=dwll(q)';
        
         if 1, % 11 11 2013 JG does not work well
         [dwl_resmax1]=max(resstd(:,dwll<mean(dwl_shift)),[],2);
         [dwl_resmax2]=max(resstd(:,dwll>mean(dwl_shift)),[],2);
         dwl_resmax=min([dwl_resmax1 dwl_resmax2],[],2);
         qflag=(dwl_resmax./dwl_res);   
         end 
        
        if 0,  % 5 11 2013 gibt gleiche Resultate!!!
        for ii=1:length(ETCWL),
            ind=q(ii)-10:q(ii)+10;ind(ind<=0)=[];
            p=polyfit(dwll(ind),resstd(ii,ind),2);
            dwl_shift2(ii)=-p(2)/2/p(1);
        end
        BUF{j}=[ETCWL dwl_shift dwl_shift2'];
        end
        
         if debu,
            t1=toc(t0);
             disp(sprintf('Elapsed time for wlshift: %f sec',t1));
        end
        
        if 0,
        flag=repmat(0,size(ETCWL));
        ind=ETCWL<rescrit{1};
        flag(ind)=qflag(ind)<rescrit{2}(1);
        flag(~ind)=qflag(~ind)<rescrit{2}(2);
        end
        
        flag=(qflag>RESCRIT(1) & dwl_res<RESCRIT(2));  % 14 11 2013 jg flag good data
        
        HEADER{end+1}=sprintf('%%RES Criteria qflag=%4.2f & DWL_res=%4.2f',RESCRIT(1),RESCRIT(2));
        
        
        dwl_out=[ETCWL dwl_shift dwl_res qflag flag];  % 22 1 2014 JG add one column with dwl_res
        %figure;plot(ETCWL,qflag,ETCWL,dwl_res);grid;
                
        if ~exist(sprintf('%s/uvanalys/%04d',ppout,yr),'dir'), % 2 6 2014 jg, add uvanalys
            mkdir(sprintf('%s/uvanalys/%04d',ppout,yr));
        end
        if ~exist(sprintf('%s/uvanalys/%04d/%s',ppout,yr,inst),'dir') ,
            mkdir(sprintf('%s/uvanalys/%04d/%s',ppout,yr,inst));
           if ~MATSHIC.fileformatout, mkdir(sprintf('%s/uvanalys/%04d/%s/shift',ppout,yr,inst));end
            
        end
        
        if sum(flag)<2 % 2 5 2013, JG no wlshift within criterium,
            p=linint(ETCWL([1 end])',[0 0]);  % make no wlshift
        else
           
            buf=[ETCWL(flag,1) dwl_shift(flag)];
            %buf=[[min(dwll) buf(1,2)];buf;[max(dwll) buf(end,2)]];
            if MATSHIC.smoothdwl>0,            % add spline smoothing
            psm=csaps(buf(:,1),buf(:,2),MATSHIC.smoothdwl);
            buf(:,2)=fnval(psm,buf(:,1));
            end
            buf=[ [min(ETCWL) buf(1,2)];buf;[max(ETCWL) buf(end,2)]]; % ppual extrapolation is bad
            p=linint(buf(:,1)',buf(:,2)');
          %  p=linint(dwll(flag,1)',dwl_shift(flag)');
        end
        dwlfit=ppual(p,ETCWL);
        dwl_out=[dwl_out(:,1) dwlfit dwl_out(:,2:end)]; 
        
        if pl,
            figure(111);plot(ETCWL,dwlfit,'.','color',colors(j,:));
            hold on;
            figure(222);plot(spec(:,1),spec(:,2),'color',colors(j,:));hold on
            drawnow;
        end

  mat.dwl{j}=dwl_out;
        HEADER{end+1}='%First Column Wavelength /nm';
        HEADER{end+1}='%Second Column Interpolated Wavelength shift /nm';
        HEADER{end+1}='%Third Column RAW Wavelength shift /nm';
        HEADER{end+1}='%Fourth Column Residuals dwl_res - RESCRIT(2)';
        HEADER{end+1}='%Fifth Column qflag - RESCRIT(1)';
        HEADER{end+1}='%Sixth Column Acceptance flag = qflag>RESCRIT(1) & dwl_res<RESCRIT(2)';
        HEADER{end+1}='%-------------------------------------';
%        savefmt(p_out,dwl_out,'%wavelength shift (nm) with matshic','%10.2f %10.4f %10.4f %10.6f %10.6f %d');
if ~MATSHIC.fileformatout, % 28 1 2014 JG old ascii format
        % save here the wl-shift to file
        p_out=sprintf('%s/uvanalys/%04d/%s/shift/%sW.%s',ppout,yr,inst,d(j).name(1:8),inst); % 2 6 2014 jg add uvanalys
        savefmt(p_out,dwl_out,HEADER,'%10.2f %10.4f %10.4f %10.6f %10.6f %d');
else
 p_out=matfilename;
end
        
        if ~MATSHIC.noinstspec,  % calculate it, it is 0
        HEADER_conv{end+1}=sprintf('%%Using Wavelength shift file %s',p_out);
        t0=tic;
        [wl,Iinst,Inom]=matshic_shiftspec(spec,ppual(p,spec(:,1)),et_spec,slit,slinom,MATSHIC.wlout);
        t1=toc(t0);
        if debu,
            disp(sprintf('Elapsed time for shifted spec: %f sec',t1));
        end
        
        
        HEADER_conv{end+1}='%First Column Wavelength /nm';
        HEADER_conv{end+1}='%Second Column Convolved file using Nominal slit function';
        HEADER_conv{end+1}='%Third Column Convolved file using Instrument slit function';
        HEADER_conv{end+1}='%-------------------------------------';
        
        dat=[wl Inom Iinst];
       % dat(isnan(dat))=-999;          % 28 1 2014 remove nans and replace with -999, 19 6 2014 JG do only for ascii files
       % 28 1 2014 remove nans and replace with -999
        
 mat.specout{j}=dat;
 if ~MATSHIC.fileformatout,
         % save here the convolved  file
        p_out=sprintf('%s/uvanalys/%04d/%s/%sI.%s',ppout,yr,inst,d(j).name(1:8),inst);
       dat(isnan(dat))=-999;          % 28 1 2014 remove nans and replace with -999, 19 6 2014 JG do only for ascii files
       savefmt(p_out,dat,HEADER_conv,'%10.2f %15.6f %15.6f');
 end
        else
            HEADER_conv{end+1}='% No calculation of conv file';
        end   % of noinstspec
         filecnt=filecnt+1;% all was OK up to here:
 mat.header{j}=HEADER;
 mat.headerconv{j}=HEADER_conv;
       catch
            disp(sprintf('Error during spec %s',fname));
        end
    end
    if MATSHIC.fileformatout & filecnt>0,   % 28 1 2014 JG, here save all data to daily file
        save(matfilename,'-struct','mat');
        disp(sprintf('Saving mat file %s',matfilename));
    end
    if debu>1,   % plot debug information
        %compdwl(i,inst);
       % compshic(i,inst,[]);   % 12 2 2014 JG, is not supported anymore... (for the time being at least)
        plotdebuginfo(mat);  % 11 2 2014 JG
    end
    % write outputr variables
    outcnt=outcnt+1;
    N=length(mat.dwl);
    dwldata=cell2spec(mat.dwl,[],1);
    WL{outcnt}=dwldata(:,1);
    DWL{outcnt}=dwldata(:,2:6:end);
    DWLM{outcnt}=nanmedian(DWL{outcnt},2);
end

function xsec=conv_xsec(wls,P)
 load brion
  ozxsec2(:,1)=brion(:,1)/10;
  ozxsec2(:,4)=brion(:,2);

% 7 6 2012 JG add chappuis band
load o3gome_chappuis
o3xsec=[ozxsec2(:,[1 4]); o3gome(901:end,:)];  % at 901 wl=332.46 nm;
%o3xsec=ozxsec2(:,[1 4]);

k=1.3806e-23;
o3x=o3xsec(:,2).*1.013*1e5/(k*273.1)*1e-6;  
o3wl=o3xsec(:,1); % in nm

ind=diff(o3wl)==0;
o3x(ind)=[];
o3wl(ind)=[];

wll=min(o3wl):0.01:max(o3wl);
do3=spline(o3wl,o3x,wll);
 

buf=falt_eqi(wll,do3,wll,P);
xsec=spline(wll,buf,wls);  % non equidistant wl

xsec(wls>max(wll))=0;
xsec(wls<min(wll))=nan;
xsec=xsec(:);

function cfg=readcfg(site,inst),
global MATSHIC
  matshic_cfg='matshic.cfg';
  maxlines=11;
  
fid=fopen(matshic_cfg,'rt');
if fid<0,error(sprintf('No Config file %s found on the matlab path!!'),matshic_cfg);end
cnt=0;

while ~feof(fid) | cnt<maxlines,
    cnt=cnt+1;
    str=fgetl(fid);
    switch strtok(str),
        case 'pathin',
            cfg.pathin=sscanf(str,'pathin %s');
        case 'pathout',
            cfg.pathout=sscanf(str,'pathout %s');
        case 'et',
            cfg.ET=sscanf(str,'et %s');
        case 'dwlrange',
            cfg.dwlrange=sscanf(str,'dwlrange %f %f %f')';
        case 'dd',
            cfg.DD=sscanf(str,'dd %f');
        case 'fwhmout',
            cfg.fwhmout=sscanf(str,'fwhmout %f');
        case 'wlout',
            buf=sscanf(str,'wlout %f %f %f')';
            cfg.wlout=(buf(1):buf(2):buf(3))';
        case 'rescrit',
            cfg.rescrit=sscanf(str,'rescrit %f %f')';
        case 'formatin',
            cfg.fileformatin=sscanf(str,'formatin %f');
        case 'formatout',
            cfg.fileformatout=sscanf(str,'formatout %f');
        case 'debug',
            cfg.debug=sscanf(str,'debug %f');  % debug
        case 'smoothdwl',
            cfg.smoothdwl=sscanf(str,'smoothdwl %f');  % debug
    end
end
fclose(fid);

fid=fopen([cfg.pathout,'/',site,'.dat'],'rt');
if fid<0,error(sprintf('No Site file %s found on matSHIC path %s!!',[site '.dat'],cfg.pathout));end
cfg.site=fgetl(fid);
cfg.lat=sscanf(fgetl(fid),'%f');
cfg.long=sscanf(fgetl(fid),'%f');
fclose(fid);

cfg.singleslit=0;  % 4 3 2014 JG default
cfg.varslit=0;   % 4 3 2014 default single slit
cfg.noinstspec=0;

% load optional instrument information to overwrite default parameters

fid=fopen([cfg.pathout '/' inst '.dat'],'rt');
if fid<0,
    disp(sprintf('No Instrument specific file %s found on matSHIC path %s\n Using default values',[inst '.dat'],cfg.pathout));
else
    cnt=0;
while ~feof(fid),
    cnt=cnt+1;
    str=fgetl(fid);
    switch strtok(str),
        case 'rescrit',
            cfg.rescrit=sscanf(str,'rescrit %f %f')';
        case 'dwlrange',
            cfg.dwlrange=sscanf(str,'dwlrange %f %f %f')';
        case 'dd',
            cfg.DD=sscanf(str,'dd %f');
        case 'et',
            cfg.ET=sscanf(str,'et %s');
        case 'fwhmout',
            cfg.fwhmout=sscanf(str,'fwhmout %f');
        case 'wlout',
            buf=sscanf(str,'wlout %f %f %f')';
            cfg.wlout=(buf(1):buf(2):buf(3))';
        case 'formatin',
            cfg.fileformatin=sscanf(str,'formatin %f');
        case 'formatout',
            cfg.fileformatout=sscanf(str,'formatout %f');
        case 'debug',
            cfg.debug=sscanf(str,'debug %f');  % debug
        case 'fast',
            cfg.fast=sscanf(str,'fast %f');  % debug
        case 'pathin',
            cfg.pathin=sscanf(str,'pathin %s');
        case 'pathout',
            cfg.pathout=sscanf(str,'pathoutt %s');
        case 'singleslit',
            cfg.singleslit=sscanf(str,'singleslit  %f');   %  use only single slit at this wavelength, otherwise comment out or remove
        case 'noinstspec',
            cfg.noinstspec=sscanf(str,'noinstspec %f');  % 1 means do not calculate instrument slit, 0 do it (default is to do it)

    end
end
fclose(fid);
end

if ~isfield(cfg,'fast'),
    cfg.fast=0;
end

if ~isfield(cfg,'wlout'),
    cfg.wlout=nan;
end

function slitint=gridslit(slit,wl)
% 7 2 2014, JG, fits slit to wavelength grid from spectrum

slitlen=ceil((max(slit.wl)-min(slit.wl))/2+0.1);   % wavelength range given by slit in nm

inc=slitlen/2;
wl_var=[min(wl):inc:max(wl)]';

if wl_var(1)<min(slit.slit_wl),
    slit.slit_wl=[wl_var(1);slit.slit_wl(:)];
    slit.data=[slit.data(:,1) slit.data];
end
if wl_var(end)>max(slit.slit_wl),
    slit.slit_wl=[slit.slit_wl(:);wl_var(end)];
    slit.data=[slit.data slit.data(:,end) ];
end


slitint=griddata(slit.slit_wl,slit.wl,slit.data,wl_var',slit.wl);  % takes about 2.5 seconds , jg machine..., cubic gives bad results

function plotdebuginfo(matdata)
% plots info for this day
% we will assume a uniform wavelength grid
N=length(matdata.dwl);

dwldata=cell2spec(matdata.dwl,[],1);

wl=dwldata(:,1);
dwlfit=dwldata(:,2:6:end);
dwlraw=dwldata(:,3:6:end);
dwlres=dwldata(:,4:6:end);
qflag=dwldata(:,5:6:end);
flag=dwldata(:,6:6:end);

rescrit=matdata.MATSHIC.rescrit;

% estimate best dwlres criterium from the data, assuming qflag is OK:
buf=qflag;
buf(dwlres>rescrit(2))=nan; % 27 2 2014 JG
newqflag=nanmedian(nanmedian(buf,2))/2;

buf=dwlres;

qflag(isnan(qflag))=0;
buf(~qflag)=nan;

newrescrit=nanmedian(nanmedian(buf,2)*2);
disp(sprintf('%s: Old rescrit=[%.1f %.1f]',matdata.MATSHIC.inst,rescrit(1),rescrit(2)));
disp(sprintf('%s: Suggested rescrit=[%.1f %.1f]',matdata.MATSHIC.inst,newqflag,newrescrit));

figure;
buf=[dwlraw];buf(~flag)=nan;
subplot(2,2,1);q=plot(wl,nanmedian(dwlfit,2),wl,dwlfit);title('wavelength shifts');xlabel('Wavelength /nm');ylabel('Wavelength shift /nm');
grid;
set(q(2:end),'color',[0.7 0.7 0.7])
set(q(1),'linewidth',4,'color','k')
set(gca,'children',q)

subplot(2,2,2);q=plot(wl,dwlres,[min(wl) max(wl)],[rescrit(2) rescrit(2)],'k',[min(wl) max(wl)],[newrescrit newrescrit],'r');grid;title('dwl_res');
set(q(end-1:end),'linewidth',4);axis;axis([ans(1:2) 0 4*rescrit(2)]);
subplot(2,2,3);q=plot(wl,qflag,[min(wl) max(wl)],[rescrit(1) rescrit(1)],'k',[min(wl) max(wl)],[newqflag newqflag],'r');grid;title('qflag');
set(q(end-1:end),'linewidth',4);axis;axis([ans(1:2) 0 4*rescrit(1)]);
subplot(2,2,4);
buf=dwlraw;
ind=dwlres<newrescrit & qflag>newqflag;
buf(~ind)=nan;
q=plot(wl,nanmedian(buf,2),wl,buf);title(sprintf('Wavelength shift using new criteria [%.1f %.1f]',newqflag,newrescrit));grid;
xlabel('Wavelength /nm');ylabel('Wavelength shift /nm');
set(q(2:end),'color',[0.7 0.7 0.7])
set(q(1),'linewidth',4,'color','k')
set(gca,'children',q)


function [ETC,mat,HEADER,o3]=prepareETC(spec,slit,et_spec,tm,sza,m,mat,HEADER,debu,j,dwll,P,dwllim)
global MATSHIC
        if nargin<13,dwllim=[];end
        if isempty(dwllim),dwllim=[310 320];end

        indwl=spec(:,1)>dwllim(1) & spec(:,1)<dwllim(2);  % 13 4 2013
        %indwl=spec(:,1)>300 & spec(:,1)<315;
        if isempty(indwl),
            indwl=spec(:,1)>310 & spec(:,1)<min(spec(:,1))+20;  % at least 20 nm
        end
        if MATSHIC.varslit,
            ind=find(slit.slit_wl>=310 & slit.slit_wl<=350);  % choose the slit at the shortest wl
            P=csapi(slit.wl,slit.data(:,ind(1)));
            etc_temp=falt_eqi(et_spec(:,1),et_spec(:,2),et_spec(:,1),P);
            etc=spline(et_spec(:,1),etc_temp,spec(:,1));  % non equidistant grid...
        else
            etc=falt_spec(et_spec(:,1),et_spec(:,2),spec(:,1),P);
        end
        % for ozone retrieval
     %   ind=ETCWL>320 & ETCWL<330;fact=nanmean(spec(ind,2))./nanmean(etc(ind));
        
        % load ozxsec and convolve.
        ozxsec=conv_xsec(spec(:,1),P);
        fact=1;
        etc=etc.*fact;   % 13 4 2013 JG
        o3=fminbnd('wlshiftm_geto3',0,2e3,[],spec(indwl,1),spec(indwl,2),etc(indwl),m,ozxsec(indwl));
        HEADER{end+1}=sprintf('%%Fitting ozone between 310 nm to 320 nm. O3=%5.f DU with SZA=%4.1f and m=%4.1f',o3,sza,m);
   mat.o3(j)=o3;    
       if debu, disp(sprintf('%s o3=%4.0f DU  sza=%3.1f  m=%3.1f',datestr(tm(1)),o3,sza,m));end % 10 7 2014 JG tm is a vector for scanning insts
        transo3=exp(-atmosatten(et_spec(:,1),o3,0,2)*m);
        
       rat=spec(:,2)./(etc.*exp(-ozxsec*o3/1e3*m));
       ind=spec(:,1)>325 & ~isnan(rat);
       if sum(ind)==0, ind=spec(:,1)>310 & ~isnan(rat);end   % 11 7 2014, for single brewer
       pp=polyfit(spec(ind,1),rat(ind),1);
       fact=polyval(pp,spec(:,1)).*fact;
       if fact==0,fact=1;end
       
    if MATSHIC.varslit,
      buf=convvarslit([et_spec(:,1),et_spec(:,2).*transo3],slit); 
      buf=buf(:,2);
    else
    buf=falt_spec(et_spec(:,1),et_spec(:,2).*transo3,et_spec(:,1),P);
    end
    etcpp=linint(et_spec(:,1)',buf(:)');
    
    % now make a huge matrice of shifted ETC... etc is given every 0.01 nm
    ETC=repmat(0,size(spec,1),length(dwll));
    for k=1:length(dwll),
       etc=ppual(etcpp,spec(:,1)+dwll(k)).*fact;
        ETC(:,k)=etc;%*fact;   % reduce with ozone absorption
        
    end

    
