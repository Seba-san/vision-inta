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
FRAME=626;
Ventana=[140 95];% Alto ancho
Solapamiento=0.95;% % porcentaje de solapamiento entre ventanas
load('SVMq976.mat') ;% Cargar el clasificador
load('Camara_Parametros.mat');load('Polinomio.mat');Ss=S; % Carga los parametros de la camara y el polinomio de ajuste
S=[720 1280];
classifier=SVMq976.ClassificationSVM; % Cargar el algoritmo del clasificador
%load('SVMq95.mat') ;% Cargar el clasificador
%classifier=SVMq95.ClassificationSVM; % Cargar el algoritmo del clasificador
IMAGENES=0;
h = fspecial('disk',1); % Esta es la mascara con la que se promedia
%h = fspecial('gaussian', [10 3], [0.9 0.5]) % La idea es seleccionar una mascara
%no cuadrada

%------------------------------------------------------------------------

I2 = imread(sprintf('%s%1di.jpg',img_dir,FRAME));
I1 = imread(sprintf('%s%1dd.jpg',img_dir,FRAME));
I2 = undistortImage(I2,Camara.L);
% I1 = undistortImage(IR,Camara.R);
%Extraigo los centros positivos, TARDA UNA BOCHA
Centros2=TroncoDetect(I2,classifier,Ventana,Solapamiento,Caracteristicas,IMAGENES);
%------------------------------------------------------------------------ 
% % %Cargar esto para alivianar  el peso
% clc;clear all;close all;
% load('Precarga6.mat')
% IMAGENES=0;
%-----------------------------------------------------------------------
S=size(I1(:,:,1));
[Troncos]=Centroides(Centros2,[S(1) S(2)],IMAGENES);
[Traquear]=GenPunTk(Troncos,I2,IMAGENES);
%--------- Traqueo
% Creo tantos trackers como troncos encontrados
Ds=size(Traquear);
tracker = vision.PointTracker('MaxBidirectionalError',1);
for q=1:Ds(2)
    trackers{q}=clone(tracker);
    initialize(trackers{q},Traquear{q},I1);
end
LL=size(h);FiltroGrande=zeros(S(1),S(2));
i=1;Activo=ones(1,Ds(2)); NuevosT=1;
%----------------------------------------------------------------
% % Inicio del loop
FRAME1=FRAME;
FRAME_Fin=FRAME+150;
Seguir=1;
while Seguir==1
    I1a=imread(sprintf('%s%1dd.jpg',img_dir,FRAME1));
    I2a=imread(sprintf('%s%1di.jpg',img_dir,FRAME1));
    [I,a,outliers]=FunProf(I1a,I2a,p,Ss,mu,Camara.L,IMAGENES);
%         I1a = undistortImage(I1a,Camara.R);
        I2a = undistortImage(I2a,Camara.L);
   % Iaa=undistortImage(I,Camara.L);
%       Ia = disparity(rgb2gray(I2a), rgb2gray(I1a),'BlockSize',BlockSize,'DistanceThreshold',DistanceThreshold,'DisparityRange',DisparityRange);%,'Method','BlockMatching');%,'DisparityRange',disparityRange);
%     [P_d,delta] = polyval(p,abs(Ia),Ss,mu);
%     I=1./P_d;
%     %     imagesc(Ia,[0 80]);colormap jet;colorbar;
%     imagesc(I,[100 1000]);colormap jet;colorbar;
    %imshow(I2a)
    
%         figure(1)
%         imshow(I2a)
%         hold on
    %frame = step(videoFileReader);
    for q=1:Ds(2)
        [points, validity] = step(trackers{q},I2a);
%         Proporcion=sum(validity)/size(validity,1);
%         if Proporcion<0.2
%             validity=zeros(size(validity));
%         end
        %         plot(points(validity, 1),points(validity, 2),'g+')
