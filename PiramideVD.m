% Este codigo funciona Correctamente 

cd 'C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab' ;
img_dir      = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas\image';
%img_dir      = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas\image';
%Cand_dir     = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\Candidatas\';
Neg_dir     = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\Entrenamiento_segundo\Negativas\';
Pos_dir     = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\Entrenamiento_segundo\Positivas\';
viewId=100;
I1 = imread(sprintf('%s%1dd.jpg',img_dir,viewId));
imshow(I1)
Ventana=[140 95];% Alto ancho
Solapamiento=[70 10];% en vertical, en horizontal
S=size(I1);
EscMin=1/(min(S(1)/Ventana(1),S(2)/Ventana(2))); % Escala minima
I=I1;
i=1;
%detector = vision.CascadeObjectDetector('postesdetector.xml');
%load('Clasificadores.mat');classifier=trainedClassifier1.ClassificationKNN;
load('CosKnn886.mat');classifier=CosKnn886.ClassificationKNN;

cellSize = [8 8];hogFeatureSize = 6336;
score=zeros(200,2);
for escala=1:-0.2:EscMin
    I = imresize(I,escala);
    S=size(I);
    % Ventana deslizante
    for y=1:Ventana(1)-Solapamiento(1):S(1)-Ventana(1) %Le resto una ventana para que no quede fuera de la imagen
        for x=1:Ventana(2)-Solapamiento(2):S(2)-Ventana(2)
            bbox=[x y Ventana(2) Ventana(1)];
            Ic = imcrop(I,bbox);
            Ic2=rgb2hsv(Ic);Ic3=1-Ic2(:,:,3);
            %Ic=(Ic(:,:,2)-0.39*Ic(:,:,1)-0.61*Ic(:,:,3));
            [testFeatures]= extractHOGFeatures(Ic3, 'CellSize', cellSize);
            [predictedLabels, score(i,:)] = predict(classifier, testFeatures);
           % bbox2 = step(detector,Ic);
           % if size(bbox2)>0
           if score(i,2)>0.2
               imwrite(Ic,sprintf('%s%d%d.jpg',Pos_dir,viewId,i))
            else
                imwrite(Ic,sprintf('%s%d%d.jpg',Neg_dir,viewId,i))
            end
            %imwrite(Ic,sprintf('%s%d.jpg',Cand_dir,i))
             %Im= insertObjectAnnotation(I,'rectangle',bbox,'ventana');
           % imshow(Im)
           %pause(2)
           i=i+1;
        end
    end
   % close all
end
disp('Listo')
%score
%para quitar los warnings:
% w = warning('query','last');
% id=w.identifier;
% warning('off',id)
% rmpath('folderthatisnotonpath')
% 
% % Para volverlo a activar
% warning('on',id)
% rmpath('folderthatisnotonpath')
% warning('on','all')

%% Pruebo el clasificador sobre el dataset
dir='C:\Users\seba\Dropbox\Filtradas_manual\Positivas';
load('CosKnn886.mat');classifier=CosKnn886.ClassificationKNN;
Set=imageDatastore(dir);
Cantidad=numel(Set_img.Files);
score=zeros(Cantidad,2);
predictedLabels=zeros(Cantidad,1);
for i=1:Cantidad
img = readimage(Set,i);
I=rgb2hsv(img);
[Features] = extractHOGFeatures(1-I(:,:,3), 'CellSize', [8 8]);
[predictedLabels(i), score(i,:)] = predict(classifier, Features);
I2=imbinarize(1-I(:,:,3));
imshow(I2)
pause()
            
end
