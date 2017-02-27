function [varargout]=readncfiles(subroutine,varargin)
% [ncOut vName vDescrpition vUnit globalAttrs ncAllVars vNames]=readncfiles()
%
% Summary: Reads netCDF data for given fields from given files

% Description: This function can be called with no input arguments, in which 
% case the inputs will be asked interactively from the user via GUI. Or, 
% the function can be called with the name of one of its subroutines as the
% first argument and the required inputs of that subroutine as the
% following arguments. Eash of these subrountines can be used specifically
% to do a certain task on netCDF files. These subroutines can be called as 
% below with their required inputs and outputs.
%
% Subroutines: 'ncglobalattrs','findncindexes','ncseries','ncgrid'
%
%  [ncAllVars globalAttrs resol vNames XLAT XLONG]=readncfiles('ncglobalattrs',ncid)
%  [X_idx Y_idx pointsLatLon]=readncfiles('findncindexes',resol,XLAT,XLONG,matxls)
%  [ncOut]=readncfiles('ncseries',ncPath,ncFiles,vID,leveL,t,diM,tOffset,pointsLatLon)
%  [ncOut]=readncfiles('ncgrid',ncPath,ncFiles,vID,leveL,t,diM)
%
% Additionally, the following subroutines are also included in this
% function, but they cannot be called from outside; they are only used
% inside this function:
%  [imrotated] = imrotate2(imin, angle_deg, showOp, method) 
%  [methodname id]=findmethod(method, methods)
%
% Note: This function is tested only with the WRF model's netcdf outputs.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Matlab codes for the analysis of the MODIS LST and the WRF model outputs
% % First version: Nov. 16, 2011
% % email: sohrabinia.m@gmail.com
% %******************************************

% Tested Variables: 
% TSK (82), SMOIS (49), SOILTB (130), U (6), V (7), W (8) 
% OLR (106), HFX (121), QFX (QFX), LH (123)

if nargin >0
    %Subroutines:
    subroutines={'ncglobalattrs','findncindexes','ncseries','ncgrid'};
    [funcname id]=findmethod(subroutine,subroutines);
    f=str2func(funcname);
    %v=varargin;
    switch subroutine
        % List of functions:
        case 'ncglobalattrs'
            [v{1} v{2} v{3} v{4} v{5} v{6}]    =f(varargin{:});
        case 'findncindexes'
            [v{1} v{2} v{3}]                   =f(varargin{:});            
        case 'ncseries'
            [v{1}]                             =f(varargin{:});
        case 'ncgrid'
            [v{1}]                             =f(varargin{:});
    end
    
    %[varargout{:}]=f(varargin{:});    
else
    [v{1} v{2} v{3} v{4} v{5} v{6} v{7} v{8}]=readfiles();
end
varargout=v;
end % end of readncfiles main function
%--------------------------------------------------------------------------


function [varargout]=readfiles()
%% netcdf.open: Open netCDF file
% ncid = netcdf.open(filename, mode)
%[chosen_chunksize, ncid] = netcdf.open(filename, mode, chunksize)
% 'NC_WRITE' Read-write access 
% 'NC_SHARE' Synchronous file updates 
% 'NC_NOWRITE' Read-only access 

fprintf(['A textfile with the names of netCDF files where each filename'...
    ' is in one line\n']);%, as the following example:']);
%hdf_files_list=['wrf_file1';'wrf_file2';'wrf_file3';'wrf_file4';'wrf_file5';]

[fileName, ncPath] = uigetfile('*.txt', 'List of netCDF files',...
    './ncFilesList.txt'); %C:/mso46/WRF/Nov2011
fid=fopen([ncPath fileName]);
    ncFiles= textscan(fid,'%s');             %read the list of nc filename
    ncFiles=ncFiles{1};                      %extract the inner cell-array
fclose(fid); 