%         if q==3
%             out = insertMarker(I2a,points(validity, :),'+');
%             imshow(out);%,'InitialMagnification',50)
%             
%             pause()
%         end
        if ~isempty(points(validity, 2)) && sum(validity)/size(validity,1)>0.2  % Por si el tracker no pierde los puntos
            y=round(mean(round(points(validity, 2))));
            x=round(mean(round(points(validity, 1))));
            if ((S(1)-y)>Ventana(1) && x>Ventana(2) && S(2)-x>Ventana(2)&& y>Ventana(1))%en esto evito tener que ventanear cerca de los bordes
                Objetivo=[x y]; % Obtengo un punto aproximado centrado
                % Ver si se puede reducir la siguiente ventana
                NuevaVentana=[Objetivo(1)-Ventana(2)*3/4 Objetivo(2)-Ventana(1)*3/4 Ventana(2)*4/3 Ventana(1)*4/3];
                Ic=imcrop(I2a,NuevaVentana);
                Dimencion=size(Ic);
                Solapamiento3=0.95;% Solapamiento a 1 pixel                
                Centros2=TroncoDetect(Ic,classifier,Ventana,Solapamiento3,Caracteristicas,IMAGENES);
                [Troncos2, P_L]=Centroides(Centros2,[Dimencion(1) Dimencion(2)],IMAGENES,0.003); % Se obtiene la nueva posicion de los troncos; Le bajo el umbral a 0.003 ya que como la "nuevaVEntana" es mas pequeña, se generan menos puntos, implicando menores niveles
                sst=size(Troncos2);
                Distancia2=zeros(sst(1),4);
                xa=zeros(1,sst(1));
                ya=zeros(1,sst(1));
                %---------- Muy util
%                 figure(q);imshow(Ic);pause()
                % ----------------------
                % Lo siguiente sirve por si hay mas de un tronco en la
                % imagen, calcula el angulo y distancia de cada uno
                for dd1=1:sst(1)
                    xa(dd1)=round(Troncos2(dd1,1)+Objetivo(1)-Ventana(2)*3/4);
                    ya(dd1)=round(Troncos2(dd1,2)+Objetivo(2)-Ventana(1)*3/4);
                    if (xa(dd1)>0 && ya(dd1)>0)
                        FiltroGrande=zeros(S(1),S(2));
                        FiltroGrande(ya(dd1)-(LL(1)-1)/2:(ya(dd1)+(LL(1)-1)/2),xa(dd1)-(LL(2)-1)/2:(xa(dd1)+(LL(2)-1)/2))=h;
                        aa=I.*FiltroGrande; dd=isnan(aa);kk=isinf(aa);rr=dd|kk|outliers;
%                         xcorr=xa(dd1)-659.544; % Cx=737.995,576.186 (da esto la izq, calib seba) , 640, 659.544(da esto la izq, calib stereolabs)
                       %  Distancia2(dd1,:)=[sum(sum(aa(~rr))),asin(-xcorr/(xcorr^2+699.585^2)^0.5)];
