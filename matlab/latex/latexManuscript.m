function latexManuscript(latexsource,latexout,hidecomments,spaceflag,figurename,figurestart)
% latexManuscript collects system of LaTeX files into one LaTeX
% manuscript file. The LaTeX files must be linked together by
% the '\input{}' command. The bibliography file must be a '.bbl'
% (obtained form bibtex) with the same file name,
% and be in the same folder as 'latexsource'. An option is to rename
% figure names in numbering order, e.g. Fig1, Fig2, Fig3 and so on
% in the way thay appear in the manuscript. The new file names are
% documented in the file 'newFigureFiles.txt'.
% 
% Usage:
%
% (only the manuscript, figures unchanged)
% 
% latexManuscript(latexsource,latexout)
% latexManuscript(latexsource,latexout,hidecomments,spaceflag)
%
% (manuscript with/and new figure file names)
% 
% latexManuscript(latexsource,latexout,hidecomments,spaceflag)
%
% 
% Inputs:
% 
% latexsource - The LaTeX compileable file.
% latexout - Output LaTeX file. Must be different from latexsource. 
% hidecomments - (optional) Flag (0/1).
%                 0 (default) show comments, 1 hide comments.
% spaceflag - (optional) Flag ((-1),(0),1,2,3...).
%              >0 Removes spaces more than "spaceflag" in a line.  
%              0 (default) no removal of spaces.
%             -1 Replaces all spaces of type '160' to spaces of type '32'.
% figurename - The common new figure name. (default) 'Fig'
%              Folders will be relative to folder in latexout.
%              If no folder name is given in figurename the new figures
%              will be copied to the same folder as latexout.
% figurestart - first figure number. (default) 1
%               The figures will be numbered {figurestart},
%               {figurestart}+1, , {figurestart}+2 and so on.
% 
% Example:
% 
% (only manuscript)
%
% latexManuscript('c:/latex/paper.tex','c:/latex/fullpaper.tex')
%
% 
% (manuscript and figures)
%
% latexManuscript('c:/latex/paper.tex','c:/latex/manuscript/fullpaper.tex',0,0,'Fig',1)
%
% written by Per Bergström 2009-02-05
% 
% Free for download at
%
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=
% 19920&objectType=FILE
%
% e-mail: per.bergstrom 'at' ltu.se

if nargin<6
    figurestart=1;
    if nargin<5
        figurename='Fig';
        if nargin<4
            spaceflag=0;
            if nargin<3
                hidecomments=0;
                if nargin<2
                    error('LaTeX source file and LaTeX output file must be specified!');
                end
            end
        end
    end
end

if isempty(spaceflag)
    spaceflag=0;
end
if isempty(hidecomments)
    hidecomments=0;
end
if isempty(figurestart)
    figurestart=1;
end
if isempty(figurename)
    figurename='Fig';
end

% Check
if length(latexsource)>4
    if not(all(latexsource((end-3):end)=='.tex'))
        latexsource=[latexsource,'.tex'];
    end
else
    latexsource=[latexsource,'.tex'];
end

% Correct '\' to '/'
for i=1:length(latexsource)
    if latexsource(i)=='\'
        latexsource(i)='/';
    end
end

% Finds out the home directory
indsla=find(latexsource=='/',1,'last');
if isempty(indsla)
    homedirectory='';
else
    homedirectory=latexsource(1:indsla);
end


% Check
if length(latexout)>4
    if not(all(latexout((end-3):end)=='.tex'))
        latexout=[latexout,'.tex'];
    end
else
    latexout=[latexout,'.tex'];
end

% Correct '\' to '/'
for i=1:length(latexout)
    if latexout(i)=='\'
        latexout(i)='/';
    end
end

% Finds out the new directory
indsla=find(latexout=='/',1,'last');
if isempty(indsla)
    newdirectory='';
else
    newdirectory=latexout(1:indsla);
end


try
    % Reads bib generated '.bbl' file.
    bibitems=getLaTeX([latexsource(1:(end-4)),'.bbl'],hidecomments,[],homedirectory);
catch
    bibitems=[];
end