%% prompt user for readOptions:
prompt = {sprintf(['Grid subset dimensions?        \n',...
    '[0: entire grid, or any value more than 0 as subset]']),...
    sprintf(['Save output?        \n',...
    ' [0: no, 1: .mat only, 2: .mat and .xls]']),...
    sprintf(['Save output as geotiff image(s)?        \n',...
    ' [0: no, 1: yes]']),...
    sprintf(['Input temporal resolution in hours?     \n',...
    ' [0.5: 30 min, 1: 1 hr, etc. ]']),...
    sprintf(['Output temporal resolution?        \n',...
    ' [0: same as input, or any value in hours]'])};
dlg_title = 'Subset & reading options';
def       = {'0','0','0','1','0'};
answers   = inputdlg(prompt,dlg_title,[1 70],def);
SubsetDim = str2double(answers{1}); %data dimension
matxls    = str2double(answers{2}); %local time offset relative to UTC
geotifOp  = str2double(answers{3}); %local time offset relative to UTC
tempRes   = str2double(answers{4});
aveOp  = str2double(answers{5});

%% Open first nc file:
ncid = netcdf.open([ncPath ncFiles{1}], 'NC_NOWRITE'); %open FIRST nc file as "Readonly"
%netcdf.close(ncid)

% read NC global attributes:
[ncAllVars globalAttrs resol vNames XLAT XLONG]=ncglobalattrs(ncid);
%[x y t]=size(XLAT); 
% Ask user to choose desired var:
%vNames=vNames';
%vNames=vNames;%{'spline';'linear'};
[varsSortd i]=sort(vNames);
varsSortd=[varsSortd ncAllVars(i,4)];%varsSortd
%for i=1:size(varsSortd,1), vv=varsSortd{i,1};vvi(i)=length(vv);end
for i=1:size(varsSortd,1)
    vv=varsSortd{i,1};%vv(max(vvi(:))+1)='o';
    %vv(length(vv)+1:19)='_';vv(20)='>';
    vv=[vv ':      ' varsSortd{i,2}];
    varsSortd{i,1}=vv;
end; varsSortd=varsSortd(:,1);

Selection=zeros(2,2);
while length(Selection)~=1
    fprintf('please select at least one, and only one option\n')
    [Selection,ok] = listdlg('ListString',varsSortd,'ListSize',[200 300],...
        'Name','Variable Selection','SelectionMode','single',...
        'PromptString','Select the variable to read');
end
clear varsSortd vv vvi;

% inquire information about desired var from first nc file 
vID=Selection-1; %vIDs start from 0
%vID     = netcdf.inqVarID(ncid,'TSK');
[vName, xtype, varDimIDs, varAtts] = netcdf.inqVar(ncid,vID);%details of desired var
% attrID = netcdf.inqAttID(ncid,vID,'coordinates');
% attName = netcdf.inqAttName(ncid,vID,attrID);
% attval = netcdf.getAtt(ncid,vID,attName);

% inq var description
attrID = netcdf.inqAttID(ncid,vID,'description'); 
attName = netcdf.inqAttName(ncid,vID,attrID);
vDescrpition = netcdf.getAtt(ncid,vID,attName);
% inq var units
attrID = netcdf.inqAttID(ncid,vID,'units'); 
attName = netcdf.inqAttName(ncid,vID,attrID);
vUnit = netcdf.getAtt(ncid,vID,attName);
% read var:
v2read=netcdf.getVar(ncid,vID); %vID starts from 0, goes to nvars-1
dims=size(v2read);
% close the first nc file after getting var info
netcdf.close(ncid) %close first nc file

%% prompt user for dimensions of the variable2read
prompt = {sprintf(['Confirm dimensions of variable?        \n',...
    ' possible dims: [x y (z) t]']),...
    sprintf(['How many hours offset from UTC/GMT?        \n',...
    ' [default: UTC + 12 (NZST)]']),...
    sprintf(['Spatial resolution of grid along xy?        \n',...
    ' [default: from data in m]'])};