%                        if NuevosT==0 && Distancia{i-1}(q,1)~=0
%                            Dist_Ant=Distancia{i-1}(q,1);
                           Xi= double(round(Centros2(:,1)+Objetivo(1)-Ventana(2)*3/4));
                           Yi= double(round(Centros2(:,2)+Objetivo(2)-Ventana(1)*3/4));
                           CentrosAct=[Xi Yi];
                           kki= find(Centros2(:,4)==max(Centros2(:,4)));
                          Dist_Ant= I(Yi(kki,1),Xi(kki,1));
                               xcorr=Xi(kki,1)-659.544; % Cx=737.995,576.186 (da esto la izq, calib seba) , 640, 659.544(da esto la izq, calib stereolabs)
                  
                           % I(CentrosAct')
%                            Dist=zeros(size(Xi,1),1);
%                            for Du=1:size(Xi,1)
%                                Dist(Du)=I(Yi(Du,1),Xi(Du,1));
%                            end
%                            min(Dist)
%                            mean(Dist)
%                            I(Yi(kki,1),Xi(kki,1))
%                            pause()
%                             disp('Diferencia con actual')
%                            Mama=Distancia{i-1}(q,1)-I(ya(dd1),xa(dd1));
%                            if abs(Mama)>50
%                                figure (1);imagesc(I,[100 800]);colormap jet;colorbar;
%                                figure (2);imshow(I2a);hold on;plot(xa(dd1),ya(dd1),'rx');hold off                               
%                                pause()
%                            end
%                         else
%                            Dist_Ant =I(ya(dd1),xa(dd1));
%                         end
%  Distancia2(dd1,:)=[EncPlano(xa(dd1),ya(dd1),I,Dist_Ant),asin(-xcorr/(xcorr^2+699.585^2)^0.5)];
%                     
                       Distancia2(dd1,:)=[ Dist_Ant,asin(-xcorr/(xcorr^2+699.585^2)^0.5),Xi(kki,1),Yi(kki,1)];
%                          aa=a.*FiltroGrande; dd=isnan(aa);kk=isinf(aa);rr=dd|kk|outliers;
%                          disp('Altura1')
%                          sum(sum(aa(~rr)))
                    end
                end
                %---------------------------------
                % En caso de que encuentre 2 troncos, se queda con el mas cercano                
                kd=find(Distancia2(1:sst(1),1)~=0);
                kr=find(min(Distancia2(kd,1))); 
                if ~isempty(kr)
%                      x=xa(kr);
%                      y=ya(kr);
                     Distancia{i}(q,:)=[Distancia2(kr,:) NuevosT FRAME1];% [x y]];
                     %                      if NuevosT==0
                     %                     Distancia{i-1}(q,1)-Distancia2(kr,1)
                     %                      end
                     
                     %                     [p00]=EncPlano(x,y,I);
                     % %                     [X,Y] = meshgrid(1:41,1:41);
                     % %                     Z=I(y-20:y+20,x-20:x+20);
                     % %                     figure(3);plot3(X,Y,Z);hold on ;plot3(20,20,I(y,x),'x');plot3(20,20,Distancia2(kr,1),'o');plot3(20,20,p00,'^');hold off;%ylim([I(y,x)-50 I(y,x)+50]);xlim([I(y,x)-50 I(y,x)+50]);
               
                    
%                      if NuevosT==0  && Distancia{i-1}(q,1)~=0
%                          [min(Dist) mean(Dist) I(Yi(kki,1),Xi(kki,1))...
%                          Distancia2(kr,1)-Distancia{i-1}(q,1)]'
%                          pause()
%                          %                      figure(1); plot(I(y-40:y+40,x)); hold on ;plot(40,I(y,x),'x');plot(40,Distancia2(kr,1),'o');plot(40,Distancia{i-1}(q,1),'^');hold off; ylim([I(y,x)-50 I(y,x)+50]);title('corte en Y')
%                          %                      figure(2); plot(I(y,x-40:x+40)); hold on ;plot(40,I(y,x),'x');plot(40,Distancia2(kr,1),'o');plot(40,Distancia{i-1}(q,1),'^');hold off;ylim([I(y,x)-50 I(y,x)+50]);title('corte en X')
%                          %                  [I(y,x) Distancia{i-1}(q,1) Distancia2(kr,1)]'
%                          
%                      end
                     Trx=round(P_L(kr).PixelList(:,1)+Objetivo(1)-Ventana(2)*3/4);
                      Try=round(P_L(kr).PixelList(:,2)+Objetivo(2)-Ventana(1)*3/4);
%                       imshow(I2a);hold on;plot(Trx,Try,'gx');hold off
                     setPoints(trackers{q},[Trx Try])
                     
%                                          [Traquear]=GenPunTk([x y],I2a,IMAGENES,0.7,Ventana); %Conviene agregar un factor para la ventana?
%                                          setPoints(trackers{q},Traquear{1}) % Actualizo los nuevos puntos del tracker
                end
                %                  plot(x,y,'gx')
            else
                Activo(q)=0;
            end
        else
            Activo(q)=0;
        end        
    end
    %--------------------- Aca termina una imagen
