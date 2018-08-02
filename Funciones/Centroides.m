function [Troncos, P_L]=Centroides(Centros,Parametros,umbral,Sensivilidad)
%[Troncos, P_L]=Centroides(Centros,Parametros,umbral)
% Entran puntos de troncos, y aca se filtran y se obtenen los troncos
% reales
%
IMAGENES=Parametros.IMAGENES; Dimencion=Parametros.Centroides.Dimencion;
% if nargin<3
%     IMAGENES=0;
% end
if nargin<3
    umbral=0.01;
end
if nargin<4
   Sensivilidad=0;
end

Imagen=zeros(Dimencion(1),Dimencion(2));

Centros3=round(Centros(:,1:2));
for i=1:numel(Centros3(:,1))
Imagen(Centros3(i,2), Centros3(i,1))=Centros(i,4);
end
h = fspecial('gaussian', 20, 3);%h = fspecial('gaussian', hsize, sigma)
B = imfilter(Imagen,h);
if IMAGENES==1
imagesc(B);colormap jet
pause()
end
b = imhmax(B,umbral); % Saca los umbrales que estan por debajo de este. 0.01
if IMAGENES==1
    imagesc(b);colormap jet
    pause()
end
if Sensivilidad==1
b2=imbinarize(b,'adaptive'); % Ver de agregar un umbral para ver si mejora
else
    b2=imbinarize(b); % Ver de agregar un umbral para ver si mejora
end

if IMAGENES==1
imshow(b2)
 pause()
end
stats = regionprops(b2,'Centroid');
P_L=regionprops(b2,'PixelList');
% imshow(Ic);hold on; plot(pepe.PixelList(:,1),pepe.PixelList(:,2),'rx');hold off
L=numel(stats);
Troncos=zeros(L,2);
for i=1:L % Esto lo hago asi porque no se como hacerlo con funciones de matlab
    Troncos(i,:)=stats(i).Centroid;
end

if IMAGENES==1
    hold on
    plot(Troncos(:,1),Troncos(:,2),'rx')
    hold off
    pause()
end
% hold on
% plot(Centroides(:,1),Centroides(:,2),'rx')
% hold off


end