dlg_title = 'Dimensions';
def = {num2str(length(dims)),'12',num2str(resol(1))};
answers = inputdlg(prompt,dlg_title,[1 70],def);
diM     = str2double(answers{1}); %data dimension
tOffset = str2double(answers{2}); %local time offset relative to UTC
resol   = str2double(answers{3});
leveL=1;
if diM>3
    prompt = {sprintf(['Which level of z to read?                \n',...
    '[%d max levels in the variable]'],dims(3))};
    dlg_title = 'z Level';    
    def = {'1'};
    leveL   = inputdlg(prompt,dlg_title,[1 70],def);
    leveL   = str2double(leveL{1}); %which z dim    
end


geotiffNames=[];
t=dims(end);
% if subset>0, read coordinates of sites:
if SubsetDim > 0
    tempCheckPoint=1; %timeseries
    % calculate time diff betwn local and model output
    dt1='2011-05-10 18:00:00'; %example1 dateTime
    dt2='2011-05-11 18:00:00'; %example2 dateTime with 1day difference
    t24hr=datenum(dt2)-datenum(dt1); %hr value for 1 day (must be eq to 1)
    t1hr=t24hr/24;  %calculate the value for 1hr
    tOffset=t1hr*tOffset;%difference betwn local vs UTC/GMT output from model
    
    [coordX_idx coordY_idx pointsLatLon]=findncindexes(resol,XLAT,XLONG,matxls);
    
    %clear XLAT XLONG;
    [ncOut]=ncseries(ncPath,ncFiles,vID,leveL,t,diM,tOffset,pointsLatLon);
else
    tempCheckPoint=0; %images
    [ncOut]=ncgrid(ncPath,ncFiles,vID,leveL,t,diM);
    if aveOp>0 %average and rotate 90 degree cclockwise
        %tempRes
        for k=1:size(ncOut,1)
            t=0;
            for i=1:size(ncOut,2)
                t=ncOut{k,i}+t;
            end
            t=t/size(ncOut,2);
            ncOut2{k,1}=imrotate2(t, -90);
        end
        ncOut=ncOut2;
    else %only rotate 90 degree cclockwise
        for k=1:size(ncOut,1)
            for i=1:size(ncOut,2)
                t=ncOut{k,i};
                ncOut{k,i}=imrotate2(t, -90);
            end
        end
    end
    
    if geotifOp==1 %write geotiff files:
        for k=1:size(ncOut,1)
            for j=1:size(ncOut,2)
                %t=ncOut{k};
                im=ncOut{k,j};%imrotate2(t, -90);
                UL=double([XLAT(end,end,1) XLONG(1,1,1)]);
                LR=double([XLAT(1,1,1) XLONG(end,end,1)]);
                [R,key]=latlon2r(im,[UL; LR]);
                geotiffNames{k,j}=cell2geotif(im,R,['nc2geotif' ...
                    num2str(j) num2str(k) ],key);
            end
        end
    end
end

%% Save/export output
SavedFileName=[];
if matxls~=0
    SavedFileName=strcat(fileName(1:6),'_',vName,'_simul','.mat'); %define filename to be saved
    save(['./' SavedFileName],'ncOut', 'vName','vDescrpition','vUnit',...
        'globalAttrs','ncAllVars','vNames');         %save output to .mat file
    if matxls==2
        SavedFileName=strcat(fileName(1:6),'_',vName,'_simul','.xls'); %define filename to be saved
        if tempCheckPoint==0
        i2=1;
        for i=1:size(ncOut,1)
            for j=1:size(ncOut,2)
                xlswrite(['./' SavedFileName],ncOut{i,j},i2,'A1');
                i2=i2+1;
            end
        end
        else            
            xlswrite(['./' SavedFileName],ncOut,1,'A1');            
        end
    end
