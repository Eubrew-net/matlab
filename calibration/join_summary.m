function [ref,ratio_ref,sync]=join_summary(Cal,summary,reference_brw,analyzed_brewer,TSYNC)
% impunt cell of summaries, 
% reference brewer (index of the brewer of the reference)
% analyzed brewer (index of gthe sumaries of all the brewer to be analyzed)
%
%  ref :are the syncronized ozone measurments
%    if Cal.sl is the sl corrected or not  
%  
%  ratio_ref are the ratios to the reference
%            only if the simultaneous measuremetns of the reference exist
%            the last column is the ozone slant column of the reference
%  
%  
% %struct output
% sync.med=ref;
% sync.std=ref_std;
% sync.sza=ref_sza;
% sync.flt=ref_flt;
% sync.airm=ref_airm;
% sync.ratio_ref=ratio_ref;
% sync.temp=ref_flt

if nargin==4
    TSYNC=10;
elseif nargin==3
    TSYNC=10;
    analyzed_brewer=reference_brw;
elseif nargin<3
    disp(error);
    disp('join_summary(Cal,summary,reference_brw,analyzed_brewer,TSYNC)');
end
    

% building the reference

ref=[];
ref_std=[];
ref_sza=[];
ref_flt=[];
ref_airm=[];
ref_temp=[];

%reference_brw=Cal.n_ref(2:3);
%analyzed_brewer=[1:3,5]; 
%Cal.sl_c=[1,1,1,1,0];  % warning 145 sl correction
%build syncronized meaurements
brw_idx=0; ref_idx=[]; %ones(size(reference_brw));
for ii=analyzed_brewer
     
  brw_idx=brw_idx+1;
  if any(reference_brw==ii)
   ref_idx=[ref_idx,brw_idx];
  end
      
  if Cal.sl_c(ii)
      med=summary{ii}(:,[1 12]);
      meds=summary{ii}(:,[1 13]);
  else
      med=summary{ii}(:,[1 6]);
      meds=summary{ii}(:,[1 7]);
  end
     med_sza=summary{ii}(:,[1,2]);
     med_flt=summary{ii}(:,[1,5])/64;
     med_airm=summary{ii}(:,[1,3]);
     med_temp=summary{ii}(:,[1,4]);

    
     time=([fix(med(:,1)*24*60/TSYNC)/24/60*TSYNC,med(:,1)]);
     med(:,1)= time(:,1);
     meds(:,1)=med(:,1); med_sza(:,1)=med(:,1); med_flt(:,1)=med(:,1);
     med_airm(:,1)=med(:,1);

     ref=scan_join(ref,med);
     ref_std=scan_join(ref_std,meds);
     ref_sza=scan_join(ref_sza,med_sza);
     ref_flt=scan_join(ref_flt,med_flt);
     ref_airm=scan_join(ref_airm,med_airm);
     ref_temp=scan_join(ref_temp,med_temp);
 end
 
sync.med=ref;
sync.std=ref_std;
sync.sza=ref_sza;
sync.flt=ref_flt;
sync.temp=ref_temp;
sync.airm=ref_airm;
 
 
 %ref(ref(:,1)>datenum(2014,4,29),2)=NaN;
 % only analyzed brewer are presenet
 
 % index change
 reference_brw=ref_idx;
 
 
 ref_m=[ref(:,1),ref(:,reference_brw+1)];
 jsim=all(~isnan(ref(:,reference_brw+1)),2); 
 
  mean_o3=nanmean(ref_m(jsim,2:end),2); 
  mean_airm=nanmean(ref_airm(jsim,2:end),2); 
  %filter_=ref_filter(jsim,2:end);
  %temperature_=ref_temp(jsim,2:end);
  
 
% analized brewer
%+2 date, ratios +osc
  ratio_ref=NaN*ones(length(find(jsim==1)),length(analyzed_brewer)+2);  
 
  ratio_ref(:,1)=ref(jsim,1);  % only the reference
  ratio_ref(:,2:end-1)=100*matdiv(matadd(ref(jsim,2:end),-mean_o3), mean_o3);
  ratio_ref(:,end)=matmul(mean_airm,mean_o3); %air mass
  

sync.ratio_ref=ratio_ref;
sync.jsim=jsim;
  