function woudc=read_woudc_csv(filename)

woudc=struct();


st=fileread(filename);
% sections are defined by #
 b=mmstrtok(st,'#');
 
 for i=1:size(b)
    l=mmstrtok(b{i},char(10));
    aux=struct();
    if size(l,1)>2
      s=l{1} ;%sections
      ff=mmstrtok(l{2},',') ;% fields
      vv=textscan(l{3},'%s','Delimiter',{','},'Endofline','\n') ;
      val=vv{:};
      val(cellfun(@isempty,val))={'NaN'};
      for ll=4:length(l)
        if ~(l{ll}(1)=='*' ||  l{ll}(1)==char(13))
         v=textscan(l{ll},'%s','Delimiter',{','},'Endofline','\n') ;
         v=v{:};
         v(cellfun(@isempty,v))={'NaN'};
         val=[val,v];         
        end
      end
      if size(val,2)==1    
         for jj=1:length(ff);aux=setfield(aux,ff{jj},val(jj,:)); end;
      else
         for jj=1:length(ff);aux=setfield(aux,ff{jj},val(jj,:)); end;
      end
      woudc=setfield(woudc,s,aux);
      
    end
    
 end
 
 