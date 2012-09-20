  function txt = myupdatefcn(empt,event_obj)
   % Customizes text of data tips

   pos = get(event_obj,'Position');
   txt = {['time: ',datestr(pos(1))],...
['amplitude: ',num2str(pos(2))]};
%--------------------------------------------------------------------
%and name it myupdatefcn.m