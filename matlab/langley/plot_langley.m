function [ resp,stats ] = plot_langley(lgl,brw )
%UNTITLED6 Summary of this function goes here
%   resp four dim matrix(AM_PM,CFG,Parameter,Results);
%          dim  (2,2,4,8);
%   AM_PM dim 2  AM=1/PM=2
%   CFG dim 2  CFG1,CFG2
%   Paramenter dim 4   ETC,SLOPE,FILTER1,FILTER2
%   results    dim 8   1 Value, 2 Standard Error,
%                      3-6 coefcorr (i,1:4)
%                      7 ratio Vaule/Se
%                      p valor of 7
%   stats(AM,PM) output of roboust_fit
if nargin==1
    brw='XXX';
end
fecha=datestr(unique(fix(lgl(:,1))));

    
    o3.ozone_lgl_legend={'date'	'hg'    'idx'   'sza'	'm2'	'm3'	'sza'	'saz'	'tst'	'temp'  'flt'...  %1-11
        'f0'  'f1'	'f2'	'f3'	'f4'	'f5'	'f6'	...  % 12-18 c/c 1º
        'o3'    'r1'    'r2'    'r3'    'r4'    'r5'    'r6'   ... % 19 25ratios (Rayleight corrected !!)                % 19-25
        'F0'	'F1'	'F2'	'F3'	'F4'	'F5'	'F6'	...  %  % 26-32Segund configuracion
        'O3'    'R1'    'R2'    'R3'    'R4'    'R5'    'R6'   ... %  % 33-39   ratios (Rayleight corrected !!)
        };
    
    
    %%cortamos en airmass 6
    lgl=lgl(lgl(:,5)<6,:);
    % separamos la mañana de la tarde (tst-> true solar time)
    jpm=(lgl(:,9)/60>12) ; jam=~jpm;
    stats=[];
    resp=NaN*zeros(2,2,4,8);
    for ampm=1:2
        for ncfg=1:2
            if ampm==1 jk=jam; else jk=jpm; end
            if ncfg==1 jc=25;  else jc=39;   end
            %% FIlTER regression
            try
                X=[lgl(jk,5),lgl(jk,10)==128,lgl(jk,10)==192];
                [c1,ci]=robustfit(X,lgl(jk,jc));
                resp(ampm,ncfg,:,:)=[c1,ci.se,ci.coeffcorr,ci.t,ci.p];
                stats{ampm,ncfg}=ci;
                %yh=lgl(jk,jc)-XF(:,3:end)*c1(3:end);
            catch
                disp('warning');
            end
        end
    end
    
    
    figure;
    mmplotyy_temp(lgl(:,9)/60,lgl(:,12:18),lgl(:,[19,33]),'.')
    %legend(o3.ozone_lgl_legend(12:18));
    legend(o3.ozone_lgl_legend([12:18,19,33]))
    ylabel('counts second');
    mmplotyy('ozone')
    title(['raw data ',brw,' ',fecha]);
    
    
    
    %%
    figure;
    plot(lgl(:,5),lgl(:,[25]),'g:')
    hold on;
    plot(lgl(jam,5),lgl(jam,25),'.r')
    hold on
    plot(lgl(jpm,5),lgl(jpm,25),'.b')
    legend('all','am','pm')
    xlabel('time')
    ylabel('ms9 ratios');
    [a,b]=rline;
    legend(num2str(b'))
    title(['raw data total /am /pm robust regression  ', brw,' ',fecha]);
    %% Filter
%     figure;
%     gscatter(lgl(:,5),lgl(:,[25]),{jam,lgl(:,10)},['rb'],'+o')
%     xlabel('air mass')
%     ylabel('ms9 ratios');
%     title(['Filter ',brw,' ',fecha]);
    %%
    figure
    plot(lgl(jam,5),lgl(jam,[12,14:18]),'.')
    legend(o3.ozone_lgl_legend([12,14:18]));
    ylabel('ratios ');
    [h,r]=rline;
    %r=fliplr(r);
    title([brw,' ',fecha]);
    O3W=[  0.00    0.00   -1.00    0.50    2.20   -1.70];
    try
        r6=(r*O3W');
        title([brw,' ',fecha,' AM ',round(num2str(r6(2)))]);
    catch
        title([brw,' ',fecha,' AM ','NODATA']);
    end
    figure
    plot(lgl(jpm,5),lgl(jpm,[12,14:18]),'.')
    legend(o3.ozone_lgl_legend([12,14:18]));
    ylabel('ratios ');
    [h,r]=rline;
    title([brw,' ',fecha]);
    O3W=[  0.00    0.00   -1.00    0.50    2.20   -1.70];
    try
        r6=(r*O3W');
        title([brw,' ',fecha,' PM ',num2str(r6(2))]);
    catch
        title('NO_DATA')
    end
end
