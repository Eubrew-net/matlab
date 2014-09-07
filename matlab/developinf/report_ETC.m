function [ETC_Op ETC_Chk]=report_ETC(Cal,summary,summary_old,ETC,A,varargin)


%% Validacion de input's
arg = inputParser;   % Create an instance of the inputParser class
arg.FunctionName='report_ETC';

arg.addRequired('Cal', @isstruct);
arg.addRequired('summary', @iscell);
arg.addRequired('summary_old', @iscell);
arg.addRequired('ETC', @isstruct);
arg.addRequired('A',   @isstruct);

arg.addParamValue('reference_brw', Cal.n_ref, @isfloat); 
arg.addParamValue('analyzed_brw', 1:Cal.n_brw, @isfloat); 
arg.addParamValue('grp_custom', [], @isstruct);    
arg.addParamValue('date_range', Cal.Date.CALC_DAYS, @isfloat);    

arg.parse(Cal, summary, summary_old, ETC, A, varargin{:});

tsync=5;

%% set of comparison:  instrument = first, reference = second
comp=sortrows([nchoosek(1:Cal.n_brw,2);nchoosek(fliplr(1:Cal.n_brw),2)]);
comp=comp(ismember(comp(:,1),arg.Results.analyzed_brw) & ismember(comp(:,2),arg.Results.reference_brw),:);

%% Periods, if any
    event_info=arg.Results.grp_custom;
    if isempty(event_info)
       fprintf('\rDebes definir una variable de eventos valida (help report_ETC)\n');
       return
    end
 
