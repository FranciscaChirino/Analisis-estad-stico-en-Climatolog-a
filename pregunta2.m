clc
clear
close all

ncdisp('air.2m.mon.mean.nc')

% Posiciones de las latitudes y longitudes que quieres
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

  
%% 2 

%determinamos tendencia lineal en el periodo de análisis, para el invierno boreal 
%(diciembre-enero-febrero) y el verano boreal (junio-julio-agosto)


%para hacer tendencia lineal debo usar y,x donde en x tengo fechas y en y
%datos

%trabajo con las fechas pero ojo pondre un vector de 1:75 pq tengo 75 datos es decir 75 años
%no puedo usar el time_ver pq los datos de fecha 'time' de del archivo nc
%no estan en formato matlab, por lo que no puedo hacer esto, esto no lo
%borro para acordarme de mi error, lo correcto es crear un vector fecha 


% saco el tiempo para el verano boreal

%c=0;
%  for i=6:12:903
%        c=c+1;
%        time_ver(:,c)=mean(time(i:i+2,:)); %time es un vector columna 
%  end
 


%saco el tiempo para el invierno boreal 
 
%c=0;
%for i=12:12:903
%        c=c+1;
%        time_inv(:,c)=mean(time(i:i+2,:));
%end
  


%algo un poco mas correcto es crear un vector de fechas
%entre 1948 y 2023
%pero para esta pregunta tampoco es necesario ya que la tendencia la saque
%con mis datos de fecha (1:70) es decir cada un año(?

%c=0;
%for i=1948:2023
%    for j=1:12
%        c=c+1;
%        tiempo(c)=datenum(i,j,1);
%    end
%end
  


%% SACAMOS TENDENCIA LINEAL

%tomo latitud 1 longitud 1 para todos los tiempos 
%polyfit = (x,,y,1) x tiempo, y datos

%p=polyfit(time_ver,temp_ver(1,1,:),1);


%polyfit verano pendiente verano o tendencia 

for i=1:70 %lon
    for j=1:38 %lat
   
        p = polyfit(1:75,temp_ver(i,j,:),1);
        pendiente_ver(i,j)=p(1);
    end
end




% tendencia lineal invierno

for i=1:70
    for j=1:38
   
        p = polyfit(1:75,temp_inv(i,j,:),1);
        pendiente_inv(i,j)=p(1);
    end
end

%observamos la tendencia lineal 


figure()
subplot(1,2,1)
m_proj('miller','lon',[ 11  140],'lat',[ 0 70]);
m_contourf(lon,lat,(pendiente_ver)'); 
shading interp
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'C°';
hold on
m_grid('Box','Fancy','LineStyle','none','FontSize',9);
m_gshhs_i('Color','k','LineWidth',2);
title('Tendencia Lineal Verano Boreal')
colormap('jet')
hold off


subplot(1,2,2)
m_proj('miller','lon',[ 11  140],'lat',[ 0 70]);
m_contourf(lon,lat,(pendiente_inv)'); 
shading interp
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'C°';
hold on
m_grid('Box','Fancy','LineStyle','none','FontSize',9);
m_gshhs_i('Color','k','LineWidth',2);
title('Tendencia Lineal Invierno Boreal')
colormap('jet')
hold off




%% lo hacemos para una sola grilla para de esta formar sacar significancia 

%primero lo pense en una sola grilla, este procedimiento fue para entender
%que era lo que estaba pasando y que era lo que tenia que hacer 

%mas abajo esta generalizado, esto está comentado 

%falta generalizar para todas las grillas


%for i=1:5
%ser(i,:)=remuestreo(temp_ver(1,1,:));
%end

%for i=1:5
%aux=polyfit(time_ver,ser(i,:),1);
%pendientesnuevas(i)=aux(1);
%end

%valoralto=prctile(pendientesnuevas(:),97.5)
%valorbajo=prctile(pendientesnuevas(:),2.5)


%if pendiente_ver < valoralto | pendiente_ver > valorbajo
%    pendiente_ver=NaN
%end



%% saco significancia estadistica para verano todas las grillas 

%recordar que montecarlo solo sirve para 3 estadisticos, tendencia lineal,
%correlacion  y skewness

%ya que si sacas montecarlo al promedio o sdt en teoria deberia darte lo
%mismo por que el remuestreo no afecta al estadistico 


%remuestreo la serie para todas mis grillas

for j=1:70 
    for k=1:38
        for i=1:1000
ser(i,:)=remuestreo(temp_ver(j,k,:)); %remuestreo serie
aux=polyfit(1:75,ser(i,:),1); %saco pendiente
pendientesnuevas_ver(i)=aux(1); %las guardo
        end   
        valoralto_ver(j,k)=prctile(pendientesnuevas_ver(:),97.5);
        valorbajo_ver(j,k)=prctile(pendientesnuevas_ver(:),2.5);
        
    end
end

%con esto realizo montecarlo, recuerda que desorodeno mi serie 1000 veces
%para cada grilla, luego a cada grilla le saco la pendiente de todas las
%series remuestreadas, tendria 1000 pendientes por cada grilla, luego a
%cada grilla le saco el percentil 97.5 y 2.5 respectivamente,es decir,a esas
%1000 pendientes por cada grilla les saco los percentiles, obteniendo 
%un mapa de percentiles (bajos y altos), que luego compararé con mi
%tendencia original, para determinar si es significante o no 
% aca trabajamos con una significancia del 5% 



%hago la comparacion para ver si es o no significante 
%si mi pendiente_ver en cada grilla es menor al percentil 97 en esa grilla
%y mayor al percentil 2.5 en esa grilla, significa que no es significante 
%si no es significante guardare esa grilla con un Nan 
%finalmente voy a obtener un mapa donde los valores con NaN no son
%significativos (al 5%)

%ojo que en estos mapas no puedo decir por la colobar que un lugar es mas
%significativo que otro, aunque al mirar el mapa den ganas de hacerlo no es
%correcto, solo puedo decir que es significativo al 5% lo que si podria
%hacer es aumentar las zonas que NO son significativas aumentando la
%significancia al 2% es decir sacar el percentil 99 y el 1, en teoria
%deberian aumentar las zonas de Nan 

for j = 1:70
    for k = 1:38
        if pendiente_ver(j,k) <= valoralto_ver(j,k) && pendiente_ver(j,k) >= valorbajo_ver(j,k)
            pendiente_sver(j,k) = NaN;
        else
            pendiente_sver(j,k) = pendiente_ver(j,k);
        end
    end
end

%aca finalmente observo si es significante o no 
%y guardo ese mapita de significancia pendiente_sver para plotearlo
%posteriormente 


%ya esta hecho para verano lo hacemos para invierno 

% para invierno 

for j=1:70 
    for k=1:38
        for i=1:1000
ser(i,:)=remuestreo(temp_inv(j,k,:)); %remuestreo serie
aux=polyfit(1:75,ser(i,:),1); %x es mi cant de datos en este caso de 1:75
pendientesnuevas_inv(i)=aux(1); %las guardo
        end   
        valoralto_inv(j,k)=prctile(pendientesnuevas_inv(:),97.5);
        valorbajo_inv(j,k)=prctile(pendientesnuevas_inv(:),2.5);
        
    end
end

for j = 1:70
    for k = 1:38
        if pendiente_inv(j,k) <= valoralto_inv(j,k) && pendiente_inv(j,k) >= valorbajo_inv(j,k)
            pendiente_sinv(j,k) = NaN;
        else
            pendiente_sinv(j,k) = pendiente_ver(j,k);
        end
    end
end




figure()
subplot(1,2,1)
m_proj('miller','lon',[ 11  140],'lat',[ 0 70]);
m_contourf(lon,lat,(pendiente_sver)'); 
shading interp
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'C°';
hold on
m_grid('Box','Fancy','LineStyle','none','FontSize',9);
m_gshhs_i('Color','k','LineWidth',2);
title('Significancia de la Tendencia Verano Boreal')
colormap('jet')
hold off


subplot(1,2,2)
m_proj('miller','lon',[ 11  140],'lat',[ 0 70]);
m_contourf(lon,lat,(pendiente_sinv)'); 
shading interp
a=colorbar(gca,'Location','EastOutside')
a.Label.String = 'C°';
hold on
m_grid('Box','Fancy','LineStyle','none','FontSize',9);
m_gshhs_i('Color','k','LineWidth',2);
title('Significancia de la Tendencia Invierno Boreal')
colormap('jet')
hold off
