function [ref,ratio_ref,sync]=join_summary(Cal,summary,reference_brw,analyzed_brewer,TSYNC,varargin)
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
% %struct output
% sync.med=ref;
% sync.std=ref_std;
% sync.sza=ref_sza;
% sync.flt=ref_flt;
% sync.airm=ref_airm;
% sync.ratio_ref=ratio_ref;
% sync.temp=ref_flt

%% Validacion de argumentos de entrada
arg = inputParser;   % Create instance of inputParser class.
arg.FunctionName = 'join_summary';

% input obligatorio
arg.addRequired('Cal');
arg.addRequired('summary');
arg.addRequired('reference_brw');
arg.addRequired('analyzed_brewer');
arg.addRequired('TSYNC');

% input param - value
arg.addParamValue('date_range', [], @isfloat); % por defecto, no control de fechas

% validamos los argumentos definidos:
arg.parse(Cal,summary,reference_brw,analyzed_brewer,TSYNC,varargin{:});

%%
if nargin==4
    TSYNC=10;
elseif nargin==3
    TSYNC=10;
    analyzed_brewer=reference_brw;
elseif nargin<3
    disp(error);
    disp('join_summary(Cal,summary,reference_brw,analyzed_brewer,TSYNC)');
end
    
sizes=NaN*ones(1,max(reference_brw));
for i=reference_brw
    sizes(i)=size(summary{i},1);
end
[a idx]=max(sizes);

% build syncronized meaurements
ref=fix(summary{idx}(:,1)*24*60/TSYNC)/24/60*TSYNC; ref_std=ref;  
ref_sza=ref;  ref_flt=ref;
ref_airm=ref; ref_temp=ref;
for ii=1:length(Cal.brw)
    if ~isempty(summary{ii}) && ii<=length(summary) 
       med_sza=summary{ii}(:,[1,2]);
       med_flt=summary{ii}(:,[1,5])/64;
       med_airm=summary{ii}(:,[1,3]);
       med_temp=summary{ii}(:,[1,4]);    
       if Cal.sl_c(ii)
          med=summary{ii}(:,[1 12]);
          meds=summary{ii}(:,[1 13]);
       else
          med=summary{ii}(:,[1 6]);
          meds=summary{ii}(:,[1 7]);      
       end
       
       med(:,1) = fix(med(:,1)*24*60/TSYNC)/24/60*TSYNC; meds(:,1) = med(:,1); 
       med_sza(:,1) = med(:,1); med_flt(:,1) = med(:,1);
       med_airm(:,1)= med(:,1); med_temp(:,1)= med(:,1); 
    else
       aux=NaN*ones(size(ref,1),2);
       med=aux;       meds=aux;  
       med_sza=aux;   med_flt=aux;     
       med_airm=aux;  med_temp=aux; 
     
       med(:,1) = fix(ref(:,1)*24*60/TSYNC)/24/60*TSYNC;  meds(:,1)=med(:,1); 
       med_sza(:,1) = med(:,1);  med_flt(:,1) = med(:,1);
       med_airm(:,1)= med(:,1);  med_temp(:,1)= med(:,1);
    end
    ref=scan_join(ref,med);
    ref_std=scan_join(ref_std,meds);
    ref_sza=scan_join(ref_sza,med_sza);
    ref_flt=scan_join(ref_flt,med_flt);
    ref_airm=scan_join(ref_airm,med_airm);
    ref_temp=scan_join(ref_temp,med_temp);
end

%% Time Filter
if ~isempty(arg.Results.date_range)
   ref(ref(:,1)<arg.Results.date_range(1),:)=[];
   ref_std(ref_std(:,1)<arg.Results.date_range(1),:)=[];
   ref_sza(ref_sza(:,1)<arg.Results.date_range(1),:)=[];
   ref_flt(ref_flt(:,1)<arg.Results.date_range(1),:)=[];
   ref_airm(ref_airm(:,1)<arg.Results.date_range(1),:)=[];
   ref_temp(ref_temp(:,1)<arg.Results.date_range(1),:)=[];

   if length(arg.Results.date_range)>1
      ref(ref(:,1)>arg.Results.date_range(2),:)=[];
      ref_std(ref_std(:,1)>arg.Results.date_range(2),:)=[];
      ref_sza(ref_sza(:,1)>arg.Results.date_range(2),:)=[];
      ref_flt(ref_flt(:,1)>arg.Results.date_range(2),:)=[];
      ref_airm(ref_airm(:,1)>arg.Results.date_range(2),:)=[];
      ref_temp(ref_temp(:,1)>arg.Results.date_range(2),:)=[];
   end
end

%% Building the reference
 ref_m=ref(:,[1 reference_brw+1]); jsim=all(~isnan(ref_m(:,2:end)),2); 
 mean_o3=nanmean(ref_m(jsim,2:end),2); 
 mean_airm=nanmean(ref_airm(jsim,reference_brw+1),2); 
  
% analized brewer+2: date, ratios +osc
 ratio_ref=NaN*ones(length(find(jsim==1)),length(analyzed_brewer)+2);  
 
 ratio_ref(:,1)=ref_m(jsim,1); 
 ratio_ref(:,2:end-1)=100*matdiv(matadd(ref(jsim,analyzed_brewer+1),-mean_o3), mean_o3);
 ratio_ref(:,end)=matmul(mean_airm,mean_o3); %air mass
  
 sync.med=ref;             sync.std=ref_std;
 sync.sza=ref_sza;         sync.flt=ref_flt;
 sync.temp=ref_temp;       sync.airm=ref_airm;
 sync.ratio_ref=ratio_ref; sync.jsim=jsim;
  