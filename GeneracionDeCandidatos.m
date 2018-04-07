cd 'C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab' ; % Carpeta de dropbox

% generacion de candidatos positivos
img_dir      = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas\image';
img_dir2     = 'C:\Users\seba\Dropbox\Facultad\CIN\Dataset\Frontal\image';
viewId = 106;
first_frame = viewId;
last_frame = 106;
prompt = 'Mas? Y/N [Y]: ';
%Posiciones
for viewId=first_frame:last_frame
    disp(['Frame n°: ' num2str(viewId)])
I1 = imread(sprintf('%s%1dd.jpg',img_dir,viewId));
figure(1)
imshow(I1)
Salir=0;
i=1;
PosF=zeros(10,4);
while Salir==0;
    %figure(1)
h = imrect;
position = wait(h);
hold on
rectangle('Position',position,'LineWidth',3,'EdgeColor','r');
hold off
PosF(i,:)=position;
str = input(prompt);
if(str==1)
    Salir=1;
end
i=i+1;
end
PosF

imwrite(IrgbIzq,sprintf('%s%di.jpg',img_dir2,viewId))
% hold on
% X=zeros(2,2);
% for i=1:2
% [x,y] = ginput(1)
% plot(x(1),y(1),'xr')
% X(1,i)=x(1);
% X(2,i)=y(1);
% end
% rectangle('Position',[X(2,1) X(1,1) X(2,2) X(1,2)],'LineWidth',3,'EdgeColor','r');
% hold off
end
%prompt = 'Do you want more? Y/N [Y]: ';
%str = input(prompt)
%if isempty(str)
%    str = 'Y';
%end

I2 = imcrop(I1);%,position);
imshow(I2)
%% FUNCIONA CORRECTAMENTE imagens NEGATIVAS
% imagenes entrenadas:
% 50i 60d 100d 592d 200d
Neg_dir='E:\Facultad\Becas\CIN\TRABAJo\Dataset\Entrenamiento\negativo\image'
% Extractor de imagenes negativas
S=size(NegativeInstances);
%S(2)=1;
for i=1:S(2)
img_dir=NegativeInstances(i).imageFilename;
Cajas=NegativeInstances(i).objectBoundingBoxes;
Sc=size(Cajas);
I=imread(img_dir);
for k=1:Sc(1)
Ic = imcrop(I,Cajas(k,:));
imwrite(Ic,sprintf('%s%d%d.jpg',Neg_dir,i,k));
end
end
%% Guardo las imagenes en el drop
Pos_dir='C:\Users\seba\Dropbox\Facultad\CIN\Dataset\GenCandi\image';
S=size(positiveInstances);
for i=1:S(2)
img_dir=NegativeInstances(i).imageFilename;
I=imread(img_dir);
imwrite(I,sprintf('%s%d.jpg',Pos_dir,i));
end

%%
%addpath('C:\Program Files\MATLAB\MATLAB Production Server\R2015a\mcr\toolbox\matlab\datastoreio');
%Select the bounding boxes for stop signs from the table.
%positiveInstances1 = positiveInstances.objectBoundingBoxes;
%Add the image directory to the MATLAB path.
%imDir ='E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas';
positiveInstances = CasosPositivos(:,1:2);
imDir='D:\Datasets\Salidas_de_Campo_INTA\25Ene2017\prueba9\partidas';
addpath(imDir);
%Specify the foler for negative images.
negativeFolder='C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Dataset\GenCandi\Entrenamiento\negativo';
%negativeFolder='E:\Facultad\Becas\CIN\TRABAJo\Dataset\Entrenamiento\negativo';
%Create an imageDatastore object containing negative images.
negativeImages =imageDatastore(negativeFolder);
%datastore(fullfile(matlabroot, 'toolbox', 'matlab'),...
%'IncludeSubfolders', true,'FileExtensions', '.tif','Type', 'image')
%negativeImages = datastore(negativeFolder,'IncludeSubfolders', true,'FileExtensions', '.jpg','Type', 'image')%,'Type','image');%,'FileExtensions','.jpg');
%Train a cascade object detector called 'stopSignDetector.xml' using HOG features. NOTE: The command can take several minutes to run.
trainCascadeObjectDetector('postesdetector.xml',positiveInstances, ...
    negativeFolder,'FalseAlarmRate',0.1,'NumCascadeStages',10);

%Use the newly trained classifier to detect a stop sign in an image.
detector = vision.CascadeObjectDetector('postesdetector.xml');
%Read the test image.
%img = imread('D:\Datasets\Salidas_de_Campo_INTA\25Ene2017\prueba11\image52.jpg');
img = imread('E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas\image60i.jpg');
%Detect a stop sign.
tic
bbox = step(detector,img);
toc
%Insert bounding box rectangles and return the marked image.
 detectedImg = insertObjectAnnotation(img,'rectangle',bbox,'poste');
%Display the detected stop sign.
figure; imshow(detectedImg);
rmpath(imDir);

%% Busqueda de colores
% La idea de esta parte del algoritmo es levantar una imagen, y anotar los
% colores de los troncos, para que cuando se pase a escala de grises, este
% color sea el que mas resalte. Para lograrlo hay que obtener las
% relaciones entre RGB de los troncos. Hacer una base de R3 y obtener la
% matriz que lleva de B3 a la canonica.

dir_img='E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas';
Set_img=imageDatastore(dir_img);
img = readimage(Set_img,50);
imshow(img)
[x,y] = ginput(4); x=round(x);y=round(y);
a=zeros(4,3);
for i=1:4
    a(i,:)=img(y(i),x(i),:);
end
b=min(a');c=a./b';d=mean(c);
T=[d;1 0 0;0 1 0]';
Tm=(T^-1)';
%
I=img;
I1=img;
%I2=permute(img,[3,1,2]);
%n=min(I2);
%n2=permute(n,[2 3 1]);
%I=(img./n2)*120;
%imshow(I)
I1(:,:,1)=double(I(:,:,1)*Tm(3,1)+I(:,:,2)*Tm(3,2)+I(:,:,2)*Tm(3,3));
I1(:,:,2)=double(I(:,:,2));I1(:,:,3)=double(I(:,:,3));
%imagesc(I1)

imshow(I1)

[featureVector,hogVisualization] = extractHOGFeatures(I,'CellSize',[8 8]);
 figure;
 %imshow(a);
 imagesc(I,[-5 50]); colormap jet
 hold on;
 plot(hogVisualization);
 hold off
J = rangefilt(img(:,:,2));
imshow(J)

%% Aplicacion de paper: "Object Shape Recognition in Image for Machine Vision Application"

%dir_img='E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas';
%dir_img='E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas';
dir_img='C:\Users\seba\Dropbox\Filtradas_manual\Positivas';
Set_img=imageDatastore(dir_img);Cantidad=numel(Set_img.Files);
for i=1:Cantidad
img = readimage(Set_img,i);
% RGB2 HSV
I=rgb2hsv(img);
imshow(I(:,:,1))
pause()
end
%I=permute(img,[3,2,1]);
%L=(max(I)-min(I))/2;
%L=permute(L,[3,2,1]);
%Binarizacion que saque el fondo, con el metodo de  Otsu
%[counts,x] = imhist(L);
%T = otsuthresh(counts);
Bin=imbinarize(L,0.04);
BW2 = imfill(Bin,'holes');
BW = edge(BW2,'Sobel');
imshow(BW)