%     pause()
%     hold off
    if sum(Activo)<3
%         if i==6
%             IMAGENES=1;
%         else
%             IMAGENES=0;
%         end
        % Busco nuevos troncos
        disp('Buscar nuevos troncos')       
        Centros2=TroncoDetect(I2a,classifier,Ventana,Solapamiento,Caracteristicas,IMAGENES);
        [Troncos]=Centroides(Centros2,[S(1) S(2)],IMAGENES);
        [Traquear]=GenPunTk(Troncos,I2a,IMAGENES);
        Ds=size(Traquear);
        for q=1:Ds(2)
            trackers{q}=clone(tracker);           
            initialize(trackers{q},Traquear{q},I2a);
        end
        
        if size(Distancia,2)==i
            if (sum(Distancia{i}(:,5))==0 )
%                 Activo=ones(1,Ds(2));
                Distancia{i}(:,:)=0;
                FRAME1=FRAME1-1;
                i=i-1;
%                 NuevosT=1;
            end
            
        end
        Activo=ones(1,Ds(2));
        NuevosT=1;
        close all;
    else
        NuevosT=0;
    end   
    %hold off
    FRAME1=FRAME1+1;
    i=i+1    
    if FRAME1>FRAME_Fin
        Seguir=0;
    end
end
disp('Fin')
%%
%Esta seccion se encarga de mostrar puntos filtrandolos y ordenadolos
%previamente
ORF2=[0 0];
da=size(Distancia);
Cr=zeros(da(2),2);
for i=2:da(2)
    % acomodo los vectores para que se pueda saber cual es viejo y cual es
    % nuevo; NO considera el rescaneo de troncos lo cual provoca un
    % reacomodamiento de las posiciones
    if ~isempty(Distancia{i})&& ~isempty(Distancia{i-1})
        if sum(Distancia{i}(:,3))==0 % no tiene que tner una actualizacion el frame siguiente
%             OR1=Distancia{i-1}(:,cat(2,(1:2),(4:5))); % Copio angulos, distancias, y posicion en imagen; antes Distancia{i-1}(:,1:2);
%             OR2=Distancia{i}(:,cat(2,(1:2),(4:5)));
            OR1=Distancia{i-1}(:,1:2); % Copio angulos, distancias, y posicion en imagen; antes Distancia{i-1}(:,1:2);
            OR2=Distancia{i}(:,1:2);
            a=size(OR1(:,1));b=size(OR2(:,1));
            aa=max([a b]); V1=zeros(aa,2);V2=zeros(aa,2);
            V1(1:a,:)=OR1; V2(1:b,:)=OR2; % Hago 2 vectores de igual dimension
            nz1=find(V1(:,1)~=0);dd=zeros(1,aa);dd(nz1)=1;
            nz2=find(V2(:,1)~=0);dd2=zeros(1,aa);dd2(nz2)=1; % genero una matriz que pone 1 donde no hay zeros
            a=dd&dd2;a2=xor(dd,dd2);
            clear OR1;clear OR2;
            OR1=V1(a,:); OR2=V2(a,:); % Vuelve a cargar los valores de las variables pero esta vez en un vector de igual dimension y sin zeros
            if V2(a2,1)~=0
                ORF2=V2(a2,:);
            else
                ORF2=[0 0];
            end
            %-----------------------------------------------------
            %Hasta aca OR1 son los puntos del frame i y OR2 los mismos puntos
            %pero en el frame i+1 ORF2 son los puntos "nuevos"
            [x,y] = pol2cart(pi/2+OR1(:,2),OR1(:,1));
            [x2,y2] = pol2cart(pi/2+OR2(:,2),OR2(:,1));
            %---------------------------------------------------------
            % Se obtienen distancias de desplazamiento y se descartan aquellas
            % que se mueven mas de lo esperado
            Vv=x(:)-x2(:); Vb=y(:)-y2(:); Vp=[Vv Vb]; rata=zeros(size(Vp,1),1);
            for mu=1:size(Vp,1)
                rata(mu)=norm(Vp(mu,:));
            end
            In=find(rata<1000);
           % find(rata>100)
           
                        figure(1)
                        plot(x(In),y(In),'bx');xlim([-400 400]);ylim([0 1000])
                        hold on
                        plot(x2(In),y2(In),'rx')
                        hold off
                        pause()
