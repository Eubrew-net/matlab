function [sum, resp,stats,O3R,lgl_cor] = langley_day(lgl,nb,cfg,FC,fplot,Cal,Dep )
%Plotea el langley del dia
% nd=1;nb=1;langley_day(lgl_s{nb,nd},nb,cfg_s{nb,nd},[128]);
%configuration_dif_table(cfg_s{nb,nd});
%   Detailed explanation goes here
%         aux=ozone_lgl{nb};
%         auxc=cfg{nb};
%         j=find(fix(aux(:,1))==fecha);
%         %o3.ozone_lgl=aux(j,:);
%         lgl=aux(j,:);
%         j=find(auxc(end,:,1)==fecha);
%         setup=squeeze(auxc(:,j,:));
if nargin<=3
    FC=[];
    fplot=0;
    Cal.brw_str{nb}='xxx';
    Dep=1;
elseif nargin==4
        fplot=0;
        Cal.brw_str{nb}='xxx';
        Dep=1;
elseif nargin==5
        Cal.brw_str{nb}='xxx';
        Dep=1;
end



        fecha=unique(fix(lgl(:,1)));
        % for recalculation
        %[o_3,so_2,rat]=ozone_cal_raw(lgl(:,12:18),lgl(:,5),770,lgl(:,6),setup(:,1));
% 
    if  ndims(cfg)==2;
        cfg_idx=find(cfg(:,1)==fecha);
        setup=cfg(cfg_idx,:);
    elseif ndims(cfg)==3     
        cfg_idx=find(cfg(end,:,1)==fecha);
        setup=squeeze(cfg(:,cfg_idx,:));
    
        % depuracion de observaciones
        [m,s,n,g]=grpstats(lgl(:,[2,19,33]),fix(lgl(:,3)/10));
        j=find(s(:,2)<2 & m(:,2)>100 & m(:,2)<600 & m(:,1)>0 & n(:,1)==5);
        idx=cellfun(@str2num,g(j));
        t=ismember(fix(lgl(:,3)/10),idx);
        lgl=lgl(t,:);
        
    end
    %airmas 5
        lgl=lgl(lgl(:,5)<5,:);
        
        %%
        % plot
        %Cal.brw_str={'157','183','185'};
        if isempty(FC)
        switch nb
            case 1
                FC=[];
            case 2
                FC=256;
            case 3
                FC=[192,256];
            case 4
                FC=[192];
        end
        end
        %% depuracion de michalsky
        lgl_org=lgl;
        try
        if Dep==1    
         [lgl,idx_]=michalsky_filter_2(lgl,FC,fplot);
        end
        catch
            disp('error en michalsky')
        end
         
        fplot=1;
        [resp,stats]=simple_langley_summ(lgl,Cal.brw_str{nb},FC,fplot);
        % individual vs R6
         O3W=[  0.00    0   0.00   -1.00    0.50    2.20   -1.70];
         %BE=[0,0,4870,4620,4410,4220,4040];

         
         
