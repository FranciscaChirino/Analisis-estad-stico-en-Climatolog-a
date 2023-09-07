% A. Campos globales con información mensual desde enero de 1871 a diciembre de 2012. Son el 
% resultado de un proceso de reanálisis de información observada, usando un modelo climático global 
% (GCM en inglés). 
% Origen: Monthly NOAA-CIRES 20th Century Reanalysis V2 
% https://www.psl.noaa.gov/data/gridded/data.20thC_ReanV2.html

% i. uwnd.sig995.mon.mean.nc y vwnd.sig995.mon.mean.nc
% Con la componente zonal (uwnd) y meridional (vwnd) del viento cerca de la superficie (nivel sigma 
% 0,995; 1 es la superficie), en m/s, calcular la magnitud del viento.
% Cortar entre enero de 1980 a diciembre de 2012. Extraer la región: 0°-30°S; 180°-280° (80°W).

clc
clear
close all

ncdisp('vwnd.sig995.mon.mean.nc');
ncdisp('uwnd.sig995.mon.mean.nc');


% Para calcular la magnitud del viento a partir de las componentes zonal 
% (uwnd) y meridional (vwnd) del viento cerca de la superficie, puedes 
% seguir los siguientes pasos utilizando MATLAB:
% 
% Cargar los datos del archivo netCDF 'uwnd.sig995.mon.mean.nc' y 
% 'vwnd.sig995.mon.mean.nc' que contienen las componentes zonal y meridional 
% del viento, respectivamente.

uwnd_data = ncread('uwnd.sig995.mon.mean.nc', 'uwnd');
vwnd_data = ncread('vwnd.sig995.mon.mean.nc', 'vwnd');
lat = ncread('uwnd.sig995.mon.mean.nc', 'lat');
lon = ncread('uwnd.sig995.mon.mean.nc', 'lon');
time = ncread('uwnd.sig995.mon.mean.nc', 'time');

%para ver las fechas que tenemos
% Convertir los valores de tiempo a fechas normales
% Convertir los valores de fecha numérica a componentes individuales
dateComponents = datevec(time/24 + datenum('1800-01-01 00:00:00')); %info del tiempo 0
%de esta forma sabemos la fila de 1980 hasta 2012



% Cortar entre enero de 1980 a diciembre de 2012. Extraer la región: 0°-30°S; 180°-280° (80°W).
lat_v = ncread('uwnd.sig995.mon.mean.nc', 'lat',[46],[16],[1]);
lon_v = ncread('uwnd.sig995.mon.mean.nc', 'lon',[91],[51],[1]);
time = ncread('uwnd.sig995.mon.mean.nc', 'time',[1309],[396],[1]);
uwnd_data = ncread('uwnd.sig995.mon.mean.nc', 'uwnd', [91 46 1309], [51 16 396], [1 1 1]); %lon lat time
vwnd_data = ncread('vwnd.sig995.mon.mean.nc', 'vwnd', [91 46 1309], [51 16 396], [1 1 1]);




% Calcular la magnitud del viento utilizando la fórmula: magnitude = sqrt(uwnd.^2 + vwnd.^2).
magnitud = sqrt(uwnd_data.^2 + vwnd_data.^2);


% Esto calculará la magnitud del viento en cada punto de la rejilla para 
% los datos proporcionados. La matriz resultante magnitud_viento tendrá las 
% dimensiones 51x16x396, donde cada elemento representa la magnitud del 
% viento en ese punto y tiempo específico.

%%


% ii. lhtfl.mon.mean.nc Campo reanalizado del flujo de calor latente en 
% superficie, en W/m². Un valor positivo (negativo) indica un flujo hacia 
% arriba (abajo). Cortar entre enero de 1980 a diciembre de 2012. Extraer 
% la región: 0,9524°S a 29,5234°S; 180° a 279,3750° (80,625°W)
% Notar que las variables a utilizar, no tienen la misma resolución espacial


ncdisp('lhtfl.mon.mean.nc')
lat = ncread('lhtfl.mon.mean.nc', 'lat');
lon = ncread('lhtfl.mon.mean.nc', 'lon');
time = ncread('lhtfl.mon.mean.nc', 'time');