%             % ---------------------------------------------------
            %Lo que sigue calcula el desplazamiento de la camara
            
%             Pw=[x,y]; % Punto del mundo
%             Camara1=Pw(1,:);
%             Pw=Pw(:,:)-Pw(1,:)% Referencio con respecto al primero
%             figure(2)
%             plot(-Pw(:,1),-Pw(:,2),'rx')
%            hold on
%            plot(Camara1(1),Camara1(2),'^')
%             for qq=1:size(Pw,1)
%             text(Pw(qq,1),Pw(qq,2),num2str(qq))
%             end
            
%             [rotationMatrix,translationVector] = extrinsics( OR1(:,3:4),Pw,Camara.L);
%             [orientation, location] = extrinsicsToCameraPose(rotationMatrix,translationVector);
%             plotCamera('Location',location,'Orientation',orientation,'Size',20);
%             hold on
%             pcshow([Pw,zeros(size(Pw,1),1)],'VerticalAxisDir','down','MarkerSize',40);
%             hold off
            %location
%             pause() 
           
            if  size(In,1) >1
                [Ca,ORF1]=ConversionMarcosRef(OR1(In,:),OR2(In,:),[0 0]);
                [C1(1), C2(2)]= pol2cart(Ca(2),Ca(1));
                Cr(i,:)=[C1(1) C2(2)];
               % Ct=Cr+Ct;
%                 figure(2)
%                 plot(Ct(1),Ct(2),'rx'); text(Ct(1),Ct(2),num2str(i))
%                 hold on
            end
        else
            disp('Rescaneo')
        end
%         pause()
        i
    end
end
%hold off
Ct=[0 0];
for i=1:da(2)
    if ~isnan(Cr(i,1))
    Ct=Ct+Cr(i,:);
    figure(2)
    plot(Ct(1),Ct(2),'rx'); text(Ct(1),Ct(2),num2str(i))
    hold on
    pause()
    end
end
hold off
%%
% GEnerador de puntos artificiales
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
% Esta idea no funciona muy bien que digamos... plan b?
% Prueba piloto, lo que voy a hacer aca es intentar calcular las distancias
% en base a detectar el mismo tronco en las 2 imagenes por separado para
% luego hacer la disparidad manualmente.

I1=imread(sprintf('%s%1dd.jpg',img_dir,FRAME1));
I2=imread(sprintf('%s%1di.jpg',img_dir,FRAME1));
I1a = undistortImage(I1,Camara.R);
I2a = undistortImage(I2,Camara.L);
%-----------------------------------------------------------
% % Sin disparidad
Centros2=TroncoDetect(I2a,classifier,Ventana,Solapamiento,Caracteristicas,IMAGENES);
[Troncos]=Centroides(Centros2,[S(1) S(2)],IMAGENES);
TroncosI1=zeros(size(Troncos,1),2);
for i=1:size(Troncos,1)
    x=round(Troncos(i,1));
    y=round(Troncos(i,2));
    if ((S(1)-y)>Ventana(1) && x>Ventana(2) && S(2)-x>Ventana(2)&& y>Ventana(1))%en esto evito tener que ventanear cerca de los bordes
        Objetivo=[Troncos(i,1)+50 Troncos(i,2)]; % Obtengo un punto aproximado centrado
        % Ver si se puede reducir la siguiente ventana
        NuevaVentana=[Objetivo(1)-Ventana(2) Objetivo(2)-Ventana(1) 2*Ventana(2) 2*Ventana(1)];
        Ic=imcrop(I1a,NuevaVentana);
        Dimencion=size(Ic);
