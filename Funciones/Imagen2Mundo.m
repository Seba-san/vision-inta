function[Mun]=Imagen2Mundo(Img,Parametros,Z)
%[Mun]=Imagen2Mundo(Img,Parametros,Z)
%Mun(:,1)= X, Mun(:,2)=Y altura 
% Da el parametro X cambiado de signo (para que se vea bien y coincida con las otras estimaciones)
CamMx=Parametros.Camara.L.IntrinsicMatrix';
H=Parametros.Hcamara;
if nargin<3
   Mun(:,1)=(Img(:,1)-CamMx(1,3))/CamMx(1,1);%(x-cx)*Z/fx
    Mun(:,2)=H-(Img(:,2)-CamMx(2,3))/CamMx(2,2);%H-(y-cy)*Z/fy
else
    Mun(:,1)=(Img(:,1)-CamMx(1,3)).*Z/CamMx(1,1);%(x-cx)*Z/fx
    Mun(:,2)=H-(Img(:,2)-CamMx(2,3)).*Z/CamMx(2,2);%H-(y-cy)*Z/fy
end
end
