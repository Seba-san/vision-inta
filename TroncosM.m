% TroncosM es el intento de encontrar los troncos usando los datos de la
% camara stereo. En este algoritmo se generan Las muestras positivas y
% negativas para el clasificador.

% Cargo Toda la info del programa "profundidad" version 6; voy a usar esas
% nomenclaturas. Para cargar las variables hay que poner la variable
% IMAGENES=0; y poner last_frame=ViewId. Ahi se cargan todas las variables
% al workspace.
clc;clear all;close all
cd 'C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab';
addpath('C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Funciones')
%img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas';
img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas';
Pos='E:\Facultad\Becas\CIN\TRABAJo\Dataset\DataComp2\Positivas\';
Neg='E:\Facultad\Becas\CIN\TRABAJo\Dataset\DataComp2\Negativas\';
warning('off')
%img_dir      ='E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas';
ImageStore=imageDatastore(img_dir);
IMAGENES=0;


for FRAME=51:40:821
    %FRAME=201;
    I1=readimage(ImageStore,FRAME);
    I2=readimage(ImageStore,FRAME+1);
    [I,a,outs]=FunProf(I1,I2,IMAGENES); % aca se hace el primer pase magico
    %figure(1);imagesc(I,[3000 7000]);colormap jet;colorbar;
    %figure(1);imagesc(a,[-1000 7000]);colormap jet;colorbar;
    b=a;
    S=size(a);
    for k=1:S(1)
        for j=1:S(2)
            if (a(k,j)<0 || a(k,j)>4000 )
                b(k,j)=0;  % Recorto alturas negativas y mayores a 4m (supongo que 1000 es 1 metro)
            end
        end
    end
    %figure(1);imagesc(b,[0 4000]);colormap jet;colorbar;
    % detectar OUTLIERS DE SOMBRAS y de regiones de alta luminosidad Marce
    % decia usar HSV y limpiar todo aquello que V<1 o V>254.  ver: https://pdfs.semanticscholar.org/5db2/5e8c1e45bcdb64b743f81dbdc69f32c70004.pdf
    
    %Lo implemento manualmente
    
    % I3=rgb2hsv(I1);
    % [outsx,outsy]=find(I3(:,:,3)>0.01);
    % I3(outsx(:),outsy(:),3)=1;
    % imshow(I3(:,:,3))
    % EscMin=1/(min(S(1)/Ventana(1),S(2)/Ventana(2))); % Escala minima
    
    
    %close all
    Ventana=[140 95];% Alto ancho
    Solapamiento=[130 90];% en vertical, en horizontal
    [bbox]=FunPira(I2,Ventana,Solapamiento,0); % Genero todas las escalas y las regiones a recortar en un vector bbox(i,:)=[x y Ventana(2) Ventana(1) escala];
    disp('Listo')
     figure(1)
     imshow(I2)
    prompt='¿Hay tronco? [Y/N] Y=';
%     Troncos = inputdlg(prompt,'hola',1,{'3'}); str2uint8(Troncos{1})
otro=1;
    while (otro)
        figure(1)
        %imshow(I2)
        [x,y] = ginput(1);
        Punto=[x,y];
        hold on
        plot(x,y,'xr','LineWidth',3)
        hold off
        [indice,err]=Buscbbox(Punto,bbox,Ventana);
        if err==0
            Ss=size(indice);
            for i=1:Ss(2)
                Ii = imresize(I2,bbox(indice(i),5)); % Es todo por 3 porque una es la imagen, otra es la disparidad y la otra 
                Id=imresize(I,bbox(indice(i),5));
                Ia=imresize(b,bbox(indice(i),5));
                Ici = imcrop(Ii,bbox(indice(i),1:4));
                Icd = imcrop(Id,bbox(indice(i),1:4));
                Ica = imcrop(Ia,bbox(indice(i),1:4));
                imwrite(Ici,sprintf('%s%d_%d.jpg',Pos,FRAME,indice(i)))
                save(sprintf('%s%d_%d.mat',Pos,FRAME,indice(i)),'Icd','Ica')