end
%% Inform the user about the output
vname1=@(x) inputname(1);
icon1=1:100;icon1=(icon1'*icon1)/100;
msgbox(sprintf(['Successfully finished generating TimeSeries from netCDF files, '...
    'output is written to %s and saved to %s'],vname1(ncOut),SavedFileName),...
    'Finished Successfully','custom',icon1,cool(64),'modal');
clear icon1;

%% clear
clear i ii j i2 k rows cols t x y h  dt1 dt2 t24hr t1hr tOffset vname1 ans;
clear coord2look coord2find coordX_idx coordY_idx coordsFound coordsId coordsVerif;
clear Lats Lons lats lons ncFiles pointsLatLon Times colNames;
clear varAtts varDimIDs xtype TSK nvars ndims points; %var2read vars 
clear fid ncid vID latID lonID TimesID leveL diM ok Selection v;
clear fileName ncPath  fName2 fPath2 SavedFileName;
clear def dlg_title prompt saveChoice num_lines matxls;
clear attrID attName ngatts gAttName gAttVal answers;
clear resol sq1 sq2 dFound distInitial v2read tempRes interpOp;
clear LR R SubsetDim UL XLAT XLONG dims geotifOp key ncOut2 im;

fprintf('\n Outputs:\n');
whos        %display what has been calculated and whats the results
varargout{1}=ncOut;
varargout{2}=vName;
varargout{3}=vDescrpition;
varargout{4}=vUnit;
varargout{5}=globalAttrs;
varargout{6}=ncAllVars;
varargout{7}=vNames;
varargout{8}=geotiffNames;
end % end of main function

%% Subfunctions:

function [ncAllVars globalAttrs resol vNames XLAT XLONG]=ncglobalattrs(ncid)

% ncinfo: Return information about NetCDF file: this part didnt work in v2009
% %%finfo = ncinfo(filename)
% %%vinfo = ncinfo(filename,varname)
% %%ginfo = ncinfo(filename,groupname)
%    ncFinfo=ncinfo([ncPath ncFiles{1}]);%ncid);
%    dimNames = {ncFinfo.Dimensions.Name};
%    vNames={ncFinfo.Variables.Name}; %extract variable names
%  %%get global attributes:
%    gAttName={ncFinfo.Attributes.Name};
%    gAttVal={ncFinfo.Attributes.Value};
%    globalAttrs=vertcat(gAttName,gAttVal)';
%  %%get variable info, name and attributes
%    ncVinfo=ncinfo([ncPath ncFiles{1}],vNames{83});%ncid);
%    attrNames={ncVinfo.Attributes.Name}; %vNames(50):SMOIS, vNames(83):TSK
% %%syntax: attvalue = ncreadatt(filename,location,attname); example:
% attValue = ncreadatt([ncPath ncFiles{1}],vNames{83},attrNames{6});%coordinate fields

% v2009: Read global attrs, Lat and Lon
%%inq ncfile, syntax: [ndims,nvars,ngatts,unlimdimid]=netcdf.inq(ncid);
[ndims,nvars,ngatts]=netcdf.inq(ncid); 
for i=1:ngatts
    gAttName{i} = netcdf.inqAttName(ncid,netcdf.getConstant('NC_GLOBAL'),i-1);
    gAttVal{i} = netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),gAttName{i});
end

globalAttrs=vertcat(gAttName,gAttVal)';
latID   = netcdf.inqVarID(ncid,'XLAT');
XLAT    = netcdf.getVar(ncid,latID); %read Lat var
lonID   = netcdf.inqVarID(ncid,'XLONG');
XLONG   = netcdf.getVar(ncid,lonID); %read Lon var
%resol=sqrt((XLAT(1,2,1)-XLAT(1,1,1) )^2 + (XLONG(1,2,1)-XLONG(1,1,1) )^2);%calc res
%resol=111*resol; %resolution along Latitudes in km
resol(1)=netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DX');
resol(2)=netcdf.getAtt(ncid,netcdf.getConstant('NC_GLOBAL'),'DY');
%%inq ncvar, syntax: [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid)
for vID=0:nvars-1 %varID starts from 0 
  vNames{vID+1,1} = netcdf.inqVar(ncid,vID); %but we cant use 0 as index so vID+1
