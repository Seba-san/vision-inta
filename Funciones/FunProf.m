function [I,a,outliers]=FunProf(I1a,I2a,Parametros)
%Esta funcion hace lo que hace "profundidad" sin obtener las rectas, de
%manera automatica. I Mapa de distancias, a Mapa de alturas, outsliers son
%valores negativos de la disparidad.
p=Parametros.Polinomio.p;Ss=Parametros.Polinomio.S;mu=Parametros.Polinomio.mu;
IMAGENES=Parametros.IMAGENES;ParametrosCam=Parametros.Camara.L;
% if nargin<6
%     IMAGENES=0;
% end
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
if IMAGENES==1
    figure (1);imagesc(I,[100 800]);colormap jet;
    c = colorbar;
    c.Label.String = 'Distancia[cm]';
    title('Mapa de distancias ')
    pause()
    close 1
end
a=RestarSuelo(I,450,3);
if IMAGENES==1
    figure(1);imagesc(a,[-100 3000]); colormap jet;colorbar
    title('Mapa de alturas "a"')
    pause()
    close 1
end
end