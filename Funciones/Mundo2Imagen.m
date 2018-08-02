function [Img]=Mundo2Imagen(X,Altura,Z,Parametros)
%[Img]=Mundo2Imagen(X,Altura,Z,Parametros)
% X, Altura y distancia tienen que estar en centimetros
%Img.X= Posicion en X pixeles
%Img.Y= Posicion en Y pixeles
CamMx=Parametros.Camara.L.IntrinsicMatrix';
%CamMx(1,1)=CamMx(1,1)/10;CamMx(2,2)=CamMx(2,2)/10;
H=Parametros.Hcamara;
Img.X=round(((X).*CamMx(1,1)./Z)+CamMx(1,3));
Img.Y=round(((H-Altura).*CamMx(2,2)./Z)+CamMx(2,3));
end
% --------------------------------------------------------------------------
% Ejemplo de uso

% Mundo.A=0; Mundo.X=+200; BarridoZ=200:1:2000;
% Img=Mundo2Imagen(Mundo.X,Mundo.A,BarridoZ,Parametros);
% imshow(Data.Img.I2a)
% hold on
% plot(Img(:,1),Img(:,2),'r')
% Mundo.X=-200; BarridoZ=200:1:2000;
% Img=Mundo2Imagen(Mundo.X,Mundo.A,BarridoZ,Parametros);
% plot(Img(:,1),Img(:,2),'r')
% hold off
%-------------------------------------------------------------------------------           


% function[Mun]=Imagen2Mundo(Img,Parametros,Z)
% CamMx=Parametros.Camara.L.IntrinsicMatrix';CamMx(1,1)=CamMx(1,1)/10;CamMx(2,2)=CamMx(2,2)/10;
% H=Parametros.Hcamara;
% if nargin<3
% Mun=inv(CamMx)*Img;
% Mun(2)=H-Mun(2);
% else
% Mun(1)=(Img(1)-CamMx(1,3))*Z/CamMx(1,1);
% Mun(2)=(Img(2)-CamMx(2,3))*Z/CamMx(2,2);
% end
% end

