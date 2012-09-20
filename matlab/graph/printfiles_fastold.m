
function Options=printfiles(n0,n1,patern,Options)

Options.Format='eps';   %'Format'  a string specifies the output format. Defaults to 'eps'. For 
Options.Preview='tiff'; %'Preview' one of the strings 'none', 'tiff' specifies a preview for EPS files. Defaults to 'none'.  

Options.Width=13.5;  %cm a positive scalar specifies the width in the figure's PaperUnits
Options.Height=7.5;  %a positive scalar  specifies the height in the figure's PaperUnits
                   %Specifying only one dimension sets the other  dimension so that the exported aspect ratio is the same as the
                   %figure's or reference axes' current aspect ratio. 
Options.Bounds='loose';  %'Bounds' one of the strings 'tight', 'loose'  specifies a tight or loose bounding box. Defaults to 'tight'.
%Options.Reference       %'Reference' an axes handle or a string  specifies that the width and height parameters
                         %are relative to the given axes. If a string is  specified then it must evaluate to an axes handle.
 
Options.Color='cmyk' ;  %one of the strings 'bw', 'gray', 'cmyk','rgb' The default color setting is 'bw'.
Options.Resolution=300; %a positive scalar  specifies the resolution in dots-per-inch.
Options.LockAxes=1;     %LockAxes'  one of 0 or 1 specifies that all axes limits and ticks should be fixed  while exporting.
      
      
Options.FontMode='fixed';  %one of the strings 'scaled', 'fixed'
Options.FontSize=11.5;     %'scaled' mode multiplies with the font size of each  text object to obtain the exported font size
                           %'fixed' mode specifies the font size of all text objects in points
                           %If FontMode is 'scaled' but FontSize is not specified then a  scaling factor is computed from the ratio of the size of the
                           %exported figure to the size of the actual figure. The default 'FontMode' setting is 'scaled'.
Options.DefaultFixedFontSize=18; %a positive scalar in 'fixed' mode specified the default font size in points
Options.FontSizeMin=5;           %a positive scalar specifies the minimum font size allowed after scaling
Options.FontSizeMax=18;          %a positive scalar specifies the maximum font size allowed after scaling

Options.LineMode='fixed';
Options.Linewidth=1;         
      
Options.FontEncoding='latin1'; %one of the strings 'latin1', 'adobe' specifies the character encoding of the font
Options.SeparateText=0 ;       %one of 0 or 1 specifies that the text objects are stored in separate
                               %file as EPS with the base filename having '_t' appended.end

mkdir('figures'); cwd=pwd; cd('figures');
try
 for i=n0:n1
    h=figure(i);
    label=get(h,'Tag');
%     grid on;
    figura=[patern,'_',label];%,num2str(i)];
    
    set(h,'WindowStyle','normal');    
    set(h,'PaperUnits','centimeters');
    set(h,'PaperPositionMode','Auto')
  
    applytofig(h,Options);
    previewfig(h,Options);
    exportfig(h,[strtok(figura,'.')],Options);
%    save as fig file
    saveas(h,[patern,label,num2str(i)],'fig');

    
%     saveas(h,[patern,num2str(i)],'fig');
%      print(h,'-r300','-dpng',[patern,label]);
%     if ispc
%      save2word([patern,'.doc']);
%     end
%     %orient landscape;
%      if i==n0
%         print(h,'-dpsc','-r300',patern);
%     else
%        print(h,'-dpsc','-append','-r300',[patern,label]);
%     end
    close(h);
end
cd(cwd);
catch
    cd(cwd);
end