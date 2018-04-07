% Idea de fran: Mejorar la resolucion en los puntos cercanos a un punto
% encontrado con la funcion TroncoDetect. De esta manera reconocer por
% densidad de puntos (o cualquier otro parametro) si es un tronco real o
% no.
clc;clear all;close all;IMAGENES=0;
img_dir=setPc('vaio');% server o vaio
%img_dir='E:\Facultad\Becas\CIN\TRABAJo\Dataset\Probando_pres\image'
%------------------ PARAMETROS
cellSize = [8 8];
hogFeatureSize = 6336;
Caracteristicas={cellSize hogFeatureSize};
FRAME=150;
Ventana=[140 95];% Alto ancho
Solapamiento=0.95;% % porcentaje de solapamiento entre ventanas
load('SVMq976.mat') ;% Cargar el clasificador
load('Camara_Parametros.mat');load('Polinomio.mat');Ss=S; % Carga los parametros de la camara y el polinomio de ajuste
S=[720 1280];
classifier=SVMq976.ClassificationSVM; % Cargar el algoritmo del clasificador
%load('SVMq95.mat') ;% Cargar el clasificador
%classifier=SVMq95.ClassificationSVM; % Cargar el algoritmo del clasificador
IMAGENES=0;h = fspecial('disk',1);
Parametros.classifier=classifier;Parametros.Caracteristicas=Caracteristicas;
Parametros.Ventana=Ventana;Parametros.Solapamiento=Solapamiento;
Parametros.Camara=Camara;
Parametros.Polinomio.p=p;Parametros.Polinomio.S=Ss;Parametros.Polinomio.mu=mu;
Parametros.FRAME=FRAME;Parametros.img_dir=img_dir;Parametros.SizeImg=S;
Parametros.IMAGENES=IMAGENES;Parametros.h=h;
Parametros.Hcamara=180; % La camra esta mas o menos a 180Cm del suelo
%------------------------------------------------------------------------
save('Parametrosc.mat','Parametros');
%%
clc;clear all;
load('Parametrosc.mat')

I2a = imread(sprintf('%s%1di.jpg',Parametros.img_dir,Parametros.FRAME));
I2a = undistortImage(I2a,Parametros.Camara.L);
% I1 = undistortImage(IR,Camara.R);
%Extraigo los centros positivos, TARDA UNA BOCHA
Centros2=TroncoDetect(I2a,Parametros);
Data.Img.I2a=I2a;Data.Centros=Centros2;
clear I1;clear I2a;clear Centros2
%% ------------------------------------------------------------------------ 
% %Cargar esto para alivianar  el peso
clc;clear all;close all;
load('matlab.mat')
Parametros.IMAGENES=0;
%-----------------------------------------------------------------------
Parametros.Centroides.Dimencion=Parametros.SizeImg;Data.Centros=Centros2;
tracker = vision.PointTracker('MaxBidirectionalError',1);Data.Gentracker=tracker;
[Data]=Iniciar_Traquers(Data,Parametros,0);
% Cargando variables
LL=size(Parametros.h);FiltroGrande=zeros(Parametros.SizeImg(1),Parametros.SizeImg(2));
i=1;Data.Activo=ones(1,Data.Trackers.Ds); Data.NuevosT=1;Data.iteracion=i;
Data.L.PosX=-200;Data.L.Altura=50;Data.R.PosX=200;Data.R.Altura=100;Data.DisMin=300;
%----------------------------------------------------------------
% % Inicio del loop
FRAME1=Parametros.FRAME;
FRAME_Fin=Parametros.FRAME+400;
Seguir=1;
% Bandera=1;
while Seguir==1
    Data.iteracion=i;
    Parametros.FrameActual=FRAME1;
    I1a=imread(sprintf('%s%1dd.jpg',Parametros.img_dir,FRAME1));
    I2a=imread(sprintf('%s%1di.jpg',Parametros.img_dir,FRAME1));
    [Data.Img.I,~,Data.Img.outliers]=FunProf(I1a,I2a,Parametros);
    Data.Img.I2a = undistortImage(I2a,Parametros.Camara.L);
    Data.Img.I1a=I1a;
    %     imagesc(Data.Img.I,[100 1000]);colormap jet;colorbar;
    %         figure(1)
    %         imshow(I2a)
    %         hold on
    for q=1:Data.Trackers.Ds
        Data.NTracker=q;
        [points, validity] = step(Data.Trackers.trackers{q},Data.Img.I2a);
