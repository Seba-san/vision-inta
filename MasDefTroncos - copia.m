% Idea de fran: Mejorar la resolucion en los puntos cercanos a un punto
% encontrado con la funcion TroncoDetect. De esta manera reconocer por
% densidad de puntos (o cualquier otro parametro) si es un tronco real o
% no.
clc;clear all;close all
% %### Seteo para el server
% cd 'C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Proyectos\programasMatlab'
% addpath('C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Funciones')
% img_dir= 'D:\Datasets\Salidas_de_Campo_INTA\25Ene2017\prueba9\partidas';
% %### Seteo para el server

%### Seteo para la VAIO
cd 'C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab';
addpath('C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Funciones')
%img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas';
img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas\image';
%img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas';
%### Seteo para la VAIO


%############ PARAMETROS
cellSize = [8 8];
hogFeatureSize = 6336;
Caracteristicas={cellSize hogFeatureSize};
FRAME=300;
Ventana=[140 95];% Alto ancho
Solapamiento=0.95;% 
load('SVMq976.mat') ;% Cargar el clasificador
classifier=SVMq976.ClassificationSVM; % Cargar el algoritmo del clasificador
%load('SVMq95.mat') ;% Cargar el clasificador
%classifier=SVMq95.ClassificationSVM; % Cargar el algoritmo del clasificador

%#################
%ImageStore=imageDatastore(img_dir); % creando el Dataset
% Leo una imagen del dataset 
%I1=readimage(ImageStore,FRAME);
I1 = imread(sprintf('%s%1di.jpg',img_dir,FRAME));
%Extraigo los centros positivos
Centros=TroncoDetect(I1,classifier,Ventana,Solapamiento,Caracteristicas);
%L=find(Centros(:,4)>0.4);
%#######
%Muestro
% figure(1)
% imshow(I1)
% Rojo=[1 0 0]; Rojohsv=rgb2hsv(Rojo); % La idea es mostrar con un color mas "saturado" cuando los puntos tengan un puntaje mas alto.
% Centros(:,4)=Centros(:,4)/max(Centros(:,4));
%  for i=1:numel(Centros(:,1))
% hold on
% %plot(Centros(:,1),Centros(:,2),'rx');
% Color=Rojohsv;Color(2)=Centros(i,4);Color=hsv2rgb(Color);
% plot(Centros(i,1),Centros(i,2),'x','color',Color)
% %plot(Centros2(:,1),Centros2(:,2),'x', 'color',[Centros2(:,4) 0 0])      
% % text(double(Centros(i,1)),double(Centros(i,2)),num2str(Centros(i,4)),'Color','red')
%  end
% hold off
%#######
[Troncos]=Centroides(Centros);
% figure(2)
% imshow(I1)
% hold on
% plot(Troncos(:,1),Troncos(:,2),'rx')
% hold off
Ventana=[50 50];
% RGB = insertShape(I1,'Rectangle',[Troncos(1,:)-Ventana(1)/2 Ventana]);
% imshow(RGB)

K=1;
Region=round([Troncos(K,1)-Ventana(1)/2 Troncos(K,2)-Ventana(2)/2 Ventana(1) Ventana(2)]);
Ii=imcrop(I1,Region);
BW = edge(rgb2gray(Ii),'Canny',0.7); % Para mejorar la obtencion de puntos de borde, utilizar otro umbral o metodo. actualmente Canny 0.7
[j,k]=find(BW); % Busco los unos de la imagen (Los uso como puntos a seguir)  
Traquear=[k+Region(1),j+Region(2)];
% Traquear=[j+Region(2),k+Region(1)]; % Puntos a traquear
% imshow(I1)
% hold on
% plot(Traquear(:,2),Traquear(:,1),'rx')
% hold off
% 
%### Traqueo
%Create a tracker object.
tracker = vision.PointTracker('MaxBidirectionalError',1);
%Initialize the tracker.
initialize(tracker,Traquear,I1);
%Read, track, display points, and results in each video frame.

h = fspecial('disk', 3); % Genero una circunferencia 
LL=size(h);S=size(I1);FiltroGrande=zeros(S(1),S(2));