% Gets the new LaTeX source code
if nargin>4
    % Correct '\' to '/'
    for i=1:length(figurename)
        if figurename(i)=='\'
            figurename(i)='/';
        end
    end
    extraSpaces=figurename==' ';
    figurename=figurename(not(extraSpaces));
    if not(all(extraSpaces))
        if figurename(1)=='/'
            figurename=figurename(2:end);
        end
    end
    laou=getLaTeX(latexsource,hidecomments,bibitems,homedirectory,newdirectory,figurename,figurestart);
else
    laou=getLaTeX(latexsource,hidecomments,bibitems,homedirectory);
end

% For removal of unneccesary blank rows
bolvec=logical(ones(1,length(laou)));
isemptyrow=logical(1);
is=1;
ie=length(laou)+1;
ieP=ie;
while is<length(laou)
    for i=is:(length(laou)-1)
        if and(laou(i)==13,laou(i+1)==10)
            ie=i+1;
            break
        end
    end
    if ie>length(laou)
        break
    end
    if all(laou(is:ie)==13 | laou(is:ie)==10 | laou(is:ie)==32 | laou(is:ie)==160)
        if isemptyrow
            bolvec(is:ie)=logical(0);
        else
            isemptyrow=logical(1);
        end
    else
        isemptyrow=logical(0);
    end
    if ie==ieP
        ie=ie+1;
    end
    ieP=ie;
    is=ie+1;
end
laou=laou(bolvec);

if hidecomments
    bolvec=logical(ones(1,length(laou)));
    for i=1:(length(laou)-15)
        if all(laou(i:(i+7))==uint8('\author{'))
            co=1;
            iend=length(laou);
            for j=(i+8):(length(laou))
                if laou(j)==uint8('}')
                    co=co-1;
                end
                if laou(j)==uint8('{')
                    co=co+1;
                end
                if co==0
                    iend=j;
                    break
                end
            end
            
            for j=(i+8):(iend-8)
                if all(laou(j:(j+7))==uint8('\thanks{'))
                    for k=(j-1):-1:i
                        if or(or(or(laou(k)==32,laou(k)==13),laou(k)==10),laou(k)==160)
                            bolvec(k)=logical(0);
                        else
                            break
                        end
                    end
                end
            end
            for j=(i+8):(iend-26)
                if all(laou(j:(j+25))==[92   73   69   69   69   99  111  109  112  115  111   99  105  116  101  109  105  122 101  116  104   97  110  107  115  123])
                    for k=(j-1):-1:i
                        if or(or(or(laou(k)==32,laou(k)==13),laou(k)==10),laou(k)==160)
                            bolvec(k)=logical(0);
                        else
                            break
                        end
                    end
                end
            end            
            for k=(iend-1):-1:i
                if or(or(or(laou(k)==32,laou(k)==13),laou(k)==10),laou(k)==160)
                    bolvec(k)=logical(0);
                else
                    break
                end
            end
            
        elseif all(laou(i:(i+14))==uint8('\end{biography}'))
            for k=(i-3):-1:1
                if or(or(or(laou(k)==32,laou(k)==13),laou(k)==10),laou(k)==160)
                    bolvec(k)=logical(0);
                else
                    break
                end
            end
        end
    end
    for i=1:(length(laou)-34)
        % before abstract and after keywords
        if all(laou(i:(i+34))==[92 73  69   69   69   99  111  109  112  115  111   99  116  105  116  108  101  97 98  115  116  114   97   99  116  105  110  100  101  120  116  101  120  116  123])
            co=1;
            iend=length(laou);
            for j=(i+8):(length(laou))
                if laou(j)==uint8('}')
                    co=co-1;
                elseif laou(j)==uint8('{')
                    co=co+1;
                end
                if co==0
                    iend=j;
                    break
                end
            end
            for k=(i+35):iend
                if or(or(or(laou(k)==32,laou(k)==13),laou(k)==10),laou(k)==160)
                    bolvec(k)=logical(0);
                else
                    break
                end
            end             
            for k=(iend-1):-1:i
                if or(or(or(laou(k)==32,laou(k)==13),laou(k)==10),laou(k)==160)
                    bolvec(k)=logical(0);
                else
                    break
                end
            end            
        end
    end    
    for i=1:(length(laou)-25)
        if all(laou(i:(i+25))==[92  101  110  100  123   73   69   69   69   98  105  111  103  114   97  112  104  121 110  111  112  104  111  116  111  125])
            for k=(i-3):-1:1
                if or(or(or(laou(k)==32,laou(k)==13),laou(k)==10),laou(k)==160)
                    bolvec(k)=logical(0);
                else
                    break
                end
            end
        elseif all(laou(i:(i+18))==[92  101  110  100  123   73   69   69   69   98  105  111  103  114   97  112  104  121 125])
            for k=(i-3):-1:1
                if or(or(or(laou(k)==32,laou(k)==13),laou(k)==10),laou(k)==160)
                    bolvec(k)=logical(0);
                else
                    break
                end
            end
        end
    end
    for k=(length(laou)):-1:1
        if or(or(or(laou(k)==32,laou(k)==13),laou(k)==10),laou(k)==160)
            bolvec(k)=logical(0);
        else
            break
        end
    end 
    for i=1:(length(laou)-20)
        if all(laou(i:(i+20))==uint8('\end{thebibliography}'))
            for k=(i-3):-1:1
                if or(or(or(laou(k)==32,laou(k)==13),laou(k)==10),laou(k)==160)
                    bolvec(k)=logical(0);
                else
                    break
                end
            end
        end
    end    
    laou=laou(bolvec);
    
    for i=1:(length(laou)-13)
        if all(laou(i:(i+13))==uint8('\documentclass'))
            if i==1
                newro=[];
            else
                newro=[13,10];
            end
            laou=[laou(1:(i-1)),newro,uint8('%10pt,12pt,letterpaper,a4paper,journal,final,draft,draftcls,draftclsnofoot,conference,technote,captionsoff,onecolumn,twocolumn'),13,10,uint8('%12pt,letterpaper,peerreviewca,onecolumn,draftcls   10pt,letterpaper,journal,compsoc'),13,10,uint8('%See your .cls file for more information.'),13,10,laou(i:end)];
            break
        end
    end
  