lat_c = ncread('lhtfl.mon.mean.nc', 'lat', [48], [16], [1]);
lon_c = ncread('lhtfl.mon.mean.nc', 'lon', [97], [54], [1]);
time = ncread('lhtfl.mon.mean.nc', 'time',[1309],[396],[1]);
lhtfl_data = ncread('lhtfl.mon.mean.nc', 'lhtfl', [97 48 1309], [54 16 396], [1 1 1]);


%leo los datos EC
EC=readmatrix('EC.txt');
%saco las columnas con nan
EC(:,5:6) = []; 
%restringo la fecha que me interesa
EC = EC(1201:1596,:);


%% PREGUNTAS

% 1. Obtener el promedio climatológico (o promedio de largo plazo) de la 
% magnitud del viento (wind speed) y del flujo de calor latente (latent heat).
% El promedio climatológico corresponde a la media de los 396 meses. No 
% confundir con el ciclo anual, que corresponde al promedio climatológico de cada 
% meses, donde hay 33 elementos para calcular el promedio de cada mes.

promedio_viento = double(nanmean(magnitud, 3)); %lo paso a double pq estaba en single 
promedio_calor = double(nanmean(lhtfl_data, 3));


%para poder graficar
[lat_v,lon_v] = meshgrid(double(lat_v),double(lon_v));
[lat_c,lon_c] = meshgrid(double(lat_c),double(lon_c));



%% algo no funciona con el mapa no se pq


%opcion1
figure()
subplot(1,2,1)
m_proj('mercator','lon',[min(lon_v(:)) max(lon_v(:))],'lat',[min(lat_v(:)) max(lat_v(:))]) %11 min lon 140 max lon ; 0 min lat 70 max lat
m_pcolor(lon_v, lat_v, promedio_viento)
shading flat
m_coast('color', 'k');
colorbar
title('Promedio Climatológico de la magnitud del viento')
xlabel('Longitud')
ylabel('Latitud')
axis tight
m_grid('box','fancy','linestyle','none','linewidth',1,'tickdir','out');
%caxis([-40 40]) %para que la barrita sea de ese tamaño 
colormap(jet)
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'm/s';

% Gráfico promedio de temperatura invierno 
subplot(1,2,2)
m_proj('mercator','lon',[min(lon_v(:)) max(lon_v(:))],'lat',[min(lat_v(:)) max(lat_v(:))])
m_pcolor(lon_c, lat_c, promedio_calor)
shading flat
m_coast('color', 'k');
colorbar
title('Promedio climatológico del flujo de calor')
xlabel('Longitud')
ylabel('Latitud')
axis tight
m_grid('box','fancy','linestyle','none','linewidth',1,'tickdir','out');
%caxis([-40 40])
colormap(jet)
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'w/m^2';


%opcion 2 
figure()
subplot(1,2,1)
m_proj('mercator','lon',[min(lon_v(:)) max(lon_v(:))],'lat',[min(lat_v(:)) max(lat_v(:))])
m_contourf(lon_v,lat_v,promedio_viento,...
 'LabelSpacing',600,'ShowText','on','LineWidth',0.1, 'color',[0 0 0])
colormap('jet')
colorbar
hold on
title('Promedio Climatológico de la magnitud del viento')
m_grid('Box','Fancy','LineStyle','none','FontSize',14);
m_gshhs_c('color','k','linewidth',2)
set(gca,'FontSize',15)
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'm/s';
hold off

subplot(1,2,2)
m_proj('mercator','lon',[min(lon_c(:)) max(lon_c(:))],'lat',[min(lat_c(:)) max(lat_c(:))])
m_contourf(lon_c,lat_c,promedio_calor,...
 'LabelSpacing',600,'ShowText','on','LineWidth',0.1, 'color',[0 0 0])
colormap('jet')
colorbar
hold on
title('Promedio climatológico del flujo de calor')
m_grid('Box','Fancy','LineStyle','none','FontSize',14);
m_gshhs_c('color','k','linewidth',2)
set(gca,'FontSize',15)
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'w/m^2';
hold off