for FRAME=300:1:350
    I1a=imread(sprintf('%s%1dd.jpg',img_dir,FRAME));
    I2a=imread(sprintf('%s%1di.jpg',img_dir,FRAME));
    [I,a,outliers]=FunProf(I1a,I2a);
    %frame = step(videoFileReader);
    [points, validity] = step(tracker,I2a);
    out = insertMarker(I2a,points(validity, :),'+');
    x=round(mean(round(points(validity, 2))));
    y=round(mean(round(points(validity, 1))));
    FiltroGrande(x-(LL(1)-1)/2:(x+(LL(1)-1)/2),y-(LL(2)-1)/2:(y+(LL(2)-1)/2))=h;
    aa=I.*FiltroGrande; dd=isnan(aa);kk=isinf(aa);rr=dd|kk;
    Distancia=sum(sum(aa(~rr)))
    
    %      Distancias=I(round(points(validity, 2)),round(points(validity, 1)));
    %      Infi=isinf(Distancias);
    %      mean(Distancias(~Infi))
   
%     figure(1)
%     imshow(out)
%     hold on
%     plot(y,x,'rx','LineWidth',2)
%     hold off
%     
    
    figure (2);imagesc(I,[3000 7000]);colormap jet;colorbar;
    hold on
    plot(y,x,'rx')
    hold off
      pause()
end

I(x,y)
I(y,x)
% x=round(mean(round(points(validity, 2))));
% y=round(mean(round(points(validity, 1))));
% Distancia=I(x,y)
% 
% figure (1);imagesc(I,[3000 7000]);colormap jet;colorbar;
% hold on
% plot(points(validity, 1),points(validity, 2),'gx')
% hold off
%     title('Mapa de distancias "I"')
% 

%%
for FRAME=300:2:350
    FRAME
    frame=readimage(ImageStore,FRAME);
      imshow(frame)
     pause()
end
%#####




%%
  %  En esta seccion  se aumenta la definicion de los puntos encontrados
    %  anteriormente
% #####################################
Total=numel(Centros(:,1));
for Indi=1:Total
    if 0~=Centros(Indi,1)
        Objetivo=round([Centros(Indi,1) Centros(Indi,2)]);
        % figure(2)
        % imshow(I1)
        % hold on
        % plot(Objetivo(1),Objetivo(2),'rx')
        % hold off
        % Solapamiento2=Ventana*Solapamiento; % Cambio el formato del solapamiento
        % [bbox]=FunPira(I1,Ventana,Solapamiento2);
        % [indice,err]=Buscbbox(round(Objetivo),bbox,Ventana);
        %Considero una region al rededor del punto equivalente a 4 ventanas.
        NuevaVentana=[Objetivo(1)-Ventana(2) Objetivo(2)-Ventana(1) 2*Ventana(2) 2*Ventana(1)];
        Ic=imcrop(I1,NuevaVentana);
        % Solapamiento a 1 pixel
        Solapamiento3=(min(Ventana)-1)/min(Ventana);
        Centros2=TroncoDetect(Ic,classifier,Ventana,Solapamiento3,Caracteristicas);        
        % ##### Muestro
        figure(2)
        imshow(Ic)
        hold on
        plot(Centros2(:,1),Centros2(:,2),'rx')
        hold off
        % ##### Muestro
  
        for i=1:Total
            Dis=((Centros2(:,1)+Objetivo(1)-Ventana(2)-Centros(i,1)).^2 ...
            +(Centros2(:,2)+Objetivo(2)-Ventana(1)-Centros(i,2)).^2).^0.5;
            %K=find(Dis<2);
            if find(Dis<20)
                Centros(i,:)=0;
                i
            end
        end
        numel(Centros2(:,1))
        figure(1)
        hold on
        if numel(Centros2(:,1))>700
            disp('Tronco')
            plot(Centros2(:,1)+Objetivo(1)-Ventana(2),Centros2(:,2)+Objetivo(2)-Ventana(1),'rx')
        else
            disp('Falso Positivo')
            plot(Centros2(:,1)+Objetivo(1)-Ventana(2),Centros2(:,2)+Objetivo(2)-Ventana(1),'bo')
        end
        hold off
    end
    pause(1)
end



%%

%#### Mostrar caja
RGB = insertShape(I1,'Rectangle',bbox(indice,1:4));
imshow(RGB)
%####

