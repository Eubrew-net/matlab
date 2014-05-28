function [res,detail, DSP_QUAD,QUAD_SUM,QUAD_DETAIL,CUBIC_SUM,CUBIC_DETAIL,...
             salida,CSN]=dspreport(file_setup,varargin)
         
% Dispersion Analysis REPORT
%
%  % res= step o3abs so2abs o3/so2 Raley ETC
%     5 steps (step_3=cal_step) X six colums x 2 methods
%     method 1=normal    method 2= Julian
%  % detail=(6,6,5,2)
%   6 wavelenth X 6 columns X 5 stpes X 2 methods  
%   detail colummn-> wavelength ; Resolution;o3abs ;so2abs; Raley; ETC
%     method 1=normcdal    method 2= Julian 

% A�ado salida QUAD_SUM_table para report
% Se incluye la posibilidad de uvr
% TODO: poner todas las salidas en ceTldas
% ahora no saca todas solo la 'ULITIMA'
% TODO: Reorganizar las salidas
%
%
         
%% Validamos argumentos                                                      
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'dspreport';

% input obligatorio
arg.addRequired('file_setup'); 


% input param - value
arg.addOptional('n_inst',NaN,@isfloat); % Es opcional -------------> Ya esta en config
arg.addOptional('dsp_dir','',@ischar);% por defecto todos los dsp's
arg.addOptional('config_n',2,@(x)(isfloat(x) || ischar(x)));% por defecto la confg. final (2)
arg.addOptional('csn',[],@(x)isfloat(x));% por defecto la confg. final (2)

% validamos los argumentos definidos:
try
arg.parse(file_setup,varargin{:});
mmv2struct(arg.Results);
chk=1;

catch
  errval=lasterror;
  if length(varargin)==3
      dsp_dir=varargin{1};
      config_n=varargin{2};
      n_inst=varargin{3};
  elseif length(varargin)==2
      dsp_dir=varargin{1};
      config_n=varargin{2};
      n_inst=NaN; % por defecto 
  elseif length(varargin)==1
      dsp_dir=varargin{1};
      config_n=2; % por defecto 
      n_inst=NaN; % por defecto 
  else
      dsp_dir='';   % por defecto todos los DSP's
      config=''; % por defecto valores nominales      
      n_inst=NaN; % por defecto 
  end
  chk=0;
end


if isnan(n_inst) n_inst=file_setup.n_inst; end

%%
if isstruct(file_setup)
  brw_config_files=file_setup.brw_config_files;
  brw_str=file_setup.brw_str; calyear=file_setup.Date.cal_year;
else
   eval(file_setup);
end

if isempty(dsp_dir)
   s=dir(['DSP',filesep(),brw_str{n_inst},'*']);
   res={}; detail={};DSP_QUAD={};QUAD_SUM={};QUAD_DETAIL={};
   CUBIC_SUM={};CUBIC_DETAIL={};salida={};
else
   s(1).name=(dsp_dir);
   s(1).isdir=1;
end

    
for j=1:length(s)
    if s(j).isdir
       [a name]=fileparts(s(j).name);
       aux=sscanf(name,'%d_%d_%d');
       day=aux(3);
       year=aux(2);
       brewnb=aux(1);
       datefile=datenum(year+2000,1,0)+day
       path=fullfile('.',name,filesep);
       try
         if ischar(config_n)
           cfg=read_icf(config_n,datefile); CSN=[cfg(14) cfg(8) cfg(44)];
         else
           cfg=read_icf([brw_config_files{n_inst,config_n}],datefile); CSN=[cfg(14) cfg(8) cfg(44)];
         end   
       catch
          cfg=NaN*ones(44,1);
       end
       if ~isempty(csn)
           cfg(14)=csn(1); cfg(8)=csn(2); cfg(44)=csn(3);
       end
       coment=brw_str{n_inst};       
       uvr_file=dir(['..',filesep(),brw_str{n_inst},filesep(),'UVR*.',brw_str{n_inst}]);
       if ~isempty(uvr_file)
           uvr=load(['..',filesep(),brw_str{n_inst},filesep(),uvr_file(1).name]);
       else
           uvr=[];
       end
       if isempty(dsp_dir)
          [res{j},detail{j}, ...
          DSP_QUAD{j},QUAD_SUM{j},QUAD_DETAIL{j},CUBIC_SUM{j},CUBIC_DETAIL{j},salida{j}...
          ]=dsp_report(day,year,brewnb,dsp_dir,cfg,coment,uvr);% path
%          ]=dsp_report(day,year,brewnb,path,cfg,coment,uvr);
       else
          [res,detail, ...
          DSP_QUAD,QUAD_SUM,QUAD_DETAIL,CUBIC_SUM,CUBIC_DETAIL,salida...
          ]=dsp_report(day,year,brewnb,dsp_dir,cfg,coment,uvr);           
%          ]=dsp_report(day,year,brewnb,path,cfg,coment,uvr);           
       end
       
       dsp_sum.day=day;
       dsp_sum.year=year;
       dsp_sum.brewnb=brewnb;
       dsp_sum.cfg=cfg;
       dsp_sum.uvr=uvr;
       dsp_sum.res=res;
       dsp_sum.detail=detail;
       dsp_sum.salida=salida;
       save(fullfile(dsp_dir,sprintf('%03d_%02d_%03d',brewnb,year,day)),'dsp_sum') 
%       save( fullfile(path,sprintf('%03d_%02d_%03d',brewnb,year,day)),'dsp_sum') 
       
   else
    disp('err');
   end
end


