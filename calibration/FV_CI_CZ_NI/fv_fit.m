function [ out,data_int,sd ] = fv_fit( fv_data,lim,fplot )
%FV_fit ajusta la medida fv a un trapecio simetrico interpolando entre los
%datos. la parte superior del trapecio es una parbola
%
%                xu(2)->  ++++++++   <-xd(2)
%                        +        +
%                       +          +
%                      +            +
%                     +              +
%      BASE up+++++++ <-xu(1)  xd(1)-> +++++BASE down
%
%  out{ii},data_int{ii} ii=1 zenith, ii=2 azimut
%   out{ii}=[mx{ii},max_{ii},step_mx{ii},rup{ii},rdw{ii},rp{ii},xu{ii},...
%                             xd{ii},fwhm,p_top{ii},p_b_up{ii},p_b_dw{ii}]
%   [rup,rdw,rp] coef corr (up,dw y parabola)
%   mx= x del maximo de la parabola
%   step_mx step del maximo
%   max_ valor maximo de los datos con el que se normaliza
%   xu= corte de la rama de subida xu(1) en la base xu(2) en la  cima
%   xd= corte de la rama de bajada xd(1) en la base xd(2) en la  cima
%   fwhm= ancho en pasos.

%   out{ii}=[mx{ii},xu{ii},xd{ii},p_top{ii},p_b_up{ii},p_b_dw{ii}]
% mx= x del maximo de la parabola
% xu= corte de la rama de subida xu(1) en la base xu(2) en la  cima
% xd= corte de la rama de bajada xd(1) en la base xd(2) en la  cima
% p_top polinomio de la parabola
% p_b_up polinomio lineal de la base 1
% p_b_dw polinomio lineal de la base 2
% usa dspchi3
% Alberto Redondas 2011
% TODO: comprobar Semianchura
% TODO: salida en angulos no en pasos


if nargin==1 || (nargin==3 && isempty(lim))
    uplim=0.9;
    dwlim=0.1;
    fplot=0;
elseif nargin>=2
    lim=sort(lim);
    uplim=lim(2);
    dwlim=lim(1);
    if nargin~=3
        fplot=0;
    end
else
    disp('wrong args');
end


data_az=unique(fv_data(:,1)); %steps
data_ze=unique(fv_data(:,2)); %steps
labelx=[data_az;data_ze]';

j1=find(diff(labelx)<0)+1;
i_az=1:j1-1;  %az
i_ze=j1:size(labelx,2);%ze


% i_az_up=i_az(1:find(~fv_data(i_az,1)));
% i_az_dw=i_az(find(~fv_data(i_az),1):end);
% i_ze_up=i_ze(1:find(~fv_data(i_ze,2)));
% i_ze_dw=i_ze(find(~fv_data(i_ze,2)):end);
% 
%% renormalizamos y calculamos los maximos
data_az=fv_data(i_az,[1,3,5,6]);
[max_{1},idx]= max(data_az(:,3));
step_max{1}=data_az(idx,1); 
data_az(:,4)=data_az(:,3)/max(data_az(:,3));

data_ze=fv_data(i_ze,[2,4,5,6]);
[max_{2},idx]= max(data_ze(:,3));
step_max{2}=data_ze(idx,1);
data_ze(:,4)=data_ze(:,3)/max(data_ze(:,3));

data={data_az,data_ze};
%inicializamos
F=cell(2,1); %F{ii}=dspchi3(data_dw{ii}(j_dw{ii},1),data_dw{ii}(j_dw{ii},5),data_up{ii}(j_up{ii},1),data_up{ii}(j_up{ii},5));
xd=F;       %xd {ii}=[(-F{ii}(1))/F{ii}(3),(-F{ii}(1)+1)/F{ii}(3)]; % corte con el eje superior
xu=F;            % xu{ii}=[(F{ii}(2))/F{ii}(3),-(-F{ii}(2)+1)/F{ii}(3)]; % cortes con el eje inferior
fwhm=F;           %   fwhm_{ii}=(F{ii}(2)+F{ii}(1)-1)/F{ii}(3);

    
for ii=1:2
    