figure()
subplot(1,2,1)
m_proj('mercator','lon',[min(lon_v(:)) max(lon_v(:))],'lat',[min(lat_v(:)) max(lat_v(:))])
m_contourf(lon_v,lat_v,promedio_viento,...
 'LabelSpacing',600,'ShowText','on','LineWidth',0.1, 'color',[0 0 0])
colormap('jet')
colorbar
hold on
title('Promedio Climatológico de la magnitud del viento')
m_grid('Box','Fancy','LineStyle','none','FontSize',14);
m_gshhs_c('color','k','linewidth',2)
set(gca,'FontSize',15)
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'm/s';
hold off

subplot(1,2,2)
m_proj('mercator','lon',[min(lon_c(:)) max(lon_c(:))],'lat',[min(lat_c(:)) max(lat_c(:))])
m_contourf(lon_c,lat_c,promedio_calor,...
 'LabelSpacing',600,'ShowText','on','LineWidth',0.1, 'color',[0 0 0])
colormap('jet')
colorbar
hold on
title('Promedio climatológico del flujo de calor')
m_grid('Box','Fancy','LineStyle','none','FontSize',14);
m_gshhs_c('color','k','linewidth',2)
set(gca,'FontSize',15)
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'w/m^2';
hold off







%% 2 
% 2. A partir de los campos de anomalías (extraer ciclo anual), obtener 
% los modos de covarianza acoplados o combinados de los campos de rapidez del
% viento y del flujo turbulento de calor latente, que no están mezclados, de 
% acuerdo al criterio de North et al. 1982. (0,5 puntos)


%extraemos el ciclo anual 

%ciclo anual viento
  c=0;
  for i=1:12:396
        c=c+1;
        anual_viento(:,:,c)=mean(magnitud(:,:,i:i+11),3);
  end
  
  
  
  %ciclo anual calor
  c=0;
  for i=1:12:396
        c=c+1;
        anual_calor(:,:,c)=mean(lhtfl_data(:,:,i:i+11),3);
  end


%vamos a sacar las anomalías estandarizadas pq parece que para EOF siempre
%se trabaja con anomalías estandarizadas

%viento

%tenemos el promedio                          %promedio para todos los años
promedio_viento = double(nanmean(magnitud, 3)); %lo paso a double pq estaba 

%desviacion estandar
desv_viento=std(magnitud,0,3);

% construimos la anomalia estandarizada
AE_viento= (anual_viento-promedio_viento)./(desv_viento);



%calor latente


promedio_calor = double(nanmean(lhtfl_data, 3));
%desviacion estandar
desv_calor=std(lhtfl_data,0,3);

% construimos la anomalia estandarizada
AE_calor= (anual_calor-promedio_calor)./(desv_calor);



%ahora que tenemos las anomalias tratamos de extraer los modos

% EOF Tiene que estar como anomalia estandarizada si o si y sacarle la tendencia
% estas 2 cosas siempre se tiene que cumplir
AE_dviento=detrend3(AE_viento);  % si tenemos matrices 3d detrend3 saca la tendencia a lo largo de la 3ra dimension
AE_dcalor=detrend3(AE_calor);

figure()
contourf(lon_v,lat_v,AE_dviento(:,:,1))
%caxis([-2 2])
colormap(redbluecmap)
colorbar

[X,Y,T]=size(AE_viento);
[x,y,T]=size(AE_calor);
F = reshape(permute(AE_dviento,[3 1 2]),T,X*Y); % Matriz bidimensional de anomalias, variable 1
[L,A,E,error]=EOF(F'); % entrando con F(N,M)...% n: meses,  m: puntos de grilla  
% L varianza asocaiada de cada modo
% A matriz de componentes principales  (tiene que tener la menor dimension en este caso 63x63, debe ser cuadrada)
% E componente espacial (EOF) (vectores propios)




%% 

clear F 
S = reshape(permute(AE_dviento,[3 1 2]),T,X*Y); % Matriz bidimensional de anomalias, variable 1
P = reshape(permute(AE_dcalor,[3 1 2]),T,x*y); % Matriz bidimensional de anomalias, variable 2

F=[S' ;P']; % ¿Qué dimensión se duplica?
clear L A err
[L,A,E,error]=EOF(F); % ¿Que dimension tiene f? n: tiempo, m:espacial
% tenemos una sola serie de tiempo para 2 variables





