end

% spaceflag
if spaceflag>0
    bolvec=logical(ones(1,length(laou)));
    is=1;
    ie=length(laou);
    while is<length(laou)
        for i=is:length(laou)
            if not(or(laou(i)==32,laou(i)==160))
                ie=i-1;
                break
            end
        end
        if (is+spaceflag)<=ie
            bolvec((is+spaceflag):ie)=logical(0);
        end
        is=ie+2;
    end
    laou=laou(bolvec);
elseif spaceflag<0
    if any(laou==160)
        laou(laou==160)=32;
    end
end

% Add info
if not(hidecomments)
    infodoc=[uint8('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'),13,10];
    infodoc=[infodoc,uint8('%%                                                              %%'),13,10];
    infodoc=[infodoc,uint8('%%   LaTeX file gathered using ´latexManuscript´ for MATLAB.    %%'),13,10];
    infodoc=[infodoc,uint8('%%                                                              %%'),13,10];
    infodoc=[infodoc,uint8('%%   The script code ´latexManuscript´ is written by            %%'),13,10];
    infodoc=[infodoc,uint8('%%                                                              %%'),13,10];
    infodoc=[infodoc,uint8('%%   Per Bergström and is free for download at:                 %%'),13,10];
    infodoc=[infodoc,uint8('%%                                                              %%'),13,10];
    infodoc=[infodoc,uint8('%%   http://www.mathworks.com/matlabcentral/fileexchange/       %%'),13,10];
    infodoc=[infodoc,uint8('%%   loadFile.do?objectId=19920&objectType=FILE                 %%'),13,10];
    infodoc=[infodoc,uint8('%%                                                              %%'),13,10];
    infodoc=[infodoc,uint8('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'),13,10];

    laou=[infodoc,laou];
end


% Writes the LaTeX output file
if length(latexout)>4
    if not(all(latexout((end-3):end)=='.tex'))
        latexout=[latexout,'.tex'];
    end
else
    latexout=[latexout,'.tex'];
end
if length(latexout)==length(latexsource)
    if latexout==latexsource
        error('Input file and output file are the same!');
    end
end
fid = fopen(latexout,'w');
fwrite(fid,laou);
fclose(fid);


function [laou,insbib,fignr,figureDOC]=getLaTeX(latexsource,hidecomments,bibitems,homedirectory,newdirectory,figname,fignr,figureDOC)

if nargin>4
    newfigs=logical(1);
    if nargin<8
        figureDOC='';
    end
else
    newfigs=logical(0);
