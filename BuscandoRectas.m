function [Puntos]=GeneradorDePuntos(Data,Parametros)
% Esta funcion obtiene puntos  para ingresar a la funcion "TroncoDetect" 
% AlturaL=Data.L.Altura;AlturaR=Data.R.Altura;
% PosX_L=Data.L.PosX;PosX_R=Data.R.PosX;
% DisMin=Data.DisMin;
AlturaL=Data.L.Altura;AlturaR=Data.R.Altura;
PosX_L=Data.L.PosX;PosX_R=Data.R.PosX;
DisMin=Data.DisMin;
Z=DisMin:1:2000;
Img_L=Mundo2Imagen(PosX_L,AlturaL,Z,Parametros);
Img_R=Mundo2Imagen(PosX_R,AlturaR,Z,Parametros);
Puntos=[Img_L Img_R];
if Parametros.IMAGENES==1
figure(1)
imshow(Data.Img.I2a)
hold on
plot(Img_L.X,Img_L.Y,'rx')
plot(Img_R.X,Img_R.Y,'rx')
hold off
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