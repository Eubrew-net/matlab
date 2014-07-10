function array_post_processing(datestart,dateend,interval)
delgraf
% 3.4.13 le
% loads test data and makes regular wl grid and average within a selected time span

if nargin<1,datestart='';end
if isempty(datestart),datestart='1-april-2014';end
if nargin<2,dateend='';end
if isempty(dateend),dateend=datestart;end
if nargin<3,interval='';end
if isempty(interval),interval=1;end

inst='pfs';
domatshic=0;
pp='/corona/calib/uv/matshic';

datea=datenum(datestart);
dateb=datenum(dateend);

for i=datea:dateb % select here day of processing
    [doy,day,month,yr]=julianday(i);
    if inst=='pfs'
        buf=load(sprintf('%s/uvdata/%04d/pfs/mat_uv%03d%04d_ori.pfs',pp,yr,doy,yr),'-mat');
        wl=buf.wl;
        test_irradiance=buf.data;
        test_time=datenum(yr,month,day)+buf.tm(1,:)./24;
    end
    
  
    
    if 0,
        time_step=interval; %make timestep in minutes % remark with test 1 minute does not work!!!
        time_vec=nanmin(test_time):(time_step/60/24):nanmax(test_time);
        
        % aggregate here data to specific time step (in minute)
        [dat_ag,tim_ag,nb_dat] = tim_agreg(test_time,test_irradiance,time_vec,'ave');
        
        
        array_time=repmat(tim_ag,size(dat_ag,1),1);
        
        tm=array_time;
        spec=dat_ag;
    else
        tm=test_time;
        spec=test_irradiance;
    end
    
    fname_mat=sprintf('%s/uvdata/%04d/%s/mat_uv%03d%04d.%s',pp,yr,inst,doy,yr,inst);
    save(fname_mat,'tm','spec','wl');
    
    %sli=brslit(1,[],1);
    %load jrc sli:
    sli=load('/corona/calib/uv/matshic/jrc.sli');
    P=csapi(sli(:,1),sli(:,2));
    wln=[290:0.01:400]'; % spline it to eqi
    wlout=[290:0.25:400]'; % but it on the qasume grid
    for j=1:size(tm,2),
        buf=spline(wl,spec(:,j),wln);
        buf2=falt_eqi(wln,buf,wln,P);
        specout(:,j)=spline(wln,buf2,wlout);
    end 
    
    
    if 0,
        fname_mat=sprintf('%s/uvdata/%04d/%s/mat_uv%03d%04d_1nm.%s',pp,yr,inst,doy,yr,inst);
        save(fname_mat,'tm','specout','wlout');
    end
    
    arr.time=tm(1,:);
    wl_out_array=wlout;
    nom_mat_array=specout;

    % SCANNER - QASUME
    if 0,
        %make here matshic for scanner
        if domatshic,
            matshic(datestart,dateend,'berlin',inst_scan,1);
        end
        fname_out=sprintf('%s/%04d/%s/matshic_%03d%04d.%s',pp,yr,inst_scan,doy,yr,inst_scan);
        scan2=load(fname_out,'-mat');
        
        wl_in_scanner=scan.specraw{1}(:,1);
        wl_out_scanner=scan.specout{1}(:,1);
        [i,a,b]=intersect(wl_in_scanner,wl_out_scanner);
        for l=1:1:size(scan.specout,2)
            
            if ~isempty(scan.specout{l})
                nom_mat_scanner(:,l)=scan.specout{l}(:,3);
                tim_mat_scanner(:,l)=datenum(yr,month,day)+scan.specraw{l}(a,3)./24;
            end
            if isempty(scan.specout{l})
                nom_mat_scanner(:,l)=repmat(nan,size(wl_out_scanner,1),1);
                inst_mat_scanner(:,l)=repmat(nan,size(wl_out_scanner,1),1);
            end
            
            
        end
    else
        
        fname_out=sprintf('%s/../qasume/data/data/%04d/mat_uv%03d%04d.B5503',pp,yr,doy,yr);
        scan=load(fname_out,'-mat');
        wl_out_scanner=scan.wl;
        nom_mat_scanner=scan.spec/1e3; % in W/m2
        tim_mat_scanner=datenum(yr,month,day)+scan.time/60/24;
        scannertime=datenum(yr,month,day)+scan.time(1,:)/60/24;
    end
    
    %make here synchronization
    
    min_time=[nanmin(arr.time) nanmin(scannertime)];
    max_time=[nanmax(arr.time) nanmax(scannertime)];
    
    maxmin=max(min_time);
    minmax=min(max_time);
    
    index_array=arr.time>maxmin & arr.time<minmax;
    index_scanner=scannertime>maxmin & scannertime<minmax;
    
    
    array_spec_mat= nom_mat_array(:,index_array);
    array_time_mat = repmat(arr.time(1,index_array),size(array_spec_mat,1),1);
    array_wl_mat = repmat(wl_out_array,1,size(array_spec_mat,2));
    
    scanner_spec_mat = nom_mat_scanner(:,index_scanner);
    scanner_time_mat = tim_mat_scanner(:,index_scanner);
    scanner_wl_mat = repmat(wl_out_scanner,1,size(scanner_spec_mat,2));
    
    
    
    x=double(array_time_mat);
    y=double(array_wl_mat);
    xi=double(scanner_time_mat);
    yi=double(scanner_wl_mat);
    
    display('Interpolate ARRAY data to SCANNER wl and time')
    display('Waiting for gridgeneration method linear (default)')
    new_array_mat = griddata(x,y,double(array_spec_mat),xi,yi,'nearest');
    
    save('PSFdata'    ,'array_wl_mat','array_time_mat','array_spec_mat');
    save(sprintf('griddata_%03d%04d.pfs',doy,yr),...
        'scanner_wl_mat','scanner_time_mat','new_array_mat');
    save('QASUMEdata' ,'scanner_wl_mat','scanner_time_mat','scanner_spec_mat');
    
    time=scan2.scanner_time_mat(1,:);
    
    figure;
    plot3(array_wl_mat,rem(array_time_mat,1)*24,array_spec_mat)
    title('PFS Specs')
    figure;
    plot3(scanner_wl_mat,rem(scanner_time_mat,1)*24,new_array_mat)
    title('PFS Specs on Grid')
    figure;
    plot3(scanner_wl_mat,rem(scanner_time_mat,1)*24,scanner_spec_mat)
    title('QASUME Specs')
    
    printpsc('pfs_3dplot',[1:3])
    delgraf
    
    %for j=1:1:size(new_array_mat)
    for j=1:size(scanner_spec_mat,2),
        figure
        plot(wl_out_scanner,scanner_spec_mat(:,j)./new_array_mat(:,j));
        grid
        axis([280 400 0.8 1.2])
    end
    printpsc('pfs_2d_ratios',[1:size(scanner_spec_mat,2)])
    delgraf
    
    for j=1:size(scanner_spec_mat,2),
        figure
        plot(wl_out_scanner,scanner_spec_mat(:,j),wl_out_scanner,new_array_mat(:,j));
        legend('REF',inst)
        grid
    end
    printpsc('pfs_2d',[1:size(scanner_spec_mat,2)])
    delgraf
    
    
end


