%% ejercicio 3
%Pregunta 3

%Se utilizan las variables air y prate. Extraer la región tropical-subtropical 
%de Sudamérica: 14°N - -30°S;279° (81°W) - 330° (30°W).

%En el caso de Sudamérica tropical-subtropical, determinar la correlación punto a punto entre la 
%temperatura a 2 m y la precipitación, durante el otoño austral (marzo-abril-mayo). Obtener 
%significancia estadística

clear all 
clc

ncdisp('air.2m.mon.mean.nc')
ncdisp('prate.sfc.mon.mean.nc')

%extraigo datos air.2m.mon.mean.nc

% Posiciones de las latitudes y longitudes que quieres
latini = 40;
latfin = 64;
lonini = 44;
lonfin = 177;

%restringo a america 

lat = ncread('air.2m.mon.mean.nc', 'lat', latini, latfin - latini + 1);
lon = ncread('air.2m.mon.mean.nc', 'lon', lonini, lonfin - lonini + 1);
time = ncread('air.2m.mon.mean.nc', 'time');
temp = ncread('air.2m.mon.mean.nc', 'air', [lonini, latini, 1], [lonfin - lonini + 1, latfin - latini + 1, numel(time)], [1, 1, 1]);

temp = temp - 273.15; % Convertir a grados Celsius


%extraigo datos prate.sfc


latini = 40;
latfin = 64;
lonini = 44;
lonfin = 177;


lat = ncread('prate.sfc.mon.mean.nc', 'lat', latini, latfin - latini + 1);
lon = ncread('prate.sfc.mon.mean.nc', 'lon', lonini, lonfin - lonini + 1);
time = ncread('prate.sfc.mon.mean.nc', 'time');
pp = ncread('prate.sfc.mon.mean.nc', 'prate', [lonini, latini, 1], [lonfin - lonini + 1, latfin - latini + 1, numel(time)], [1, 1, 1]); %Monthly Mean of Precipitation Rate


%Son datos mensuales, entre enero de 1948 y marzo de 2023.
%otoño austral (marzo-abril-mayo).

%otoño austral
%para temp
  c=0;
  for i=3:12:901
        c=c+1;
        temp_ot(:,:,c)=mean(temp(:,:,i:i+2),3);
  end
  

%otoño austral para pp
  c=0;
  for i=3:12:901 %hasta 901 para que no exceda e 903 
        c=c+1;
        pp_ot(:,:,c)=mean(pp(:,:,i:i+2),3); %deberia sacar la lluvia acumulada? es decir sum en vez de mean? no lo se
  end
  

  
  %temp_ot y pp_ot son los importantes

%% hagamos un mapa de correlación punto a punto ayudantia 6 manu


for x=1:134 %lon
     for y=1:25 %lat
        corr_xy(x,y)=corr(squeeze(temp_ot(x,y,:)),squeeze(pp_ot(x,y,:)));   
          % siempre deben estar en vectores filas (n,1) en este caso 75x1
          % cada grilla
     end 
end 

%aca por cada grilla tengo dos series de 75 datos y voy hacer la
%correlacion de estas 2 series punto a punto es decir correlaciono las
%series para cada grilla, uso el squeeze para que me baje una dimension 


%con esto obtengo una correlacion 'original' para luego comparar para ver
%la significancia 


figure()
m_proj('miller','lon',[ 279  330],'lat',[ -30 14]);
m_pcolor(lon,lat,corr_xy'); 
shading interp
a=colorbar(gca,'Location','EastOutside')
a.Label.String = '';
hold on
caxis([-1 1])
m_grid('Box','Fancy','LineStyle','none','FontSize',9);
m_gshhs_i('Color','k','LineWidth',2);
title('Correlacion Precipitacion Otoño Boreal y Temperatura Otoño Boreal')
colormap(redbluecmap)
hold off
  
  
%ahora sacamos la significancia 
%% veamos significancia estadística

%OJO que para sacar signficancia estadistica para la correlacion es
%necesario solo remuestrear una serie, no es necesario remuestrear ambas
%series, con remuestrear solo una basta 


for x = 1:134 %lon
    for y = 1:25 %lat
        for i = 1:1000
            s_cor2(x,y,i) =corr((squeeze(temp_ot(x,y,:))),remuestreo(squeeze(pp_ot(x,y,:)))');
        end
    end
end

%squeeze(temp_ot(x,y,:) me lo deja en 75x1 vector fila 

%squeeze(pp_ot(1,1,:)) me lo deja en 75x1
%remuestreo(squeeze(pp_ot(1,1,:))) me remuestrea la serie da 1x75 por lo
%tanto le saco la transpuesta asi obtengo 75x1 y obtengo vector fila para
%poder hacer la correlacion 

%hago la transpuesta de remuestreo(squeeze(pp_ot(1,1,:))) para poder sacar
%correlacion ya que debo correlacionar fila

%para cada grilla, sacare la correlacion 1000 veces con una pp_ot aleatoria
%cada vez, da lo mismo que serie eliges remuestrear pero tiene que ser una
%


%saco 1000 veces la correlacion para una grilla, cada vez remuestreare una
%serie, obtendre un mapa de 134x25x1000 donde en cada punto tengo 1000
%veces una correlacion, cada escalon de mi cubo rubik es la correlacion de mi serie remuestrada
%por eso tengo 1000, entonces a cada grilla le sacare los percentiles
%para de esta forma sacar signficancia 


%% sacamos significancia 

%ahora creare dos grillas una grilla sacare el percentil 97.5 para cada
%grilla, y la otra grilla sacara el percentil 2.5 
%esto lo hago para posteriormente sacar significancia "comparar"

for x = 1:134
    for y = 1:25
        s_cor2_ic_sup(x,y) = prctile(squeeze(s_cor2(x,y,:)),97.5);
        s_cor2_ic_inf(x,y) = prctile(squeeze(s_cor2(x,y,:)),2.5);
    end
end


%% apliquemos la significancia...

%si mi "correlacion original o fija" es menor a mi percentil 97.5 y mayor a
%mi percentil 2.5 la correlacion es producto del azar

%para cada grilla yo voy a comparar mi correlacion original, con cada punto
%de las grillas sacadas anteriormente, es decir si ese punto es menor al
%percentil 97.5 EN ESE PUNTO y mayor al 2.5 signfica que ESE PUNTO NO ES
%SIGNIFICATIVO, ES PRODUCTO DEL AZAR, entonces si lo pensamos para todas
%las grillas finalmente obtendre una grilla donde tendre algunos puntos con
%Nan donde esa correlacion no era signficatica y los lugares signficaticos
%simplemente volvemos a guardar el valor de la correlacion fija en ese
%punto 

for x = 1:134
    for y = 1:25
        if corr_xy(x,y) < s_cor2_ic_sup(x,y) && corr_xy(x,y) > s_cor2_ic_inf(x,y)
            s_cor_sig(x,y) = NaN;
        else
            s_cor_sig(x,y) = corr_xy(x,y);
        end
    end
end


figure()
m_proj('miller','lon',[ 279  330],'lat',[ -30 14]);
m_pcolor(lon,lat,s_cor_sig'); 
shading interp
a=colorbar(gca,'Location','EastOutside')
a.Label.String = '';
hold on
caxis([-1 1])
m_grid('Box','Fancy','LineStyle','none','FontSize',9);
m_gshhs_i('Color','k','LineWidth',2);
title('PP.OTOÑO y TEMPERATURA.OTOÑO (SIG 95%) 1948-2023')
colormap(redbluecmap)
hold off

