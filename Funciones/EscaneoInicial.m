function [Data,Parametros]=EscaneoInicial(Parametros)
I2a = imread(sprintf('%s/%s',Parametros.img_dir_izq(Parametros.FRAME).folder,Parametros.img_dir_izq(Parametros.FRAME).name));
I2a = undistortImage(I2a,Parametros.Camara.L);
% I1 = undistortImage(IR,Camara.R);
%Extraigo los centros positivos, TARDA UNA BOCHA
Centros2=TroncoDetect(I2a,Parametros);
Data.Img.I2a=I2a;Data.Centros=Centros2;
end