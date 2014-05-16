function Options=printfiles_report(n0,patern,varargin)
% function Options=printfiles_report(n0,patern,varargin)
% print eps files acording with format
% 30/04/2010 Juanjo: para el caso de m?ltiples figuras habr?n varias
%                    posibilidades: 
%                    1) No se especifica un 'aux_pattern'. En ese caso se
%                    imprimen todas las figuras sin a?adir ningun
%                    identificador al nombre. El problema surge cuando hay
%                    multiples figuras con igual Tag. En este caso las
%                    segundas sustituyen a las primeras
%                    2) Si se especifica el argumento 'aux_pattern', en ese
%                    caso se enumeran las figuras se?aladas en n0, la
%                    primera no y a partir de ah? empezando con 1 en
%                    adelante. Cabe la posibilidad tambi?n de especificar
%                    un cell de strings, tantos como figuras se quieran
%                    imprimir.


Options.Format='eps';   %'Format'  a string specifies the output format. Defaults to 'eps'. For 
Options.Preview='tiff'; %'Preview' one of the strings 'none', 'tiff' specifies a preview for EPS files. Defaults to 'none'.  

Options.Width=12;  %cm a positive scalar specifies the width in the figure's PaperUnits
Options.Height=6.5;  %a positive scalar  specifies the height in the figure's PaperUnits
                   %Specifying only one dimension sets the other  dimension so that the exported aspect ratio is the same as the
                   %figure's or reference axes' current aspect ratio. 
Options.Bounds='tight';  %'Bounds' one of the strings 'tight', 'loose'  specifies a tight or loose bounding box. Defaults to 'tight'.
% Options.Reference='auto';   %'Reference' an axes handle or a string  specifies that the width and height parameters
                         %are relative to the given axes. If a string is  specified then it must evaluate to an axes handle.
 
Options.Color='cmyk' ;  %one of the strings 'bw', 'gray', 'cmyk','rgb' The default color setting is 'bw'.
Options.Resolution=300; %a positive scalar  specifies the resolution in dots-per-inch.
Options.LockAxes=1;     %LockAxes'  one of 0 or 1 specifies that all axes limits and ticks should be fixed  while exporting.
      
      
Options.FontMode='scaled';  %one of the strings 'scaled', 'fixed'
Options.FontSize=.9;     %'scaled' mode multiplies with the font size of each  text object to obtain the exported font size
                           %'fixed' mode specifies the font size of all text objects in points
                           %If FontMode is 'scaled' but FontSize is not specified then a  scaling factor is computed from the ratio of the size of the
                           %exported figure to the size of the actual figure. The default 'FontMode' setting is 'scaled'.
Options.DefaultFixedFontSize=15; %a positive scalar in 'fixed' mode specified the default font size in points
Options.FontSizeMin=5;           %a positive scalar specifies the minimum font size allowed after scaling
Options.FontSizeMax=18;          %a positive scalar specifies the maximum font size allowed after scaling

Options.LineMode='fixed';
Options.Linewidth=1;         
      
Options.FontEncoding='latin1'; %one of the strings 'latin1', 'adobe' specifies the character encoding of the font
Options.SeparateText=0 ;       %one of 0 or 1 specifies that the text objects are stored in separate
                               %file as EPS with the base filename having '_t' appended.end

okargs = {'Format','Color','Width','Height','LineWidth','DefaultFixedFontSize',...
          'LockAxes','FontSize','FontMode','aux_pattern','LineMode','Reference','axes'};

for j=1:2:(length(varargin)-1)
    pname = varargin{j};
    pval = varargin{j+1};
    k = strmatch(pname, okargs);
    if isempty(k)
        disp(sprintf('%s %s','Error printfiles_fast: Unknown parameter name ', pname));
    elseif length(k)>1
        disp(sprintf('%s %s','Error printfiles_fast: Ambiguous parameter name ', pname));
    else
        switch(k)
            case 1  % Format
                Options.Format = pval;
            case 2  % color
                Options.Color = pval;
            case 3  % Width
                Options.Width = pval;
            case 4  % Height
                Options.Height = pval;
            case 5  % LineWidth
                Options.Linewidth = pval;
            case 6  % FontSize
                Options.DefaultFixedFontSize = pval;
            case 7  % Lockaxes
                Options.LockAxes=pval;
            case 8  % FontSize
                Options.FontSize=pval;
            case 9  % FontSize
                Options.FontMode=pval;
            case 10  % aux_pattern
                aux_pattern=pval;
            case 11  % LineMOde
                Options.LineMode=pval;
            case 12  % Reference
                Options.Reference=pval;             
            case 13  % Axes
                Options.axes=pval;             
        end
    end
end
                               
cwd=pwd; cd(patern);
naux=1; % contador de figuras
try
 for i=n0
     set(findobj(gcf,'Tag','legend'),'HandleVisibility','Off');
     h=figure(i);
     label=get(h,'Tag');
     brw=regexp(patern,'\<\d\d+\_\w+\>','match');
          if isempty(brw); brw={'General'}; end
     if exist('aux_pattern','var')
        if isnumeric(aux_pattern)
           if i==n0(1)
              figura=[brw{1},'_',label]; 
           else
              figura=[brw{1},'_',label,'_',num2str(naux)];    
              naux=naux+1;   
           end
        elseif iscell(aux_pattern)
            figura=[brw{1},'_',label,'_',aux_pattern{naux}];
            naux=naux+1;            
        end
     else
%         if i==n0(1)
         figura=[brw{1},'_',label]; 
%         else
%          figura=[brw{1},'_',label,'_',num2str(naux)];    
%          naux=naux+1;   
%         end
     end
     figura=strrep(figura,' ','_');
     
     set(h,'WindowStyle','normal');
     set(h,'PaperUnits','centimeters');
     set(h,'PaperPositionMode','Auto')
     orient portrait
  
     if any(strcmp(varargin,'no_export'))
        applytofig(h,Options);
        print(h,'-depsc','-tiff','-r300','-cmyk',[figura,'.eps']);
        
     else
        exportfig(h,strtok(figura,'.'),Options);
     end
     %saveas(h,figura,'fig');
     saveas(h,figura,'png');
end
cd(cwd);
catch exception
      fprintf('Error en printfiles_report: %s\n',exception.message); 
      cd(cwd);
end