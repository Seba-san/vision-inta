% Idea de fran: Mejorar la resolucion en los puntos cercanos a un punto
% encontrado con la funcion TroncoDetect. De esta manera reconocer por
% densidad de puntos (o cualquier otro parametro) si es un tronco real o
% no.
clc;clear all;close all;IMAGENES=0;
%### Seteo para el server
cd 'C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Proyectos\programasMatlab'
addpath('C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Funciones')
img_dir= 'D:\Datasets\Salidas_de_Campo_INTA\25Ene2017\prueba9\partidas\image';
%### Seteo para el server

%### Seteo para la VAIO
% cd 'C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab';
% addpath('C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Funciones')
% %  img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas';
% img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas\image';
% %img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas\image';
 load('Camara_Parametros.mat');load('Polinomio.mat');Ss=S;
%### Seteo para la VAIO


%############ PARAMETROS
cellSize = [8 8];
hogFeatureSize = 6336;
Caracteristicas={cellSize hogFeatureSize};
FRAME=90;
Ventana=[140 95];% Alto ancho
Solapamiento=0.95;% 
load('SVMq976.mat') ;% Cargar el clasificador
classifier=SVMq976.ClassificationSVM; % Cargar el algoritmo del clasificador
%load('SVMq95.mat') ;% Cargar el clasificador
%classifier=SVMq95.ClassificationSVM; % Cargar el algoritmo del clasificador

%#################

I1 = imread(sprintf('%s%1di.jpg',img_dir,FRAME));
I2=imread(sprintf('%s%1dd.jpg',img_dir,FRAME));
I2 = undistortImage(I2,Camara.R);
I1 = undistortImage(I1,Camara.L);
%Extraigo los centros positivos, TARDA UNA BOCHA
Centros2=TroncoDetect(I1,classifier,Ventana,Solapamiento,Caracteristicas,IMAGENES);
%------------------------------------------------------------------------ 
%Cargar esto para alivianar  el peso
%
% clc;clear all;close all;IMAGENES=0;
% load('Precarga4.mat')
%-----------------------------------------------------------------------
S=size(I1(:,:,1));
[Troncos]=Centroides(Centros2,[S(1) S(2)]);
[Traquear]=GenPunTk(Troncos,I1);
%### Traqueo
% Creo tantos trackers como troncos encontrados
Ds=size(Traquear);
tracker = vision.PointTracker('MaxBidirectionalError',1);
for q=1:Ds(2)
    trackers{q}=clone(tracker);
    %Initialize the tracker.
    initialize(trackers{q},Traquear{q},I1);
end
%Read, track, display points, and results in each video frame.

h = fspecial('disk',1); % Esta es la mascara con la que se promedia
%h = fspecial('gaussian', [10 3], [0.9 0.5]) % La idea es seleccionar una mascara
%no cuadrada
LL=size(h);S=size(I1);FiltroGrande=zeros(S(1),S(2));
i=1;
%Distancia=zeros(50,Ds(2),2);
Activo=ones(1,Ds(2));
%Ventana=Ventana/2;
NuevosT=1;
for FRAME1=FRAME:1:FRAME+500
    I1a=imread(sprintf('%s%1dd.jpg',img_dir,FRAME1));
    I2a=imread(sprintf('%s%1di.jpg',img_dir,FRAME1));
%     I1a = undistortImage(I1,Camara.R);
%     I2a = undistortImage(I2,Camara.L);
    DisparityRange=[0 80];BlockSize=5;DistanceThreshold=80;
    Ia = disparity(rgb2gray(I2a), rgb2gray(I1a),'BlockSize',BlockSize,'DistanceThreshold',DistanceThreshold,'DisparityRange',DisparityRange);%,'Method','BlockMatching');%,'DisparityRange',disparityRange);
    [P_d,delta] = polyval(p,Ia,Ss,mu);
    I=1./P_d;
