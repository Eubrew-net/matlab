function numReplacements=latexFindReplace(latexsource,findthis,replacewith)
% latexFindReplace finds and replaces (non comment) text strings in a
% LaTeX file system liked together by the '\input{}' command. The usage
% differ dependent of types of input.
% Warning! latexFindReplace() will change your LaTeX files. It is
% impossible to Undo.
%
% Usage I:
%
% numReplacements=latexFindReplace(latexsource,findthis,replacewith)
%
% latexsource - The LaTeX file.
% findthis - old text string to be changed
% replacewith - new text string
%
%                findthis   ->   replacewith
%
% numReplacements - the number of replacements
%
%
% Usage II:
%
% numReplacements=latexFindReplace(latexsource,inputflag,newstring)
%
% latexsource - The LaTeX file.
% inputflag - flag (number) {1,2,3}
% newstring - string to be inserted in the LaTeX file system
%
% inputflag=1,
%        \label{'oldref'}   ->   \label{['oldref',newstring]}
%        \ref{'oldref'}     ->   \ref{['oldref',newstring]}
%
% inputflag=2,
%        \bibitem{'pap'}    ->   \bibitem{['pap',newstring]}
%        \cite{'pap'}       ->   \cite{['pap',newstring]}
%        \cite{'pap1','pap1',...}   ->   \cite{['pap1',newstring],['pap2',newstring],...}
%        (\bibitem in additional *.bbl files will not be changed)
%
% inputflag=3,
%        \includegraphics{['oldpath','file']}   ->   \includegraphics{[newstring,'file']}
%
% numReplacements - the number of replacements
%
% numReplacements=latexFindReplace(latexsource,inputflag,cellstring)
%
% latexsource - The LaTeX file.
% inputflag - flag (number) {4}
% cellstring - cell array of strings
%
% inputflag=4,
%        [cellstring{1}]{'any'}       ->   [cellstring{1}]{['any',cellstring{2}]}
%        [cellstring{1}]{'any1','any1',...}   ->     [cellstring{1}]{['any1',cellstring{2}],['any2',cellstring{2}],...}
%
% numReplacements - the number of replacements
%
% remark: The (Matlab) notation ['string1','string2'] is used for concate two strings
%
% Usage III:
%
% numReplacements=latexFindReplace(latexsource)
%
% Replaces all spaces of type "160" to type "32"
%
% numReplacements - the number of replacements
%
% Example:
%
% latexManuscript('c:/latex/paper.tex','dog','cat')
%
% latexManuscript('c:/latex/paper.tex',1,'II')
%
% written by Per Bergström 2009-02-05
%
% Free for download at
%
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=
% 19920&objectType=FILE
%
% e-mail: per.bergstrom 'at' ltu.se


if not(or(nargin==1,nargin==3))
    error('Wrong number of input arguments in latexFindReplace!');
end

% Check
if length(latexsource)>4
    if not(or(all(latexsource((end-3):end)=='.tex'),all(latexsource((end-3):end)=='.bbl')))
        error('File name must end with .tex or .bbl!');
    end
else
    error('File name must end with .tex or .bbl!');
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


if nargin==1
    numReplacements=fireLaTeX(0,latexsource,homedirectory,160,32,0,{});
elseif and(isstr(findthis),isstr(replacewith))
    numReplacements=fireLaTeX(0,latexsource,homedirectory,uint8(findthis),uint8(replacewith),0,{});
elseif and(not(isstr(findthis)),iscell(replacewith))
    if and(isstr(replacewith{1}),isstr(replacewith{2}))
        numReplacements=fireLaTeX(100,latexsource,homedirectory,uint8(replacewith{1}),uint8(replacewith{2}),0,{});
    else
        error('Error with replacewith!');
    end
elseif and(any(findthis==[1,2]),isstr(replacewith))
    numReplacements=fireLaTeX(findthis,latexsource,homedirectory,[],uint8(replacewith),0,{});
elseif and(findthis==3,isstr(replacewith))
    if isempty(replacewith)
        numReplacements=fireLaTeX(findthis,latexsource,homedirectory,[],[],0,{});
    else
        % Correct '\' to '/'
        for i=1:length(replacewith)
            if replacewith(i)=='\'
                replacewith(i)='/';
            end
        end
        if replacewith(end)=='/'
            replacewith=replacewith(1:(end-1));
        end
        numReplacements=fireLaTeX(findthis,latexsource,homedirectory,[],uint8(replacewith),0,{});
    end
else
    error('Error with input arguments!');
end



function [numReplacements,cellLaTeX]=fireLaTeX(inputflag,latexsource,homedirectory,findthis,replacewith,numReplacements,cellLaTeX)

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

cellLaTeX2=cell(1,length(cellLaTeX)+1);

bol=logical(1);
for i=1:length(cellLaTeX)
    cellLaTeX2{i}=cellLaTeX{i};
    if length(cellLaTeX{i})==length(latexsource)
        if all(cellLaTeX{i}==latexsource)
            bol=logical(0);
        end
    end
end