%                 figure(i)
%                 imshow(Ici)
%                 figure(i+1)
%                 imagesc(Icd,[3000 7000]);colormap jet;colorbar;
%                 figure(i+2)
%                 imagesc(Ica,[0 4000]); colormap jet;colorbar;
%                 pause()
%                 close all
            end
        end
        
        % Genero las imagenes negativas muy cercanas a las positivas. Esto lo
    % hago tomando el punto de referencia y metiendole ruido con una
    % amplitud determinada
    
        x=Punto(1);y=Punto(2);
        Signo=[0 180]; % Sirve para que excluya los angulos 270 y 90 con un margen de 30°
        Rm=40; R=rand(1)*10+Rm; fi=((rand(1)*150-75)+Signo(randperm(2,1)))*2*pi/360; [dx,dy] = pol2cart(fi,R); % En polares es mas facil que hacerlo en cartecianas
        Punto(1)=x+dx;Punto(2)=y+dy;
        [indice,err]=Buscbbox(Punto,bbox,Ventana);
        if err==0
            Ss=size(indice);
            for i=1:Ss(2)
                Ii = imresize(I2,bbox(indice(i),5));
                Id=imresize(I,bbox(indice(i),5));
                Ia=imresize(b,bbox(indice(i),5));
                Ici = imcrop(Ii,bbox(indice(i),1:4));
                Icd = imcrop(Id,bbox(indice(i),1:4));
                Ica = imcrop(Ia,bbox(indice(i),1:4));
                imwrite(Ici,sprintf('%s%d_%d.jpg',Neg,FRAME,indice(i)))
                save(sprintf('%s%d_%d.mat',Neg,FRAME,indice(i)),'Icd','Ica')
%                 figure(2)
%                 imshow(Ici)
%                 figure(i+1)
%                 imagesc(Icd,[3000 7000]);colormap jet;colorbar;
%                 figure(i+2)
%                 imagesc(Ica,[0 4000]); colormap jet;colorbar;
%                  pause()
%                 close all
            end
        end
        
        
        
        data = input(prompt);
        if isempty(data)
            otro=1;
        else
            otro=0;
        end
    end
    
    
    
    
    
    
    
    
    
    % figure(i)
    % imshow(Ici)
    % figure(i+Ss(2))
    % imagesc(Icd,[3000 7000]);colormap jet;colorbar;
    % DDD=sum(Ica);
    % plot(DDD)
    % figure(i+Ss(2)*2)
    % imagesc(Ica,[0 4000]); colormap jet;colorbar;
    %
    % imagesc(b,[0 4000]); colormap jet;colorbar;
    
end



warning('on')



% trainingFeatures = zeros(D(1),6336);
% for i=1:D(1)
% II = imresize(I2,bbox(i,5));
% Ic = imcrop(II,bbox(i,1:4));
% Ia = imresize(b,bbox(i,5));
% Disp = imcrop(Ia,bbox(i,1:4));
% %imshowpair(Ic,Disp,'montage')
% %[trainingFeatures(i,:)] = extractHOGFeatures(b,'CellSize',[8 8]);
% 
% subplot(2,1,1)
% imagesc(Disp,[0 6000]); colormap jet;colorbar;
% subplot(2,1,2)
% imshow(Ic)
% pause(1)
% end
% [featureVector,hogVisualization] = extractHOGFeatures(b,'CellSize',[4 4]);
% figure(3);imagesc(b,[0 4000]); colormap jet;colorbar
% hold on;
% plot(hogVisualization);
% hold off

%%
Cx=0; Cy=0; Cr=40; Vx=39;
close all
x=rand(1)*80-40;
        r=rand(1)*10+Cr;
        y=(r^2-x^2)^0.5;
        plot(x,y,'rx')
hold on
for i=1:500
x=Vx*(rand(1)*2-1);
        r=rand(1)*10+Cr;
        y=(r^2-x^2)^0.5;
        signo=rand(1)*2-1;
        if signo<0
            y=-y;
        end
        plot(x+Cx,y+Cy,'rx')

end
hold off

%% En polares
Rm=40; 
R=rand(1,100)*10+Rm;
fi=rand(1,100)*2*pi; 
[x,y] = pol2cart(fi,R);
plot(x+10,y+10,'rx')
R=10;Signo=[0 180];
for i=1:500
fi=((rand(1)*150-75)+Signo(randperm(2,1)))*2*pi/360;
[x,y] = pol2cart(fi,R);
plot(x,y,'rx')
hold on
end
hold off

Cx=10; Cy=10; Cr=40; Vx=40;

x=randn(1,500);
y=randn(1,500);
xp=find(abs(x)>1,100);yp=find(abs(y)>1,100);
plot(x(xp),y(yp),'rx')
h=hist(x)