%     jn=find(~(data{ii}(:,4)>=uplim | data{ii}(:,4)<=dwlim) );
    %if size(jn)>4
    %    dataup=datax(jn,:);  % zedw to fit
    %else % interpolamos siempre de momento
        pp=pchip(data{ii}(:,1),data{ii}(:,4));
        dx=mean(diff(data{ii}(:,1)))/4;
        xi=data{ii}(1,1):dx:data{ii}(end,1);
        xi=union(xi,data{ii}(:,1));
        yi=ppval(pp,xi);
        data{ii}=scan_join(data{ii},[xi;yi]');
        data_up{ii}=data{ii}(1:find(~data{ii}(:,1)),:);
        data_dw{ii}=data{ii}(find(~data{ii}(:,1)):end,:);
        j_up{ii}=find(~(data_up{ii}(:,5)>=uplim | data_up{ii}(:,5)<=dwlim) );
        j_dw{ii}=find(~(data_dw{ii}(:,5)>=uplim | data_dw{ii}(:,5)<=dwlim) );
        %
        %ploty(data_up{ii}(:,[1,5]),'r.'); hold on;ploty(data_up{ii}(j_up{ii},[1,5]),'ro')
        %ploty(data_dw{ii}(:,[1,5]),'b.'); ploty(data_dw{ii}(j_dw{ii},[1,5]),'bo')
        
    %end
    F{ii}=dspchi3(data_dw{ii}(j_dw{ii},1),data_dw{ii}(j_dw{ii},5),data_up{ii}(j_up{ii},1),data_up{ii}(j_up{ii},5));
    xd{ii}=[(-F{ii}(1))/F{ii}(3),(-F{ii}(1)+1)/F{ii}(3)]; % corte con el eje 0
    xu{ii}=[(F{ii}(2))/F{ii}(3),-(-F{ii}(2)+1)/F{ii}(3)]; % cortes con el eje 1
    fwhm{ii}=(F{ii}(2)+F{ii}(1)-1)/F{ii}(3);
    %fwhm{ii}=(F{ii}(2)+F{ii}(1)-(F{ii}(1)+F{ii}(3)*xu{ii}(1)))/F{ii}(3);
    
    % ajuste 
    ll=polyfit(xd{ii},[0,1],1); y1=polyval(ll,data_dw{ii}(j_dw{ii},1));
    r=sqrt(corrcoef(y1,data_dw{ii}(j_dw{ii},5))); % sqrt (?)
    r_d{ii}=r(1,2);
    ll=polyfit(xu{ii},[0,1],1); y1=polyval(ll,data_up{ii}(j_up{ii},1));
    r=sqrt(corrcoef(y1,data_up{ii}(j_up{ii},5))); % sqrt (?) 
    r_u{ii}=r(1,2);
    
    %% TOP
    jtop{ii}=find(data{ii}(:,1)>xu{ii}(2) & data{ii}(:,1)<xd{ii}(2))';
    [p_top{ii},st{ii}]=polyfit(data{ii}(jtop{ii},1),data{ii}(jtop{ii},5),2);
    y1=polyval(p_top{ii},data{ii}(jtop{ii},1));
    r=sqrt(corrcoef(y1,data{ii}(jtop{ii},5)));
    r_top{ii}=r(1,2);
    
    mx{ii}=-p_top{ii}(2)/2/p_top{ii}(1);
    %% BASE1
    jbase_up{ii}=find(data{ii}(:,1)<xu{ii}(1))';
    [p_b_up{ii},st_b_up{ii}]=polyfit(data{ii}(jbase_up{ii},1),data{ii}(jbase_up{ii},5),1);
    %% BASE1
    jbase_dw{ii}=find(data{ii}(:,1)>xd{ii}(1))';
    [p_b_dw{ii},st_b_dw{ii}]=polyfit(data{ii}(jbase_dw{ii},1),data{ii}(jbase_dw{ii},5),1);
    
    %%
    out{ii}=[mx{ii},max_{ii},step_max{ii},r_u{ii},r_d{ii},r_top{ii},...
        xu{ii},xd{ii},fwhm{ii},p_top{ii},p_b_up{ii},p_b_dw{ii}];
    %out{ii}=[mx{ii},xu{ii},xd{ii},p_top{ii},p_b_up{ii},p_b_dw{ii}];
    sd{ii}=st{ii};
end
data_int=data;

if fplot
    figure;
    for ii=1:2
        subplot(1,2,ii);
        if ii==1
            plot(data_az(:,1),data_az(:,4),'o','linewidth',3);
            axis('tight');
            xl=get(gca,'Xlim');
        else
            plot(data_ze(:,1),data_ze(:,4),'o','linewidth',3);
            axis('tight');
            xl=get(gca,'Xlim');
        end
        
        set(gca,'YLim',[0,1]);
        set(gca,'XLim',xl);
        hold on;
        ploty(data{ii}(:,[1,5]),'r.')
        ploty(data_up{ii}(j_up{ii},[1,5]),'rx')
        ploty(data_dw{ii}(j_dw{ii},[1,5]),'rx')
       
        
        line(xd{ii},[0,1]);
        line(xu{ii},[0,1]);
        set(gca,'YLim',[0,1]);
        
        
        ploty(data{ii}(jtop{ii},[1,5]),'x');
        plot(data{ii}(jtop{ii},1),polyval(p_top{ii},data{ii}(jtop{ii},1)),'b-','linewidth',2)
        vline(mx{ii},'b',sprintf('v=%.1f mx=%.1f',[mx{ii},step_max{ii}]));
        hline(.5,'g',sprintf('fwhm %.1f',abs(fwhm{ii})));
        hline(p_b_up{ii}(2),'b',sprintf('%.1f',p_b_up{ii}(2)));
        hline(p_b_dw{ii}(2),'b',sprintf('%.1f',p_b_dw{ii}(2)));
        title(sprintf('R^2=%.4f (%.2f %.2f %.2f)',[(r_d{ii}*r_u{ii}*r_top{ii})^(1/3),r_d{ii},r_u{ii},r_top{ii}]));

        set(gca,'YLim',[0,1]);
        set(gca,'XLim',xl);
    end
end
end