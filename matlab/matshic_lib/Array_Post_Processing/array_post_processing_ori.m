function array_post_processing(datestart,dateend,interval)
delgraf
% 3.4.13 le
% loads avos data and makes regular wl grid and average within a selected time span

if nargin<1,datestart='';end
if isempty(datestart),datestart='25-feb-2014';end
if nargin<2,dateend='';end
if isempty(dateend),dateend=datestart;end
if nargin<3,interval='';end
if isempty(interval),interval=1;end

inst='avv';

pp='/corona/calib/uv/matshic';

datea=datenum(datestart);
dateb=datenum(dateend);

for i=datea:dateb % select here day of processing
    datename=datestr(i);
    %load avos file and make data processing (including 2 integration times)
    if inst=='avo'
        [wl,spec_count,res,tim,doy,yr]=loadavos(datename);
        res_name=sprintf('responsivity.%s',inst);
        load(res_name,'-mat')
        ress =repmat(out_resp_april,1,size(spec_count,2)); % res 2048x817
    end
    
    if inst=='avv'
        [wl,spec_count,res,tim,doy,yr]=load_avos_two(datename);  % wl 2048x1, spec_count 2048x817, tim 1x817, doy=56, yr=2014
        load('responivity_avos2_feb14.mat')
        ress =repmat(res_feb,1,size(spec_count,2));
    end
    
    if inst=='pfs'
        [wl,spec_count,res,tim,doy,yr]=load_pfs(datename)
        
    end
    
  
    
        
    
    irradiance = (spec_count./ress);
    irradiance(isinf(irradiance) | isnan(irradiance))=0;
    
    % here not very nice to handle first overlapping day
    avos_irradiance=irradiance(:,(2:end));
    avos_time=tim(1,(2:end));
    avos_wl=wl;
    
    time_step=interval; %make timestep in minutes % remark with avos 1 minute does not work!!!
    time_vec=nanmin(avos_time):(time_step/60/24):nanmax(avos_time);
    
    % aggregate here data to specific time step (in minute)
    [dat_ag,tim_ag,nb_dat] = tim_agreg(avos_time,avos_irradiance,time_vec,'ave');
    
    
    array_time=repmat(tim_ag,size(dat_ag,1),1);
    tm=array_time;
    spec=dat_ag;
    
    fname_mat=sprintf('%s/uvdata/%04d/%s/mat_uv%03d%04d.%s',pp,yr,inst,doy,yr,inst);
    save(fname_mat,'tm','spec','wl');
    
    %make here wavelenght and bandwidth homogenization (in particular regular avos grid)
    %matshic(datestart,dateend,'davos','avv',1);
    
    
    % write out file
    fname_out=sprintf('%s/%04d/%s/matshic_%03d%04d.%s',pp,yr,inst,doy,yr,inst);
    arr=load(fname_out,'-mat');
    wl_out_array=arr.specout{1}(:,1);
    for k=1:1:size(arr.specout,2)
        if ~isempty(arr.specout{k})
            nom_mat_array(:,k)=arr.specout{k}(:,3);
            inst_mat_array(:,k)=arr.specout{k}(:,2);
        end
        if isempty(arr.specout{k})
            nom_mat_array(:,k)=repmat(nan,size(wl_out_array,1),1);
            inst_mat_array(:,k)=repmat(nan,size(wl_out_array,1),1);
        end
    end
    
    
    %make here matshic for scanner
    inst_scan='isq';
    %matshic('25-apr-2013','25-apr-2013','davos',inst_scan,1);
    
    fname_out=sprintf('%s/%04d/%s/matshic_%03d%04d.%s',pp,yr,inst_scan,doy,yr,inst_scan);
    scan=load(fname_out,'-mat');
    
    wl_out_scanner=scan.specout{1}(:,1);
    
    for l=1:1:size(scan.specout,2)
        
        if ~isempty(scan.specout{l})
            nom_mat_scanner(:,l)=scan.specout{l}(:,3);
            inst_mat_scanner(:,l)=scan.specout{l}(:,2);
        end
        if isempty(scan.specout{l})
            nom_mat_scanner(:,l)=repmat(nan,size(wl_out_scanner,1),1);
            inst_mat_scanner(:,l)=repmat(nan,size(wl_out_scanner,1),1);
        end
        
        
    end
    
    %make here synchronization
    
    min_time=[nanmin(arr.time) nanmin(scan.time)];
    max_time=[nanmax(arr.time) nanmax(scan.time)];
    
    maxmin=max(min_time);
    minmax=min(max_time);
    
    index_array=arr.time>maxmin & arr.time<minmax;
    index_scanner=scan.time>maxmin & scan.time<minmax;
    
    
    array_spec_mat= nom_mat_array(:,index_array);
    array_time_mat = repmat(arr.time(1,index_array),size(array_spec_mat,1),1);
    array_wl_mat = repmat(wl_out_array,1,size(array_spec_mat,2));
    
    scanner_spec_mat = nom_mat_scanner(:,index_scanner);
    scanner_time_mat = repmat(scan.time(1,index_scanner),size(scanner_spec_mat,1),1);
    scanner_wl_mat = repmat(wl_out_scanner,1,size(scanner_spec_mat,2));
    
    x=double(array_time_mat);
    y=double(array_wl_mat);
    xi=double(scanner_time_mat);
    yi=double(scanner_wl_mat);
    
    display('Interpolate ARRAY data to SCANNER wl and time')
    display('Waiting for gridgeneration method linear (default)')
    new_array_mat = griddata(x,y,double(array_spec_mat),xi,yi,'nearest');
    
    
    %for j=1:1:size(new_array_mat)
    for j=1:1:10
        
        figure
        semilogy(wl_out_scanner,scanner_spec_mat(:,j).*1000,wl_out_scanner,new_array_mat(:,j).*2.3);
        grid
        
    end
    
    
end


