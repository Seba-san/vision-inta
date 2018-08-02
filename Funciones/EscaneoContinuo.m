function [Distancia,Data,Parametros]=EscaneoContinuo(Parametros,Data)
% Parametros.IMAGENES=0;
%-----------------------------------------------------------------------
Parametros.Centroides.Dimencion=Parametros.SizeImg;
tracker = vision.PointTracker('MaxBidirectionalError',3);Data.Gentracker=tracker;
[Data]=Iniciar_Traquers(Data,Parametros,0);
% Cargando variables
LL=size(Parametros.h);FiltroGrande=zeros(Parametros.SizeImg(1),Parametros.SizeImg(2));
i=1;Data.Activo=ones(1,Data.Trackers.Ds); Data.NuevosT=1;Data.iteracion=i;
Data.L.PosX=-200;Data.L.Altura=50;Data.R.PosX=200;Data.R.Altura=100;Data.DisMin=300;
%----------------------------------------------------------------
% % Inicio del loop
FRAME1=Parametros.FRAME;
FRAME_Fin=Parametros.FRAME_Fin;
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
 Data.Trackers.Puntos{q}=points(validity,:);
        if ~isempty(points(validity, 2)) && sum(validity)/size(validity,1)>0.2  % Por si el tracker no pierde los puntos
            y=round(mean(round(points(validity, 2))));
            x=round(mean(round(points(validity, 1))));        
%             if i==9
%                 Parametros.IMAGENES=1;
%                 pause()
%             else
%                 Parametros.IMAGENES=0;
%             end
                Data.Trackers.Puntos{q}=points(validity,:);
%----------------------------------------------------------------
% Aca hay mucha magia
            [Distancia_aux, Data,Parametros]=AdqTr(x,y,Data,Parametros);
%-----------------------------------------------------------------
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
    try
    MostrarXZ(Distancia{i})
%     if i==10
%         pause()
%     end
    MostrarEscenario(Distancia{i},Data)
    catch
        disp('No se pudo leer Distancia{i}')
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
    else
        Data.NuevosT=0;
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
%     if i==107
%         Parametros.IMAGENES=0;
% %         pause()
%     end
    if FRAME1>FRAME_Fin
        Seguir=0;
    end
    save('jueves.mat','Distancia');
end
disp('Fin')
end

function MostrarXZ(Distancia)
if ~isempty(Distancia)
    mm=find(~isnan(Distancia(:,1)));
    t=find(Distancia(mm,1));
    
    for k=1:numel(t)
        % hay que pasar los datos de distancia a cartesianos
        [X Y]=pol2cart(Distancia(mm(t(k)),2)+pi/2,Distancia(mm(t(k)),1));
        Y=Y/100;X=X/100;
        if k==1
            mydata=[X Y];
        else
            mydata=cat(1,mydata ,[X Y]);
        end
    end
    figure(4)
    plot(mydata(:,1), mydata(:,2),'rx')
    xlim([-4 4]); ylim([0 10])
    pause(0.3)
end
%     fwrite(fileID, mydata, 'double')
end

function MostrarEscenario(Distancia4,Data)
figure(3)
imshow(Data.Img.I2a)
hold on
Ds=Data.Trackers.Ds;
m=size(Distancia4(:,1),1);
for i=1:Ds
    Posicion.x=min(Data.Trackers.Puntos{i}(:,1));
    Posicion.h=max(Data.Trackers.Puntos{i}(:,1)) -Posicion.x;
    Posicion.y=min(Data.Trackers.Puntos{i}(:,2));
    Posicion.w=max(Data.Trackers.Puntos{i}(:,2))-Posicion.y;
    if m>=i
    if ~isnan(Distancia4(i,1))
    Posicion.label=Distancia4(i,1); 
    else
        Posicion.label=1   ;     
    end
    end
    if i==1
        Pos=[ Posicion.x,  Posicion.y,Posicion.h ,Posicion.w];
        Label= (Posicion.label );
    else
        Pos=cat(1,Pos,[Posicion.x,  Posicion.y,Posicion.h ,Posicion.w]);
        Label= cat(2,Label,([Posicion.label ]));
    end
    if Data.Activo(i)==1
        plot(Data.Trackers.Puntos{i}(:,1),Data.Trackers.Puntos{i}(:,2),'bo')
    end
    if Data.Activo(i)==0
        plot(Data.Trackers.Puntos{i}(:,1),Data.Trackers.Puntos{i}(:,2),'rx')
    end
end
hold off



% RGB=insertObjectAnnotation(Data.Img.I2a,'rectangle',Pos,Label,'TextBoxOpacity',1,'FontSize',20 );
% figure(4)
% imshow(RGB)
pause(1)

end



