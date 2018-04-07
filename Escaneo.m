%figure(1);imagesc(b,[0 7000]);colormap jet;colorbar; 
%figure(1);imagesc(I,[3000 7000]);colormap jet;colorbar; 
S=size(b);
se = strel('sphere',5);
Sa=size(se.Neighborhood);
%imshow(se.Neighborhood(:,:,round(Sa(3)/2)))
see=se.Neighborhood(:,:,round(Sa(3)/2));

b2 = imfill(b, 'holes');
figure(2);imagesc(b2,[0 4000]);colormap jet;colorbar; 

S=size(b2);
TresD=zeros(S(1),S(2),20);
Derivada=zeros(S(1),S(2),20);
for i=1:20
    lim1=i*100;
    lim2=i*100+200;
    Sup=b2>lim1;
    Inf=b2<lim2;
    Resultado=Sup&Inf;
%     figure(1)
TresD(:,:,i)=Resultado; % HAY QUE SABER SI DIO CERO!!! (SEPARARLO DEL RESTO DE CEROS) con un ¡¡¡¡¡¡¡¡¡& !!! si señor 
if i>3
    % Derivada(:,:,i)=-TresD(:,:,i-2)+TresD(:,:,i);
    % imagesc(Derivada(:,:,i));colorbar
    % pause();
    
    Fil=TresD(:,:,i)&TresD(:,:,i-1)&TresD(:,:,i-2); 
    imagesc(Fil)
    hold on
    imagesc(Resultado+Fil)
    hold off
    colorbar   
    pause()
end
   % Imerode=imerode(Resultado,see);
%     figure(2)
%     imshow(Imerode)
   %  Imdilatado=imdilate(Imerode,see2);
  %  figure(3)
   % imshow(Imdilatado)
   % imshow(Resultado)
    %pause( )    
end
h1=[-1 0 1;-1 0 1;-1 0 1];
h2=ones(3)/9;
h=[1 1 1;0 0 0;1 1 1]';
B = imfilter(B1,h1);
figure(2);imagesc(B,[0 2]);colormap jet;colorbar; 
b2 = imfill(b, 'holes');
figure(2);imagesc(b2,[0 4000]);colormap jet;colorbar; 
figure(2);imagesc(b,[0 4000]);colormap jet;colorbar; 
B1=imbinarize(b);
figure(2);imagesc(B1,[0 1]);colormap jet;colorbar; 
imshow(Resultado1)

imshow(Resultado)

B3=edge(b);
figure(2);imagesc(B3,[0 2]);colormap jet;colorbar; 









%% Mas boludeo!!!!!




se = strel('sphere',10);
Sa=size(se.Neighborhood);
%imshow(se.Neighborhood(:,:,round(Sa(3)/2)))
see2=se.Neighborhood(:,:,round(Sa(3)/2));
S=size(b);
TresD=zeros(S(1),S(2),20);
for i=1:20
    lim1=i*100;
    lim2=i*100+20;
    Sup=b>lim1;
    Inf=b<lim2;
    Resultado=Sup&Inf;
%     figure(1)
    % imshow(Resultado)
     TresD(:,:,i)=Resultado;
   % Imerode=imerode(Resultado,see);
%     figure(2)
%     imshow(Imerode)
   %  Imdilatado=imdilate(Imerode,see2);
  %  figure(3)
   % imshow(Imdilatado)
   % imshow(Resultado)
    %pause( )
    
end
se = strel('sphere',4);
Sa=size(se.Neighborhood);
%imshow(se.Neighborhood(:,:,round(Sa(3)/2)))
see3=se.Neighborhood(:,:,round(Sa(3)/2));


se = strel('line',10,90);
Sa=size(se.Neighborhood);
%imshow(se.Neighborhood(:,:,round(Sa(3)/2)))
see4=se.Neighborhood;

S=size(I);
TresD=zeros(S(1),S(2),80);
a=1;
for i=3000:50:7000
    lim1=i;
    lim2=i+200;
    Sup=I>lim1;
    Inf=I<lim2;
%     imshow(Sup)
%     pause()
%     imshow(Inf)
%     pause()
    Resultado=Sup&Inf;
    TresD(:,:,a)=Resultado;
%     Imerode=imerode(Resultado,see3);
%   Imdilatado=imdilate(Imerode,see4);
%     figure(1)
%     imagesc(Imdilatado)
%     pause()
a=a+1;
end
ss = regionprops(Imerode,'Orientation');
dd=ss(:).Orientation;
find(dd<95)

%%
% Boludeando y creando un GIF para seguir boludeando :P 

close all
filename = 'Profundidad.gif'; % Specify the output file name
for i=3000:10:7000
    lim1=i;
    lim2=i+200;
    Sup=I>lim1;
    Inf=I<lim2;
%     imshow(Sup)
%     pause()
%     imshow(Inf)
%     pause()
    Resultado=Sup&Inf;
    figure(1)
    imagesc(Resultado)
    
    
    frame = getframe(1);
    im = frame2im(frame);       
[A,map] = rgb2ind(im,256);
    if i == 3000
        imwrite(A,map,filename,'gif','LoopCount',65535,'DelayTime',0.01);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.01);
    end
pause(0.2)
    %figure(1)
    %imshow(Resultado)
    %imagesc(Resultado)
  %  imagesc(I(Resultado),[3000 7000]);colormap jet;colorbar; 
 % i
  %  pause()    
end




for idx = 1:nImages
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
    end
end


