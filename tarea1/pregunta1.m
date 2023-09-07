%este codigo esta bien, falta agregarle el continente 

clc
clear
close all

ncdisp('air.2m.mon.mean.nc')

% Posiciones de las latitudes y longitudes que quieres

%ojo que para hacer esto antes debes ver toda tu serie, despues las
%restringes 

latini = 10;
latfin = 47;
lonini = 7;
lonfin = 76;

%restringo el continente euroasiatico

lat = ncread('air.2m.mon.mean.nc', 'lat', latini, latfin - latini + 1);
lon = ncread('air.2m.mon.mean.nc', 'lon', lonini, lonfin - lonini + 1);
time = ncread('air.2m.mon.mean.nc', 'time');
temp = ncread('air.2m.mon.mean.nc', 'air', [lonini, latini, 1], [lonfin - lonini + 1, latfin - latini + 1, numel(time)], [1, 1, 1]);

temp = temp - 273.15; % Convertir a grados Celsius

%verano boreal
  c=0;
  for i=6:12:903
        c=c+1;
        temp_ver(:,:,c)=mean(temp(:,:,i:i+2),3);
  end
  
  
%invierno boreal
c=0;
for i=12:12:903
        c=c+1;
        temp_inv(:,:,c)=mean(temp(:,:,i:i+2),3);
  end


% Promedio de temperatura verano e invierno
promedio_ver = mean(temp_ver, 3);
promedio_inv = mean(temp_inv, 3);

%trimean_anual = prctile(temp, [25, 50, 75], 3);

% Gráfico de promedio de temperatura verano boreal sin continente
%este gráfico no es necesario para la pregunta
figure
subplot(1, 2, 1)
contourf(lon, lat, promedio_ver', 'LineColor', 'none')
colorbar
title('Promedio de Temperatura Verano Boreal')
xlabel('Longitud')
ylabel('Latitud')
axis tight

% Gráfico promedio de temperatura invierno 
subplot(1, 2, 2)
contourf(lon, lat, promedio_inv', 'LineColor', 'none')
colorbar
title('promedio de Temperatura Invierno Boreal')
xlabel('Longitud')
ylabel('Latitud')
axis tight



%intentando agregar el continente
%agrego continente sin usar contour, uso m_pcolor

% Crear la proyección utilizando m_proj

% Gráfico de promedio de temperatura verano boreal

figure()
subplot(1,2,1)
m_proj('mercator','lon',[11 140],'lat',[0 70]) %11 min lon 140 max lon ; 0 min lat 70 max lat
m_pcolor(lon, lat, promedio_ver')
shading flat
m_coast('color', 'k');
colorbar
title('Promedio de Temperatura Verano Boreal')
xlabel('Longitud')
ylabel('Latitud')
axis tight
m_grid('box','fancy','linestyle','none','linewidth',1,'tickdir','out');
caxis([-40 40]) %para que la barrita sea de ese tamaño 
colormap(jet)


% Gráfico promedio de temperatura invierno 
subplot(1,2,2)
m_proj('mercator','lon',[11 140],'lat',[0 70])
m_pcolor(lon, lat, promedio_inv')
shading flat
m_coast('color', 'k');
colorbar
title('Promedio temperatura Invierno Boreal')
xlabel('Longitud')
ylabel('Latitud')
axis tight
m_grid('box','fancy','linestyle','none','linewidth',1,'tickdir','out');
caxis([-40 40])
colormap(jet)


%ahora usando m_contour como practica 3 jose

figure()
subplot(1,2,1)
m_proj('miller','lon',[ 11  140],'lat',[ 0 70]);
m_contourf(lon,lat,(promedio_ver)'); 
shading interp
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'Celsius';
hold on
m_grid('Box','Fancy','LineStyle','none','FontSize',9);
m_gshhs_i('Color','k','LineWidth',2);
title('Promedio temperatura Verano Boreal')
colormap('jet')
caxis([-40 40])
hold off

subplot(1,2,2)
m_proj('miller','lon',[ 11  140],'lat',[ 0 70]);
m_contourf(lon,lat,(promedio_inv)'); 
shading interp
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'Celsius';
hold on
m_grid('Box','Fancy','LineStyle','none','FontSize',9);
m_gshhs_i('Color','k','LineWidth',2);
title('Promedio Temperatura Invierno Boreal')
colormap('jet')
caxis([-40 40])
hold off

%arreglar lo del caxis en los otros estadisticos 
%ojo siempre arriba del hold off 


%% ahora que lo hice con el promedio, lo hago con los otros estadisticos 

%en la tarea pondré promedio, desviacion estandar y skweness 



% Promedio de temperatura verano e invierno
promedio_ver = mean(temp_ver, 3);
promedio_inv = mean(temp_inv, 3);

%desviacion estandar
stdtem_ver=nanstd(temp_ver,0,3);
stdtem_inv=nanstd(temp_inv,0,3);


%skewness
skwtem_ver=skewness(temp_ver,0,3);
skwtem_inv=skewness(temp_inv,0,3);


%std
%graficamos con contour como lo hizo jose
figure()
subplot(1,2,1)
m_proj('miller','lon',[ 11  140],'lat',[ 0 70]);
m_contourf(lon,lat,(stdtem_ver)'); 
shading interp
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'Celsius';
hold on
m_grid('Box','Fancy','LineStyle','none','FontSize',9);
m_gshhs_i('Color','k','LineWidth',2);
title('Desviacion Estandar Verano Boreal')
colormap('jet')
caxis([0.1 5])
hold off

subplot(1,2,2)
m_proj('miller','lon',[ 11  140],'lat',[ 0 70]);
m_contourf(lon,lat,(stdtem_inv)'); 
shading interp
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'Celsius';
hold on
m_grid('Box','Fancy','LineStyle','none','FontSize',9);
m_gshhs_i('Color','k','LineWidth',2);
title('Desviacion Estandar Invierno Boreal')
colormap('jet')
caxis([0.1 5])
hold off



%skewness
figure()
subplot(1,2,1)
m_proj('miller','lon',[ 11  140],'lat',[ 0 70]);
m_contourf(lon,lat,(skwtem_ver)'); 
shading interp
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'Celsius';
hold on
m_grid('Box','Fancy','LineStyle','none','FontSize',9);
m_gshhs_i('Color','k','LineWidth',2);
title('Skewness Verano Boreal')
colormap('jet')
caxis([-4 2])
hold off

subplot(1,2,2)
m_proj('miller','lon',[ 11  140],'lat',[ 0 70]);
m_contourf(lon,lat,(skwtem_inv)'); 
shading interp
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'Celsius';
hold on
m_grid('Box','Fancy','LineStyle','none','FontSize',9);
m_gshhs_i('Color','k','LineWidth',2);
title('skewness Invierno Boreal')
colormap('jet')
caxis([-4 2])
hold off



