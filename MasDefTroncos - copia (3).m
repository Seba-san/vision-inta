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

I1 = imread(sprintf('%s%1di.jpg',img_dir,FRAME));
%Extraigo los centros positivos, TARDA UNA BOCHA
Centros=TroncoDetect(I1,classifier,Ventana,Solapamiento,Caracteristicas);
%##########
[Troncos]=Centroides(Centros);
[Traquear]=GenPunTk(Troncos,I1);
%### Traqueo
% Creo tantos trackers como troncos encontrados
Ds=size(Traquear);
tracker = vision.PointTracker('MaxBidirectionalError',1);
for q=1:Ds(2)
trackers{q}=clone(tracker);
%Initialize the tracker.
initialize(trackers{q},Traquear{q},I1);
end
%Read, track, display points, and results in each video frame.

h = fspecial('disk', 5); % Esta es la mascara con la que se promedia
%h = fspecial('gaussian', [10 3], [0.9 0.5]) % La idea es seleccionar una mascara
%no cuadrada
LL=size(h);S=size(I1);FiltroGrande=zeros(S(1),S(2));
i=1;
Distancia=zeros(50,Ds(2));
for FRAME=300:1:350
    I1a=imread(sprintf('%s%1dd.jpg',img_dir,FRAME));
    I2a=imread(sprintf('%s%1di.jpg',img_dir,FRAME));
    [I,a,outliers]=FunProf(I1a,I2a);
    %frame = step(videoFileReader);
    for q=1:Ds(2)
        [points, validity] = step(trackers{q},I2a);
        %  out = insertMarker(I2a,points(validity, :),'+');
        x=round(mean(round(points(validity, 2))));
        y=round(mean(round(points(validity, 1))));
        FiltroGrande=zeros(S(1),S(2));
        FiltroGrande(x-(LL(1)-1)/2:(x+(LL(1)-1)/2),y-(LL(2)-1)/2:(y+(LL(2)-1)/2))=h;
        aa=I.*FiltroGrande; dd=isnan(aa);kk=isinf(aa);rr=dd|kk;
        Distancia(i,q)=sum(sum(aa(~rr)));
        sum(sum(aa(~rr)))
    end
    i=i+1
    pause()
    
    %considero f=692.964
    %I(x,y)
    %      Distancias=I(round(points(validity, 2)),round(points(validity, 1)));
    %      Infi=isinf(Distancias);
    %      mean(Distancias(~Infi))
    
    %     figure(1)
    %     imshow(out)
    %     hold on
    %     plot(y,x,'rx','LineWidth',2)
    %     hold off
    %
    
    %    imagesc(I,[3000 7000]);colormap jet;colorbar;
    %     hold on
    %     plot(y,x,'rx','LineWidth',2)
    %     hold off
    %imagesc(aa)
    % pause()    
end

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

