function [ o3_c,osc_smooth, osc_out] = brewer_comparison(n_inst,n_ref,Cal,summary,summary_old,blinddays )
%UNTITLED Summary of this function goes here
% imput n_ins n_ref Cal 
% output
% osc_smooth [x,y,1] ->  configuracion final   sumary
% osc_smooth [x,y,2] ->  configuracion inicial sumary_old

%   Detailed explanation goes here
brw_str_inst=Cal.brw_str{n_inst}; 
brw_str_ref=Cal.brw_str{Cal.n_ref(n_ref)};

jday=findm(diaj(summary{Cal.n_ref(n_ref)}(:,1)),blinddays{Cal.n_ref(n_ref)},0.5);
if n_ref==1
ref=summary_old{Cal.n_ref(n_ref)}(jday,:);
else
ref=summary{Cal.n_ref(n_ref)}(jday,:);
end    
jday=findm(diaj(summary{n_inst}(:,1)),blinddays{n_inst},0.5);
inst=summary{n_inst}(jday,:);
inst_blind=summary_old{n_inst}(jday,:);

% [outlier_old,data_out_old]=ratio_min_ozone_dep(inst(:,[1,12,3,2,8,9,4,5]),ref(:,[1,10,3,2,8,9,4,5]),Cal.Tsync);
% disp(datestr(data_out_old(:,1)));
% j_bad=findm(summary_old{n_inst}(:,1),data_out_old(:,1),0.0001)
% summary{n_inst}(j_bad,:)=[];
% jday=findm(diaj(summary_old{n_inst}(:,1)),blinddays{n_inst},0.5);
% inst=summary_old{n_inst}(jday,:);

o3_c{n_inst,n_ref}=[];
osc_out{n_inst,n_ref}=[];
osc_smooth{n_inst,n_ref}=[];

[o3c,r_,ab_,rp_,data_,oscout,oscsmooth,outliers]=...
    ratio_min_summary(inst,ref,Cal.Tsync);%,brw_str_inst,brw_str_ref);
[o3c_b,r_b,ab_b,rp_b,data_b,oscout_b,oscsmooth_b,outliers_b]=...
    ratio_min_summary(inst_blind,ref,Cal.Tsync);

% o3_ref=o3c(:,13);
% o3_inst=o3c(:,23);
% ozone_slant=o3c(:,13).*o3c(:,16)/1000; % o3 reference
% ozone_scale=o3c(:,13).*o3c(:,4)/1000;  % o3 ref/m_i

aux=[];
aux(:,:,1)=o3c;
aux(:,:,2)=o3c_b;
o3_c=aux;

aux=[];
aux(:,:,1)=oscsmooth;
aux(:,:,2)=oscsmooth_b;
osc_smooth=aux;

aux=[];
aux(:,:,1)=oscout;
aux(:,:,2)=oscout_b;
osc_out=aux;


end

