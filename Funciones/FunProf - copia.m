function [I,a,outliers]=FunProf(I1,I2,IMAGENES)
%Esta funcion hace lo que hace "profundidad" sin obtener las rectas, de
%manera automatica. I Mapa de distancias, a Mapa de alturas, outsliers son
%valores negativos de la disparidad.
if nargin==2
    IMAGENES=0;
end
BaseLine=120.647;
Foco=700;
Constante=BaseLine*Foco;
I = disparity(rgb2gray(I2),rgb2gray(I1),'BlockSize',5,'DistanceThreshold',40);%,'Method','BlockMatching');%,'DisparityRange',disparityRange);
if IMAGENES==1
    figure (1);imagesc(I,[0 80]);colormap jet;colorbar;
    title('Mapa de Disparidad')
    pause()
end
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
if IMAGENES==1
    imshow(outliers)
    title('Outliers')
    pause()
end
I=Constante./I;
if IMAGENES==1
    close 1
    figure (1);imagesc(I,[1500 3500]);colormap jet;colorbar;
    title('Mapa de distancias "I"')
    pause()
end
a=RestarSuelo(I,450,3);
if IMAGENES==1
    figure(1);imagesc(a,[-1000 6000]); colormap jet;colorbar
    title('Mapa de alturas "a"')
    pause()
    close 1
end
end