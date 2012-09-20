function [ config_dif_table] = configuration_dif_table( config )
%function [ config_dif_table] = configuration_dif_table( config )
% muestra las diferencias entre las configuraciones 1->2,1->3,2->3
% para una matriz config(dia,1º,2º,y bfile)
if ~isempty(config)
[i,j]=find(diff(config(:,1:2)'));
[i,jj]=find(diff(config(:,1:3)'));
[i,jjj]=find(diff(config(:,2:3)'));

j=unique([j(:);jj(:);jjj(:)]);

config_dif_table=[icf_legend(j),num2cell(config(j,:))];
%disp(config_dif_table);
else
    config_dif_table=cell(1,4);
end

end

