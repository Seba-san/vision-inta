function [bbox]=FunPira(I,Ventana,Solapamiento,Escala)
%Esta funcion genera las cajas en el formato necesario para cargarlo en
%otras funciones.
% Ventana debe estar en formato [Alto Ancho]; Por defecto es: Ventana=[140 95] 
%Solapamiento [vertical horizontal] pixeles que se solapan en la vertical y
%pixeles que se solapan en lo horizontal. Si no dice nada se asume: Solapamiento=[10 10]
% bbox esta en el formato: bbox(i,:)=[x y Ventana(2) Ventana(1) escala];
if nargin<2
Ventana=[140 95];% Alto ancho
end
if nargin<3
Solapamiento=[10 10];% en vertical, en horizontal
end
if nargin<4
    Escala=1;
end
S=size(I);
if Escala==1
EscMin=1/(min(S(1)/Ventana(1),S(2)/Ventana(2))); % Escala minima
else
   EscMin=1; 
end

i=1;
bbox=zeros(100,5); % OJO, son 72, con este tamaño de ventana, esta cantidad de escalas y esta resolucion!!

for escala=1:-0.2:EscMin   
    I = imresize(I,escala);
    S=size(I);
    % Ventana deslizante
    for y=1:Ventana(1)-Solapamiento(1):S(1)-Ventana(1) %Le resto una ventana para que no quede fuera de la imagen
        for x=1:Ventana(2)-Solapamiento(2):S(2)-Ventana(2)
            bbox(i,:)=[x y Ventana(2) Ventana(1) escala];
          %  Ic = imcrop(I,bbox);   
           % imwrite(Ic,sprintf('%s%d%d.jpg',Dir,tag,i))
            i=i+1;
        end
    end
end
end
%disp('Listo')
