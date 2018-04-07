%------------------------------
%Cargo parametros standart
FRAME1=150;
I1a=imread(sprintf('%s%1dd.jpg',Parametros.img_dir,FRAME1));
I2a=imread(sprintf('%s%1di.jpg',Parametros.img_dir,FRAME1));

%------------------------------------------------------------
% Filtro las 2 imagenes con gauss
I2a=imgaussfilt(I2a, 2);
I1a=imgaussfilt(I1a, 2);
%-----------
% No funciona bien 
h = fspecial('log');%, hsize, sigma)
I2a = imfilter(I2a,h);%,'replicate'); 
I1a = imfilter(I1a,h);%,'replicate'); 

%----------------------------------------
% Generacion de Disparidad
p=Parametros.Polinomio.p;Ss=Parametros.Polinomio.S;mu=Parametros.Polinomio.mu;
IMAGENES=Parametros.IMAGENES;ParametrosCam=Parametros.Camara.L;
DisparityRange=[0 80];BlockSize=5;DistanceThreshold=80;  
I = disparity(rgb2gray(I2a),rgb2gray(I1a),'BlockSize',BlockSize,'DistanceThreshold',DistanceThreshold,'DisparityRange',DisparityRange);%,'Method','BlockMatching');%,'DisparityRange',disparityRange);
S=size(I);
outliers=zeros(S(1),S(2));
for k=1:S(1)
    for j=1:S(2)
        if (I(k,j)<0)
            outliers(k,j)=1;
            I(k,j)=0;
        end
    end
end
I=undistortImage(I,ParametrosCam);
[P_d,~] = polyval(p,abs(I),Ss,mu);
I=1./P_d;
t= I(:,:)>2000|I(:,:)<50;
I(t)=NaN;outliers(t)=1;
figure;imagesc(I,[100 800]);colormap jet;
c = colorbar;
c.Label.String = 'Distancia[cm]';
title('Mapa de distancias ')
figure;imshow(I2a)
figure;imshow(I1a)
%---------------------------
%Interpolacion de NaN 
% Lo que voy a intentar hacer es aplicar un interpolador en las filas en
% donde hay un NaN para que de esta manera, eliminar los pixeles ocultos y
% mejorar, si es que lo hace, la estimacion de la distancia.
S=Parametros.SizeImg;
A.x=1:S(1);A.y=1:S(2);
[X,Y] = ngrid(A.x,A.y);
nt=~t;

F = griddedInterpolant(I(~t),'spline');
I(t)=F(I(t));
figure;imagesc(I,[100 800]);colormap jet;


Vq = interp2(~t,I(~t),I(t)); 


I=ones(10)*4;
for i=3:7
    I(i,5)=1;
    I(i,4)=1;
    I(i,3)=3;
    I(i,1)=3;
    I(i,2)=3;
    
end
t=I(:,:)==1;
F = griddedInterpolant(I(~t),'spline');
I(t)=F(I(~t));
imshow(I)
Vq = interp2(X(~t)',Y(~t)',I(~t)',X(t|~t),Y(t|~t)); 
