function [Traquear]=GenPunTk(Troncos,I1,IMAGENES,umbral,Ventana)
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
if nargin<5
   Ventana=[50 50];
end

D=size(Troncos); %Traquear=zeros(D(1),2,250);

for i=1:D(1)
    
    Region=round([Troncos(i,1)-Ventana(1)/2 Troncos(i,2)-Ventana(2)/2 Ventana(1) Ventana(2)]);
    Ii=imcrop(I1,Region);
     BW = edge(rgb2gray(Ii),'Canny',umbral); % Para mejorar la obtencion de puntos de borde, utilizar otro umbral o metodo. actualmente Canny 0.7
   %[ BW,visualization,ptvis] = extractHOGFeatures(Ii);
%     BW = detectBRISKFeatures(rgb2gray(Ii));
    %BW = detectMSERFeatures(rgb2gray(Ii));
%     BW= detectMinEigenFeatures(rgb2gray(Ii));
[j,k]=find(BW); % Busco los unos de la imagen (Los uso como puntos a seguir)
Traquear{i}=[k+Region(1),j+Region(2)];
%     Traquear(i,:,1:numel(k))=[k+Region(1),j+Region(2)]';
      ram=1;
    while isempty(Traquear{i}) || numel(j)<100 % Se agrega esto porque hay casos en los que no funciona bien con el umbral tan alto
        umbral=0.7-ram*0.001;
         Region=round([Troncos(i,1)-Ventana(1)/2 Troncos(i,2)-Ventana(2)/2 Ventana(1) Ventana(2)]);
    Ii=imcrop(I1,Region);
    BW = edge(rgb2gray(Ii),'Canny',umbral); % Para mejorar la obtencion de puntos de borde, utilizar otro umbral o metodo. actualmente Canny 0.7
    [j,k]=find(BW); % Busco los unos de la imagen (Los uso como puntos a seguir)
    %Traquear(i,:,1:numel(k))=[k+Region(1),j+Region(2)]';
    Traquear{i}=[k+Region(1),j+Region(2)];        
        ram=ram+1;
    end
%     
% ok=1;k=1;cc=(size(Ii,1)-1)/2;
% while ok==1    
%     mm=find(BW.Orientation==min(BW.Orientation));
%     if isempty(mm)
%         k=k+1;
%     else
%         size(BW.PixelList{k})       
%     end
% end
%      Traquear{i}=[BW.PixelList{k}(:,1)+Region(1),BW.PixelList{k}(:,2)+Region(2)];
%  
    if IMAGENES==1
        figure(1)
%         imshow(Ii)
%         hold on
%         plot(BW.Location,'g+')
%  plot(BW.Location)
%         hold off
%         figure(2)
%         for k=1:80
%         imshow(Ii); hold on;
% % plot(BW,'showPixelList',true,'showEllipses',false);
% % plot(BW.PixelList{mm}(:,1),BW.PixelList{mm}(:,2),'g+');hold off
% plot(BW.Location(:,1),BW.Location(:,2),'g+');hold off
% 
%         pause(0.5)
%         end
%         figure(2)
         out = insertMarker(I1,Traquear{i},'+');
         imshow(out)
%          figure(3)
%          imshow(BW)
%          imshow(visualization)
         pause()
    end
end
end
