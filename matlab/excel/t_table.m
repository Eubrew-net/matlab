function [ output_table ] = t_table( input_table,n,var_colum )

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin==1
    n=1;
    var_colum=0;
end
if nargin==2
    var_colum=0;
end
if isempty(n) n=1; end
if n==1 
  s=vartype('numeric');
  output_array= table2array(input_table(:,s));
  output_table = array2table(output_array');
  output_table.Properties.RowNames = rowname(input_table(:,s).Properties.VariableNames(:,n:end));

else
  output_array= table2array(input_table(:,n:end));
  output_table = array2table(output_array');
  output_table.Properties.RowNames = rowname(input_table.Properties.VariableNames(:,n:end));
end
output_table = array2table(output_array');
output_table.Properties.RowNames = rowname(input_table(:,s).Properties.VariableNames(:,n:end));
if ~isempty(input_table.Properties.RowNames)
  output_table.Properties.VariableNames = colname(input_table.Properties.RowNames);
end
if var_colum
    if ~iscellstr(input_table{:,var_colum})
        x=cellstr(input_table{:,var_colum});
    else
       x=input_table{:,var_colum};
    end
    output_table.Properties.VariableNames = colname(x);
end

