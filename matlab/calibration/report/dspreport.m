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
%% o poner como parametro el directorio de dispersion que interese
% tambi�n se podr�an hacer dos modos: uno depuracion y otro final que no plotee los scanes individuales

function [res,detail, ...
       DSP_QUAD,QUAD_SUM,QUAD_DETAIL,CUBIC_SUM,CUBIC_DETAIL,salida...
       ]=dspreport(file_setup,n_inst,dsp_directory)
eval(file_setup);
if nargin==2
    n_inst=n_inst;
end
if nargin==2
s=dir(['DSP',filesep(),brw_str{n_inst},'*']);
else
s(1).name=(dsp_directory);
s(1).isdir=1;
end
for j=1:length(s)
    if s(j).isdir
       aux=sscanf(s(j).name,'%d_%d_%d');
       day=aux(3);
       year=aux(2);
       brewnb=aux(1);
       path=fullfile('.',s(j).name,filesep);
       cfg=read_icf([brw_config_files{n_inst,2}]);
       coment=brw_str{n_inst};
       cd('DSP')
       
       uvr_file=dir(['..',filesep(),brw_str{n_inst},filesep(),'UVR*.',brw_str{n_inst}]);
       if ~isempty(uvr_file)
           uvr=load(['..',filesep(),brw_str{n_inst},filesep(),uvr_file(1).name]);
       else
           uvr=[];
       end
       
       [res,detail, ...
       DSP_QUAD,QUAD_SUM,QUAD_DETAIL,CUBIC_SUM,CUBIC_DETAIL,salida...
       ]=dsp_report(day,year,brewnb,path,cfg,coment,uvr);

%       QUAD_SUM_table=dsp_tables(DSP_QUAD,QUAD_SUM,QUAD_DETAIL);
       cd('..')
   else
    disp('err');
   end
end


