function Dist=CorteZ(Punto,Parametros,Data)
% Proyecto 2, proyectar puntos sobre el suelo para que luego la estimacion
% de la medicion se haga en el suelo y no en el arbol.
% Punto=[406,496];
Punto=round(Punto);
Z=Data.Img.I(Punto(2),Punto(1));
Mun=Imagen2Mundo(Punto,Parametros,Z);
%reemplazar Mun(2) por 60 o algo asi
Test=Mundo2Imagen(Mun(1),60,Z-40:Z+40,Parametros);
%  figure(1)
% imshow(Data.Img.I2a)
% hold on
%  plot(Test.X,Test.Y,'rx')   
%  hold off
K=zeros(size(Test.Y,2),1);
 for i=1:size(Test.Y,2)
     if Test.X(i)<Parametros.SizeImg(2) & Test.Y<Parametros.SizeImg(1)
 K(i)=Data.Img.I(Test.Y(i),Test.X(i));
     end
 end
%  figure(2)
%  plot(K,'x')
dd=find(K);
 Dist=min(K(dd));
%  pause()
end
%  imagesc(Data.Img.I,[100 1000]);colormap jet;colorbar;
%  hold on
%  plot(Test.X,Test.Y,'rx') 
%  hold off
% figure(1)
% imshow(Data.Img.I2a)
% hold on
% for i=1:size(Img(:,1))
% if Img(i,1)<Parametros.SizeImg(2)&&Img(i,2)<Parametros.SizeImg(1)
%     plot(Img(i,1),Img(i,2),'rx')    
%     Dist(i)=Data.Img.I(Img(i,2),Img(i,1));
% end      
% end
% hold off
% figure(2)
% plot(Dist)
% Px=1:1:size(Dist,2);
% Dist2=1./Dist;
% plot(Dist2)
% 
% [Mun]=Imagen2Mundo(Img,Parametros)