%          recalculation
%          
%   resp four dim matrix(AM_PM,CFG,Parameter,Results);
%          dim  (2,2,5,7,8);
%   AM_PM dim 2  AM=1/PM=2  
%   CFG dim 2  CFG1,CFG2  
%   Paramenter dim 5   ETC,SLOPE,FILTER1,FILTER2,FILTER3
%    WV  dim 7  F0,R6,F2,F3,F4,F5,F6  
%   results    dim 3   1 Value,
%                      2-3 ci,  
   o3.ozone_lgl_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'	'temp'  'flt'...  %1-11              
          'f0'  'f1'	'f2'	'f3'	'f4'	'f5'	'f6'	...  % 12-18 c/c 1º
          'o3 cfg1'    'r1'    'r2'    'r3'    'r4'    'r5'    'r6'   ... % 19 25ratios (Rayleight corrected !!)                % 19-25  
          'F0'	'F1'	'F2'	'F3'	'F4'	'F5'	'F6'	...  %  % 26-32Segund configuracion                          
          'O3 cfg2'    'R1'    'R2'    'R3'    'R4'    'R5'    'R6'   ... %  % 33-39   ratios (Rayleight corrected !!)               
        };   
 %% ozone recalculation
  
    [O3R,lgl_cor]=langley_o3_recalculation_sum(lgl,cfg,resp,FC);
     
    jam=(lgl(:,9)/60<=12);
    jpm=~jam;
         
         o3_am=lgl(:,[19,33]);o3_am(jpm,:)=NaN;
         o3_pm=lgl(:,[19,33]);o3_pm(jam,:)=NaN;
         
         sum.o3_r=[o3_am(:,1),o3_pm(:,1),O3R{1:2,1},...
                   o3_am(:,2),o3_pm(:,2),O3R{1:2,2}]; 
         sum.date=fecha;
         sum.brw=nb;
         sum.label_row={'am1','pm1','amr1','pmr1','am2','pm2','amr2','pmr2'};
         sum.o3r_mean=(nanmean(sum.o3_r(:,1:end)));
         sum.o3r_std=(nanstd(sum.o3_r(:,1:end)));
         sum.o3r_range=(abs(max(sum.o3_r(:,1:end))-min(sum.o3_r(:,1:end))));
         tableform(sum.label_row,[sum.o3r_mean;sum.o3r_std;sum.o3r_range],{'mean','std','range'});
        % tableform(sum.label_row,{'mean','std','range'},[sum.o3r_mean;sum.o3r_std;sum.o3r_range]);         
         
         sum.label_row2={'am1','pm1','am2','pm2'};
         sum.label_col={'R6','SW'};
         
         
         %filter #1
         r=resp;
         rf=squeeze(r(:,:,3,:,1));rm=reshape(rf,4,[]);
         sum.filter_3=[rm(:,2),rm*O3W'];

         tableform({'R6','W'},sum.filter_3,sum.label_row2');
        
         %filter #2
         rf=squeeze(r(:,:,4,:,1));rm=reshape(rf,4,[]);
         sum.filter_4=[rm(:,2),rm*O3W'];
         tableform({'R6','W'},sum.filter_4,sum.label_row2');
         
         %etc
         rf=squeeze(r(:,:,1,:,1));rm=reshape(rf,4,[]);
         sum.etc_r=[rm(:,2),rm*O3W'];
         tableform({'R6','W'},sum.etc_r,sum.label_row2');
         
         
         
         sum.etc=rm;       
         rx=squeeze(stats(:,:,:,1));rm=reshape(rx,4,[]);
         sum.r=rm;
         rf=squeeze(r(:,:,1,2,1:3));rm=reshape(rf,4,[])'
         sum.etc_o3=rm;
         
         tableform(sum.label_row2,sum.etc_o3,{'m','ci1','ci2'})
         
   if fplot    
       
        figure;
        boxplot(sum.o3_r,sum.label_row);
  
       
       
       
        figure;
          plot(lgl(:,1),sum.o3_r);
         legend(sum.label_row);
         %gscatter(lgl(:,1),sum.o3_r,lgl(:,10),'','rb','+.o');
         datetick;
         figure;
         plot(lgl(:,9)/60,lgl_cor(:,[12,14:18]),'-',lgl(:,9)/60,lgl(:,[12,14:18]),'.')
         %,...  lgl_cor(:,[12,14:18])-lgl(:,[12,14:18]));
         legend(o3.ozone_lgl_legend([12,14:18]),'Location','South','orientation','horizontal');
         ylabel('counts second');
         %mmplotyy('corrected-uncorrrecte')
         title([num2str(nb),' 1 CONFIG  filter corrected ',fecha]);
  
         figure;
         mmplotyy_temp(lgl(:,9)/60,...
             [lgl_cor(:,[26,28:32]),lgl(:,[26,28:32])],...
             lgl_cor(:,[26,28:32])-lgl(:,[26,28:32]));
         %plot(lgl(:,9)/60,lgl_cor(:,[26,28:32]),'-',lgl(:,9)/60,lgl(:,[25,28:32]),'.');
         legend(o3.ozone_lgl_legend([12,14:18]),'Location','South','orientation','horizontal');
         ylabel('counts second');
         mmplotyy('corrected-uncorrrected')
         title([num2str(nb),' 2º CONFIG  filter corrected ',fecha]);
         
   end
         %figure;
         %mmplotyy_temp(lgl(:,9)/60,...
         %    [lgl_cor(:,[12,14:18]),lgl(:,[12,14:18]),lgl_cor(:,[26,28:32]),lgl(:,[26,28:32])],...
         %    [(lgl_cor(:,12:18)-lgl(:,12:18)),lgl_cor(:,26:32)-lgl(:,26:32)]);
%          
%          
%          ylabel('counts second');
%          mmplotyy('corrected-uncorrrecte')
%          title([num2str(nb),' etc & filter corrected ',fecha]);
%   
%         figure;
%         h=mmplotyy_temp(lgl(:,9)/60,lgl_cor(:,26:32),lgl_cor(:,[19,33]),'.');
%         legend(o3.ozone_lgl_legend([26:32,19,33]),'Location','South','orientation','horizontal');
%         ylabel('counts second');
%         mmplotyy('ozone')
%         title([brw,' corrected-uncorrected ',fecha]);
  
         
         
         
         
         
         
         
end