end
% read names, desc and units of all vars in ncfile
ncAllVars{1,1}='vID'; ncAllVars{1,2}='vName'; 
ncAllVars{1,3}='vUnit';ncAllVars{1,4}='vDescription'; 
for v=1:nvars-1 %start from varID 1 ignoring first var (Times) 
    ncAllVars{v+1,1}=v;
    ncAllVars{v+1,2}=vNames{v+1,1}; %skip DateTime
    attrID = netcdf.inqAttID(ncid,v,'units');
    attName = netcdf.inqAttName(ncid,v,attrID);
    ncAllVars{v+1,3} = netcdf.getAtt(ncid,v,attName);
    attrID = netcdf.inqAttID(ncid,v,'description');
    attName = netcdf.inqAttName(ncid,v,attrID);
    ncAllVars{v+1,4} = netcdf.getAtt(ncid,v,attName); %var description
end

end % end of ncglobalattr


%% find Lat-Lon indices
% use distance function, see the following link for formula:
%%http://www.purplemath.com/modules/distform.htm

function [coordX_idx coordY_idx pointsLatLon]=findncindexes(resol,XLAT,XLONG,matxls)

[fName2, fPath2] = uigetfile('*.txt', 'List of coordinates[Name Lat Lon]',...
    './pointsLatLon.txt'); %C:/mso46/WRF/Nov2011
fid=fopen([fPath2 fName2]);
pointsLatLon=textscan(fid,'%s %f %f','HeaderLines', 1,'delimiter','\t'); % skip 0 headerline
fclose(fid);

points= pointsLatLon{1};
lats = pointsLatLon{2};
lons = pointsLatLon{3};
for k=1:length(lats)
    distInitial=resol*10; %initial distance approximated based grid resolution
    [x y t]=size(XLAT); %x or y are stored
    for i=1:x
        for j=1:y
            sq1=(XLAT(i,j,1)-lats(k) )^2; %lat part of dist func
            sq2=(XLONG(i,j,1)-lons(k) )^2; %lon part of dist func
            dFound=sqrt(sq1+sq2);   %distance function        
            if dFound<distInitial
                coordX_idx(k)=i; %Lat or Lon x coord in nc files
                coordY_idx(k)=j; %Lat or Lon y coord in nc files
                distInitial=dFound;  %replace initial dist with found dist       
            end
        end
    end
end

% read matching LatLon to found indexes:
%coordsFound=cell(length(points),3);
for i=1:length(coordX_idx)
    %coordsFound{i,1}=points{i};
    if coordX_idx(i)~=0 && coordY_idx(i)~=0
        coordsFound(i,1)=XLAT(coordX_idx(i),coordY_idx(i),1); %point's found lat
        coordsFound(i,2)=XLONG(coordX_idx(i),coordY_idx(i),1); %point's found lon
        coordsFound(i,3)=coordX_idx(i); %lat/lon's x index
        coordsFound(i,4)=coordY_idx(i); %lat/lon's y index      
    end    
end
%clear XLAT XLONG;
% Export found coords to csv/xls file:
if matxls==2
    colNames = {'ID','Lat','Lon','coordXidx','coordYidx'};
    SavedFileName=strcat(fName2(1:6),'_coords_found','.xls'); %define filename to be saved
    xlswrite([fPath2 SavedFileName],colNames,1,'A1');
    xlswrite([fPath2 SavedFileName],points,1,'A2');
    xlswrite([fPath2 SavedFileName],coordsFound,1,'B2');
    %xlswrite([fPath2 SavedFileName],coordX_idx,1,'D2');
    %xlswrite([fPath2 SavedFileName],coordY_idx,1,'E2');    
else
    %%Syntax: csvwrite(filename,M,row,col)
    SavedFileName=strcat(fName2(1:6),'_coords_found','.csv'); %define filename to be saved      
    csvwrite([fPath2 SavedFileName],coordsFound,1,1);