%     imagesc(Ia,[0 80]);colormap jet;colorbar;
    %imagesc(I,[100 1000]);colormap jet;colorbar;
    %imshow(I2a)
    [ffd,outliers]=FunProf(I1a,I2a,IMAGENES);
    %     figure(1)
    %     imshow(I2a)
    %     hold on
    %frame = step(videoFileReader);
    for q=1:Ds(2)
        [points, validity] = step(trackers{q},I2a);
        %  out = insertMarker(I2a,points(validity, :),'+');
       % imshow(out)
        if ~isempty(points(validity, 2)) % Por si el tracker no pierde los puntos
            y=round(mean(round(points(validity, 2))));
            x=round(mean(round(points(validity, 1))));
            if ((S(1)-y)>Ventana(1) && x>Ventana(2) && S(2)-x>Ventana(2)&& y>Ventana(1))%en esto evito tener que ventanear cerca de los bordes
                Objetivo=[x y]; % Obtengo un punto aproximado centrado
                % Ver si se puede reducir la siguiente ventana
                NuevaVentana=[Objetivo(1)-Ventana(2) Objetivo(2)-Ventana(1) 2*Ventana(2) 2*Ventana(1)];
                Ic=imcrop(I2a,NuevaVentana);
                Dimencion=size(Ic);
                % Solapamiento a 1 pixel
                Solapamiento3=0.95;
                %             if(i==13)
                %                 imshow(Ic)
                %                 disp('Pausado')
                %                 pause()
                %                 IMAGENES=1;
                %             end
                Centros2=TroncoDetect(Ic,classifier,Ventana,Solapamiento3,Caracteristicas,IMAGENES);
                [Troncos2]=Centroides(Centros2,[Dimencion(1) Dimencion(2)],IMAGENES); % Se obtiene la nueva posicion de los troncos
                sst=size(Troncos2);
                %         if sst(1)>1
                %         kr=find(min(Troncos2(1,:))); % Esto es por si se detecta mas de un tronco en la imagen
                %         Troncos3=Troncos2;
                %         clear Troncos2
                %         Troncos2=[Troncos3(1,kr) Troncos3(2,kr)];
                %         clear Troncos3
                %         end
                %Troncos2
                Distancia2=zeros(sst(1),2);
                xa=zeros(1,sst(1));
                ya=zeros(1,sst(1));                
                for dd1=1:sst(1)
                    xa(dd1)=round(Troncos2(dd1,1))+Objetivo(1)-Ventana(2);
                    ya(dd1)=round(Troncos2(dd1,2))+Objetivo(2)-Ventana(1);
                    if (xa(dd1)>0 && ya(dd1)>0)
                        FiltroGrande=zeros(S(1),S(2));
                        FiltroGrande(ya(dd1)-(LL(1)-1)/2:(ya(dd1)+(LL(1)-1)/2),xa(dd1)-(LL(2)-1)/2:(xa(dd1)+(LL(2)-1)/2))=h;
                        aa=I.*FiltroGrande; dd=isnan(aa);kk=isinf(aa);rr=dd|kk|outliers;
                        xcorr=xa(dd1)-576.186; % Cx=737.995,576.186, 640
                        Distancia2(dd1,:)=[sum(sum(aa(~rr))),asin(-xcorr/(xcorr^2+692.964^2)^0.5)];
                    end
                end
                % sum(sum(aa(~rr)))         
               % ESTO ES NUEVO
               kd=find(Distancia2(1:sst(1),1)~=0);
                kr=find(min(Distancia2(kd,1))); % En caso de que encuentre 2 troncos, se queda con el mas cercano
               
                %kr=kr&(~kkr);% % ESTO ES NUEVO Tiene que ser minimo, pero no cero
                if ~isempty(kr)
                    Distancia{i}(q,:)=[Distancia2(kr,:) NuevosT];
                    %Distancia2(kr,1)
                    x=xa(kr);
                    y=ya(kr);                    
                    [Traquear]=GenPunTk([x y],I2a,IMAGENES); %Conviene agregar un factor para la ventana?                  
                    %setPoints(trackers{q},[Traquear{1}; [ points(validity,1) points(validity,2) ]]) % Actualizo los nuevos puntos del tracker
%                     %[Traquear]=GenPunTk(Troncos,I1);
                    setPoints(trackers{q},Traquear{1}) % Actualizo los nuevos puntos del tracker                  
                end
             %  plot(x,y,'rx')
            else
                Activo(q)=0;
            end
        else
            Activo(q)=0;
        end
        
    end
    % Aca termina una imagen
  % hold off
    if sum(Activo)<3
        % Busco nuevos troncos
        disp('Buscar nuevos troncos')
        %pause()
        Centros2=TroncoDetect(I2a,classifier,Ventana,Solapamiento,Caracteristicas,IMAGENES);
        [Troncos]=Centroides(Centros2,[S(1) S(2)],IMAGENES);
        [Traquear]=GenPunTk(Troncos,I2a,IMAGENES);
        Ds=size(Traquear);
        for q=1:Ds(2)          
            trackers{q}=clone(tracker);
            %Initialize the tracker.
            initialize(trackers{q},Traquear{q},I2a);
        end
        if size(Distancia,2)==i
            if (sum(Distancia{i}(:,3))==0 )
                Activo=ones(1,Ds(2));
                Distancia{i}(:,:)=0;
                FRAME1=FRAME1-1;
                i=i-1;
                NuevosT=1;
            end            
        end
        Activo=ones(1,Ds(2));
    else
        NuevosT=0;
    end
