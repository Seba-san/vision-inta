function [bbox]=CajasSelectiva(Puntos,Ventana)
%Esta funcion genera las cajas en el formato necesario para cargarlo en
%otras funciones.
% Ventana debe estar en formato [Alto Ancho]; Por defecto es: Ventana=[140 95] 
%Solapamiento [vertical horizontal] pixeles que se solapan en la vertical y
%pixeles que se solapan en lo horizontal. Si no dice nada se asume: Solapamiento=[10 10]
% bbox esta en el formato: bbox(i,:)=[x y Ventana(2) Ventana(1) escala];
% Puntos son los centros de la ventanas
if nargin<2
Ventana=[140 95];% Alto ancho
end

bbox=zeros(size(Puntos(1,:),2),5); 
escala=1;
for i=1:size(Puntos(1,:),2)
    bbox(i,:)=[Puntos(1,i)-Ventana(2)/2 Puntos(2,i)-Ventana(1)/2 Ventana(2) Ventana(1) escala];    
end







% for escala=1:-0.2:EscMin   
%     I = imresize(I,escala);
%     S=size(I);
%     % Ventana deslizante
%     for y=1:Ventana(1)-Solapamiento(1):S(1)-Ventana(1) %Le resto una ventana para que no quede fuera de la imagen
%         for x=1:Ventana(2)-Solapamiento(2):S(2)-Ventana(2)
%             bbox(i,:)=[x y Ventana(2) Ventana(1) escala];
%           %  Ic = imcrop(I,bbox);   
%            % imwrite(Ic,sprintf('%s%d%d.jpg',Dir,tag,i))
%             i=i+1;
%         end
%     end
% end
end
%disp('Listo')