end
% Inform user about found coordinates and ask to verify them
h=questdlg(sprintf(['The list of given coordinates were matched with all '...
    'coordinates of netCDF files, and indices of matched coordinates are '...
    'written to %s.\nTo verify if the indices are '...
    'correct, and if there has been any 0 values, press Yes, otherwise '...
    'press No. If yes, the verified file will be requested.'],...
    SavedFileName),'Verify found coordinates?',...
    'Yes','No','No');
waitfor(h);
switch h
    case 'Yes'
        % Inquire list of verified coordsFound to use for reading data
        if matxls==2
            [fName2, fPath2] = uigetfile({'*.xls'}, 'List of verified Indices',...
                [fPath2 SavedFileName]);
            [num,txt,raw] = xlsread([fPath2 SavedFileName],1);
            coordX_idx=[raw{2:end,4}];
            coordY_idx=[raw{2:end,5}];
        else
            [fName2, fPath2] = uigetfile({'*.csv'}, 'List of verified Indices',...
                [fPath2 SavedFileName]);%'coordsVerif.txt']);
            fid = fopen([fPath2 fName2]);
            coordsVerif=textscan(fid,'%s %f %f %f %f','HeaderLines', 1,...
                'delimiter',','); % skip 0 headerline
            fclose(fid);
            coordX_idx = coordsVerif{4};
            coordY_idx = coordsVerif{5};
        end
        %coordsId   = coordsVerif{1};

end %end of switch
pointsLatLon{2}=coordsFound(:,1);
pointsLatLon{3}=coordsFound(:,2);
pointsLatLon{4}=coordX_idx;
pointsLatLon{5}=coordY_idx;
%pointsLatLon
end %end of findIndexes



function [ncOut]=ncseries(ncPath,ncFiles,vID,leveL,t,diM,tOffset,pointsLatLon)
% ncread: Read data from variable in NetCDF file
% vardata = ncread(filename,varname)
% vardata = ncread(filename,varname,start,count,stride)
% [varname, xtype, varDimIDs, varAtts] = netcdf.inqVar(ncid,0);
% varid = netcdf.inqVarID(ncid,varname);
% data = netcdf.getVar(ncid,varid)
siteNames=pointsLatLon{1};
coordX_idx=pointsLatLon{4}; 
coordY_idx=pointsLatLon{5};
ncOut =cell(t(end),length(coordX_idx)+1); % cell for TimeSeries of all points in all files
ncOut{1,1}='DateTime'; %first colName is DateTime
for i=1:length(siteNames)
    ncOut{1,i+1}=siteNames{i};%colNames of series of each site
end
i=2;%ncFiles %debug
for k=1:length(ncFiles)
    ncid = netcdf.open([ncPath ncFiles{k}], 'NC_NOWRITE'); %open nc file as "Readonly"    
    %vID = netcdf.inqVarID(ncid,'TSK'); %identify and read TSK    
    v2read=netcdf.getVar(ncid,vID); %vID starts from 0, goes to no. of vars
    t=size(v2read);
    if length(t)<diM
        t=1; disp('only a single time-interval exists');
    else
        t=t(end); %last element would be time-> in case 4D, time will be 
        % 4th element, in case 3D, time will be 3rd element
        %t(t<48)=1;
    end
    TimesID = netcdf.inqVarID(ncid,'Times'); %identify and read Times
    Times=netcdf.getVar(ncid,TimesID);
    for ii=1:t
        ncOut{i,1} = Times(:,ii)';
        ncOut{i,1}=datenum(ncOut{i,1})+tOffset;
        ncOut{i,1}=datestr(ncOut{i,1},'dd mmm yyyy HH:MM');%:SS');
        for j=1:length(coordX_idx)
            if diM==3
            ncOut{i,j+1} = v2read(coordX_idx(j),coordY_idx(j),ii); %if 3D, x  y and var
            elseif diM==4
               ncOut{i,j+1} = v2read(coordX_idx(j),coordY_idx(j),leveL,ii);%if 4D, include leveL
            else
                msgbox(['Wrong dimensions entered, only 3D [x y t] or 4D [x y z t] netCDF ',...
                    'data can be read by this code, ',...
                    'make sure dimensions are correct; exiting the code'],...
                    'Dimensions out of range','Error','modal');
                return
            end
        end
        i= i+1;       
    end
    %fprintf('file %d ',k); %debug
    netcdf.close(ncid)