if bol

    cellLaTeX2{length(cellLaTeX)+1}=latexsource;
    cellLaTeX=cellLaTeX2;
    clear cellLaTeX2

    % Reads the LaTeX source code
    [fid,msg]=fopen(latexsource,'r');
    if fid==-1
        disp(latexsource);
        error(msg);
    end
    laso = fread(fid,'uint8=>uint8')';
    fclose(fid);

    laou=[];

    notincomment=logical(1);

    i=0;

    % Start finding
    while i<length(laso)
        i=i+1;

         if laso(i)==37
%             if i>1
%                 if laso(i-1)~=92
%                     notincomment=logical(0);
%                 end
%             else
%                 notincomment=logical(0);
%             end
        elseif or(laso(i)==13,laso(i)==10)
            notincomment=logical(1);
        end

        if notincomment

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

                    laso_n=laso(i+7:(iend-2));
                    indx=1;
                    for k=1:length(laso_n)
                        if laso_n(k)==findthis(indx)
                             laso_n(k)=replacewith(indx); 
                             indx=indx+1;
                        end
                    end
                    laso(i+7:(iend-2))=laso_n;
                    
                    [numReplacements,cellLaTeX]=fireLaTeX(inputflag,[homedirectory,newlatexfile],homedirectory,findthis,replacewith,numReplacements,cellLaTeX);

                    clear extraSpaces newlatexfile

                    laou=[laou,laso(i:(iend-1))];
                    i=iend-1;
                    bol=logical(0);
                end
            end

            if bol
                if inputflag==0
                    if (i+length(findthis)-1)<=length(laso)
                        if all(laso(i:(i+length(findthis)-1))==findthis)
                            numReplacements=numReplacements+1;
                            laou=[laou,replacewith];
                            i=i+length(findthis)-1;
                            bol=logical(0);
                        end
                    end
                elseif inputflag==1
                    if (i+4)<length(laso)
                        if all(laso(i:(i+4))==uint8('\ref{'))
                            numReplacements=numReplacements+1;
                            co=1;
                            for j=(i+5):(length(laso))
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
                            laou=[laou,laso(i:(iend-1)),replacewith,laso(iend)];
                            i=iend;
                            bol=logical(0);
                        end
                    end
                    if bol
                        if (i+6)<length(laso)
                            if all(laso(i:(i+6))==uint8('\label{'))
                                numReplacements=numReplacements+1;
                                co=1;
                                for j=(i+7):(length(laso))
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
                                laou=[laou,laso(i:(iend-1)),replacewith,laso(iend)];
                                i=iend;
                                bol=logical(0);
                            end
                        end
                    end

                elseif inputflag==2

                    if (i+8)<length(laso)
                        if all(laso(i:(i+8))==uint8('\bibitem{'))
                            numReplacements=numReplacements+1;
                            co=1;
                            for j=(i+9):(length(laso))
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
                            laou=[laou,laso(i:(iend-1)),replacewith,laso(iend)];
                            i=iend;
                            bol=logical(0);
                        end
                    end
                    if bol

                        if (i+5)<length(laso)
                            if all(laso(i:(i+5))==uint8('\cite{'))
                                numReplacements=numReplacements+1;
                                co=1;
                                for j=(i+6):(length(laso))
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
                                for j=i:(iend-2)
                                    if laso(j)==uint8(',')
                                        laou=[laou,replacewith,uint8(',')];
                                    else
                                        laou=[laou,laso(j)];
                                    end
                                end
                                laou=[laou,replacewith,laso(iend-1)];

                                i=iend-1;
                                bol=logical(0);
                            end
                        end

                    end

                elseif inputflag==3

                    if (i+15)<length(laso)
                        if all(laso(i:(i+15))==uint8('\includegraphics'))
                            numReplacements=numReplacements+1;
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
                            laou=[laou,laso(i:iend),replacewith];
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
                            co=i+1;
                            for j=(iend):(-1):(i+1)
                                if laso(j)==uint8('/')
                                    co=j;
                                    break
                                end
                            end
                            if and(co==(i+1),not(isempty(replacewith)))
                                laou=[laou,uint8('/'),laso(co:iend)];
                            else
                                laou=[laou,laso(co:iend)];
                            end
                            i=iend;
                            bol=logical(0);
                        end
                    end

                elseif inputflag==100

                    if (i+length(findthis)-1)<length(laso)
                        if all(laso(i:(i+length(findthis)-1))==findthis)
                            numReplacements=numReplacements+1;
                            co=0;
                            for j=(i+length(findthis)):(length(laso))
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
                            for j=i:(iend-2)
                                if laso(j)==uint8(',')
                                    laou=[laou,replacewith,uint8(',')];
                                else
                                    laou=[laou,laso(j)];
                                end
                            end
                            laou=[laou,replacewith,laso(iend-1)];

                            i=iend-1;
                            bol=logical(0);
                        end
                    end

                end
            end

        end

        if bol
            laou=[laou,laso(i)];
        end

        bol=logical(1);

    end

    % Start replace
    disp(latexsource);  fid = fopen(latexsource,'w');
    fwrite(fid,laou);   fclose(fid);

end


