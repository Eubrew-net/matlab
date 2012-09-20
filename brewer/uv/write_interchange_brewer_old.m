function write_interchange_brewer(uv) 
for i=1:length(uv)
    if ~isempty(uv(i).date)
        write_interchange(uv(i));
    end
end    





function write_interchange(uv)
      

    for i=1:size(uv.date,2)
          diajul=uv.date(2,i);
          year=uv.date(1,i)+2000;
          date_0=datenum(year,1,1)+diajul;
          aux=find(~isnan(uv.time(:,i)));
          
          date_=date_0+uv.time(aux(1),i)/60/24;
          fecha=datevec(date_);
          hora=fecha(4);
          min=fecha(5);
          
          
          date_fin=date_0+uv.time(aux(end),i)/60/24;
          fecha_fin=datevec(date_fin);
          horaf=fecha_fin(4);
          minf=fecha_fin(5);
          
          if uv.inst==157
            file_int=sprintf('%03d%02d%02dG.iz1',diajul,hora,min);
          elseif  uv.inst==183
            file_int=sprintf('%03d%02d%02dG.iz2',diajul,hora,min);
          elseif  uv.inst==185
            file_int=sprintf('%03d%02d%02dG.iz3',diajul,hora,min);
          else  
            file_int=sprintf('%03d%02d%02dG.%03d',diajul,hora,min,uv.inst)
          end 
          
          f=fopen(file_int,'w');
          if f~=1
          uv.dark(i)=0.0;
          fprintf(f,'Observatorio Atmosferico de Izana \r\n'); % linea 1
          fprintf(f,'Brewer # %d \r\n',uv.inst);              % linea 2
          fprintf(f,'fichero:%s_respuesta:%s\r\n',uv.file,uv.resp); % linea 3
          fprintf(f,'dark=%6.4f \r\n',uv.dark(i));  %linea 4
          fprintf(f,'PMT_V:%f\r\n',uv.temp(i)); %
          fprintf(f,'fecha: %02d/%02d/%04d \r\n',fecha(3),fecha(2),fecha(1));  
          fprintf(f,'hora_inicio:%0d:%0d \r\n',hora,min); 
          fprintf(f,'hora_fin: %0d:%0d \r\n' ,horaf,minf); 
          fprintf(f,'operator:Alberto_Redondas\r\n');
          %fprintf(f,'operators:Alberto_Redondas Virgilio_Carreno Carlos Torres');
          fprintf(f,'No cosine correction\r\n#11\r\n#12\r\n#13\r\n');
          fprintf(f,'lamda(nm) irradiancia (W/m2) time \r\n');
          scan_int=[uv.l(:,i)/10,uv.uv(:,i),uv.time(:,i)/60];
          fprintf(f,'%5.1f %2.8E %8.5f \r\n',scan_int');
          
          fclose(f);
      else
          warnnig([file_int ,' can open for output ']);
          end
          
      end
      