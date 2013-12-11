file_setup='calizo2013_setup';
run(fullfile('.','calizo2013_setup.m'))

Date.dayend=150; Date.day0=Date.dayend-30; % Esto para los weekly
Date.CALC_DAYS =Date.day0:Date.dayend;
Cal.Date=Date;

% READ Brewer Summaries
for i=1%:Cal.n_brw
     [ozone,log_,missing_]=read_bdata_dz(i,Cal);
end

 %% function dz_process(ozone)
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

dz_raw0=ozone.ozone_dz_raw0;

% raw counts -> raw countrates: 2*(rawcounts-dark)/(cycles*0.1147). Including Hg slit 
countRates=cellfun(@(x) cat(2,x(:,1),matdiv(2*matadd(x(:,11:18),-x(:,12)),matmul(0.1147,x(:,10)))),dz_raw0,'UniformOutput',false);

% We remove circumsolar component
out=cellfun(@(x) sortrows(repmat(x(1:4:end,:),4,1),1),countRates,'UniformOutput',false);
countRates=cellfun(@(x,y) matadd(x(:,2:end),-y(:,2:end)),countRates,out,'UniformOutput',false);

idx=cellfun(@(x) x(:,end)~=0,countRates,'UniformOutput',false); 

aux=cellfun(@(x,y) x(y,[1 6]),dz_raw0,idx,'UniformOutput',false);
countRates=cellfun(@(x,y) x(y,:),countRates,idx,'UniformOutput',false);

% Filtering data
outlier1=cellfun(@(x) x<=2,countRates,'UniformOutput',false);
outlier2=cellfun(@(x) x>=1e7,countRates,'UniformOutput',false);
for i=1:length(countRates)
   countRates{i}(outlier1{i})=2;
   countRates{i}(outlier2{i})=1e7;  
end

% As a first approximation set the true (unknown) count-rates equal to the observed count-rates
% (it is assumed that WL=0 and WU=7):
f3=cellfun(@(x) x(:,4),countRates,'UniformOutput',false); f3_=f3;
f5=cellfun(@(x) x(:,6),countRates,'UniformOutput',false); f5_=f5;
f7=cellfun(@(x) x(:,end),countRates,'UniformOutput',false);
% Iterate steps until the value for T1 converges (10 times on Brewer code)
clear log; % to avoid variables named as the matlab function for ln
for count=1:30
    a=cellfun(@(x,y) matadd(x,y),f3,f5,'UniformOutput',false);
    t2=cellfun(@(x,y) matdiv(log(matdiv(x,y)),x),a,f7,'UniformOutput',false);
        
    outlier1=cellfun(@(x) x<=1e-8,t2,'UniformOutput',false);
    outlier2=cellfun(@(x) x>=1e-7,t2,'UniformOutput',false);
    for i=1:length(t2)
        t2{i}(outlier1{i})=1e-8;
        t2{i}(outlier2{i})=1e-7;  
    end
    f3=cellfun(@(x,y,z) matmul(x,exp(matmul(y,z))),f3_,f3,t2,'UniformOutput',false);
    f5=cellfun(@(x,y,z) matmul(x,exp(matmul(y,z))),f5_,f5,t2,'UniformOutput',false);
end

% ploteo
data=cell2mat(aux); check=cell2mat(t2);
figure; gscatter(data(:,1),check,data(:,2)); grid; datetick('x','keeplimits','keepticks');
