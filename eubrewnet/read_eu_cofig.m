cdfunction [data,str]=get_eu(query,server)

%webciai2new.aemet.es/eubrewnet/data/get/ConfigbyId?id=1053&format=text
if nargin==1
    server=2;
end

url{1}='http://rbcce.ciai.inm.es/eubrewnet/';
url{2}='http://rbcce.aemet.es/eubrewnet/';
url{3}='http://webciai2new.aemet.es/eubrewnet/data/get/'
wop=weboptions('Username', 'ibero', 'Password', 'nesia','ContentType','json','TimeOut',60)

 cdm='http://rbcce.ciai.inm.es/eubrewnet/data/get/'; 
 str=[cdm,query];
 str=strrep(str,url{1},url{server})
 [data]=webread(str, wop);
                