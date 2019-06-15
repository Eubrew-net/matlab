%format dspnorm to brewer files 
function dcf_format(dspnorm_file,dsp_out)
dspnorm=load(dspnorm_file); % dsp_mtlb=flipud(reshape(dsp(1:18),3,6))
s=sprintf('%f \r\n %.8f \r\n %E \r\n',[dspnorm;dspnorm]);
s=[s,datestr(now)];
filewrite(dsp_out,s')