%     figure(2)
%         [xr,yr] = pol2cart(Distancia{i}(:,2),Distancia{i}(:,1));
%         plot(xr,yr,'x');
%     pause()
    
    %hold off
    i=i+1
    % FRAME1=FRAME1+1;
    %    disp('Pausado')
    %     pause()
    %considero el foco f=692.964
end
disp('Fin')
% figure (1);imagesc(I,[3000 7000]);colormap jet;colorbar;
% hold on
% plot(y,x,'wx')
% hold off
% % hold on
%%
%#######
%Muestro
figure(3)
imshow(Ic)
Rojo=[1 0 0]; Rojohsv=rgb2hsv(Rojo); % La idea es mostrar con un color mas "saturado" cuando los puntos tengan un puntaje mas alto.
Centros2(:,4)=Centros2(:,4)/max(Centros2(:,4));
 for i=1:numel(Centros2(:,1))
hold on
%plot(Centros(:,1),Centros(:,2),'rx');
Color=Rojohsv;Color(2)=Centros2(i,4);Color=hsv2rgb(Color);
plot(Centros2(i,1),Centros2(i,2),'x','color',Color)
%plot(Centros2(:,1),Centros2(:,2),'x', 'color',[Centros2(:,4) 0 0])      
% text(double(Centros(i,1)),double(Centros(i,2)),num2str(Centros(i,4)),'Color','red')
 end
hold off
%#######

%%
i=1;
for i=1:48
%[x,y] = pol2cart(angulo,R)
[x,y] = pol2cart(pi/2-Distancia(i,:,2),Distancia(i,:,1));
figure(3)
plot(x,y,'x');ylim([0 7000]);xlim([-4000 4000])
pause()
end



%%
da=size(Distancia);
for i=1:da(2)
    %[x,y] = pol2cart(angulo,R)
    if ~isempty(Distancia{i})
        %Distancia{i}
        i
        [x,y] = pol2cart(pi/2-Distancia{i}(:,2),Distancia{i}(:,1));
        figure(3)
        plot(x,y,'x');ylim([0 4000]);xlim([-2000 2000])
        %hold on
        pause()
    end
end
%hold off
%%
%Esta seccion se encarga de mostrar puntos filtrandolos y ordenadolos
%previamente
ORF2=[0 0];
Ct=zeros(1,2);
da=size(Distancia);
for i=2:da(2)
    % acomodo los vectores para que se pueda saber cual es viejo y cual es
    % nuevo; NO considera el rescaneo de troncos lo cual provoca un
    % reacomodamiento de las posiciones
    if ~isempty(Distancia{i})&& ~isempty(Distancia{i-1})
        if sum(Distancia{i}(:,3))==0 % no tiene que tner una actualizacion el frame siguiente
            OR1=Distancia{i-1}(:,1:2);
            OR2=Distancia{i}(:,1:2);
            a=size(OR1(:,1));b=size(OR2(:,1));
            aa=max([a b]); V1=zeros(aa,2);V2=zeros(aa,2);
            V1(1:a,:)=OR1; V2(1:b,:)=OR2;
            nz1=find(V1(:,1)~=0);dd=zeros(1,aa);dd(nz1)=1;
            nz2=find(V2(:,1)~=0);dd2=zeros(1,aa);dd2(nz2)=1;
            a=dd&dd2;a2=xor(dd,dd2);
            clear OR1;clear OR2;
            OR1=V1(a,:); OR2=V2(a,:);
            if V2(a2,1)~=0
                ORF2=V2(a2,:);
            else
                ORF2=[0 0];
            end
            %-----------------------------------------------------
            %Hasta aca OR1 son los puntos del frame i y OR2 los mismos puntos
            %pero en el frame i+1 ORF2 son los puntos "nuevos"
            [x,y] = pol2cart(OR1(:,2),OR1(:,1));
            [x2,y2] = pol2cart(OR2(:,2),OR2(:,1));
            %---------------------------------------------------------
            % Se obtienen distancias de desplazamiento y se descartan aquellas
            % que se mueven mas de lo esperado
            Vv=x(:)-x2(:); Vb=y(:)-y2(:); Vp=[Vv Vb]; rata=zeros(size(Vp,1),1);
            for mu=1:size(Vp,1)
                rata(mu)=norm(Vp(mu,:));
            end
            In=find(rata<30);
            
