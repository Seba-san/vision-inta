% No usar cosas muy oscuras o muy claras. Filtrar previamente con un pasa bajos cada
% imagen.



%I1 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\image523d.jpg');
%I2 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\image523i.jpg');

%I1 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\Frontal\image1d.jpg');
%I2 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\Frontal\image1i.jpg');

I1 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\prueba2\image1i.jpg');
I2 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\prueba2\image1d.jpg');
%I1 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\cones\im2.png');
%I2 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\cones\im6.png');


%%
%TGI=V-0.39R-0.61A
%VARI=(V-R)/(V+R-A)
%I1 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\image523i.jpg');
%I2 = imread('C:\Users\seba\Dropbox\Facultad\CIN\Dataset\image523d.jpg');
I1 = imread('D:\Datasets\Salidas_de_Campo_INTA\25Ene2017\prueba9\partidas\image50i.jpg');
I2 = imread('D:\Datasets\Salidas_de_Campo_INTA\25Ene2017\prueba9\partidas\\image50d.jpg');
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
cd 'C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab' ; % Seteo la carpeta de dropbox
hfiltro=ones(3,3)/9;  % Cargo un filtro Pb
H = fspecial('disk',5);% Cargo un filtro Pb

viewId = 106;
first_frame = viewId;
last_frame = 106;
img_dir      = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas\image';
%img_dir      = 'D:\Datasets\Salidas_de_Campo_INTA\25Ene2017\prueba9\partidas\image';
%img_dir2     = 'D:\Datasets\Salidas_de_Campo_INTA\25Ene2017\prueba9\partidas\disparidad\image';
%Fuga=zeros(2,last_frame-viewId);
for viewId=first_frame:last_frame
    disp(['Frame n°: ' num2str(viewId)])
I1 = imread(sprintf('%s%1dd.jpg',img_dir,viewId));
I2 = imread(sprintf('%s%1di.jpg',img_dir,viewId));
%21
%disparityMap = disparity(rgb2gray(I2),rgb2gray(I1),'BlockSize',15,'Method','BlockMatching');%,'DisparityRange',disparityRange);
I = disparity(rgb2gray(I2),rgb2gray(I1),'BlockSize',5,'DistanceThreshold',40);%,'Method','BlockMatching');%,'DisparityRange',disparityRange);
S=size(I);
%disparityRange = [min(min(disparityMap>0)) max(max(disparityMap))];
% Hay puntos muy negativos, no se como eliminarlos, por lo que lo hago
% manualmente, despues vere que opciones hay en opencv.
for k=1:S(1)
    for j=1:S(2)
        if (I(k,j)<0) 
            I(k,j)=0; end
    end
