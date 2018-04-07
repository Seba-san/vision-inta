function [Puntos,Data]=GeneradorDePuntos(Distancia,Data,Parametros)
%[Puntos]=GeneradorDePuntos(Data,Parametros)
% Esta funcion obtiene puntos  para ingresar a la funcion "TroncoDetect" 
% AlturaL=Data.L.Altura;AlturaR=Data.R.Altura;
% PosX_L=Data.L.PosX;PosX_R=Data.R.PosX;
% DisMin=Data.DisMin;

[Z,~]=pol2cart(-Distancia(:,2),Distancia(:,1));
Pm=Imagen2Mundo(Distancia(:,3:4),Parametros,Z);

Data.DisMin=min(Z);
Der=find(Pm(:,1)>0);
% Se usa la ponderacion (P(k)+P(k-1)*4)/5
if ~isempty(Der)
    Data.R.PosX=(mean(Pm(Der,1))+4*Data.R.PosX)/5;Data.R.Altura=(mean(Pm(Der,2))+4*Data.R.Altura)/5; % calculo las rectas en funcion de los promedios ultimos medidos 
end
    Izq=find(Pm(:,1)<0);
if ~isempty(Izq)
    Data.L.PosX=(mean(Pm(Izq,1))+4* Data.L.PosX)/5;Data.L.Altura=(mean(Pm(Izq,2))+4*Data.L.Altura)/5;
end
% Data.L.Altura=80; % QUITAR ESTO!

Z=Data.DisMin:10:1000;
AlturaL=Data.L.Altura-20:4:Data.L.Altura+20;
AlturaR=Data.R.Altura-20:4:Data.R.Altura+20;
for i=1:size(AlturaL,2)
    Img_L=Mundo2Imagen(Data.L.PosX,AlturaL(i),Z,Parametros);
    Img_R=Mundo2Imagen(Data.R.PosX,AlturaR(i),Z,Parametros);
    X=cat(2,Img_L.X,Img_R.X);Y=cat(2,Img_L.Y,Img_R.Y);
    if i==1
        Puntosx=X;
        Puntosy=Y;
    else
        Puntosx=cat(2,Puntosx,X);
        Puntosy=cat(2,Puntosy,Y);
    end
end
Puntos(1,:)=Puntosx;
Puntos(2,:)=Puntosy;
if Parametros.IMAGENES==1
    figure(1)
    imshow(Data.Img.I2a)
hold on
% plot(Img_L.X,Img_L.Y,'rx')
% plot(Img_R.X,Img_R.Y,'rx')
plot(Puntos(1,:),Puntos(2,:),'rx')  
hold off
pause()
end
end

% Como se usa

% Altura=60;X=-200;Z=250:1:2000;
% Img=Mundo2Imagen(X,Altura,Z,Parametros);
% figure(1)
% imshow(Data.Img.I2a)
% hold on
% plot(Img.X,Img.Y,'rx')
% hold off
% Parametros.IMAGENES=1;
% Puntos=[Img.X ;Img.Y];
% figure(2)
% Centros2=TroncoDetect(I2a,Parametros,Puntos);