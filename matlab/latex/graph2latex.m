function graph2latex(path,pattern,brew,varargin)

% Uso:
% graph2latex(path,pattern,brew,varargin)
% donde
%   - path es el directorio donde se encuentran los gráficos a incluir   
%   - pattern es un cell array de dos elementos con:
%                 1- pattern{1} Nombre parcial del archivo tex que vamos a crear
%                 2- pattern{2} patrón de busqueda a aplicar
%   - brew es el numero de brewer (string)
% 
%   - varargin es uno o combinacion de los siguientes
%            'scale', float -> Escalar el tamaño de los graficos
% 
% Ejemplo:
%  graph2latex(dir_figs,{'apendiceSC','SC_INDIVIDUAL'},brw_str{n_inst},'scale',0.8);
% 
% El fichero latex resultante se puede incluir en cualquier fichero latex 
% como /input{salida.tex}
  

    idx=sort(findobj('-regexp','Tag',sprintf('%c%s','^',pattern{2})));
    filename=[pattern{1},'_',brew,'.tex'];
    fid = fopen(fullfile(path,filename), 'w');
    
    
    for jj=1:length(idx)   
        if jj==1
           fprintf(fid,'\\begin{figure}[h!]\r\n');
        else
           fprintf(fid,'\\begin{figure}[p]\r\n');            
        end
        fprintf(fid,'\t\\begin{center}\r\n'); 
        if strcmp(varargin{1},'scale')
           fprintf(fid,'\\includegraphics[scale=%s]{./%s_figures/%s_figures_%s.eps}\r\n',...
                       num2str(varargin{2}),brew,brew,get(idx(jj),'Tag'));
        end
        fprintf(fid,'\t\\end{center}\r\n');
        fprintf(fid,'\\end{figure}\r\n\r\n');
        if mod(jj,15)==0
           fprintf(fid,'\\clearpage\r\n\r\n');
        end            
    end
    fclose(fid);