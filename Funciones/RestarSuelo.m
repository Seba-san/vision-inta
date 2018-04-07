function [Isal]=RestarSuelo(Ient,Pxmin,Tipo)
%  #######   Detectando que es y que no es Suelo
% Supongo que la camara esta centrada, por lo que en el medio no hay
% obstaculos, solo esta el suelo. De aqui tomo la altura del suelo. La
% siguiente figura muestra la curva  Y[pixeles] vs distancia [adimenicional]
%Pxmin determina en que pixel hacer la aproximacion.
%Ient=I;Pxmin=450;Tipo=3; Tipo 1 es lineal, Tipo 2 es 1/x con fit y tipo 3
%es 1/x con ransac
S=size(Ient);
%C=[S(1)/2 S(2)/2]; % Cargo la matriz de disparidad en una variable mas corta
II2=Ient(Pxmin:S(1),S(2)/2);x=Pxmin:S(1); % solo me fijo en la mitad inferior de la columna central

if Tipo==1 % Tipo 1 es lineal, otro (o tipo 2) es homo grafico 1/x
    outliers = excludedata(x',II2,'range',[10 60]); % saco los outliers (valores muy negativos o muy positivos)
    % Dado que hay un gran porcentaje de outliers, en vez de usar "fit" uso
    % ransac;  %NO se porque da una recta, pero interpolo con una recta
    pts=[x(~outliers)',II2(~outliers)]';iterNum=1e+3;thDist=5;thInlrRatio=0.3;
    % Todo lo que tenga una distancia Inferior a la de la recta se considera
    % como un obstaculo.
    [ t,r ] = ransac( pts,iterNum,thDist,thInlrRatio );  % Da la inclinacion (t) y la distancia del centro (r)
    k1 = -tan(t); % Recupero la pendiente
    b1 = r/cos(t); %ordenada al origen
    Isal=zeros(S(1),S(2));
    for i=S(1):-1:1
        Isal(i,:)=Ient(i,:)-(k1*i+b1); % Le sumo 2 ya que la recta ajustada (o fiteada) no ajusta perfectamente
    end
end
if Tipo==2
    BaseLine=120.647;
    Foco=700;
    Constante=BaseLine*Foco;
    II2=Constante./II2; Ient=Constante./Ient;
    pts=[x',II2]';iterNum=1e+3;thDist=5;thInlrRatio=0.3;
    [ t,r ] = ransac( pts,iterNum,thDist,thInlrRatio );  % Da la inclinacion (t) y la distancia del centro (r)
    k1 = -tan(t); % Recupero la pendiente
    b1 = r/cos(t); %ordenada al origen
    Isal=zeros(S(1),S(2));
    for i=S(1):-1:1
        Isal(i,:)=Ient(i,:)-(k1*i+b1); % Le sumo 2 ya que la recta ajustada (o fiteada) no ajusta perfectamente
    end
    % imagesc(-Isal,[-1000 2000]);colormap jet;
    Isal=-Isal;
end

if Tipo==3   
    outliers1 = excludedata(x',II2,'range',[150 1000]); % saco los outliers (valores muy negativos o muy positivos)
    % Dado que hay un gran porcentaje de outliers, en vez de usar "fit" uso
    % ransac;  %NO se porque da una recta, pero interpolo con una recta
    II2=1./II2;
    pts=[x(~outliers1)',II2(~outliers1)]';iterNum=1e+3;thDist=5;thInlrRatio=0.3;
    % Todo lo que tenga una distancia Inferior a la de la recta se considera
    % como un obstaculo.
    [ t,r ] = ransac( pts,iterNum,thDist,thInlrRatio );  % Da la inclinacion (t) y la distancia del centro (r)
    k1 = -tan(t); % Recupero la pendiente
    b1 = r/cos(t); %ordenada al origen
    Isal=zeros(S(1),S(2));
    for i=S(1):-1:1
        Isal(i,:)=-Ient(i,:)+1/(k1*i+b1); % Le sumo 2 ya que la recta ajustada (o fiteada) no ajusta perfectamente
    end
   % figure(1);imagesc(Isal,[-1000 3000]); colormap jet           
end
% mostrarSAC(pts,k1,b1);
end