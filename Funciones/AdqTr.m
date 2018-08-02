% Adquisicion de datos
function [Distancia, Data,Parametros]=AdqTr(x,y,Data,Parametros)
CamTx=Parametros.Camara.L.IntrinsicMatrix;
if ((Parametros.SizeImg(1)-y)>Parametros.Ventana(1) && x>Parametros.Ventana(2) && Parametros.SizeImg(2)-x>Parametros.Ventana(2)&& y>Parametros.Ventana(1))%en esto evito tener que ventanear cerca de los bordes
    Objetivo=[x y]; % Obtengo un punto aproximado centrado
    % Ver si se puede reducir la siguiente ventana
    NuevaVentana=[Objetivo(1)-Parametros.Ventana(2)*3/4 Objetivo(2)-Parametros.Ventana(1)*3/4 Parametros.Ventana(2)*4/3 Parametros.Ventana(1)*4/3];
    Ic=imcrop(Data.Img.I2a,NuevaVentana);
    Parametros.Centroides.Dimencion=size(Ic);
    Parametros.Solapamiento=0.95;% Solapamiento a 1 pixel
    Centros2=TroncoDetect(Ic,Parametros);
    [Troncos2, P_L]=Centroides(Centros2,Parametros,0.003); % Se obtiene la nueva posicion de los troncos; Le bajo el umbral a 0.003 ya que como la "nuevaVEntana" es mas pequeña, se generan menos puntos, implicando menores niveles
    sst=size(Troncos2);
    Distancia2=zeros(sst(1),4);
    xa=zeros(1,sst(1)); ya=zeros(1,sst(1));
    %---------- Muy util
    %     figure(Data.NTracker);imshow(Ic);pause(0.3) % hay que agregar el
    %     parametro de la figura para que la ubique automaticamente en la
    %     pantalla
    % ----------------------
    % Lo siguiente sirve por si hay mas de un tronco en la imagen, calcula el angulo y distancia de cada uno
    if sst(1)~=0 % Si no encuentra tronco
        for dd1=1:sst(1)
            xa(dd1)=round(Troncos2(dd1,1)+Objetivo(1)-Parametros.Ventana(2)*3/4);
            ya(dd1)=round(Troncos2(dd1,2)+Objetivo(2)-Parametros.Ventana(1)*3/4);
            if (xa(dd1)>0 && ya(dd1)>0)
                Xi= double(round(Centros2(:,1)+Objetivo(1)-Parametros.Ventana(2)*3/4));
                Yi= double(round(Centros2(:,2)+Objetivo(2)-Parametros.Ventana(1)*3/4));
                %             Med=zeros(size(Xi,1),1);
                %             for m=1:size(Xi,1)
                %                 Med(m)=Data.Img.I(Yi(m,1),Xi(m,1));
                %             end
                %             k=isnan(Med);
                %             Dist=median(Med(~k));
                %             XX=median(Xi(:,1));YY=median(Yi(:,1));
                %             xcorr=XX-CamTx(3,1);angulo=-atan(xcorr/CamTx(1,1));
                
                kki= find(Centros2(:,4)==max(Centros2(:,4)));
                Dist= Data.Img.I(Yi(kki,1),Xi(kki,1));
                if isnan(Dist)
                    while isnan(Dist) & sum(Centros2(:,4))~=0
                        Centros2(kki,4)=0;
                        kki= find(Centros2(:,4)==max(Centros2(:,4)));
                        Dist= Data.Img.I(Yi(kki,1),Xi(kki,1));
                    end
                    if sum(Centros2(:,4))==0
                        disp('Todos NaN')
                        Dist=NaN;
                    end
                end
                XX=round(mean(Xi(kki,1)));YY=round(mean(Yi(kki,1)));
                xcorr=XX-CamTx(3,1);angulo=-atan(xcorr/CamTx(1,1));
                
                
                %              Dist=CorteZ([XX,YY],Parametros,Data);
                if ~isempty(Dist)
                    Distancia2(dd1,:)=[Dist,angulo,XX,YY];
                end
            end
        end
        
        %---------------------------------
        % En caso de que encuentre 2 troncos, se queda con el mas cercano
        kd=find(Distancia2(1:sst(1),1)~=0);
        kr=find(min(Distancia2(kd,1)));
        if ~isempty(kr)
            Distancia=[Distancia2(kr,:) Data.NuevosT Parametros.FrameActual];% [x y]];
            
            
%             Trx=round(P_L(kr).PixelList(:,1)+Objetivo(1)-Parametros.Ventana(2)*3/4); % Cambio el marco de referencia del local al global
%             Try=round(P_L(kr).PixelList(:,2)+Objetivo(2)-Parametros.Ventana(1)*3/4);
%             %                       imshow(I2a);hold on;plot(Trx,Try,'gx');hold off
%             setPoints(Data.Trackers.trackers{Data.NTracker},[Trx Try])
            %         Data.Activo(Data.NTracker)=1;
            [Traquear]=GenPunTk([XX YY],Data.Img.I2a,Parametros.IMAGENES,0.7); %Conviene agregar un factor para la ventana?
             setPoints(Data.Trackers.trackers{Data.NTracker},Traquear{1}) % Actualizo los nuevos puntos del tracker
        else
            Distancia=[];
            Data.Activo(Data.NTracker)=0;
        end
    else
        Data.Activo(Data.NTracker)=0;
        Distancia=[];
    end
else
    Data.Activo(Data.NTracker)=0;
    Distancia=[];
    
end
end



function mostrarPuntos
figure(1)
 imagesc(Data.Img.I,[100 1000]);colormap jet;colorbar;
 hold on
 Med=zeros(size(Xi,1),1);
for m=1:size(Xi,1)
    Med(m)=Data.Img.I(Yi(m,1),Xi(m,1))  
    plot(Xi(m,1),Yi(m,1),'rx')
end
k=isnan(Med);
mean(Med(~k))
median(Med(~k))
hold off
figure(2)
imshow(Data.Img.I2a)
hold on
for m=1:size(Xi,1)
    
    plot(Xi(m,1),Yi(m,1),'rx')
end
hold off
end
