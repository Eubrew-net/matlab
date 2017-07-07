file_setup='calizo_setup';
run(fullfile('.',file_setup))

Date.dayend=365; Date.day0=1; % Esto para los weekly
Date.CALC_DAYS =Date.day0:Date.dayend;
Cal.Date=Date;

% READ Bfiles dz
for i=1
     ozone=read_bdata_dz(i,Cal);
end

%% Process dz's
%
% Computes DT from dz measurements on slits #3,#5 and #7
% 
% 10590 GOSUB 9710:FOR IS=2 TO 7:F(IS)=(F(IS)-F(1))*2/CY/IT:NEXT:dt.f11=f(2)
% 10591 IF F(3)>1E+07 THEN F(3)=1E+07
% 10592 IF F(3)<2 THEN F(3)=2
% 10593 IF F(5)>1E+07 THEN F(5)=1E+07
% 10594 IF F(5)<2 THEN F(5)=2
% 10595 IF F(7)>1E+07 THEN F(7)=1E+07
% 10596 IF F(7)<2 THEN F(7)=2
% 10600 F3=F(3):F5=F(5):FOR IS=1 TO 10:A=F3+F5:T2=LOG(A/F(7))/A
% 10602 IF T2<1E-08 THEN T2=1E-08
% 10603 IF T2>.0000001 THEN T2=.0000001
% 10610 F3=F(3)*EXP(F3*T2):F5=F(5)*EXP(F5*T2):NEXT:MS(1)=T2*1E+09:DT.BFILE(NT%)=MS(1):GOSUB 8050
%
% Input: variable ozone (from read_bdata)
%

t2=dz_process(ozone);
for i=1:size(t2,1)
    t2{i}(1:4:end,4)=NaN;
end

t2_=cellfun(@(x) grpstats(x,fix(x(:,2)/10)*10), t2,'UniformOutput',0);
% ploteo
time=cell2mat(cellfun(@(x) x(:,1),t2_,'UniformOutput',0)); 
filter=cell2mat(cellfun(@(x) x(:,3),t2_,'UniformOutput',0)); 
data=cell2mat(cellfun(@(x) x(:,4),t2_,'UniformOutput',0)); 
figure; gscatter(time,data,filter); grid; 
datetick('x',2,'keeplimits','keepticks');
