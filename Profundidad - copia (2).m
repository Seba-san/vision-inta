
%I1 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\image523d.jpg');
%I2 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\image523i.jpg');

%I1 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\Frontal\image1d.jpg');
%I2 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\Frontal\image1i.jpg');

I1 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\prueba2\image1i.jpg');
I2 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\prueba2\image1d.jpg');
%I1 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\cones\im2.png');
%I2 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\cones\im6.png');
disparityRange = [-6 10];
disparityMap = disparity(rgb2gray(I1),rgb2gray(I2),'BlockSize',15,'DisparityRange',disparityRange,'Method','BlockMatching');
disparityMap1 = disparity(rgb2gray(I1),rgb2gray(I2),'BlockSize',15,'DisparityRange',disparityRange);%,'Method','BlockMatching');

%figure(1)
subplot(2,2,1)
imshow(disparityMap,disparityRange);
title('BlockMatching');
%colormap jet
colormap default
colorbar
%figure(2)
subplot(2,2,2)
imshow(disparityMap1,disparityRange);
title('SemiGlobal');
colormap hot
colorbar
subplot(2,2,3)
imshow(I1)
subplot(2,2,4)
imshow(I2)
%%
disparityMap=disparity(rgb2gray(I1),rgb2gray(I2),'Method','SemiGlobal','BlockSize',9,'DisparityRange',[0 128],'ContrastThreshold',0.5);
disparityMap2=disparity(rgb2gray(I1),rgb2gray(I2),'Method','BlockMatching','BlockSize',9,'DisparityRange',[0 64],'ContrastThreshold',0.5,'TextureThreshold',0.05);

hfiltro=ones(3,3)/10;
filtrada=imfilter(disparityMap2,hfiltro);
figure(1)
imshow(disparityMap2)
figure(2)
imshow(filtrada)


%%
%I1 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\cones\im2.png');
%I2 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\cones\im6.png');
close all
%figure(1)
%imshow(stereoAnaglyph(I1,I2));
%title('Red-cyan composite view of the stereo images');

disparityMap = disparity(rgb2gray(I2),rgb2gray(I1),'BlockSize',21,'Method','BlockMatching');%,'DisparityRange',disparityRange);
%disparityMap = disparity(I1g,I2g,'BlockSize',21,'Method','BlockMatching','DisparityRange',disparityRange);
%max(max(disparityMap))
%min(min(disparityMap>0))
disparityRange = [min(min(disparityMap>0)) max(max(disparityMap))];
figure(2)
imshow(disparityMap,disparityRange);
colormap jet
colorbar
title('BlockMatching');
hfiltro=ones(4,4)/16;
filtrada=imfilter(disparityMap,hfiltro);
%figure(3)
%imshow(filtrada,disparityRange)
%colormap default
%colorbar
%title('filtrada');
%%
figure(1)
imshow(I2(:,:,3))
title('Azul')
figure(2)
imshow(I2(:,:,2))
title('Verde')
figure(3)
imshow(I2(:,:,1))
title('Rojo')

%%
%TGI=V-0.39R-0.61A
%VARI=(V-R)/(V+R-A)
I1 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\image523i.jpg');
I2 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\image523d.jpg');
I1g=(I1(:,:,2)-0.39*I1(:,:,1)-0.61*I1(:,:,3));
I2g=(I2(:,:,2)-0.39*I2(:,:,1)-0.61*I2(:,:,3));
%BW = imbinarize(I1g,'adaptive');
imshow(stereoAnaglyph(I1g,I2g));
figure(1)
imagesc(I1g)
figure(2)
imagesc(I2g)
bw1=edge(I1g,'Canny'); %Sobel, Prewitt, Roberts,Canny,log
bw2=edge(I2g,'Canny'); %Sobel, Prewitt, Roberts,Canny,log
%imagesc(bw)
imshowpair(I1,disparityMap,'montage')
colormap jet
colorbar
%filtrada=imfilter(I1g,hfiltro);
%figure(3)
%imagesc(filtrada)
[G1,Gdir] = imgradient(I1g,'prewitt');
imshow(G1)
%%  Funcioan correctamente
hfiltro=ones(3,3)/9; 

viewId = 100;
first_frame = viewId;
last_frame = 800;
img_dir      = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas\image';
for viewId=first_frame:last_frame
    disp(['Frame n°: ' num2str(viewId)])
I1 = imread(sprintf('%s%1dd.jpg',img_dir,viewId));
I2 = imread(sprintf('%s%1di.jpg',img_dir,viewId));
%I1 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\prueba2\image1i.jpg');
%I2 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\prueba2\image1d.jpg');
%21
disparityMap = disparity(rgb2gray(I2),rgb2gray(I1),'BlockSize',5,'Method','BlockMatching');%,'DisparityRange',disparityRange);
disparityRange = [min(min(disparityMap>0)) max(max(disparityMap))];
% Hay puntos muy negativos, no se como eliminarlos, por lo que lo hago
% manualmente, despues vere que opciones hay en opencv.