%         figure(1)
%         imshow(Ic)
        Solapamiento3=0.95;% Solapamiento a 1 pixel
        Centros2=TroncoDetect(Ic,classifier,Ventana,Solapamiento3,Caracteristicas,IMAGENES);
        Troncos2=Centroides(Centros2,[Dimencion(1) Dimencion(2)],IMAGENES); % Se obtiene la nueva posicion de los troncos
        if ~isempty(Troncos2(:))
            xa=round(Troncos2(:,1))+Objetivo(1)-Ventana(2);
            ya=round(Troncos2(:,2))+Objetivo(2)-Ventana(1);
            % --- Me quedo con el conjunto de puntos que este mas cercano
            % al borde
            aux=S(2)-xa;aux2=[xa ;aux];r=find(aux2==min(aux2));
            if r>size(xa,1)
                r=r-size(xa,1);
            end
            TroncosI1(i,:)=[xa(r) ya(r)];
            figure(2)
            imshow(I1a);
            hold on
            plot(xa(r),ya(r),'rx')
            hold off
            pause()
        end
    end
end
zz=find(TroncosI1(:,1)~=0);
distt=-Troncos(zz,1)+TroncosI1(zz,1);





% Centros3=TroncoDetect(I1a,classifier,Ventana,Solapamiento,Caracteristicas,IMAGENES);
% [Troncos3]=Centroides(Centros3,[S(1) S(2)],IMAGENES);
%----------------------------------
% % Con disparidad
% DisparityRange=[0 80];BlockSize=5;DistanceThreshold=80;
% Ia = disparity(rgb2gray(I2), rgb2gray(I1),'BlockSize',BlockSize,'DistanceThreshold',DistanceThreshold,'DisparityRange',DisparityRange);%,'Method','BlockMatching');%,'DisparityRange',disparityRange);
% [P_d,delta] = polyval(p,Ia,Ss,mu);
% I=1./P_d;
%-----------------------------------------------------
% %Visualizacion
% figure(1)
% imshow(I2a);
% hold on
% plot(Troncos(:,1),Troncos(:,2),'rx')
% hold off
% figure(2)
% imshow(I1a);
% hold on
% plot(TroncosI1(:,1),TroncosI1(:,2),'rx')
% hold off


% figure(3)
% plot(Troncos(:,1),Troncos(:,2),'bx')
% hold on
% plot(Troncos3(:,1),Troncos3(:,2),'rx')
% hold off

% Uso la misma tecnica que en el codigo general, filtro los puntos "nuevos"
% OR1=Troncos;
% OR2=Troncos3;
% a=size(OR1(:,1));b=size(OR2(:,1));
% aa=max([a b]); V1=zeros(aa,2);V2=zeros(aa,2);
% V1(1:a,:)=OR1; V2(1:b,:)=OR2;
% nz1=find(V1(:,1)~=0);dd=zeros(1,aa);dd(nz1)=1;
% nz2=find(V2(:,1)~=0);dd2=zeros(1,aa);dd2(nz2)=1;
% a=dd&dd2;a2=xor(dd,dd2);
% clear OR1;clear OR2;
% OR1=V1(a,:); OR2=V2(a,:);
% Vv=OR1(:,1)-OR2(:,1); Vb=OR1(:,2)-OR2(:,2); Vp=[Vv Vb]; rata=zeros(size(Vp,1),1);
% % for mu1=1:size(Vp,1)
% %     rata(mu1)=norm(Vp(mu1,:));
% % end
% % In=find(rata<100);
% % -------------- Calculo disparidad manualmente
% V=OR1(:,1)-OR2(:,1);
% a=find(V<150);


% figure(3)
% imshow(I1a);
% hold on
% plot(OR2(a,1),OR2(a,2),'rx')
% hold off
% figure(4)
% imshow(I2a);
% hold on
% plot(OR1(a,1),OR1(a,2),'rx')
% hold off



