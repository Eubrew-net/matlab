function [dsp_quad dsp_cubic]=read_dsp(dsp_dir,varargin)

% Este script lee las variables ###_yy_ddd.mat que se generan automaticamente cada vez que se procesa
% un test de dispersion y produce un fichero de texto con la siguiente informacion (quad & cubic):
% 
%     'date','Brw','idx','wl_0','wl_2','wl_3','wl_4','wl_5','wl_6',... 
%     'fwhm_0','fwhm_2','fwhm_3','fwhm_4','fwhm_5','fwhm_6','cal_ozonepos','ozonepos',... 
%     'o3_0','o3_2','o3_3','o3_4','o3_5','o3_6'
%     'Ray_0','Ray_2','Ray_3','Ray_4','Ray_5','Ray_6'
% 
% En el caso de que no esté la variable .mat, entonces se procesa el test de la forma acostumbrada (dspreport)
% 
% INPUT
% - dsp_dir: path al directorio de dsp's
%         
% INPUT OPTIONAL:
% - brwid       : número de brewer a procesar (STRING)
% - dsp         : NOMBRE del directorio a procesar (###_yy_ddd)
% - date_range  : Filtro de fechas (fecha matlab, uno o dos elementos).
% - process     : Reprocessing test (even when .mat exist)
% - configs     : Not clear yet
% 
% Si sólo le pasamos brwid, leerá todos los dsp's para el instrumento dado. 
% Si no pasamos ningún argumento, procesará todo lo que hay en dsp_dir.
% 
% OUTPUT: 
% - dsp_quad  : variable con el resultado
% - dsp_cubic : variable con el resultado
% 
% Ambas variables serán escritas en un fichero de texto
% 
% Ejemplo de uso:
% 
% read_dsp(fullfile(Cal.path_root,'..','DSP'),'brwid',Cal.brw_str{Cal.n_inst},...
%                'dsp','157_14_126','date_range',Cal.Date.CALC_DAYS([1 end]));

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'read_dsp';

arg.addRequired('dsp_dir', @ischar);

% input param - value  
arg.addParamValue('brwid'     , ' ', @ischar);            % por defecto, todo lo que hay en dsp
arg.addParamValue('inst'      , [] , @isfloat);           % por defecto, todo lo que hay en dsp
arg.addParamValue('dsp'       , [] , @ischar);            % por defecto, todo lo que hay en dsp
arg.addParamValue('configs'   , {} , @iscell);            % 
arg.addParamValue('date_range', [] , @isfloat);           % por defecto, no date_range
arg.addParamValue('process'   , 0  , @(x)(x==0 | x==1));  % por defecto, no reprocessing

arg.parse(dsp_dir,varargin{:});

%% Initial
labels={'date','Brw','idx','wl_0','wl_2','wl_3','wl_4','wl_5','wl_6',... 
        'fwhm_0','fwhm_2','fwhm_3','fwhm_4','fwhm_5','fwhm_6',... 
        'cal_ozonepos','ozonepos','o3_0','o3_2','o3_3','o3_4','o3_5','o3_6',...
        'Ray_0','Ray_2','Ray_3','Ray_4','Ray_5','Ray_6'};

if isempty(arg.Results.brwid)
   l_all=dir(fullfile('.')); 
   l_all=l_all(cellfun(@(x) ~isempty(x),cellfun(@(x) regexp(x,'^\d\d\d.'),extractfield(l_all,'name'),'UniformOutput' ,0)));
   Cal.brw=unique(cellfun(@(x) sscanf(x,'%d%d%d%*s'),extractfield(l_all,'name')));
else
   Cal.brw=str2double(arg.Results.brwid); l_all=Cal.brw; 
end

if ~isempty(arg.Results.configs)
   Cal.brw_config_files=arg.Results.configs;
end

Cal.n_brw=length(Cal.brw);
Cal.brw_str=cellfun(@(x) num2str(x,'%03d'),num2cell(Cal.brw),'UniformOutput',0);
Cal.brw_name=cellfun(@(x) strcat('#',x),Cal.brw_str,'UniformOutput' ,0);

wv_matrix_quad  = NaN*ones(length(l_all),length(labels));
wv_matrix_cubic = NaN*ones(length(l_all),length(labels));

%% dsp data
idx=1;
for brwi=1:Cal.n_brw
    
    if isempty(arg.Results.dsp)
       l=dir(fullfile(dsp_dir,[Cal.brw_str{brwi},'*'])); ldsp=cellstr(cat(1,l.name));
    else
       ldsp=cellstr(arg.Results.dsp);        
    end
    
    if ~isempty(arg.Results.date_range)
       myfunc=@(x)sscanf(x,'%*3d_%2d_%3d')';    
       A=cell2mat(cellfun(myfunc,ldsp, 'UniformOutput', false));
       %               Año    Dia
       dates=datejuli(A(:,1),A(:,2));    
       ldsp(dates<arg.Results.date_range(1))=[];    dates(dates<arg.Results.date_range(1))=[];
       if length(arg.Results.date_range)>1
          ldsp(dates>arg.Results.date_range(2))=[];
       end
   end
    
    %%
    for indx=1:length(ldsp)  
        info=sscanf(ldsp{indx},'%d_%d_%d'); info_=brewer_date(str2double(sprintf('%03d%02d',info(3),info(2))));
        if ~arg.Results.process
            try
               load(fullfile(dsp_dir,ldsp{indx},strcat(ldsp{indx},'.mat')));
               wv_matrix_quad(idx,:)=cat(2,info_(1),dsp_sum.brewnb,indx,dsp_sum.salida.QUAD{end-1}.thiswl,dsp_sum.salida.QUAD{end-1}.fwhmwl/2,...
                                                    dsp_sum.salida.QUAD{end-1}.cal_ozonepos,dsp_sum.salida.QUAD{end-1}.ozone_pos,...
                                                    dsp_sum.salida.QUAD{end-1}.o3coeff,dsp_sum.salida.QUAD{end-1}.raycoeff);        
               wv_matrix_cubic(idx,:)=cat(2,info_(1),dsp_sum.brewnb,indx,dsp_sum.salida.CUBIC{end-1}.thiswl,dsp_sum.salida.CUBIC{end-1}.fwhmwl/2,...
                                                    dsp_sum.salida.CUBIC{end-1}.cal_ozonepos,dsp_sum.salida.CUBIC{end-1}.ozone_pos,...
                                                    dsp_sum.salida.CUBIC{end-1}.o3coeff,dsp_sum.salida.CUBIC{end-1}.raycoeff);        
            catch exception
               fprintf('%s\n',exception.message);  
               [wv_quad wv_cubic]=no_hay_mat(dsp_dir,ldsp,indx,{arg.Results.inst,Cal.brw_str},Cal.brw_config_files);
               wv_matrix_quad=cat(1,wv_matrix_quad,wv_quad); wv_matrix_cubic=cat(1,wv_matrix_cubic,wv_cubic);
            end
        else
            fprintf('Reprocessing all available tests\n');  
            [wv_quad wv_cubic]=no_hay_mat(dsp_dir,ldsp,indx,{arg.Results.inst,Cal.brw_str},Cal.brw_config_files);
            wv_matrix_quad=cat(1,wv_matrix_quad,wv_quad); wv_matrix_cubic=cat(1,wv_matrix_cubic,wv_cubic);
        end           
        idx=idx+1;
    end
end
% Ordenamos en tuplas brewer - fecha 
dsp_quad=NaN*ones(size(wv_matrix_quad,1),size(wv_matrix_quad,2)); 
dsp_quad(:,[1:2 4:end])=sortrows(wv_matrix_quad(:,[1:2 4:end]),[2 1]); dsp_quad(:,3)=wv_matrix_quad(:,3); 

dsp_cubic=NaN*ones(size(wv_matrix_cubic,1),size(wv_matrix_cubic,2)); 
dsp_cubic(:,[1:2 4:end])=sortrows(wv_matrix_cubic(:,[1:2 4:end]),[2 1]); dsp_cubic(:,3)=wv_matrix_cubic(:,3); 

%% Escribimos el resultado en fichero de texto
if isempty(arg.Results.brwid)
  fid_quad  = fopen(fullfile('.','dsp_summ_all_quad.txt'),'w');
  fid_cubic = fopen(fullfile('.','dsp_summ_all_cubic.txt'),'w');
else
  fid_quad  = fopen(fullfile('.',sprintf('dsp_summ_%03d_quad.txt',Cal.brw)),'w');    
  fid_cubic = fopen(fullfile('.',sprintf('dsp_summ_%03d_cubic.txt',Cal.brw)),'w');    
end

fprintf(fid_quad,'%%%s\n\r',char(labels)'); fprintf(fid_cubic,'%%%s\n\r',char(labels)');
for l=1:size(dsp_quad,1)
    fprintf(fid_quad,'%f %d %d %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %d %d %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f\n\r',dsp_quad(l,:));
    fprintf(fid_cubic,'%f %d %d %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %d %d %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f\n\r',dsp_cubic(l,:));
end
fclose all;

function [wv_matrix_quad wv_matrix_cubic]=no_hay_mat(path_dsp,ldsp,indx,inst_info,brw_config_files) 
               
%% No hay .mat: procesamos el dsp
info=sscanf(ldsp{indx},'%d_%d_%d'); info_=brewer_date(str2double(sprintf('%03d%02d',info(3),info(2))));
Cal.brw_config_files=brw_config_files;
Cal.brw_str=cell(1,inst_info{1}); Cal.brw_str{inst_info{1}}=inst_info{2}{1};

cfg=dir(fullfile(path_dsp,ldsp{indx},'orig',strcat('icf*.',inst_info{2}{1})));
dsp_=fullfile(path_dsp,ldsp{indx},'orig',strcat('DSP.',inst_info{2}{1}));
if ~isempty(cfg)
   config_n=1;
   Cal.brw_config_files{inst_info{1},config_n}=fullfile(path_dsp,ldsp{indx},'orig',cfg.name); 
   csn=[];
elseif exist(dsp_,'file')==2
   config_n=1;
   fid=fopen(dsp_,'r');  
   csn=textscan(fid,'%f','HeaderLines',1); csn=[csn{1}(3),csn{1}(1),csn{1}(4)];
   fclose(fid);       
else
   config_n=2; csn=[];
end
           
try
   close all;
   Cal.n_inst=inst_info{1}; Cal.Date.cal_year=year(now);
   dspreport(Cal,'dsp_dir',fullfile(path_dsp,ldsp{indx}),'config_n',config_n,'csn',csn);
             
   load(fullfile(path_dsp,ldsp{indx},strcat(ldsp{indx},'.mat')));
   wv_matrix_quad =cat(2,info_(1),dsp_sum.brewnb,indx,dsp_sum.salida.QUAD{end-1}.thiswl,dsp_sum.salida.QUAD{end-1}.fwhmwl/2,...
                                         dsp_sum.salida.QUAD{end-1}.cal_ozonepos,dsp_sum.salida.QUAD{end-1}.ozone_pos,...
                                         dsp_sum.salida.QUAD{end-1}.o3coeff,dsp_sum.salida.QUAD{end-1}.raycoeff);        
   wv_matrix_cubic=cat(2,info_(1),dsp_sum.brewnb,indx,dsp_sum.salida.CUBIC{end-1}.thiswl,dsp_sum.salida.CUBIC{end-1}.fwhmwl/2,...
                                         dsp_sum.salida.CUBIC{end-1}.cal_ozonepos,dsp_sum.salida.CUBIC{end-1}.ozone_pos,...
                                         dsp_sum.salida.CUBIC{end-1}.o3coeff,dsp_sum.salida.CUBIC{end-1}.raycoeff);        
catch exception
      fprintf('%s\n',exception.message);        
end       
