function pfs2mat(datestart,dateend)

if nargin<2,dateend='';end
if isempty(dateend),dateend=datestart;end


datea=datenum(datestart);
dateb=datenum(dateend);
ppin='/corona/calib/uv/qasume/2014/ptb_berlin/data/Ave6';


for i=datea:dateb,
    
    [doy,day,month,yr]=julianday(i);
    
    
    % load resp
    buf=load('/corona/calib/uv/qasume/2014/ptb_berlin/data/responsivities.txt');
    wlr=buf(:,1);
    if doy==92,
        resp=buf(:,4);
    else
        resp=buf(:,3);
    end
       

    fname=sprintf('%s/S_P_%02d%02d%02d1*',ppin,yr-2000,month,day);
    
    d=dir(fname);
    Nfiles=length(d);
    
    for i=1:Nfiles,
        fn=sprintf('%s/%s',ppin,d(i).name);
        f=load(fn);
        f(1,:)=[];
        if i==1,
            wl=1e7./f(:,1);
            ind=wl>=290 & wl<=400;
            wl=wl(ind);
            resp=spline(wlr,resp,wl);
        end
        data(:,i)=f(ind,2)./resp;
        
        
        fid=fopen(fn);
        buf=fgetl(fid);
        fclose(fid);
        
        doy2=str2double(buf(1:3));
        hh=str2double(buf(4:5));
        mm=str2double(buf(6:7));
        ss=str2double(buf(8:9));
        tm(:,i)=repmat( (hh+mm/60+ss/3600),size(wl));
        
        
    end
    
    
    fnout=sprintf('/corona/calib/uv/matshic/uvdata/%04d/pfs/mat_uv%03d%04d_ori.pfs',yr,doy,yr);

    save(fnout,'wl','tm','data');
    
    
end



