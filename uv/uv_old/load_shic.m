function uv=load_shic(file)

s=dir(file);
lamda=[];rad_inst=[];rad_std=[];time=[];rtype=[];
       
path=fileparts(file)

for i=1:length(s)
    try

        filename=fullfile(path,s(i).name)
        [info]=sscanf(s(i).name,'%03d%02d%02d%02c.%03c');
       
        day=info(1); hour=info(2); min=info(3);
        inst=char(info(end-2:end))';
        type=char(info(end-4:end-3));
        
        date_(i,1)=day;
        date_(i,2)=2009;
        
        
        
        f=fopen(filename);
        aux=textscan(f,'', 'commentStyle','!');
        if isempty(cell2mat(aux))
         aux=textscan(f,'%f %f %f ', 'commentStyle','!','HeaderLines',5);
         %aux=cell2mat(aux);
        end
         fclose(f);
        
        lamda_    =aux{1};
        rad_std_  =aux{2};
        rad_inst_ =aux{3};
        if ~isempty(lamda_)
            if size(aux,2)==4
              time_ =aux{4};
            else
             time_=linspace(hour+min/60,hour+min/60+3/24/60/60*length(lamda_),length(lamda_))';  
            end 
        
            lamda_(end)=[];
            time_(end)=[];
            rad_std_(end)=[];
            rad_inst_(end)=[];
        end
        rad_inst=[rad_inst,rad_inst_];
        rad_std=[rad_std,rad_std_];
        lamda=[lamda,lamda_];
        time=[time,time_];
        rtype=[rtype,type];
    catch
        %fclose(f);
        lasterr
        disp('warning');
        s(i).name
    end
end


       uv.l=lamda*10; %a A
       uv.raw=rad_inst;
       uv.uv=rad_std;
       uv.ss=rad_inst;
       uv.time=time*60;
       uv.date=date_';
       uv.file=file;
       uv.inst=inst;
       uv.type=rtype;
       uv.spikes=[];
       %waterfall(uv.l',(uv.time)'/60,uv.uv');