end
%I=disparityMap;
%figure (1)
%I = imgaussfilt(disparityMap,2); %Filtrado FILTRAR ANTES LAS IMAGENES
%I=imfilter(disparityMap,H);
%imshow(I,[-5 60]);
%colormap jet
%  #######   Detectando que es y que no es Suelo
% Supongo que la camara esta centrada, por lo que en el medio no hay
% obstaculos, solo esta el suelo. De aqui tomo la altura del suelo. La
% siguiente figura muestra la curva  Y[pixeles] vs distancia [adimenicional]
C=[S(1)/2 S(2)/2]; % Cargo la matriz de disparidad en una variable mas corta 
II2=I(450:S(1),S(2)/2);x=450:S(1); % solo me fijo en la mitad inferior de la columna central
outliers = excludedata(x',II2,'range',[10 60]); % saco los outliers (valores muy negativos o muy positivos)
% Dado que hay un gran porcentaje de outliers, en vez de usar "fit" uso
% ransac;  %NO se porque da una recta, pero interpolo con una recta
pts=[x(~outliers)',II2(~outliers)]';iterNum=1e+3;thDist=5;thInlrRatio=0.3;
[ t,r ] = ransac( pts,iterNum,thDist,thInlrRatio );  % Da la inclinacion (t) y la distancia del centro (r)
% Todo lo que tenga una distancia Inferior a la de la recta se considera
% como un obstaculo. 
aa = -tan(t); % Recupero la pendiente
b = r/cos(t); %ordenada al origen
a=zeros(S(1),S(2));
for i=S(1):-1:1
a(i,:)=I(i,:)-(aa*i+b); % Le sumo 2 ya que la recta ajustada (o fiteada) no ajusta perfectamente
end
%a(1:S(1)/4,:)=I(1:S(1)/4,:);
 % ######### Gran parte de la presicion del metodo depende de la anterior
 % seccion de codigo.
%figure(1)
%-5 8
%imshow(a,[-5 50]);
%colormap jet
%imshowpair(I1,a,'montage')

% Ahora que ya se detecto el suelo bien, resta obtener el punto de fuga...
%b=a(S(1)*1/2:S(1),:)>20;% alturas mayores a 1
%c=a(S(1)*1/2:S(1),:)<30;
%aa=b&c;
b=a>1;% alturas mayores a 1
c=a<2;
aa=b&c;
%imshow(aa)
aa(1:300,:)=0;
[k,i]=find(aa==1); % Uso el find para obtener una lista de los puntos
pts=[k,i]';iterNum=1e+3;thDist=15;thInlrRatio=0.10;
[ t,r ] = ransac( pts,iterNum,thDist,thInlrRatio );
k1 = -tan(t); b1 = r/cos(t);
if (k1==0 || b1==0)
    disp('RANSAC 1 error')
end
%figure(1)
%mostrarSAC(pts,k1,b1);
%RHO = sin(theta)*k+cos(theta)*i;
% Una vez determinada la primer recta, hay que sacar los inliers y obtener la 2da
distancia=(k1*pts(1,:)-pts(2,:)+b1)/((k1^2+1))^(0.5);
outs=find(abs(distancia)>30);
pts=[k(outs),i(outs)]';iterNum=1e+3;thDist=15;thInlrRatio=0.1; %proporcion de inliers 
[ t,r ] = ransac( pts,iterNum,thDist,thInlrRatio );
k2 = -tan(t); b2 = r/cos(t);
if (k2==0 || b2==0)
    disp('RANSAC 2 error')
end
%figure(1)
%mostrarSAC(pts,k2,b2);
% con las 2 rectas obtengo las coordenadas de la interseccion
Fx=round((b1-b2)/(k2-k1));Fy=round(k1*Fx+b1);
%Fuga(:,viewId)=[Fy Fx];
%imwrite(a,sprintf('%s%ddisp.jpg',img_dir2,viewId))
%h=figure(2);
%imshow(I2)
%hold on
%plot(Fy,Fx,'xr','LineWidth',2) % Tengo que sumar S(1)*1/4 ya que antes recorte la imagen (en S(1)*1/4)
%hold off
%pause(2)
%savefig(h,sprintf('%s%ddisp.fig',img_dir2,viewId))

end
%save ('Fuga.mat','Fuga')
%% Curva de regrecion vs puntos de la imagen punto de fuga
II2=I(450:S(1),S(2)/2);x=450:S(1);%II2=I(S(1)/2:S(1),S(2)/2);x=S(1)/2:S(1);
plot(x,II2,'xr')
hold on
outliers = excludedata(x',II2,'range',[10 60]); % saco los outliers (valores muy negativos o muy positivos)
plot(x(~outliers),II2(~outliers),'xb')
pts=[x(~outliers)',II2(~outliers)]';iterNum=1e+3;thDist=5;thInlrRatio=0.3;
[ t,r ] = ransac( pts,iterNum,thDist,thInlrRatio ); %RHO = sin(THETA)*x+cos(THETA)*y.
a = -tan(t);
b = r/cos(t);
plot(x,a*x+b,'r')
hold off
% ### Calculo de inliers
k1=k2; b1=b2;

plot(pts(1,:),pts(2,:),'x')
hold on
plot(k,k1*k+b1,'r')
distancia=(k1*pts(1,:)-pts(2,:)+b1)/((k1^2+1))^(0.5);
aver=find(abs(distancia)>30);
plot(pts(1,aver),pts(2,aver),'rx');
hold off
plot(Fx,Fy,'or')




theta = atan(-a);
n = [cos(theta),-sin(theta)];
pt1 = [0;b];
err = (n*(pts-repmat(pt1,1,size(pts,2)))).^2;


%F = fit(x(~outliers)',double(II2(~outliers)),'poly1');
%Y=(F.p1*(x-S(1)/2)+F.p2);
%plot(x,Y,'xb')
%hold off
%%
[k,i]=find(aa(S(1)/2:S(1),1:S(2))==1);
pts=[i,k]';iterNum=1e+3;thDist=15;thInlrRatio=0.05;
[ t,r ] = ransac( pts,iterNum,thDist,thInlrRatio );
k1 = -tan(t);
b1 = r/cos(t);
plot(i,k1*i+b1)
hold on
plot(i,k,'x')
hold off


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
%% Filtrado... ? gaussiano
I=disparityMap;
figure (1)
imshow(disparityMap,[0 60]);
colormap jet
%[ina,inb]=find(disparityMap<0);
%I=zeros(S(1),S(2));
%disparityMap(ina,inb)=0;
%imshow(I)
figure (2)
%I=imfilter(disparityMap,H);
I = imgaussfilt(disparityMap,7);
imshow(I,[0 50])
colormap jet
%%
load('Fuga.mat');
first_frame=50;
last_frame=800;
img_dir     = 'D:\Datasets\Salidas_de_Campo_INTA\25Ene2017\prueba9\partidas\disparidad\image';
viewId=50;
%a = imread(sprintf('%s%1ddisp.jpg',img_dir,viewId));
S=size(a);
for viewId=first_frame:last_frame
    disp(['Frame n°: ' num2str(viewId)])
%a = imread(sprintf('%s%1ddisp.jpg',img_dir,viewId));
openfig(sprintf('%s%1ddisp.fig',img_dir,viewId));
%imshow(a)
%hold on
%plot(Fuga(1,viewId),Fuga(2,viewId)+S(1)*1/4,'xr','LineWidth',2) % Tengo que sumar S(1)*1/4 ya que antes recorte la imagen (en S(1)*1/4)
%hold off
pause(0.2)
end
%%

I = disparity(rgb2gray(I2),rgb2gray(I1),'BlockSize',5,'DistanceThreshold',40);%,'Method','BlockMatching');%,'DisparityRange',disparityRange);
imshow(I,[-5 60])
colormap jet

%%
TT=600*ones(1,S(1)/2);
matchedPoints1=[TT ; I(600,S(1)/2:1:S(1))];
matchedPoints2=[TT,I2(600,S(1)/2:1:S(1))];
tform = estimateGeometricTransform(matchedPoints1,matchedPoints2,'projective');
%% Mapa del terreno
figure(1)
imshow(I,[-5 60])
colormap jet
figure(2)
imshow(a,[-5 60])
colormap jet
max(max(I))
max(max(a))
b=a>1;% alturas mayores a 1
c=a<3;
aa=b&c;
imshow(aa)
Mapa=zeros(S(1),S(2),100);

%% Detectando troncos
%features = extractHOGFeatures(I1);
[featureVector,hogVisualization] = extractHOGFeatures(I1);
figure;
imshow(I1);
hold on;
plot(hogVisualization);
hold off

bw1=edge(rgb2gray(I1),'Canny'); %Sobel, Prewitt, Roberts,Canny,log
figure;imshow(bw1);title('Canny');
bw1=edge(rgb2gray(I1),'Prewitt'); %Sobel, Prewitt, Roberts,Canny,log
figure;imshow(bw1);title('Prewitt');
bw1=edge(rgb2gray(I1),'Roberts'); %Sobel, Prewitt, Roberts,Canny,log
figure;imshow(bw1);title('Roberts');
bw1=edge(rgb2gray(I1),'Sobel'); %Sobel, Prewitt, Roberts,Canny,log
figure;imshow(bw1);title('Sobel');
bw1=edge(rgb2gray(I1),'log'); %Sobel, Prewitt, Roberts,Canny,log
figure;imshow(bw1);title('log');

%%

