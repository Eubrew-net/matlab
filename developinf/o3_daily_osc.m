function ozone_osc_sum=o3_daily_osc(Cal,TIME_SYNC,n_ref,summary_orig_old,summary_old,summary)

blinddays=Cal.calibration_days{Cal.n_inst,2}; finaldays=Cal.calibration_days{Cal.n_inst,3};
if isequal(blinddays,finaldays)
   caldays=blinddays;
else
   caldays=[blinddays finaldays];
end

% Para la referencia siempre es una sola: summary
jday=findm(diaj(summary{n_ref}(:,1)),caldays,0.5);
if Cal.sl_c(n_ref)
   ref=summary{n_ref}(jday,[1 3 12]);
else
   ref=summary{n_ref}(jday,[1 3 6]);
end

% La configuración original es la misma siempre (se asume un icf) -> cuidado cuando es cfg
% Además, no corregimos filtros. ¿Siempre SL? ¿No SL? Ahora es SL
jday=findm(diaj(summary_orig_old{Cal.n_inst}(:,1)),caldays,0.5); 
inst_orig=summary_orig_old{Cal.n_inst}(jday,[1 3 12]);

% Vamos con la configuracion final / sugerida
% Ahora podrá ser icf o cfg
[a b c]=fileparts(Cal.brw_config_files{Cal.n_inst,2});
if strcmp(c,'.cfg')
  % Tenemos matrices: entonces es sencillo
   jday=findm(diaj(summary{Cal.n_inst}(:,1)),caldays,0.5); 
   inst_final=summary{Cal.n_inst}(jday,[1 3 6]);
else
  % No tenemos matrices: entonces tenemos sugerida (blind) / final
   jday=findm(diaj(summary{Cal.n_inst}(:,1)),finaldays,0.5); 
   inst2=summary{Cal.n_inst}(jday,[1 3 6]);

   inst2_b=[];
   if ~isequal(blinddays,finaldays)
      jday=findm(diaj(summary_old{Cal.n_inst}(:,1)),blinddays,0.5); 
      inst2_b=summary_old{Cal.n_inst}(jday,:);
      if Cal.sl_c_blind(Cal.n_inst)
         inst2_b=inst2_b(:,[1 3 12]);% En este caso nos interesa la correccion por SL
      else
         o3r=(inst2_b(:,8)-ETC_SUG(1).NEW)./(A1_old*inst2_b(:,3)*10);
         inst2_b=cat(2,inst2_b(:,[1 3]),o3r);
      end
   end   
   inst_final=cat(1,inst2_b,inst2);
end

[aa,bb]=findm_min(ref(:,1),inst_final(:,1),TIME_SYNC/24/60);
o3_c=[ref(aa,1),ref(aa,1)-inst_final(bb,1),ref(aa,2),ref(aa,3),inst_orig(bb,3),inst_final(bb,3)];
aux=cat(2,o3_c,o3_c(:,3).*o3_c(:,4),NaN*ones(size(o3_c,1),1)); % osc de la referencia

% por rangos de osc
aux(aux(:,end-1)<400,end)=5; aux(aux(:,end-1)>=400 & aux(:,end-1)<700,end)=4;
aux(aux(:,end-1)>=700 & aux(:,end-1)<1000,end)=3;
aux(aux(:,end-1)>=1000 & aux(:,end-1)<1500,end)=2; aux(aux(:,end-1)>=1500,end)=1;

% o3_c: 1=date 
%       7=O3_new_ref              13=O3_new_ref SL corr. -> depends on Cal.sl_c (for ref)
%       19=O3_old_inst (siempre)  23=O3_final_inst (sug o sl corr. en el caso de blinddays)
[m_osc,s_osc,n_osc]=grpstats(aux,{fix(aux(:,1)),aux(:,end)},{'mean','std','numel'});
ozone_osc_sum=round([diaj(m_osc(:,1)),m_osc(:,4),s_osc(:,4),n_osc(:,4),...
                     m_osc(:,5),s_osc(:,5),100*(m_osc(:,5)-m_osc(:,4))./m_osc(:,4),...
                     m_osc(:,6),s_osc(:,6),100*(m_osc(:,6)-m_osc(:,4))./m_osc(:,4),m_osc(:,end)]*10)/10;