%             figure(1)
%             plot(x(In),y(In),'bx');ylim([-400 400]);xlim([0 1000])
%             hold on
%             plot(x2(In),y2(In),'rx')
%             hold off
            % ---------------------------------------------------
            %Lo que sigue calcula el desplazamiento de la camara
            
                       if  size(In,1) >1
                     [Ca,ORF1]=ConversionMarcosRef(OR1(In,:),OR2(In,:),[0 0]);
                        [C1(1), C2(2)]= pol2cart(Ca(2),Ca(1));
                        Cr=[C1(1) C2(2)];
                    Ct=Cr+Ct;
                     figure(2)
                    plot(Ct(1),Ct(2),'rx'); text(Ct(1),Ct(2),num2str(i))
                    hold on
                       end
        else
            disp('Rescaneo')
        end
        pause()
        i            
    end
end
hold off



%%
  %  En esta seccion  se aumenta la definicion de los puntos encontrados
    %  anteriormente
% #####################################
Total=numel(Centros2(:,1));
for Indi=1:Total
    if 0~=Centros2(Indi,1)
        Objetivo=round([Centros2(Indi,1) Centros2(Indi,2)]);
        % figure(2)
        % imshow(I1)
        % hold on
        % plot(Objetivo(1),Objetivo(2),'rx')
        % hold off
        % Solapamiento2=Ventana*Solapamiento; % Cambio el formato del solapamiento
        % [bbox]=FunPira(I1,Ventana,Solapamiento2);
        % [indice,err]=Buscbbox(round(Objetivo),bbox,Ventana);
        %Considero una region al rededor del punto equivalente a 4 ventanas.
        NuevaVentana=[Objetivo(1)-Ventana(2) Objetivo(2)-Ventana(1) 2*Ventana(2) 2*Ventana(1)];
        Ic=imcrop(I1,NuevaVentana);
        % Solapamiento a 1 pixel
        Solapamiento3=(min(Ventana)-1)/min(Ventana);
        Centros2=TroncoDetect(Ic,classifier,Ventana,Solapamiento3,Caracteristicas);        
        % ##### Muestro
        figure(2)
        imshow(Ic)
        hold on
        plot(Centros2(:,1),Centros2(:,2),'rx')
        hold off
        % ##### Muestro
  
        for i=1:Total
            Dis=((Centros2(:,1)+Objetivo(1)-Ventana(2)-Centros2(i,1)).^2 ...
            +(Centros2(:,2)+Objetivo(2)-Ventana(1)-Centros2(i,2)).^2).^0.5;
            %K=find(Dis<2);
            if find(Dis<20)
                Centros2(i,:)=0;
                i
            end
        end
        numel(Centros2(:,1))
        figure(1)
        hold on
        if numel(Centros2(:,1))>700
            disp('Tronco')
            plot(Centros2(:,1)+Objetivo(1)-Ventana(2),Centros2(:,2)+Objetivo(2)-Ventana(1),'rx')
        else
            disp('Falso Positivo')
            plot(Centros2(:,1)+Objetivo(1)-Ventana(2),Centros2(:,2)+Objetivo(2)-Ventana(1),'bo')
        end
        hold off
    end
    pause(1)
end





%%

% r=2000;
% tita1=pi/4;
% tita2=-pi/4;
P1=[1000 1000];
P2=[1000 900];
  
for i=1:15
    %r=r-100;
%     tita1=tita1+pi/16;
%     tita2=tita2+pi/16;
P1=P1-[10 0];
P2=P2-[10 0];
[tita1 r1]=cart2pol(P1(1),P1(2) );
[tita2 r2]=cart2pol(P2(1),P2(2) );
   Distancia{i}(1,:)=[r1 tita1 0]; 
   Distancia{i}(2,:)=[r2 tita2 0];   
