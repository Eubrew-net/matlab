
function log=informes(Cal,n)
if nargin==2
    N=n;
else
    N=1:Cal.n_brw;
end

startup;
%https://www.iberonesia.net/svn/iberonesia/are2011/latex/158/html/cal_report_158a1.html
info={'a1','a2','b','c'}
%info={'a1'}
web=cell(Cal.n_brw,4);
persistent in;
persistent ixn;

log=zeros(Cal.n_brw,4);
for in=1:4
  for ixn=N
     try
      % options_pub.outputDir=fullfile(pwd,'latex','158','html'); options_pub.showCode=true;
       % publish(fullfile(pwd,'cal_report_158c.m'),options_pub);
   
      options_pub.outputDir=fullfile(Cal.path_root,'latex',Cal.brw_str{ixn},'html');
      options_pub.showCode=true;
      publish(fullfile(sprintf('cal_report_%03d%s.m',Cal.brw(ixn),info{in})),options_pub);
      web{ixn,in}= [sprintf('\r\nhttps://www.iberonesia.net/svn/aro2013/html/%03d/html/cal_report_%03da1.html\r\n',[Cal.brw(ixn),Cal.brw(ixn)])];
        disp(['OK ',Cal.brw_str{ixn},' ',info(in)]);
       % log(ixn,in)=1;
       
     catch
       close all;  
       disp(['ERROR',Cal.brw_str{ixn},' ',info(in)])
       log(ixn,in)=-1;
     end
     
  end
end
cell2csv('webout',web,' ')
