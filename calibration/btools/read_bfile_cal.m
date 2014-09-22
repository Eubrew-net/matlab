%% read bfile data according to CAL
% test routine 
    function [ bfile_data]=read_bfile_cal(Cal,analyzed_brewer)
    if nargin==1
     if isfield(Cal,'analyzed_brw')
         analyzed_brw=Cal.analyzed_brw;
     else
         analyzed_brw=find(Cal.brw);
     end
    end
        
   
%% READ Brewer Summaries
 for i=analyzed_brw
    dsum{i}={};       ozone_raw{i}={};   hg{i}={};
    ozone_sum{i}={};  ozone_raw0{i}={};  bhg{i}={};
    config{i}={};     sl{i}={};          log{i}={};
    ozone_ds{i}={};   sl_cr{i}={};       missing{i}=[];
    ozone_dz_raw{i}={};   ozone_dz_sum{i}={}

    [ozone,log_,missing_]=read_bdata(i,Cal);

    dsum{i}=ozone.dsum;
    ozone_sum{i}=ozone.ozone_sum;
    config{i}=ozone.config;
    ozone_ds{i}=ozone.ozone_ds;
    ozone_raw{i}=ozone.raw;
    ozone_raw0{i}=ozone.raw0;
    
    ozone_dzraw0{i}=ozone.dzraw0;
    ozone_dzsum{i}=ozone.dzsum;
    
    sl{i}=ozone.sl; %first calibration/ bfiles
    sl_cr{i}=ozone.sl_cr; %recalculated with 2? configuration
    hg{i}=ozone.hg;
    bhg{i}=ozone.bhg;
    log{i}=cat(1,log_{:});
    missing{i}=missing_';
 end
 
    bfile_data.dsum=dsum;
    bfile_data.ozone_sum=ozone_sum;
    bfile_data.config=config;
    bfile_data.ozone_ds=ozone_ds;
    bfile_data.ozone_raw=ozone_raw;
    bfile_data.ozone_raw0=ozone_raw0;
    
    bfile_data.ozone_dzraw0=ozone_dzraw0;
    bfile_data.ozone_dzsum=ozone_dzsum;
    
    bfile_data.sl=sl; %first calibration/ bfiles
    bfile_data.sl_cr=sl_cr; %recalculated with 2? configuration
    bfile_data.hg=hg;
    bfile_data.bhg=bhg;
    bfile_data.log=log;
    bfile_data.missing=missing;
    bfile_data.Cal=Cal;
 
 
 