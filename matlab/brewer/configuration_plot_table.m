function [ config_plot_table] = configuration_plot_table( config )
% muestra las diferencias entre las configuraciones
%
if ~isempty(config)
    [i,j]=find(diff(config(:,1:2)'));
    [i,jj]=find(diff(config(:,1:3)'));
    [i,jjj]=find(diff(config(:,2:3)'));

    j=unique([j(:);jj(:);jjj(:)]);

    config_plot_table=[repmat(config(end,3),length(j),1),j,config(j,:)];
%disp(config_dif_table);
else
    config_plot_table=NaN*zeros(1,5);
end

end

