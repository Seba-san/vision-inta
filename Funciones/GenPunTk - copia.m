function [Traquear]=GenPunTk(Troncos,I1,IMAGENES)
% Generador de puntos para trakeo. En base a los centros, busca los bordes
% en una region definida por ventana (50x50 default) y devuelve todos los
% puntos que son bordes con un umbral (0.7 default) por medio del metodo
% Canny. la Celda Traquear tiene la siguiente forma: Traquear{i}=[k+Region(1),j+Region(2)];
if nargin<3
    IMAGENES=0;
end
if nargin<4
   umbral=0.7;
end
Ventana=[50 50];
D=size(Troncos); %Traquear=zeros(D(1),2,250);

for i=1:D(1)
    
    Region=round([Troncos(i,1)-Ventana(1)/2 Troncos(i,2)-Ventana(2)/2 Ventana(1) Ventana(2)]);
    Ii=imcrop(I1,Region);
%     BW = edge(rgb2gray(Ii),'Canny',umbral); % Para mejorar la obtencion de puntos de borde, utilizar otro umbral o metodo. actualmente Canny 0.7
   %[ BW,visualization,ptvis] = extractHOGFeatures(Ii);
    BW = detectBRISKFeatures(rgb2gray(Ii));
% [j,k]=find(BW); % Busco los unos de la imagen (Los uso como puntos a seguir)
    %Traquear(i,:,1:numel(k))=[k+Region(1),j+Region(2)]';
    Traquear{i}=[BW.Location(:,1)+Region(1),BW.Location(:,2)+Region(2)];
%     ram=1;
%     while isempty(Traquear{1}) % Se agrega esto porque hay casos en los que no funciona bien con el umbral tan alto
%         umbral=0.7-ram*0.001;
%          Region=round([Troncos(i,1)-Ventana(1)/2 Troncos(i,2)-Ventana(2)/2 Ventana(1) Ventana(2)]);
%     Ii=imcrop(I1,Region);
%     BW = edge(rgb2gray(Ii),'Canny',umbral); % Para mejorar la obtencion de puntos de borde, utilizar otro umbral o metodo. actualmente Canny 0.7
%     [j,k]=find(BW); % Busco los unos de la imagen (Los uso como puntos a seguir)
%     %Traquear(i,:,1:numel(k))=[k+Region(1),j+Region(2)]';
%     Traquear{i}=[k+Region(1),j+Region(2)];
%         
%         ram=ram+1;
%     end
%     
    
    
    if IMAGENES==1
        figure(1)
        imshow(Ii)
        hold on
        plot(BW.Location,'g+')
        hold off
%         figure(2)
%          out = insertMarker(I1,Traquear{i},'+');
%          imshow(out)
%          figure(3)
%          imshow(BW)
%          imshow(visualization)
%          pause()
    end
end
end
