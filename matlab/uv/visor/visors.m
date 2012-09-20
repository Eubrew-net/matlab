function fig = visors(uv)
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

load visors.mat
%no se si es necesario ???????
clear global;
global uv_work;
global uv_trash;


file_s=[];
for i=1:length(uv);
 if ~isempty(uv(i).date)  
  year=uv(i).date(1,1); 
  dayj=uv(i).date(2,1);
  file=sprintf('SS%03d%02d',dayj,year);

else
   year=0;
   dayj=i;
   file=sprintf('ss%03d%02d',dayj,year);

end   
 file_s=[file_s;file];
end

h0 = figure('Color',[0.8 0.8 0.8], ...
	'Colormap',mat0, ...
	'PointerShapeCData',mat1, ...
	'Position',[10 10 620 520], ...
   'Tag','Fig1');
%
	set(h0,'UserData',uv);  % almacenamos uv en userdata
%
h1 = axes('Parent',h0, ...
	'Units','pixels', ...
	'CameraUpVector',[0 1 0], ...
	'Color',[1 1 1], ...
	'ColorOrder',mat2, ...
	'Position',[117 129 528 345], ...
	'Tag','Axes1', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
   'ZColor',[0 0 0]);

h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[0.4990512333965844 -0.08139534883720923 9.160254037844386], ...
	'Tag','Axes1Text4', ...
	'VerticalAlignment','cap');
set(get(h2,'Parent'),'XLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[-0.06641366223908918 0.4970930232558141 9.160254037844386], ...
	'Rotation',90, ...
	'Tag','Axes1Text3', ...
	'VerticalAlignment','baseline');
set(get(h2,'Parent'),'YLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','right', ...
	'Position',mat3, ...
	'Tag','Axes1Text2');
set(get(h2,'Parent'),'ZLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',mat4, ...
	'Tag','Axes1Text1', ...
	'VerticalAlignment','bottom');
set(get(h2,'Parent'),'Title',h2);

h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Position',[6 19 70 60], ...
	'String',file_s, ...
	'Style','listbox', ...
	'Tag','ListaUV', ...
   'Value',1,...
   'Callback','visors_s lista_files');
% boton de siguiente
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'ListboxTop',0, ...
	'Position',mat5, ...
   'Tag','B_next','String','>>',...
   'Callback','visors_s next');
% boton de Anterior
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'ListboxTop',0, ...
	'Position',[199.8620689655173 37.24137931034483 56.48275862068967 16.13793103448276], ...
   'Tag','B_prev','String','<<',...
   'Callback','visors_s prev');
% boton de Salvar
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'ListboxTop',0, ...
	'Position',[339.5172413793104 39.72413793103449 49.0344827586207 19.86206896551725], ...
	'Tag','B_save','String','Save','Callback','visors_s save');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'ListboxTop',0, ...
	'Position',[339.5172413793104 13.03448275862069 49.65517241379311 18], ...
   'Tag','B_dep','String','Depurar','Callback','visors_s dep');

if nargout > 0, fig = h0; end
