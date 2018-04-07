function [Fx,Fy,k1,b1,k2,b2]=BusquedaRectas(a,umbral,umbral2,outliers,mostrar)

if nargin==4
   mostrar=0; 
end
%Filtro la "a" de outliers
S=size(a);
for k=1:S(1)
    for j=1:S(2)
        if (outliers(k,j)==1) 
            a(k,j)=0;
        end
    end
end

b=a>umbral;% alturas mayores a 1
c=a<umbral2;
aa=b&c;
if mostrar==1
figure(1)
    imshow(aa)
end
aa(1:300,:)=0; % Limpio Toda la parte superior
[k,i]=find(aa==1); % Uso el find para obtener una lista de los puntos
pts=[k,i]';iterNum=1e+3;thDist=15;thInlrRatio=0.10;
[ t,r ] = ransac( pts,iterNum,thDist,thInlrRatio );
k1 = -tan(t); b1 = r/cos(t);
%if (k1==0 || b1==0)
%    disp('RANSAC 1 error')
%end
%figure(1)
if mostrar==1
figure(2)
   mostrarSAC(pts,k1,b1);
end

%RHO = sin(theta)*k+cos(theta)*i;
% Una vez determinada la primer recta, hay que sacar los inliers y obtener la 2da

distancia=(k1*pts(1,:)-pts(2,:)+b1)/((k1^2+1))^(0.5);
outs=find(abs(distancia)>30);
pts=[k(outs),i(outs)]';iterNum=1e+3;thDist=15;thInlrRatio=0.1; %proporcion de inliers 
[ t,r ] = ransac( pts,iterNum,thDist,thInlrRatio );
k2 = -tan(t); b2 = r/cos(t);
%if (k2==0 || b2==0)
 %   disp('RANSAC 2 error')
%end
Fx=round((b1-b2)/(k2-k1));Fy=round(k1*Fx+b1);
if mostrar==1
figure(3)
  mostrarSAC(pts,k2,b2);
end
%mostrarSAC(pts,k2,b2);
end