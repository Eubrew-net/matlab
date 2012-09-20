function [ conf_diff_table] = conf_diff_table( config )
%function [ config_plot_table] = conf_diff_table( config )
% muestra las diferencias entre las configuraciones 
% salida de read_cal_config
%

if ~isempty(config)
    [i,j]=find(diff(config'));
  
    j=unique([j(:)]);
    conf_diff_table=[icf_legend(j),num2cell(config(j,:))]; 
    conf_diff_table=[['Date',cellstr(datestr(config(1,:)))'];conf_diff_table]
    %conf_diff_table=['Date',datestr(config(1,:))'];conf_diff_table];
    %config_plot_table=[repmat(config(end,3),length(j),1),j,config(j,:)];
%disp(config_dif_table);
else
    config_plot_table=NaN*zeros(1,5);
end

end