end
end %end of ncseries function


function [ncOut]=ncgrid(ncPath,ncFiles,vID,leveL,t,diM)
ncOut =cell(length(ncFiles),t);

%i=1;
for k=1:length(ncFiles)
    ncid = netcdf.open([ncPath ncFiles{k}], 'NC_NOWRITE'); %open nc file as "Readonly"
    v2read=netcdf.getVar(ncid,vID);
    dims=size(v2read);
    t=dims(end);
    for ii=1:t
        if diM==3
            ncOut{k,ii} = v2read(:,:,ii); %if 3D, x  y and var
        elseif diM==4
            ncOut{k,ii} = v2read(:,:,leveL,ii); %if 4D, include leveL            
        end
    end
end
end %ncgrid

% Utility functions:

function [imrotated] = imrotate2(imin, angle_deg, showOp, method) 
% [imrotated] = imrotate2(imin, angle_deg, showOp, method)

if nargin<2
    error('Error! at least two arguments required: imin and angle');
elseif nargin<3
    showOp=0;
    method='nearest';
elseif nargin<4
    method='nearest';
end

% padMethods={'bound','circular','fill','replicate','symmetirc'};
% resampMethods={'nearest','linear','cubic','bicubic'};
q=angle_deg;
q=q*pi/180;
rotate=[cos(q)    sin(q) 0;
    -sin(q)    cos(q) 0;
    0    0      1];

tform = maketform('affine',rotate);
imrotated= imtransform(imin, tform,method,'FillValues',0);

if showOp~=0
    figure, subplot(1,2,1), imshow(imin), axis on, title('original');
    %subplot(3,3,2), imshow(imrotated), axis on, title('flipped');
    subplot(1,2,2), imshow(imrotated), axis on;
    title(sprintf('rotated, %s resamp',method));
end
%disp('user defined func');
end %imrotate2

function [methodname id]=findmethod(method, methods)
% [methodname id]=findmethod(method, methods)
%
% finds the name and index of a given method from the list of given
% methods. If the method is a string, the complete name of it alongside the
% index of it from the methods will be returned. If method is index one of
% the acceptable methods, its complete name will be found and returned
% alongside the index (which will be equal to method). If any name not
% given in methods or a number larger than the number of the methods is
% given, error will be returned.
%
% Inputs:
%  method: name (char) or index (double) of the intended method in the
%  list of methods
%  methods: cell-array with the full list of acceptable methods
% Outputs:
%  methodname: full name of the intended method (char)
%  id: index of the method in methods
%--------------------------------------------------------------------------

allmthds=sprintf('%s, ',methods{:});
allmthds=allmthds(1:end-2);
t=whos('method');
if  strcmp(t.class,'char')   
    yesno=strcmp(method,methods);  
    %sum(double(yesno))
    if sum(double(yesno))==1
        %f=str2func(methods{yesno}); 
        methodname=methods{yesno};
        id=1:length(methods);
        id=id(yesno);
    else

        error(['Error! %s is not valid, only %s are '...
            'acceptable methods by this function'],method,allmthds);
    end
elseif strcmp(t.class,'double') 
    if method>length(methods) || method<1
        i=sprintf('%d, ',1:length(methods));
        i=i(1:end-2);        
        error(['Error! %d is not a valid option, only %s (or %s) '...
            'are acceptable methods by this function'],...
            method,i,allmthds);
    end
    %f=str2func(methods{method});
    methodname=methods{method};
    id=method;
else
    error(['Error! %s as method is not acceptable, only a char or a '...
        'double indicating one of acceptable methods (%s) '...
        'should be provided'],t.class,allmeth);
end


end %end of findmethod function

%%% End of readncfiles function