function [p00]=EncPlano(x,y,I,Dist_Ant,IMAGENES)
if nargin<5
    IMAGENES=0;
end
if nargin<4
   Dist_Ant=I(y,x);
end
Z=I(y-20:y+20,x-5:x+5);      %Z=I(y-20:y+20,x-20:x+20); 
 [X,Y] = meshgrid(1:11,1:41);
 [xData, yData, zData] = prepareSurfaceData( X, Y, Z );
outliersfit=zData > Dist_Ant+50 | zData < Dist_Ant-50;
fitobject = fit([xData,yData],zData,'poly11','Exclude',outliersfit) ;
p00=fitobject.p00;
if IMAGENES==1
figure(1);
plot(fitobject,[xData yData],zData,'Exclude',outliersfit)
pause()
end

end