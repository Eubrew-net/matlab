function frame_s(action)
   uv=get(gcbf,'UserData');
   Value=get(findobj('Tag','ListScan'),'Value');
   
   flag3D=get(findobj('Tag','CkPlot3D'),'Value');   
   flagRx=get(findobj('Tag','CkReverseX'),'Value');
   flagLog=get(findobj('Tag','CkLog'),'Value');
   flagSel=get(findobj('Tag','CkSelect'),'Value');
   global cp0;
   global cp1;
   global ind_sel;
   global uv_trash;
   global uv_work;
switch(action)
   
case 'start'
   if flagSel==0
      set(gcbf,'Pointer','fullcrosshair');
      set(gcbf,'WindowButtonMotionFcn',' frame_s move');  
    set(gcbf,'WindowButtonUpFcn',' frame_s stop');  
      frame_s move;
   
  	else    
      set(gcbf,'Pointer','crosshair');
      cp0=get(gca,'CurrentPoint');
      rect=rbbox;
      cp1=get(gca,'CurrentPoint');     
      frame_s r_select
   end
   
case 'move'  
    cP=get(gca,'CurrentPoint');

   if flagSel==0
      setdisplay(cP);    
   else
           
   end
     
    
    
case 'stop'   
   
    set(gcbf,'WindowButtonMotionFcn',' ');  
    set(gcbf,'WindowButtonUpFcn',' ');  
    set(gcbf,'Pointer','arrow');
    
    if flagSel==1
       cP=get(gca,'CurrentPoint');
      end
      
    
   case 'select'    
      if(flagSel==0)
          %frame_s start;
      end;
      
   case 'r_select' % solo funciona en 2D 
      x0=min([cp0(1,1);cp1(1,1)]);       y0=min([cp0(1,2);cp1(1,2)]);       
      x1=max([cp0(1,1);cp1(1,1)]);       y1=max([cp0(1,2);cp1(1,2)]);
     
      xi=find(uv.l(:,Value) > x0 & uv.l(:,Value) < x1);
      yi=find(uv.uv(:,Value)>y0 & uv.uv(:,Value)<y1); 
      ind_sel=intersect(xi,yi);
      if ~isempty(ind_sel)
         plot_uv_sel(uv,Value,ind_sel,flag3D);
         h=findobj('Tag','B_del_select');
         set(h,'Enable','on');