mm=find(distt>20);
[P_d] = polyval(p,distt(mm),Ss,mu);
ad=1./P_d;
% ---------------------- Calculo distancia CON disparidad automatica
% ad=zeros(size(Troncos,1),1);
% for i=1:size(Troncos,1)
% ad(i)=I(round(Troncos(i,2)),round(Troncos(i,1)));
% end
% %------------------------------------------------
% figure(3)
% plot(Troncos(In,1),Troncos(In,2),'bx')
% hold on
% plot(Troncos3(In,1),Troncos3(In,2),'rx')
% hold off
 xcorr1=Troncos(zz(mm),1)-576.186; % Cx=737.995,576.186, 640
 xcorr2=TroncosI1(zz(mm),1)-737.995;
 Distancia1=zeros(size(Troncos(zz(mm),1),1),2);
 Distancia2=zeros(size(Troncos(zz(mm),1),1),2);
 % Si usas el metodo automatico hay que cambiar ad por ad(i)
 for i=1:size(Troncos(zz(mm),1),1)
 Distancia1(i,:)=[ad(i),asin(-xcorr1(i)/(xcorr1(i)^2+700^2)^0.5)];%681
 Distancia2(i,:)=[ad(i),asin(-xcorr2(i)/(xcorr2(i)^2+700^2)^0.5)];  
 end
 
 [Ca,ORF1]=ConversionMarcosRef(Distancia1,Distancia2,[0 0]);
 [C1(1), C1(2)]= pol2cart(Ca(2),Ca(1));
 Cr=[C1(1) C1(2)];

 

 [x,y] = pol2cart(Distancia1(:,2),Distancia1(:,1));
 [x2,y2] = pol2cart(Distancia2(:,2),Distancia2(:,1));
 
 figure(1)
 plot(x,y,'bx');ylim([-500 500]);xlim([0 1000])
 hold on
 plot(x2,y2,'rx')
 hold off
%%
% Con disparidad automatica
I1=imread(sprintf('%s%1dd.jpg',img_dir,FRAME1));
I2=imread(sprintf('%s%1di.jpg',img_dir,FRAME1));
% % Con disparidad
DisparityRange=[0 112];BlockSize=5;DistanceThreshold=112;
Ia = disparity(rgb2gray(I2), rgb2gray(I1),'BlockSize',BlockSize,'DistanceThreshold',DistanceThreshold,'DisparityRange',DisparityRange);%,'Method','BlockMatching');%,'DisparityRange',disparityRange);
[P_d,delta] = polyval(p,Ia,Ss,mu);
I=1./P_d;
%   imagesc(Ia,DisparityRange);colormap jet;colorbar; 
%%
% Hubo exito
% % Otra idea es hacer un ransac o fitear una curva al rededor del punto
% encontrado como tronco
Z=I(y-40:y+40,x-40:x+40); find(Z>1000)
outliersfit=Z > 1000 | Z < 50;
 [X,Y] = meshgrid(1:81,1:81);
 Cucu=find(X); % X(Cucu)
 InZ=find(outliersfit==0); %outliersfit(InZ);
 [xData, yData, zData] = prepareSurfaceData( X, Y, Z );
 outliersfit=zData > 1000 | zData < 50;
%  X=1:81;
%  Y=1:81;
fitobject = fit([xData,yData],zData,'poly11','Exclude',outliersfit) ;
figure(1);
plot(fitobject,[xData yData],zData,'Exclude',outliersfit)

%% 
% % Este nuevo codigo implementa la translacion y la rotacion a partir de
% la funcion: estimateWorldCameraPose


