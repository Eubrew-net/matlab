function icf_legend=icf_legend(varargin)
%function icf_legend=icf_legend(varargin)
% returns the contents of icf file, or the field if input is given
% example find the fields containg 'Mircometer'
% j=(find(~cellfun('isempty',(strfind(icf_legend,'Micrometer')))))
% icf_legend(j)

legend=[
'Release date         '
'o3 Temp coef 1       '
'o3 Temp coef 2       '
'o3 Temp coef 3       '
'o3 Temp coef 4       '
'o3 Temp coef 5       '
'Micrometer steps/deg '
'O3 on O3 Ratio       '
'SO2 on SO2 Ratio     '
'O3 on SO2 Ratio      '
'ETC on O3 Ratio      '
'ETC on SO2 Ratio     '
'Dead time (sec)      '
'WL cal step number   '
'Slitmask motor delay '
'Umkehr Offset        '
'ND filter 0          '
'ND filter 1          '
'ND filter 2          '
'ND filter 3          '
'ND filter 4          '
'ND filter 5          '
'Zenith steps/rev     '
'Brewer Type          '
'COM Port #           '
'o3 Temp coef hg      '
'n2 Temp coef hg      '
'n2 Temp coef 1       '
'n2 Temp coef 2       '
'n2 Temp coef 3       '
'n2 Temp coef 4       '
'n2 Temp coef 5       '
'O3 Mic #1 Offset     '
'Mic #2 Offset        '
'O3 FW #3 Offset      '
'NO2 absn Coeff       '
'NO2 ds etc           '
'NO2 zs etc           '
'NO2 Mic #1 Offset    '
'NO2 FW #3 Offset     '
'NO2/O3 Mode Change   '
'Grating Slope        '
'Grating Intercept    '
'Micrometer Zero      '
'Iris Open Steps      '
'Buffer Delay (s)     '
'NO2 FW#1 Pos         '
'O3 FW#1 Pos          '
'FW#2 Pos             '
'uv FW#2 Pos          '
'Zenith Offset        '
'Zenith UVB Position  '
'Date                 '
];

icf_legend=cellstr(legend);
if nargin==1
  if ischar(varargin{1})
      j=(find(~cellfun('isempty',(strfind(icf_legend,varargin{1})))));
      icf_legend=[num2cell(j),icf_legend(j)]; 
  else
    icf_legend=icf_legend(varargin{1});
  end
end
end