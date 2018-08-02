Funcioan correctamente
hfiltro=ones(3,3)/9;  % Cargo un filtro Pb
H = fspecial('disk',5);% Cargo un filtro Pb
viewId = 100;
first_frame = viewId;
last_frame = 800;
img_dir      = 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas\image';
for viewId=first_frame:last_frame
    disp(['Frame n°: ' num2str(viewId)])
I1 = imread(sprintf('%s%1dd.jpg',img_dir,viewId));
I2 = imread(sprintf('%s%1di.jpg',img_dir,viewId));
%21
disparityMap = disparity(rgb2gray(I2),rgb2gray(I1),'BlockSize',15,'Method','BlockMatching');%,'DisparityRange',disparityRange);
S=size(disparityMap);
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
% #### Parte de filtrado de puntos
%I = imgaussfilt(disparityMap,2); %Filtrado
%I=imfilter(disparityMap,H);
%imshow(disparityMap,[0 60]);
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
 % ######### Gran parte de la presicion del metodo depende de la anterior
 % seccion de codigo.
figure(1)
%-5 10
imshow(a,[-5 10]);
colormap jet
%imshowpair(I1,a,'montage')
end


