function mostrarSAC(pts,k1,b1)
Distancia=30;
plot(pts(1,:),pts(2,:),'x')
k=pts(1,:);
hold on
plot(k,k1*k+b1,'r')
distancia=(k1*pts(1,:)-pts(2,:)+b1)/((k1^2+1))^(0.5);
aver=find(abs(distancia)>Distancia);
plot(pts(1,aver),pts(2,aver),'rx');
hold off
pause(0.3)
end 