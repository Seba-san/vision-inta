function [I,a,outliers]=FunProf(I1,I2,p,Ss,mu,ParametrosCam,IMAGENES)
%Esta funcion hace lo que hace "profundidad" sin obtener las rectas, de
%manera automatica. I Mapa de distancias, a Mapa de alturas, outsliers son
%valores negativos de la disparidad.
if nargin<6
    IMAGENES=0;
end
DisparityRange=[0 80];BlockSize=5;DistanceThreshold=80;  
I = disparity(rgb2gray(I2),rgb2gray(I1),'BlockSize',BlockSize,'DistanceThreshold',DistanceThreshold,'DisparityRange',DisparityRange);%,'Method','BlockMatching');%,'DisparityRange',disparityRange);
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
if IMAGENES==1
    figure (1);imagesc(I,[100 800]);colormap jet;colorbar;
    title('Mapa de distancias "I"')
    pause()
end
a=RestarSuelo(I,450,3);
if IMAGENES==1
    figure(1);imagesc(a,[-100 3000]); colormap jet;colorbar
    title('Mapa de alturas "a"')
    pause()
    close 1
end
end