end

if length(latexsource)>4
    if and(not(all(latexsource((end-3):end)=='.tex')),not(all(latexsource((end-3):end)=='.bbl')))
        latexsource=[latexsource,'.tex'];
    end
else
    latexsource=[latexsource,'.tex'];
end

% Correct '\' to '/'
for i=1:length(latexsource)
    if latexsource(i)=='\'
        latexsource(i)='/';
    end
end

% Reads the LaTeX source code 
[fid,msg]=fopen(latexsource,'r');
if fid==-1
    error(msg);
end
laso = fread(fid,'uint8=>uint8')';
fclose(fid);

if isempty(bibitems)
    insbib=logical(0);
else
    insbib=logical(1);
end

hidecommentsIF=logical(1);

notincomment=logical(1);
dowrite=logical(1);

bol=logical(1);

ifnum=0;

laou=[];

i=0;

while i<length(laso)
    i=i+1;
    
    if and(and(notincomment,and(hidecomments,hidecommentsIF)),not(isempty(laou)))
        if (i+1)<=length(laso)
            if all(laso(i:(i+1))==[13 37])
                notincomment=logical(0);
                dowrite=logical(0);
                bol=logical(0);
                i=i+1;
            elseif all(laso(i:(i+1))==[10 37])
                notincomment=logical(0);
                dowrite=logical(0);
                bol=logical(0);
                i=i+1;
            elseif or(all(laso(i:(i+1))==[32 37]),all(laso(i:(i+1))==[160 37]))
                notincomment=logical(0);
                dowrite=logical(0);
                bol=logical(0);
                i=i+1;                
            end
        end
        if and((i+2)<=length(laso),bol)
            if all(laso(i:(i+2))==[13 10 37])
                notincomment=logical(0);
                dowrite=logical(0);
                bol=logical(0);
                i=i+2;
            end
        end
    end
    
    if and((i+2)<=length(laso),notincomment)
        if all(laso(i:(i+2))==uint8('\if'))
            ifnum=ifnum+1;
        elseif all(laso(i:(i+2))==uint8('\fi'))
            ifnum=ifnum-1;
        end
    end
    
    if ifnum<1
        ifnum=0;
        hidecommentsIF=logical(1);
    else
        hidecommentsIF=logical(0);
    end

    if laso(i)==37
        if i>1
            if laso(i-1)~=92
                if and(hidecomments,hidecommentsIF)
                    dowrite=logical(0);
                end
                notincomment=logical(0);
            end
        else
            if and(hidecomments,hidecommentsIF)
                dowrite=logical(0);
            end
            notincomment=logical(0);
        end
    elseif or(laso(i)==13,laso(i)==10)
        if and(hidecomments,hidecommentsIF)
            if not(notincomment)  % in comment
                if (i+1)<=length(laso)
                    if or(laso(i+1)==13,laso(i+1)==10)
                        if (i+2)<=length(laso)
                            if not(laso(i+2)==37)
                                dowrite=logical(1);
                                notincomment=logical(1);
                                if not(isempty(laou))
                                    laou=[laou,laso(i),laso(i+1)];
                                end
                                bol=logical(0);
                                i=i+1;
                            end
                        end
                    elseif not(laso(i+1)==37)
                        dowrite=logical(1);
                        notincomment=logical(1);
                        bol=logical(0);
                    end
                end
            end
        else
            notincomment=logical(1);
        end
    end

    if and(notincomment,bol)

        if and(insbib,(i+13)<length(laso))
            if all(laso(i:(i+13))==uint8('\bibliography{'))
                laou=[laou,13,10,uint8('% \newpage     \vfill     \vspace   \enlargethispage{-5in}'),13,10,37,32,[92   73   69   69   69  116  114  105  103  103  101  114   99  109  100  123   92  101  110  108   97  114 103  101  116  104  105  115  112   97  103  101  123   45   53  105  110  125  125],13,10,bibitems];
                co=1;
                for j=(i+14):(length(laso))
                    if laso(j)==uint8('}')
                        co=co-1;
                    elseif laso(j)==uint8('{')
                        co=co+1;
                    end
                    if co==0
                        i=j+1;
                        break
                    end
                end
                insbib=logical(0);
                bibitems=[];
                if i>length(laso)
                    bol=logical(0);
                end                
            end
        end

        if (i+6)<length(laso)
            if all(laso(i:(i+6))==uint8('\input{'))
                co=1;
                for j=(i+7):(length(laso))
                    if laso(j)==uint8('}')
                        co=co-1;
                    elseif laso(j)==uint8('{')
                        co=co+1;
                    end
                    if co==0
                        iend=j+1;
                        break
                    end
                end

                extraSpaces=or(laso((i+7):(iend-2))==32,laso((i+7):(iend-2))==160);
                newlatexfile=char(laso((i+7):(iend-2)));
                if not(isempty(newlatexfile))
                    newlatexfile=newlatexfile(not(extraSpaces));
                    if not(all(extraSpaces))
                        if newlatexfile(1)=='/'
                            newlatexfile=newlatexfile(2:end);
                        end
                    end
                end

                if newfigs
                    [laou2,insbib,fignr,figureDOC]=getLaTeX([homedirectory,newlatexfile],hidecomments,bibitems,homedirectory,newdirectory,figname,fignr,figureDOC);
                else
                    [laou2,insbib]=getLaTeX([homedirectory,newlatexfile],hidecomments,bibitems,homedirectory);
                end

                clear extraSpaces newlatexfile

                laou=[laou,laou2];
                i=iend;
                if i>length(laso)
                    bol=logical(0);
                end
            end
        end

        if newfigs

            %figname
            if (i+15)<length(laso)
                if all(laso(i:(i+15))==uint8('\includegraphics'))
                    co=0;
                    kalle=0;
                    for j=(i+16):(length(laso))
                        if laso(j)==uint8(']')
                            kalle=0;
                            co=co-1;
                        elseif laso(j)==uint8('[')
                            kalle=0;
                            co=co+1;
                        elseif laso(j)==uint8('{')
                            kalle=1;
                        end
                        if and(co==0,kalle)
                            iend=j;
                            break
                        end
                    end
                    laou=[laou,laso(i:iend)];
                    i=iend;
                    co=1;
                    for j=(i+1):(length(laso))
                        if laso(j)==uint8('}')
                            co=co-1;
                        elseif laso(j)==uint8('{')
                            co=co+1;
                        end
                        if co==0
                            iend=j;
                            break
                        end
                    end
                    laou=[laou,uint8(figname),uint8(num2str(fignr)),laso(iend)];
                    
                    try
                        if laso(iend-4)==46
                            figureDOC=strvcat(figureDOC,[char(laso((i+1):(iend-1))),'   ->    ',figname,num2str(fignr),char(laso((iend-4):(iend-1)))]);
                        elseif laso(iend-5)==46
                            figureDOC=strvcat(figureDOC,[char(laso((i+1):(iend-1))),'   ->    ',figname,num2str(fignr),char(laso((iend-5):(iend-1)))]);
                        else
                            figureDOC=strvcat(figureDOC,[char(laso((i+1):(iend-1))),'   ->    ',figname,num2str(fignr)]);
                        end                        
                    end

                    try
                        if laso(iend-4)==46
                            copyfile([homedirectory,char(laso((i+1):(iend-1)))],[newdirectory,figname,num2str(fignr),char(laso((iend-4):(iend-1)))]);
                        elseif laso(iend-5)==46
                            copyfile([homedirectory,char(laso((i+1):(iend-1)))],[newdirectory,figname,num2str(fignr),char(laso((iend-5):(iend-1)))]);
                        else
                            copyfile([homedirectory,char(laso((i+1):(iend-1))),'.*'],[newdirectory,figname,num2str(fignr),'.*']);
                        end
                    catch
                        figureDOC=strvcat(figureDOC,['Error in copyfile! Figure ',figname,num2str(fignr),' not copied. Reason: ',lasterr]);
                    end
                    fignr=fignr+1;

                    i=iend+1;

                    if i>length(laso)
                        bol=logical(0);
                    end
                end
            end
        end
    end

    if and(dowrite,bol)
        laou=[laou,laso(i)];
    end
    
    bol=logical(1);

end

if nargin==7
    fid = fopen([newdirectory,'newFigureFiles.txt'],'w');
    for i=1:size(figureDOC,1)
        fprintf(fid,figureDOC(i,:));
        fprintf(fid,'\n');
    end
    fclose(fid);
end

