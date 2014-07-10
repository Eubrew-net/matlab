function [wl,Iinst,Inom,dwl]=matshicspec(wl,spec,inst,crit,yr)
%function [wl,Iinst,Inom,dwl]=matshicspec(wl,spec,inst,crit,debu,yr)
% 30 7 2013 JG, is matshic but for already loaded spectra
%
%Operational WL-Shift software on Matlab L.E. 27.3.2013 for QASUME campaign LaReunion
% remarks:
% - Input spectrum should have a resoultion of 0.25 nm
% 8 4 2013 JG make function and compatible with STRELA
% 12 4 2013 JG add res criterium.Important to have correct slit function
% default crit=0.02 for shic
% dwl is shift of ET to agree with spec
% 25 4 2013 JG, adapt for our corona directory structure (using shicrivm''')
% debu=0, no debug information
% debu=1 , plots figures of wlshifts for checking best criterium...

REFET='kp320a3l.et';
REFET='MHP_COKITH.dat';

fwhm=1; % default nominal slit function

if nargin<5,yr=[];end
if isempty(yr),yr=2013;end

if nargin<4,crit=[];end
if isempty(crit),crit=0.02;end

pp='\\corona\calib/uv/shicrivm/';   % to be adapted for Strela, ...

ppout='\\corona\calib/uv/qasume/matshic/';  % to be adapted for other PCs ...


%load here traditional ET (important to divide by 1000)
et_spec = load(REFET,'ascii');   % still in this matshic directory
et_spec(:,2) = et_spec(:,2)./1000;

% load here instrument slit function
sli = liesfile(sprintf('%s/uvanalys/%04d/%s.sli',pp,yr,inst),1);

% nominal slit
slinom=brslit(fwhm,[],1);

%path of input data
N=size(spec,2);

for j=1:N
    SPEC=[wl spec(:,j)];
    
    % here starts the wl-shift routine
    %dwll=[290:450];
    dwll=[min(SPEC(:,1)): max(SPEC(:,1))]';
    
    t0=tic;
    [dwl_shift,res,flag,wlrange]=wlshiftm_env03([SPEC(:,1) SPEC(:,2)],dwll,8,sli,et_spec,crit);
    t1=toc(t0);
    dwl_out=[dwll dwl_shift res flag];
    if 0,
        % save here the wl-shift to file
        p_out=sprintf('%s/%04d/%s/shift/%sW.%s',ppout,yr,inst,d(j).name(1:8),inst);
        if ~exist(sprintf('%s/%04d',ppout,yr),'dir'),
            mkdir(sprintf('%s/%04d',ppout,yr));
        end
        if ~exist(sprintf('%s/%04d/%s',ppout,yr,inst),'dir'),
            mkdir(sprintf('%s/%04d/%s',ppout,yr,inst));
            mkdir(sprintf('%s/%04d/%s/shift',ppout,yr,inst));
            
        end
        savefmt(p_out,dwl_out,'%wavelength shift (nm) with matshic','%10.2f %10.4f %10.6f %d');
    end
    
    if sum(flag)==0 % 2 5 2013, JG no wlshift within criterium,
        p=linint(dwll([1 end])',[0 0]);  % make no wlshift
    else
        p=linint(dwll(flag,1)',dwl_shift(flag)');
    end
    t0=tic;
    dwl(:,j)=ppual(p,SPEC(:,1));

    [wl_out,Iinst(:,j),Inom(:,j)]=qasume_shiftspec(SPEC,ppual(p,SPEC(:,1)),et_spec,sli,slinom);
    t1=toc(t0);
    
    if 0,
        % save here the wl-shift-ed  file
        p_out=sprintf('%s/%04d/%s/%sI.%s',ppout,yr,inst,d(j).name(1:8),inst);
        dat=[wl Inom Iinst];
        savefmt(p_out,dat,'%Shifted file with matshic','%10.2f %15.6f %15.6f');
    end
end
