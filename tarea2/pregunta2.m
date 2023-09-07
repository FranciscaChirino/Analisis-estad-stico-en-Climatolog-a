%% eof combinada aldo
clear all 
clc
load('magnitud.mat');
load('lhtfl_data.mat');

lat = ncread('uwnd.sig995.mon.mean.nc', 'lat',[46],[16],[1]);
lon = ncread('uwnd.sig995.mon.mean.nc', 'lon',[91],[51],[1]);



YY=16; %lat
XX=51; %lon


aux=magnitud;

puntero=find(reshape(squeeze(aux(:,:,1)),XX*YY,1)>-1000);


% transformar la matriz de 3 dimensiones a 2 dimensiones
for i=1:396 %804 tiempo total 
    auy=reshape(squeeze(aux(:,:,i)),XX*YY,1);
    aaa(:,i)=auy(puntero);
end

% ciclo anual
for i=1:12
    med(:,i)=mean(aaa(:,i:12:end),2);
    est(:,i)=std(aaa(:,i:12:end),0,2);
end

% anomalia y anomalia estandarizada
c=0;
for i=1:33 % años entre 1980 y 2012
    for j=1:12
        c=c+1;
        S(:,c)=(aaa(:,c)-med(:,j))./est(:,j);
    end
end


%% la otra variable

plat = ncread('lhtfl.mon.mean.nc', 'lat', [48], [16], [1]);
plon = ncread('lhtfl.mon.mean.nc', 'lon', [97], [54], [1]);


YYp=16; %lat
XXp=54; %lon



% no leo 1854 a 1949: 1152 meses no leo, y luego leo los siguientes 816

aux=lhtfl_data;

% transformar la matriz de 3 dimensiones a 2 dimensiones
clear aaa
for i=1:396
    aaa(:,i)=reshape(squeeze(aux(:,:,i)),XXp*YYp,1);
end


% ciclo anual
clear med est
for i=1:12
    med(:,i)=mean(aaa(:,i:12:end),2);
    est(:,i)=std(aaa(:,i:12:end),0,2);
end


% anomalia y anomalia estandarizada
c=0;
for i=1:33 % anhos entre 1980 y 2012
    for j=1:12
        c=c+1;
        P(:,c)=(aaa(:,c)-med(:,j))./est(:,j);
    end
end

% S anomalia viento
% P anomalia calor

F=[S;P];
    
[L,E,A,error]=EOF(F'); 

L(1:10)/sum(L)

%vector fechas
c=0;
for i=1980:2012
    for j=1:12
        c=c+1;
        fecha(c)=datenum(i,j,1);
    end
end

modo=1;

Ms=length(S(:,1));
Mp=length(P(:,1));

for i=1:Ms
    corrcoef(S(i,:)',A(:,modo));
    rs(i)=ans(1,2);
end
for i=1:Mp
    corrcoef(P(i,:)',A(:,modo));
    rp(i)=ans(1,2);
end


figure(modo)
subplot(311)
plot(fecha,A(:,modo)/std(A(:,modo))),datetick
title(['Componente principal normalizada ' num2str(modo) ' :' num2str(L(modo)/sum(L)*100) '%'])
h=line([datenum(1980,1,1) datenum(2012,12,31)],[0 0])
set(h,'color','k')
axis tight
subplot(312)
campo=NaN(XX*YY,1);
campo(puntero)=rs;
contourf(lon,lat,reshape(campo,XX,YY)'),colorbar
%caxis([-0.8 0.8])
subplot(313)
contourf(plon,plat,reshape(rp,XXp,YYp)'),colorbar
%caxis([-0.8 0.8])




%% veamos significancia 

% veamos la significancia 
nn=396 % cantidad de modos lo puedo ver de L
figure()
scatter(1:10,L(1:10),'filled')  % comunemnte mas alla del decimo modo son ruido
hold on 
%metodo de north: se define un intervalo donde si se intersectan estos
%no son significativos
plot(L(1:10)+L(1:10)*sqrt(2/nn),'+r','linewidth',2)
plot(L(1:10)-L(1:10)*sqrt(2/nn),'+r','linewidth',2)
grid minor 
% si tiramos una linea desde el limite inferior del primer modo y choqua
% con otro este no es significativo



%% c. Cómo se relaciona linealmente (o qué tipo de relación lineal tiene) 
%la componente principal del modo con los índices E y C del ENSO. 
%Calcular significancia estadística

%según yo me están pidiendo correlación del modo 1 con el enso 
% la correlación del modo 1 la saco de la matriz A(:,1)

%EC(:,3) E
%EC(:,4)C

load('EC');
% A

% Calcular la correlación de Pearson
correlacion_E = corrcoef(A(:,1), EC(:,3));%0.0764 7%
correlacion_C = corrcoef(A(:,1), EC(:,4));%-0.0405 4%




% significancia
for m=1:1000
    ser=remuestreo(A(:,1)); %remmuestreo de los datos
    p(m)=corrcoef(ser,EC(:,3));
   
end
[correlacion_EC3 prctile(p,2.5) prctile(p,97.5)] % con alfa=5%