%                     out = insertMarker(I2a,points(validity, :),'+');
%                     imshow(out);%,'InitialMagnification',50)
%                     pause()
        if ~isempty(points(validity, 2)) && sum(validity)/size(validity,1)>0.2  % Por si el tracker no pierde los puntos
            y=round(mean(round(points(validity, 2))));
            x=round(mean(round(points(validity, 1))));        
%             if i==9
%                 Parametros.IMAGENES=1;
%                 pause()
%             else
%                 Parametros.IMAGENES=0;
%             end
            [Distancia_aux, Data] = AdqTr(x,y,Data,Parametros);            
            if ~isempty(Distancia_aux)                                
                    try
                        if Data.NuevosT==0
                        [Xact,Yact]= pol2cart(Distancia_aux(2),Distancia_aux(1));
                        [Xant,Yant]= pol2cart(Distancia{i-1}(q,2),Distancia{i-1}(q,1));
                        Dis=norm([Xact,Yact]-[Xant,Yant]);
                        if Dis>100 % La actualizacion debe ser menor a un metro
                       Dis
                        end
                        end
                     Distancia{i}(q,:)=Distancia_aux;
                    catch
                        disp('No se pudo')
                        Distancia{i}(q,:)=Distancia_aux;                       
                    end
                    Data.Activo(q)=1;
            end
        else
            Data.Activo(q)=0;  
        end
    end
    
    
    %--------------------- Aca termina una imagen
    if sum(Data.Activo)<4 && mod(i,3)==0
        disp('Escaneo preventivo')
%     Parametros.IMAGENES=1;
    Data.umbral=0.01; %0.01 es lo normal sino 0.003 es un buen numero
    [Data]=Iniciar_Traquers(Data,Parametros,1,Puntos);   
%     Parametros.IMAGENES=0;
     Data.Activo=ones(1,Data.Trackers.Ds);
        Data.NuevosT=1;
    end
    
    if sum(Data.Activo)<2
        disp('Buscar nuevos troncos')
        
        %         Data.L.Altura=10;
%         if Bandera==1
%             [Data]=Iniciar_Traquers(Data,Parametros,1);
%             Bandera=0;
%         else
            
             [Data]=Iniciar_Traquers(Data,Parametros,1);
%         end
        
        if size(Distancia,2)==i
            if (sum(Distancia{i}(:,5))==0 )                
                Distancia{i}(:,:)=0;
                FRAME1=FRAME1-1;
                i=i-1;            
            end           
        end
        Data.Activo=ones(1,Data.Trackers.Ds);
        Data.NuevosT=1;
        close all;
    else     
%         Parametros.IMAGENES=1;
try
        [Puntos,Data]=GeneradorDePuntos(Distancia{i},Data,Parametros);
catch
    disp('Distancia vacia')
end
%           Parametros.IMAGENES=0;
%           pause()
%         figure(1)
%         imshow(Data.Img.I2a)
%         hold on
%         plot(Puntos(1,:),Puntos(2,:),'rx')        
%         hold off
%         
%         pause()
%         Data.NuevosT=0;
    end
    FRAME1=FRAME1+1;
    i=i+1
%     if i==7
%         Parametros.IMAGENES=0;
%         pause()
%     end
    if FRAME1>FRAME_Fin
        Seguir=0;
    end
end
disp('Fin')


