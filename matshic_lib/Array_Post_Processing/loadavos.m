function [wl,spec_count,res,tim,doy,yr]=loadavos(thisdate)
%function [wl,spec,res,tim]=loadavos(thisdate)
% 11 9 2012 JG load avos data
% format is based on natalia format.
%27 9 2012 LE included 2 integration time and stray light correction matrix
%res is the responsivity measured in September with DUG11X by LE

[doy,b,b,yr]=julianday(thisdate);

%load('responsivity_avos_sept12.mat');
load('responsivity.avo','-mat')
res=out_resp_april;
res.wl=wl;



disp(sprintf('loading file: AVOS%03d%02d',doy,yr));
a_path='\\CORONA/klima/avos';
data = load(sprintf('%s/%02d/AVOS%03d%02d',a_path,yr,doy,yr));
disp('finished loading');

names = fieldnames(data);
ind=strmatch('GLO',names);

spec=repmat(nan,2048,length(ind));

% load here stray light correction matrix according to Zong and script JG:YYYYYYY

avos_isr=load('avos_C');

for i=1:1:length(ind),
    %    for i=207:20
    
    intflag=0;
    
    thisdata=getfield(data,names{ind(i)});
    
    
     if (size(thisdata.M,2)==2 & size(thisdata.Dark,2)==2)
            raw2=mean(thisdata.m(2).m,2);
            index_sat = (raw2<50000);
            
     if mean(index_sat)==1      
            
            thisdark=getfield(data,names{ind(i)-1});
            dark3=mean(thisdark.m(2).m(:,7:12),2);
            tim(i)=thisdata.time(:,2);
            %temp2(i)=thisdata.temp(:,2);
            temp(i)=thisdata.m(2).temp(1);
            IT3=thisdata.IT(:,2);
            newdark3=dark3;
            signal3=(raw2-newdark3)./IT3;
            merged_signal=signal3;
           
            intflag=1;
        
     end     
     end
    
    
    if intflag ==0
        
    raw=mean(thisdata.m(1).m,2);
    thisdark=getfield(data,names{ind(i)-1});
    dark=mean(thisdark.m(1).m,2);
    tim(i)=thisdata.time(:,1);
    temp(i)=thisdata.m(1).temp(1);
    IT=thisdata.IT(:,1);
    newdark=dark;
    signal=(raw-newdark)./IT;
    merged_signal=signal;
    
        % here if 2 integration times are available
        if (size(thisdata.M,2)==2 & size(thisdata.Dark,2)==2)
            raw2=mean(thisdata.m(2).m,2);
            index_sat = (raw2<30000);
            index_sat(wl<305)=0;
            
            thisdark=getfield(data,names{ind(i)-1});
            dark2=mean(thisdark.m(2).m(:,7:12),2);
            tim2(i)=thisdata.time(:,2);
            %temp2(i)=thisdata.temp(:,2);
            temp2(i)=thisdata.m(2).temp(1);
            IT2=thisdata.IT(:,2);
            
            
            newdark2=dark2;
            signal2=(raw2-newdark2)./IT2;
            merged_signal=signal;
            merged_signal(index_sat)=signal2(index_sat);
            tim(i)= (tim2(i)+tim(i))./2;
        end
    end
    
    
    merged_signal(isinf(merged_signal) | isnan(merged_signal))=0;
    
    
    merged_signal2 = merged_signal;

 
    temp_spec= avos_isr.C*merged_signal2;
    
    temp_spec2=temp_spec;
    
    
    temp_spec2(res.wl>390,:)=0;
    spec_count(:,i) =temp_spec2;
    
end

