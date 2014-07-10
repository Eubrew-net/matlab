function [wl,spec_count,res,tim,doy,yr]=load_avos_two(thisdate)
%function [wl,spec,res,tim]=loadavos(thisdate)
% 11 9 2012 JG load avos data
% format is based on natalia format.
%27 9 2012 LE included 2 integration time and stray light correction matrix
%res is the responsivity measured in September with DUG11X by LE

[doy,b,b,yr]=julianday(thisdate);

load('AVOS2_WL.mat');
%load('mean_responsivity_avos_april13.mat')
%res=out_resp_april;
wl=wl_avos2;
res=0;

disp('loading file');
a_path='/corona/klima/avos';
data = load(sprintf('%s/%02d/AVOS%03d%02d',a_path,yr,doy,yr));
disp('finished loading');

names = fieldnames(data);
ind=strmatch('GLO',names);

spec=repmat(nan,2048,length(ind));

% load here stray light correction matrix according to Zong and script JG:YYYYYYY

%avos_isr=load('avos_C');

for i=1:1:length(ind),
    %        for i=350:1:370
    
    intflag=0;
    
    thisdata=getfield(data,names{ind(i)});
    
    index_nosat = (thisdata.M(:,4)<45000);
    index_sat = (thisdata.M(:,4)>=45000);
    
    thisdark=getfield(data,names{ind(i)-1});
    dark_high=thisdark.m(4).m(:,4);
    signal_high=double((thisdata.m(4).m-dark_high))./thisdata.IT(:,4);
    
    % vec=[max(thisdata.M(:,1)) max(thisdata.M(:,2)) max(thisdata.M(:,3))];
    % diff = (vec-45000);
    % ind_neg = diff <0;
    % diff(ind_neg);
    
    dark_low=thisdark.m(2).m(:,2);
    signal_low=double((thisdata.m(2).m-dark_low))./thisdata.IT(:,2);
    
    
    signal_high(index_sat)=signal_low(index_sat);
    
    tim1(i)=thisdata.time(:,4);
    tim2(i)=thisdata.time(:,2);
    tim(i)=(tim1(i)+tim2(i))./2;
    
    % temp_spec= avos_isr.C*signal_high;
    temp_spec=signal_high;
    
    spec_count(:,i) =temp_spec;
    
end

