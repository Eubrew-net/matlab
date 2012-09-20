function [ etc_r,aod_r,filter_r ] = langley_calculation(lgl )
% return 3 regresion
% etc_r : R6 robust regression of R6
% aod_r : regression for every waveleng
% filter_r : robust regression with filter #3 and #4 filter
%
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%lgl_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'	'temp'  'flt'...  %1-11              
%           'f0'  'f1'	'f2'	'f3'	'f4'	'f5'	'f6'	...  % 12-18 c/c 1º
%           'o3'    'r1'    'r2'    'r3'    'r4'    'r5'    'r6'   ... % 19 25ratios (Rayleight corrected !!)                % 19-25  
%           'F0'	'F1'	'F2'	'F3'	'F4'	'F5'	'F6'	...  %  % 26-32Segund configuracion                          
%           'O3'    'R1'    'R2'    'R3'    'R4'    'R5'    'R6'   ... %  % 33-39   ratios (Rayleight corrected !!)               
%         };

% depuramos las observaciones parametros estandard
%[m,s,n,g]=grpstats(lgl(:,[2,19,33]),fix(lgl(:,3)/10));
%j=find(s(:,2)<1.0 & m(:,2)>100 & m(:,2)<600 & m(:,1)>0 & n(:,1)==5);
%idx=cellfun(@str2num,g(j));
%t=ismember(fix(lgl(:,3)/10),idx);
%lgl=lgl(t,:);
% Separados en la entrada
% separamos la mañana de la tarde (tst-> true solar time)
%jpm=(lgl(:,9)/60>12) ; jam=~jpm;
% 
%% Obtenemos el posible valor de los filtros
% mejor el valor de la regresion

% regresion por filtros
% X=[lgl(:,5),jam,jam.*lgl(:,5),lgl(:,10)==128,lgl(:,10)==192];
%igual pendiente
 X=[lgl(:,5),lgl(:,10)==128,lgl(:,10)==192]; 

try
 [c1,ci]=robustfit(X,lgl(:,25));
 filter_r(1).b=[c1,ci.se,ci.coeffcorr,ci.t,ci.p];
 filter_r(1).s=ci;
catch
 filter_r(1)=[];
end
%% Evaluacion de la 2º configuracion
try
[c1,ci]=robustfit(X,lgl(:,39));
 filter_r(2).b=[c1,ci.se,ci.coeffcorr,ci.t,ci.p];
 filter_r(2).s=ci;
catch
 filter_r(2)=[]; 
end

%% R6
try
    [c1,ci]=robustfit(lgl(:,5),lgl(:,25));
    etc_r(1).b=[c1,ci.se,ci.coeffcorr,ci.t,ci.p];
    etc_r(1).s=ci;
catch
    etc_r(1).b=[];
    etc_r(1).s=[];
end

try
    [c1,ci]=robustfit(lgl(:,5),lgl(:,39));
    etc_r(2).b=[c1,ci.se,ci.coeffcorr,ci.t,ci.p];
    etc_r(2).s=ci;
catch
    etc_r(2).b=[];
    etc_r(2).s=[];
end


%%AOD Ratios individual


for i=1:6
try
    [c1,ci]=robustfit(lgl(:,5),lgl(:,11+i));
    aod_r(1).b(i,:,:)=[c1,ci.se,ci.coeffcorr,ci.t,ci.p]';
    aod_r(1).s(i)=ci;
catch
    aod_r(1).b(:,:,i)=NaN*ones(6,2);
    aod_r(1).s=[];
end

try
    [c1,ci]=robustfit(lgl(:,5),lgl(:,25+i));
    aod_r(2).b(i,:,:)=[c1,ci.se,ci.coeffcorr,ci.t,ci.p]';
    aod_r(2).s(i)=ci;
catch
    aod_r(2).b=[];
    aod_r(2).s(i)=[];
end
    

end