%         plot_uv_frame(uv,Value,flag3D);
      end   

   case 'del_select'
      spki=[ind_sel,Value*ones(size(ind_sel)),uv.time(ind_sel,Value),...
            uv.l(ind_sel,Value),uv.uv(ind_sel,Value)];
      uv.spikes=[uv.spikes;spki];   % añadimos el pico a spikes
      uv.uv(ind_sel,Value)=NaN;     % lo quitamos de uv
      h=findobj('Tag','B_del_select')
      set(h,'Enable','off');
      set(gcbf,'UserData',uv); % salvamos uv;
      h=findobj('Tag','B_save_mat');
      set(h,'Enable','on');
      refresh_list(uv);
      
   case 'save_mat'
      year=uv.date(1,1);
      dayj=uv.date(2,1);
      file_s=sprintf('uv%03d%02d',dayj,year)
      eval([' ',file_s,'=uv ;']);
      eval(['save ',file_s,' ',file_s]);
      h=findobj('Tag','B_save_mat');
      set(h,'Enable','off');
   case 'supr_scan'      
      if ~isempty(uv_trash)
         i_trash=(size(uv_trash.uv,2)+1);
      else i_trash=1;
      end   

      f=fieldnames(uv);
      %eliminamos los campos que no se borran.
      kf=cellfun(@(x) strmatch(x,f),{'file','resp','inst','filter','spikes'});
      f(kf)=[];
      for i=1:length(f); 
           command=['uv_trash.',char(f(i)),'(:,',num2str(i_trash),')=','uv.',char(f(i)),'(:,',num2str(Value),');']

        try
          eval(command);
          eval(['uv.',char(f(i)),'(:,',num2str(Value),')=[];']) ; 
        catch
          disp('error')
          disp(command);
          disp(['uv.',char(f(i)),'(:,',num2str(Value),')=[];']);
        end
      end;      
         
      year=uv.date(1,1);
      dayj=uv.date(2,1);
      file_s=sprintf('uvt%03d%02d',dayj,year)
      eval([' ',file_s,'=uv_trash;']);
      eval(['save ',file_s,' ',file_s]); %guardamos el scan a borrar
      if ~isempty(uv.spikes)
         j=find(uv.spikes(:,2)==Value); uv.spikes(j,:)=[];
         j=find(uv.spikes(:,2)>Value) ;uv.spikes(j,2)=uv.spikes(j,2)+1;
      end
       set(gcbf,'UserData',uv); % salvamos uv;

      % refrescamos la lista
       refresh_list(uv);
       % retrocedemos 1 
       frame_s prev
       
    case 'send_close'
       uv=get(gcbf,'UserData'); % cargamos uv;
       uv_work =uv;
       eval(['save uv_work uv_work']);
       clear uv_trash;
       close(gcf); 
  
   case 'plotscan'
      Value=get(gcbo,'Value');
      plot_uv_frame(uv,Value,flag3D)


   case 'prev'
      
      Value=Value-1;
      if Value<1 Value=1; end
      plot_uv_frame(uv,Value,flag3D)
   
    case  'next'
       Value=Value+1;
       if Value>size(uv.uv,2) Value=size(uv.uv,2); end
       plot_uv_frame(uv,Value,flag3D)

    case 'log'
      if flag3D==1
         set(gca,'ZScale','log');
      else    
         set(gca,'YScale','log');
      end   

    case 'plot3D'
       plot_uv_frame(uv,Value,flag3D)
       % falta deshabilitar la seleccion no funciona en 3D
       
    case 'xreverse'
       if flagRx==1
          set(gca,'YDir','reverse');
       else 
          set(gca,'YDir','normal');
       end   

    end
    
    
	set(findobj('Tag','ListScan'),'Value',Value);
   if flag3D==1    str_r='YDir'; str_l='Zscale'; 
   else            str_r='XDir'; str_l='YScale';
   end    
   % reverse  
   if flagRx==1  set(gca,str_r,'reverse');
   else          set(gca,str_r,'normal');
   end   
   % log     
   if flagLog==1  set(gca,str_l,'log');
   else          set(gca,str_l,'linear');
   end   

   
   
   
   
   function plot_uv_frame(uv,Value,flag3D)
   
      if flag3D==1
         plotuv(uv,Value);
      else
         plot_uvs(uv,Value);    
       
      end   
       set(gca,'ButtonDownFcn','frame_s start');
       
     
       
   function plot_uv_sel(uv,Value,ind_sel,flag3D)
      hold on;
      if flag3D==1
        h=plot3(uv.l(ind_sel,Value),(uv.time(ind_sel,Value))/60,uv.uv(ind_sel,Value),'rx');
      else
        plot(uv.l(ind_sel,Value),uv.uv(ind_sel,Value),'+r');    
      end   
      hold off;        
      
       
      function setdisplay(cp)
      
      [hT]=get(findobj('Tag','TextX'),'UserData'); 
    
       
       set(hT(1),'String',sprintf('%f',cp(1,1)));
       set(hT(2),'String',sprintf('%f',cp(1,2)));
       set(hT(3),'String',sprintf('%f',cp(1,3)));

      
function refresh_list(uv)
     time_s=datestr(nanmean(uv.time/60/24));
      for i=1:size(uv.spikes)
          time_s(uv.spikes(i,2),7:8)='*';          
      end   
      haux=findobj('Tag','ListScan');
      set(haux,'String',time_s);
      