for k=1:S(1)
    for j=1:S(2)
        if (disparityMap(k,j)<0) 
            disparityMap(k,j)=0; end
    end
end
I=disparityMap;
imshow(disparityMap,[0 60]);
colormap jet
%[ina,inb]=find(disparityMap<0);
%I=zeros(S(1),S(2));
%disparityMap(ina,inb)=0;
%imshow(I)
I=imfilter(disparityMap,hfiltro);
imshow(I,[15 40])
colormap jet
% Detectando que es y que no es Suelo

% Supongo que la camara esta centrada, por lo que en el medio no hay
% obstaculos, solo esta el suelo. De aqui tomo la altura del suelo. La
% siguiente figura muestra la curva  Y[pixeles] vs distancia [adimenicional]

%I=disparityMap
S=size(disparityMap);C=[S(1)/2 S(2)/2]; % Cargo la matriz de disparidad en una variable mas corta 
II2=I(S(1)/2:S(1),S(2)/2);x=1:1:S(1)/2+1; % solo me fijo en la mitad inferior de la columna central
outliers = excludedata(x',II2,'range',[0 60]); % saco los outliers (valores muy negativos o muy positivos)
F = fit(x(~outliers)',double(II2(~outliers)),'poly1'); %NO se porque da una recta, pero interpolo con una recta 
% Todo lo que tenga una distancia Inferior a la de la recta se considera
% como un obstaculo. 
a=zeros(S(1),S(2));
for i=S(1):-1:1
a(i,:)=I(i,:)-(F.p1*(i-S(1)/2)+F.p2); % Le sumo 2 ya que la recta ajustada (o fiteada) no ajusta perfectamente
end
figure(1)
imshow(a,[-5 10])
colormap jet
%imshowpair(I1,a,'montage')
%figure(1)
%imshow(a)
%colormap jet
%colorbar
%figure(2)
%imshow(am)
%colormap jet
%colorbar
%pause(1)
%am=a;
end
% Ahora que ya se detecto el suelo bien, resta obtener el punto de fuga...
b=a>0.5;
c=a<2;
aa=b&c;
imshow(aa)
[k,i]=find(aa==1);
pts=[k,i]';iterNum=1e+3;thDist=15;thInlrRatio=0.05;
[ t,r ] = ransac( pts,iterNum,thDist,thInlrRatio );
k1 = -tan(t);
b1 = r/cos(t);
hold on
plot(S(2)-k1*k-b1,k,'r')
hold off
%RHO = sin(theta)*k+cos(theta)*i;

%	Calculate the square error of the fit
BW2 = bwareaopen(aa,25,4);
imshow(BW2)
stats = regionprops(aa,'BoundingBox');
stats = regionprops(aa,'Centroid');
Centroids = cat(1, stats.BoundingBox);
imshow(aa)
hold on
plot(Centroids(:,1),Centroids(:,2),'xr')
hold off

%end

%% Curva de regrecion vs puntos de la imagen
II2=I(450:S(1),S(2)/2);x=450:S(1);%II2=I(S(1)/2:S(1),S(2)/2);x=S(1)/2:S(1);
plot(x,II2,'xr')
hold on
outliers = excludedata(x',II2,'range',[10 60]); % saco los outliers (valores muy negativos o muy positivos)
plot(x(~outliers),II2(~outliers),'xb')
pts=[x(~outliers)',II2(~outliers)]';iterNum=1e+3;thDist=5;thInlrRatio=0.05;
[ t,r ] = ransac( pts,iterNum,thDist,thInlrRatio );
k1 = -tan(t);
b1 = r/cos(t);

plot(x,k1*x+b1,'r')
hold off

%F = fit(x(~outliers)',double(II2(~outliers)),'poly1');
%Y=(F.p1*(x-S(1)/2)+F.p2);
%plot(x,Y,'xb')
%hold off
%%
disparityRange = [min(min(disparityMap>0)) max(max(disparityMap))];
x2=[1:1:S()];
outliers = excludedata(x2',I,'range',disparityRange);
imshow(I(~outliers))
colormap jet
colorbar

figure(1)
imshow(a,[-1 10])
colormap jet
figure(2)
imshow(I1)
imshow(I,disparityRange);
colormap jet
colorbar
A=zeros(S(1),S(2),3);
A(:,:,1)=a;A(:,:,2)=a;A(:,:,3)=a;
imshow(stereoAnaglyph(A,I1));
hist3(I(:,:))