%     Distancia{i}(1,:)=[tita1 r1 0]; 
%     Distancia{i}(2,:)=[tita2 r2 0];  
end
%%
% Prueba piloto, lo que voy a hacer aca es intentar calcular las distancias
% en base a detectar el mismo tronco en las 2 imagenes por separado para
% luego hacer la disparidad manualmente.
I1=imread(sprintf('%s%1dd.jpg',img_dir,FRAME1));
I2=imread(sprintf('%s%1di.jpg',img_dir,FRAME1));
I1a = undistortImage(I1,Camara.R);
I2a = undistortImage(I2,Camara.L);
Centros2=TroncoDetect(I2a,classifier,Ventana,Solapamiento,Caracteristicas,IMAGENES);
[Troncos]=Centroides(Centros2,[S(1) S(2)],IMAGENES);
Centros3=TroncoDetect(I1a,classifier,Ventana,Solapamiento,Caracteristicas,IMAGENES);
[Troncos3]=Centroides(Centros3,[S(1) S(2)],IMAGENES);
%----------------------------------
% Visualizacion
% figure(1)
% imshow(I2a);
% hold on
% plot(Troncos(:,1),Troncos(:,2),'rx')
% hold off
% figure(2)
% imshow(I1a);
% hold on
% plot(Troncos3(:,1),Troncos3(:,2),'rx')
% hold off


% figure(3)
% plot(Troncos(:,1),Troncos(:,2),'bx')
% hold on
% plot(Troncos3(:,1),Troncos3(:,2),'rx')
% hold off

% Uso la misma tecnica que en el codigo general, filtro los puntos "nuevos"
OR1=Troncos;
OR2=Troncos3;
a=size(OR1(:,1));b=size(OR2(:,1));
aa=max([a b]); V1=zeros(aa,2);V2=zeros(aa,2);
V1(1:a,:)=OR1; V2(1:b,:)=OR2;
nz1=find(V1(:,1)~=0);dd=zeros(1,aa);dd(nz1)=1;
nz2=find(V2(:,1)~=0);dd2=zeros(1,aa);dd2(nz2)=1;
a=dd&dd2;a2=xor(dd,dd2);
clear OR1;clear OR2;
OR1=V1(a,:); OR2=V2(a,:);
Vv=OR1(:,1)-OR2(:,1); Vb=OR1(:,2)-OR2(:,2); Vp=[Vv Vb]; rata=zeros(size(Vp,1),1);
for mu=1:size(Vp,1)
    rata(mu)=norm(Vp(mu,:));
end
In=find(rata<90);
% Calculo disparidad manualmente
V=Troncos(In,1)-Troncos3(In,1);
a=norm(V);
[P_d] = polyval(p,abs(V),Ss,mu);
ad=1./P_d;

% figure(3)
% plot(Troncos(In,1),Troncos(In,2),'bx')
% hold on
% plot(Troncos3(In,1),Troncos3(In,2),'rx')
% hold off
 xcorr1=Troncos(In,1)-640; % Cx=737.995,576.186, 640
 xcorr2=Troncos3(In,1)-640;
 for FOCO=650:750
 Distancia1=[ad,asin(-xcorr1/(xcorr1.^2+681^2).^0.5)];
 Distancia2=[ad,asin(-xcorr2/(xcorr2.^2+681^2).^0.5)];                 

 [Ca,ORF1]=ConversionMarcosRef(Distancia1(1:2,1:2),Distancia2(1:2,1:2),[0 0]);
 [C1(1), C1(2)]= pol2cart(Ca(2),Ca(1));
 Cr=[C1(1) C1(2)];
 if Cr(2)>11.99 && Cr(2)<12.01
     FOCO
     Cr(2)
     pause()
 end
 end           

V=Troncos(:,1)-Troncos3(:,1);
a=norm(V);
[P_d,delta] = polyval(p,a,Ss,mu);
    ad=1./P_d;




%  DisparityRange=[0 112];BlockSize=5;DistanceThreshold=112; 
%  Ia = disparity(rgb2gray(I2a), rgb2gray(I1a),'BlockSize',BlockSize,'DistanceThreshold',DistanceThreshold,'DisparityRange',DisparityRange);%,'Method','BlockMatching');%,'DisparityRange',disparityRange);
%   imagesc(Ia,DisparityRange);colormap jet;colorbar;  


