function [Data]=Iniciar_Traquers(Data,Parametros,ConTr_Detect,Puntos)
% Esta funcion es el procedimiento usual para inicializar los trackers.
% Puede ser usada sin escanear toda la imagen o escaneando toda la imagen,
% esto se configura con la bandera: "ConTr_Detect" (Con tronco_detec)
if nargin<3
    ConTr_Detect=0;
end
if ConTr_Detect==1
    if nargin<4
    Centros2=TroncoDetect(Data.Img.I2a,Parametros);
    [Troncos]=Centroides(Centros2,Parametros);
    else
    Centros2=TroncoDetect(Data.Img.I2a,Parametros,Puntos);
    umbral=Data.umbral;
    [Troncos]=Centroides(Centros2,Parametros,umbral,1);
    end
else
    Centros2=Data.Centros;
    [Troncos]=Centroides(Centros2,Parametros);
end
[Traquear]=GenPunTk(Troncos,Data.Img.I2a,Parametros.IMAGENES);
Ds=size(Traquear);Data.Trackers.Ds=Ds(2);
% Genera cada traquer por cada tronco encontrado con los puntos generados
% en "GenPunTk"
 clear Data.Trackers.trackers;clear Data.Trackers.Puntos;
for q=1:Ds(2)
    Data.Trackers.trackers{q}=clone(Data.Gentracker);
    initialize(Data.Trackers.trackers{q},Traquear{q},Data.Img.I2a);
end
end