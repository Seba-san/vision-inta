function [indice,err]=Buscbbox(Punto,bbox,Ventana)
% Esta funcion determina cuales son los centros de las bbox que estan mas
% cerca del "Punto". Ahora no se porque tengo que ingresar el parametro "
% Ventana" si esta dentro de bbox... o no?
% La variable "Punto" debe estar en enteros, sino tira error.
x=Punto(1);y=Punto(2);
EscMin=1/(min(720/Ventana(1),1280/Ventana(2))); % Escala minima
i=1;
D=size(bbox);
err=0;
indice=0;
for Escala=1:-0.2:EscMin
    Centros=zeros(D(1),2);
    Centros2=zeros(D(2),1);
    Idx=find(bbox(:,5)==Escala);
    Centros(Idx,:)=[bbox(Idx,1)+Ventana(2)/2 , bbox(Idx,2)+Ventana(1)/2]; % Busco el centro
    Centros2(Idx)=(Centros(Idx,1)-x*Escala).^2+ (Centros(Idx,2)-y*Escala).^2; % Obtengo todas las distancias al punto
    %Centros2(Idx)=Centros2(Idx).^(0.5);
    %Idx2=find(Centros2==0);
    if ~isempty(Centros2(Centros2>0)) % El >0 lo uso porque inicialmente genero un vector de ceros para precargar Centros y Centros2
        if ~isempty(find(Centros2==min(Centros2(Centros2>0)),1))
            if min(Centros2(Centros2>0))<40 % Parametro arbitrario para seleccionar distancias
            indice(i)=find(Centros2==min(Centros2(Centros2>0)),1); % Como el nivel de solapamiento es alto con solo quedarse con una imagen alcanza.
            end
            %min(Centros2(Centros2>0))
        end
    end
    i=i+1;
    
end
if ~indice
   indice=0;err=1; 
end
end

