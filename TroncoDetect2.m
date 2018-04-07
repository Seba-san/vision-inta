function Centros=TroncoDetect(I,classifier,Ventana,Solapamiento,Caracteristicas,IMAGENES)
% I imagen; Classifier es el clasificador, Ventana es la ventana y
% Solapamiento es un numero del 0 al 1 que representa la proporcion del
% solapamiento entre ventanas. Caracteristicas es Caracteristicas={cellSize
% hogFeatureSize} En un futuro esto seguro que cambiara.
if nargin<6
    IMAGENES=0;
end
cellSize=Caracteristicas{1};
hogFeatureSize=Caracteristicas{2};
Solapamiento2=round(Ventana*Solapamiento);
[bbox]=FunPira(I,Ventana,Solapamiento2,0);
numImages = numel(bbox(:,1));
trainingFeatures = zeros(numImages, hogFeatureSize, 'single');
tic
ta=0;
%h = waitbar(0,'Please wait...');
for i=1:numImages
    %Ii = imresize(I,bbox(i,5));   % Escalo la muestra
    Ic = imcrop(I,bbox(i,1:4)); % La corto
   % Ic=rgb2hsv(Ic);
    %I11=(1-Ic(:,:,3));
    [trainingFeatures(i, :)] = extractHOGFeatures(Ic, 'CellSize', cellSize); % extraigo los paramentros
    t=toc;
    if t>ta+10
        disp(sprintf('%d%s%d%s',round(100*i/numImages),'% | faltan aprox ',round(t*numImages/i -t),'s'))
        ta=t;
        %waitbar(i / numImages,h,sprintf('%d%s%d%s',round(100*i/numImages),'% | faltan aprox ',round(t*numImages/i -t),'s'))
    end
end
%delete(h)
%disp('Listo')
[predictedLabels, score] = predict(classifier, trainingFeatures);
k=find(predictedLabels=='Positivas'& bbox(:,5)==1); % Solo me quedo con las escalas 1
Centros=[bbox(k,1)+Ventana(2)/2 , bbox(k,2)+Ventana(1)/2, score(k,1),score(k,2)];
if IMAGENES==1
    figure(1)
    imshow(I)
    Rojo=[1 0 0]; Rojohsv=rgb2hsv(Rojo); % La idea es mostrar con un color mas "saturado" cuando los puntos tengan un puntaje mas alto.
    Centros(:,4)=Centros(:,4)/max(Centros(:,4));
    for i=1:numel(Centros(:,1))
        hold on
        %plot(Centros(:,1),Centros(:,2),'rx');
        Color=Rojohsv;Color(2)=Centros(i,4);Color=hsv2rgb(Color);
        plot(Centros(i,1),Centros(i,2),'x','color',Color)
        %plot(Centros2(:,1),Centros2(:,2),'x', 'color',[Centros2(:,4) 0 0])
        % text(double(Centros(i,1)),double(Centros(i,2)),num2str(Centros(i,4)),'Color','red')
    end
    hold off
end

disp('Listo')





end
% % #################  Ejemplo de como se usa:
% clc;clear all;close all
% cd 'C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab';
% addpath('C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Funciones')
% %img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas';
% img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas';
% %############ PARAMETROS
% cellSize = [8 8];
% hogFeatureSize = 6336;
% Caracteristicas={cellSize hogFeatureSize};
% FRAME=540;
% Ventana=[140 95];% Alto ancho
% Solapamiento=0.8;% 
% load('SVMq976.mat') ;% Cargar el clasificador
% classifier=SVMq976.ClassificationSVM; % Cargar el algoritmo del clasificador
% %#################
% ImageStore=imageDatastore(img_dir); % creando el Dataset
% % Leo una imagen del dataset 
% I1=readimage(ImageStore,FRAME);
% Centros=TroncoDetect(I1,classifier,Ventana,Solapamiento,Caracteristicas);
% figure(1)
% imshow(I1)
% hold on
% plot(Centros(:,1),Centros(:,2),'rx')
% hold off
% % #####################################