y=group_time(arg.Results.date_range',event_info.dates); id_period=unique(y);
if any(id_period==0)
   fprintf('\rRemoving data before 1st event as input.\n');
   date_range=arg.Results.date_range(y~=0); y(y==0)=[]; id_period(id_period==0)=[]; 
else
   date_range=arg.Results.date_range; 
end

summary_old=arg.Results.summary_old; summary=arg.Results.summary;
if ~isempty(date_range)
   for i=arg.Results.analyzed_brw
       summary_old{i}(summary_old{i}(:,1)<date_range(1),:)=[];
       summary{i}(summary{i}(:,1)<date_range(1),:)=[];
   end
   if length(date_range)>1
      for i=arg.Results.analyzed_brw
          summary_old{i}(summary_old{i}(:,1)>date_range(end),:)=[];
          summary{i}(summary{i}(:,1)>date_range(end),:)=[];
      end
   end
end

%% Operative (old)
ETC_op=cell(max(arg.Results.analyzed_brw),max(arg.Results.reference_brw),length(id_period));
for pp=1:length(id_period)
    periods_=date_range(y==id_period(pp));
    for ii=1:size(comp,1)
        ref=comp(ii,2);    inst=comp(ii,1); 
        ETC_op{inst,ref,pp}=[];    
        try
           A_s=A.old(ismember(A.old(:,1),fix(periods_)),inst+1); A_s=unique(A_s(~isnan(A_s)));
           ETC_op{inst,ref,pp}=ETC_calibration_C(Cal,summary_old,A_s,inst,ref,...
                                                 tsync,1.8,0.01,diaj(periods_),0); 
        catch exception
           fprintf('%s, brewer: %s\n',exception.message,Cal.brw_name{inst});
           ETC_op{inst,ref,pp}=[];
        end
    end
end

% Resumen con parámetros de interés. 
ETC_Op=NaN*ones(size(comp,1)*size(ETC_op,3),8);
idx=1;
for pp=1:size(ETC_op,3)
    periods_=date_range(y==id_period(pp));
    for ind=1:size(comp,1)
        inst=comp(ind,1); ref=comp(ind,2);    
        A2=ETC.old(ismember(ETC.old(:,1),fix(periods_)),inst+1); A2=unique(A2(~isnan(A2)));
        A1=A.old(ismember(A.old(:,1),fix(periods_)),inst+1);     A1=unique(A1(~isnan(A1)));
        ETC_Op(idx,1)=mean(periods_);
        if ~isempty(ETC_op{inst,ref,pp})
           ETC_Op(idx,2:end)=cat(2,Cal.brw(inst),Cal.brw(ref),...
                                   [A2 A1],ETC_op{inst,ref,pp}(1).NEW,...
                                   ETC_op{inst,ref,pp}(1).TP(1),...
                                   ETC_op{inst,ref,pp}(1).TP(2)/10000);
        else
           ETC_Op(idx,2:5)=cat(2,Cal.brw(inst),Cal.brw(ref),[A2 A1]);  
           idx=idx+1;
           continue
        end
        idx=idx+1;
    end
end
fprintf('\nETC Transfer: Operative Config.\n');
displaytable(ETC_Op(:,2:end),{'Inst','Ref','Cfg. ETC','Cfg. A1','1P','2P','2P A1'},...
             8,{'d','d','d','.4f','.1f','.1f','.4f'},...
             reshape(repmat(arg.Results.grp_custom.labels,size(comp,1),1),1,...
             length(arg.Results.grp_custom.labels)*size(comp,1))'); 

         
%% Alternative (chk)
ETC_chk=cell(max(arg.Results.analyzed_brw),max(arg.Results.reference_brw),length(id_period));
for pp=1:length(id_period)
    periods_=date_range(y==id_period(pp));
    for ii=1:size(comp,1)
        ref=comp(ii,2);    inst=comp(ii,1); 
        ETC_chk{inst,ref,pp}=[];    
        try
           A_s=A.new(ismember(A.new(:,1),fix(periods_)),inst+1); A_s=unique(A_s(~isnan(A_s)));
           ETC_chk{inst,ref,pp}=ETC_calibration_C(Cal,summary,A_s,inst,ref,...
                                                  tsync,1.8,0.01,diaj(periods_),0); 
        catch exception
           fprintf('%s, brewer: %s\n',exception.message,Cal.brw_name{inst});
           ETC_chk{inst,ref,pp}=[];
        end
    end
end

% Resumen con parámetros de interés
ETC_Chk=NaN*ones(size(comp,1)*size(ETC_chk,3),8);
idx=1;
for pp=1:size(ETC_chk,3)
    periods_=date_range(y==id_period(pp));    
    for ind=1:size(comp,1)
        inst=comp(ind,1); ref=comp(ind,2);    
        A2=ETC.new(ismember(ETC.new(:,1),fix(periods_)),comp(ind)+1); A2=unique(A2(~isnan(A2)));
        A1=A.new(ismember(A.new(:,1),fix(periods_)),comp(ind)+1); A1=unique(A1(~isnan(A1)));
        ETC_Chk(idx,1)=mean(periods_);
        if ~isempty(ETC_chk{inst,ref,pp})
           ETC_Chk(idx,2:end)=cat(2,Cal.brw(inst),Cal.brw(ref),...
                                    [A2 A1],ETC_chk{inst,ref,pp}(1).NEW,...
                                    ETC_chk{inst,ref,pp}(1).TP(1),...
                                    ETC_chk{inst,ref,pp}(1).TP(2)/10000);  
        else
           ETC_Chk(idx,2:5)=cat(2,Cal.brw(inst),Cal.brw(ref),[A2 A1]);  
           idx=idx+1;
           continue
        end
        idx=idx+1;
    end
end
fprintf('\nETC Transfer: Alternative Config.\n');
displaytable(ETC_Chk(:,2:end),{'Inst','Ref','Cfg. ETC','Cfg. A1','1P','2P','2P A1'},...
             8,{'d','d','d','.4f','.1f','.1f','.4f'},...
             reshape(repmat(arg.Results.grp_custom.labels,size(comp,1),1),1,...
             length(arg.Results.grp_custom.labels)*size(comp,1))'); 
                           