[rotationMatrix,translationVector] = extrinsics(imagePoints,worldPoints,cameraParams)
[worldOrientation,worldLocation] = estimateWorldCameraPose(imagePoints,worldPoints,cameraParams)
%% Funciona! maso maso, falta probar mas y mas
% Idea 32.0
Ds=size(Distancia,2);
ok=1;Set=1;q=1;
while ok==1
    %---- Adquiero la cantidad de imagenes sin una actualizacion de troncos
    
    if sum(Distancia{Set}(:,3))>0
        i=Set+1;q=1;
    while  sum(Distancia{i}(:,3))==0
        q=q+1;
        i=i+1;
        if isempty(Distancia{i})
            i=i+1;
        end
    end
    i=Set;
    [x,y] = pol2cart(pi/2+Distancia{i}(:,2),Distancia{i}(:,1));
    n=size(x,1); % n es la cantidad de troncos, q es la cantidad de imagenes
    V=zeros(q,n,2);
    %-------- Convierto todos los datos a coordenadas cartesianas
    for i=Set:q+Set
        if ~isempty(Distancia{i})
        [x,y] = pol2cart(pi/2+Distancia{i}(:,2),Distancia{i}(:,1));
        V(i-Set+1,1:size(x,1),:)=[x,y];
        end
    end
    n=size(V(1,:,1),2);
%     nz=find(V(1,:,1),1); %momentaneamente elijo como referencia al primero no nulo
%     V3=V-V(1,nz,1:2);
    V2=zeros(n,3);
    %--------- Obtengo la ubicacion de los troncos y la variancia de su
    %ubicacion
    for i=1:n
        [k]=find(V(:,i,1));
        if ~isempty(k)
            V2(i,1:2)=median(V(k,i,:));% mean o median? :O 
            V2(i,3)=sum(var(V(k,i,:)));
        end
    end
    m=find(V2(:,3));
    Ref=find(V2(:,3)==min(V2(m,3))); % Me quedo con aquel punto que tiene menor variancia para tomarlo como referencia
   %--- Saco aquellas referencias que tengan pocas medidas
   Puntaje=zeros(n,1);
   for i=1:n
       m=find(V(:,i,1)==0);
       if ~isempty(m)
           Puntaje(i)=numel(m);
       end
   end
    a=Puntaje/q;
    in=find(a<0.5);  % Como requisito pongo que al menos tenga el 50% de puntos  
    Origen=V2(Ref,1:2);
    Todos=V2(in,1:2)-Origen; % Todos es el vector de posicion de los troncos considerando Troncos(Ref,:)=[0 0] como el de referencia
    %---- MUESTRA la posicion obtenida con las mediciones
    figure(1)
    plot(Todos(:,1),Todos(:,2),'^')
    hold on
    V4=zeros(q+1,n,2);
    V4(:,:,1)=V(:,:,1)-Origen(1);
    V4(:,:,2)=V(:,:,2)-Origen(2);
    for i=1:q
        plot(V4(i,in,1),V4(i,in,2),'x')
    end
    hold off
    pause()
    %-----------------------------------------------
    %------ Usando el algoritmo de Tania y teniendo en cuenta las
    %posiciones de los troncos conocidas, se calculan los desplazamientos
    %relativos
    [tita,ro]=cart2pol(Todos(:,1),Todos(:,2));
    figure(1)
    plot(Todos(:,1),Todos(:,2),'^')
    hold on
    for i=1:q
        [tita2,ro2]=cart2pol(V(i,:,1),V(i,:,2));
        k=find(tita2(in));
        if ~isempty(k)
        [Ca,ORF1]=ConversionMarcosRef([ro(k) tita(k)],[ro2(in(k))' tita2(in(k))'],[0 0]);
        [x,y]=pol2cart(Ca(2),Ca(1))  ;
        plot(x,y,'x')
       pause()
        end
    end
    hold off
    Set=Set+q;
    if Set<=Ds % Por si ya llego al final del vector de datos
        ok=0;
        while ok==0
            if sum(Distancia{Set}(:,3))>0 && sum(Distancia{Set+1}(:,3))==0
                ok=1;
            else
                ok=0;
                Set=Set+1;
            end
        end
    else
        ok=0;
    end
    else
        ok=0;
    end
    
end
disp('Fin')

