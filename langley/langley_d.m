function [sum, resp,stats ] = langley_d( ozone_lgl,nb,fecha,cfg )
%Plotea el langley del dia
%   Detailed explanation goes here
        aux=ozone_lgl{nb};
        auxc=cfg{nb};
        j=find(fix(aux(:,1))==fecha);
        %o3.ozone_lgl=aux(j,:);
        lgl=aux(j,:);
        j=find(auxc(end,:,1)==fecha);
        setup=squeeze(auxc(:,j,:));

        %recalculation
        %[o_3,so_2,rat]=ozone_cal_raw(lgl(:,12:18),lgl(:,5),770,lgl(:,6),setup(:,1));

        % depuracion de observaciones
        [m,s,n,g]=grpstats(lgl(:,[2,19,33]),fix(lgl(:,3)/10));
        j=find(s(:,2)<1 & m(:,2)>100 & m(:,2)<600 & m(:,1)>0 & n(:,1)==5);
        idx=cellfun(@str2num,g(j));
        t=ismember(fix(lgl(:,3)/10),idx);
        lgl=lgl(t,:);
        %%
          %% depuracion de michalsky
        try
        [lgl,idx_]=michalsky_filter(lgl,1)
        catch
            disp('error en michalsky')
        end
        % plot
        Cal.brw_str={'157','183','185'};

        switch nb
            case 1
                FC=[];
            case 2
                FC=256;
            case 3
                FC=[192,256];
        end



        [resp,stats]=simple_langley(lgl,Cal.brw_str{nb},FC);
        % individual vs R6
         O3W=[  0.00    0   0.00   -1.00    0.50    2.20   -1.70];
         %BE=[0,0,4870,4620,4410,4220,4040];

         sum.label_row={'am1','pm1','am2','pm2'};
         sum.label_col={'R6','SW'};
         sum.date=fecha;
         sum.brw=nb;
         %filter #1
         r=resp;
         rf=squeeze(r(:,:,3,:,1));rm=reshape(rf,4,[]);
         sum.filter_3=[rm(:,2),rm*O3W'];

         rf=squeeze(r(:,:,4,:,1));rm=reshape(rf,4,[]);
         sum.filter_4=[rm(:,2),rm*O3W'];
         %etc
         rf=squeeze(r(:,:,1,:,1));rm=reshape(rf,4,[]);
         sum.etc_r=[rm(:,2),rm*O3W'];

         sum.etc=rm;
         rx=squeeze(stats(:,:,:,1));rm=reshape(rx,4,[]);
         sum.r=rm;
         rf=squeeze(r(:,:,1,2,1:3));rm=reshape(rf,4,[])'
         sum.etc_o3=rm;
end

