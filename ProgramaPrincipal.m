% Programa principal, este es el programa en donde ejecuto los demas
% programas :O

clc;clear all;close all;
% img_dir=setPc('vaio');% server o vaio
FRAME=150;
FRAME_Fin=FRAME+750;
Parametros=CargarParametros(FRAME,FRAME_Fin,'vaio');
[Data,Parametros]=EscaneoInicial(Parametros);
save('DatosPoster.mat','Parametros','Data');
clc;clear all
load('DatosPoster.mat');% Datos 50 en realidad.
Parametros.IMAGENES=0;
[Distencia,Data,Parametros]=EscaneoContinuo(Parametros,Data); %Guarda los datos en un archivo que sellama "jueves" rastrarlo dentro del soft
%%
Generador_txt(Distancia)
Pos=[0 0 0]';save('pos.mat','Pos'); % Sirve para guardar la trayectoria del vehiculo
Mapa=slam('parametros_encArtificial.m',1,477,3)
save('MapaJueves_sinRuido2.mat','Mapa')
edit parametros

drawrawdata('parametros_encArtificial.m',1,300)

%%
% Levanto la trayectoria
% load('pos.mat');
s=size(Pos,2);
figure(3);hold on
for i=1:s-100
    plot(Pos(1,i),Pos(2,i),'.b')  
end
hold off
xlabel('Direccion Frontal [m]'),ylabel('Direccion Lateral [m]'),ylim([-3 3]),grid on;
title('Estimacion de localizacion')
% desde=1;
% hasta=40;
% A=norm([Pos(1,desde)-Pos(1,hasta),Pos(2,desde)-Pos(2,hasta)])
%%
save('Pos_SinRuido.mat','Pos')
save('Pos_Conruido5_incini.mat','Pos')
save('Pos_sinruido_incini.mat','Pos')
save('PosFull_sinruido_incini.mat','Pos')
load('PosFull_sinruido_incini.mat')
%%
% clear all;
load('E:\Facultad\Becas\CIN\TRABAJo\Programas\Matlab\Datos\DatosSeba_50_a_699.mat')
load('precarga_predic.mat')
enc.steps(1).data1=0;
enc.steps(1).data2=0;
enc.steps(20).data1=0;
enc.steps(20).data2=0;
L=size(LocationGlobal,1);
% figure(1), hold on
Mant=0;ang_Ant=0;
for i=1:L
    if mod(i,2)==0
        M(1)=LocationGlobal{i}(1);
        M(2)=LocationGlobal{i}(3);
        R=OrientationGlobal{i}; eul = Rotacion2eul(R);
        ang=eul(2);
        enc=GenEncTruch(enc,M,ang,1);
        % Se desplaza en el M2
        [r,Fxr,path] = predict(r,enc);
        M+Mant
        ang+ang_Ant
        r
        ang
        % plot(M(1),M(2),'bx')
        pause()
        Mant=M+Mant;
        ang_Ant=ang+ang_Ant;
    end   
end
% hold off
% [enc.steps.data1 enc.steps.data2]'
%%

% Rotacion2eul es ROTM2EUL para que funcione sin el toolbox instalado.
for i=1:L
    if mod(i,2)==0
R=OrientationGlobal{i};
eul = Rotacion2eul(R);
eul(2)
pause()
    end
    
end

% R=OrientationGlobal{2};
%  Rotacion2eul(R)%*180/pi

%%
for i=1:6
d{i}=camPoses.Location{i};
end
%%
% Dibujar posicion de troncos en funcion del mapa

Puntos=get(Mapa,'x');
%%

S=size(Puntos,2);
% d=get(Puntos{:},'x');
for i=2:S
  d(i-1,:)= get(Puntos{i},'x')';
%   if d(1)<30
%   plot(d(1),d(2),'rd')  
%   end
%   hold on
end
k=find(d(:,1)<30);
figure(3),clf
plot(d(k,1),d(k,2),'rd'); hold on
k=find(Pos(1,:)<30);
 plot(Pos(1,k),Pos(2,k),'.b');hold off

xlabel('Direccion Frontal [m]'),ylabel('Direccion Lateral [m]'),ylim([-4 4]),grid on;
title('Localizacion y Mapeo'), legend('Tronco','Posicion de la camara')






