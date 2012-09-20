function visors_s(action)

  global uv_work;
  global uv_trahs;

  uv=get(gcbf,'UserData');
  % revisar
  
  hlist=findobj('Tag','ListaUV');
  Value=get(hlist,'Value');
   
   switch(action)
      
   case 'lista_files'
      Value=get(gcbo,'Value');
      if ~isempty( uv(Value).l)
         plotss(uv(Value));
      end
   case 'prev'
      Value=get(hlist,'Value');
      Value=Value-1;
      if Value<1 Value=1; end
        if ~isempty( uv(Value).l)
           plotss(uv(Value))
        end   
     
   case  'next'
       Value=get(hlist,'Value');
       Value=Value+1;
       if Value>size(uv,2) Value=size(uv,2); end
         if ~isempty( uv(Value).l)
            plotss(uv(Value))
         end 
   case 'dep'
      Value=get(hlist,'Value'); 
      h=frames(uv(Value));
      waitfor(h);
      uv(Value)=uv_work;
      clear uv_work;
      set(gcbf,'UserData',uv); %grabamos los cambios
      plotuv(uv(Value));
       
    case 'save'
       save uv
       save uv_work
       save uv_trash
       
       
 end     

  set(hlist,'Value',Value);
  
  