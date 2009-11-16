%QUAD_SUM_table=[{'step', 'o3abs', 'so2abs', 'o3/so2', 'Raley', 'ETC'};num2cell(sscanf(cell2str(QUAD_SUM{i}),'%f'))'];

function QUAD_SUM_table=dsp_tables(DSP_QUAD,QUAD_SUM,QUAD_DETAIL)

DSP_QUAD_table=DSP_QUAD;
tabla_QuadSum=num2cell(sscanf(cell2str(QUAD_SUM),'%f'))';
QUAD_SUM_table=[{'Calc-step', 'O3abs coeff.', 'SO2abs coeff.', 'O3/SO2'};tabla_QuadSum(1:4)];
Q_DETAIL = cell2mat(QUAD_DETAIL');  QUAD_DETAIL={}; 
for k=1:6
    QUAD_DETAIL=[QUAD_DETAIL;num2cell(sscanf(Q_DETAIL(k,:)','%f')')];
end
QUAD_DETAIL_table=[{'wavelength', 'resolution', 'o3abs', 'so2abs', 'Raley', 'ETC'};QUAD_DETAIL'];
           
% CUBIC_SUM_table=[{'step', 'o3abs', 'so2abs', 'o3/so2', 'Raley', 'ETC'};num2cell(sscanf(cell2str(CUBIC_SUM{n_inst}),'%f'))'];
% C_DETAIL = cell2mat(CUBIC_DETAIL{n_inst}');   CUBIC_DETAIL={};
% for k=1:6
%     CUBIC_DETAIL=[CUBIC_DETAIL;num2cell(sscanf(C_DETAIL(k,:)','%f')')];
% end
% CUBIC_DETAIL_table=[{'wavelength', 'resolution', 'o3abs', 'so2abs', 'Raley', 'ETC'};CUBIC_DETAIL'];
