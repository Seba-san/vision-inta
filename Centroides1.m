function =Centroides


% Entran puntos de troncos, y aca se filtran
%
S=size(I1);
Imagen=zeros(S(1),S(2));
Centros3=round(Centros(:,1:2));
for i=1:numel(Centros3(:,1))
Imagen(Centros3(i,2), Centros3(i,1))=Centros(i,4);
end
h = fspecial('gaussian', 20, 3);%h = fspecial('gaussian', hsize, sigma)
B = imfilter(Imagen,h);
%imagesc(B);colormap jet
b = imhmax(B,0.01);
%imagesc(b);colormap jet
b2=imbinarize(b); % Ver de agregar un umbral para ver si mejora
imshow(b2)
stats = regionprops(b2,'Centroid');
L=numel(stats);
Centroides=zeros(L,2);
for i=1:L
    Centroides(i,:)=stats(i).Centroid;
end

hold on
plot(Centroides(:,1),Centroides(:,2),'rx')
hold off
end
