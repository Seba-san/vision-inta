% Testeando clasificador, Generador de imagen de proabilidades

clc;clear all;close all
cd 'C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab';
%addpath('C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Funciones')
%img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas';
img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas'
%############ PARAMETROS
cellSize = [8 8];
hogFeatureSize = 6336;
FRAME=540;
Ventana=[140 95];% Alto ancho
Solapamiento=[130 90];% en vertical, en horizontal
load('SVMq976.mat') ;% Cargar el clasificador
classifier=SVMq976.ClassificationSVM; % Cargar el algoritmo del clasificador
%#################
ImageStore=imageDatastore(img_dir); % creando el Dataset
% Leo una imagen del dataset 
I1=readimage(ImageStore,FRAME);
[bbox]=FunPira(I1,Ventana,Solapamiento); % Genero todas las escalas y las regiones a recortar en un vector bbox(i,:)=[x y Ventana(2) Ventana(1) escala];
numImages = numel(bbox(:,1));
trainingFeatures = zeros(numImages, hogFeatureSize, 'single');
tic
ta=0;
h = waitbar(0,'Please wait...');
for i=1:numImages
 I = imresize(I1,bbox(i,5));   % Escalo la muestra
 Ic = imcrop(I,bbox(i,1:4)); % La corto
[trainingFeatures(i, :)] = extractHOGFeatures(Ic, 'CellSize', cellSize); % extraigo los paramentros
t=toc;
waitbar(i / numImages,h,sprintf('%d%s%d%s',round(100*i/numImages),'% | faltan aprox ',round(t*numImages/i -t),'s'))
end
delete(h)
disp('Listo')
[predictedLabels, score] = predict(classifier, trainingFeatures);


for Escala=1:-0.2:0.2
k=find(predictedLabels=='Positivas'& bbox(:,5)==Escala);

%Insert bounding box rectangles and return the marked image.
% for i=1:size(k,1)
%  detectedImg = insertObjectAnnotation(I1,'rectangle',bbox(k(i),1:4),'Tronco');
% imshow(detectedImg)
% pause(1)
% end
I = imresize(I1,Escala); 
figure(1)
imshow(I)
hold on
Centros=[bbox(k,1)+Ventana(2)/2 , bbox(k,2)+Ventana(1)/2];
plot(Centros(:,1),Centros(:,2),'rx')
hold off
pause
close 1
end

% % Lo anterior no funciona
% %k2=find(bbox(:,5)==0.8,1);
% imshow(I1)
% caja=[bbox(k(20),1), bbox(k(20),2), bbox(k(20),3), bbox(k(20),4)];
% rectangle('Position',caja)
% I2=shapeInserter(I1, rectangle);
% 
% 
% % No funciona como lo esperaba
% S=size(I1);
%  Img_Prob=zeros(S(1),S(2));
%  k=find(bbox(:,5)==0.8,1);
% % Img_Prob(bbox(k,1),bbox(k,2))=255;
% for i=1:k
% Img_Prob(bbox(i,2),bbox(i,1))=score(i,1);
% end
% imagesc(Img_Prob,[-2 2]);colorbar
% imshow(Img_Prob)
% 
% 
%% FUNCIONA, es lo mismo que esta copiado al final de TroncoDetect
clc;clear all;close all
cd 'C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab';
addpath('C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Funciones')
%img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas';
img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas';
%############ PARAMETROS
cellSize = [8 8];
hogFeatureSize = 6336;
Caracteristicas={cellSize hogFeatureSize};
FRAME=540;
Ventana=[140 95];% Alto ancho
Solapamiento=0.9;% 
load('SVMq976.mat') ;% Cargar el clasificador
classifier=SVMq976.ClassificationSVM; % Cargar el algoritmo del clasificador
%#################
ImageStore=imageDatastore(img_dir); % creando el Dataset
% Leo una imagen del dataset 
I1=readimage(ImageStore,FRAME);
%imshow(I1)
 %I = imcrop(I1,[634 345  646 423 ]);
 %imshow(I)
Centros=TroncoDetect(I1,classifier,Ventana,Solapamiento,Caracteristicas);
figure(1)
imshow(I1)
hold on
plot(Centros(:,1),Centros(:,2),'rx')
hold off

%%
S=size(I);nbinsx=round(S(2)/20);nbinsy=3;
figure(2);histogram(Centros(:,2),nbinsy)
b=histogram(Centros(:,2),nbinsy);[k,kk]=sort(b.Values,'descend');Cy=kk(1:3)*b.BinWidth;
figure(3);histogram(Centros(:,1),nbinsx)
b=histogram(Centros(:,1),nbinsx); [k,kk]=sort(b.Values,'descend');Cx=kk(1:3)*b.BinWidth+b.BinLimits(1);
figure(3)
imshow(I)
hold on
plot(Cx,Cy,'rx')
hold off


[k1,kk1]=sort(Da.Values,1,'descend');
[k2,kk2]=sort(Da.Values,2,'descend');

%a(1)*Da.BinWidth(1)+Da.XBinEdges(1)

figure(2)
S=size(I);nbinsx=round(S(2)/20);nbinsy=3;
Da=histogram2(Centros(:,1),Centros(:,2),'BinWidth',[20 S(1)/5]);
[a,b]=find(Da.Values>3);
figure(1)
imshow(I)
hold on
plot(Da.XBinEdges(a),Da.YBinEdges(b),'rx')
hold off






[k1,kk1]=sort(Da.Values,1,'descend');Cy=kk1(1,1)*Da.BinWidth(2)+Da.YBinEdges(1)
[k2,kk2]=sort(Da.Values,2,'descend');


