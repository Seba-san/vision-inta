function [C1,ORF1]=ConversionMarcosRef(OR1,OR2,ORF2)
%Esta función sirve para realizar conversiones de marcos de referencia en
%el contexto de estimación de posición de una cámara a partir de objetos de
%referencia fijos entre dos imagenes (frame 1 y 2). Los dos marcos de
%referencia son los correspondientes a cada frame (mr1 y mr2, para
%abreviar). Las entradas de la función son: la posición de los objetos de
%referencia en cada frame, OR1 para el mr1 y OR2 para el mr2, y la posición
%de futuros objetos de referencia en coordenadas del mr2, ORF2. La posición
%de la cámara en el segundo frame es (0,0) en coordenadas del mr2. Se
%pretende estimar las coordenadas de la cámara en el frame 2 y de los
%futuros obtjetos de referencia según el mr1, C1 y ORF1, respectivamente.
%Para ello se buscan las matrices de rotación y trasalción bidimensional
%que convertirían el mr2 en el mr1, suponiendo que OR1 y OR2 son dos
%representaciones de exactamente los mismos puntos (los objetos de
%referencia son fijos). Tanto los puntos de entradas como los de salidas se
%trabajan en coordenadas polares. OR1 y OR2 son matrices de Nx2, donde N es
%la cantidad de objetos de ref, ORi(k,1) es el módulo del k-ésimo objeto de
%ref y ORi(k,2) es el ángulo del mismo (ambos en el marco de ref i).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Explicación de los cálculos matemáticos a efectuar: Dado un punto X=(x,y)
%en el mr2, cuya representación en el mr1 es X'=(x',y'), debería cumplirse
%que: X'=RX+t, donde t es un vector de traslación: t=(tx,ty), y R es una
%matriz de rotación en 2D: R=[cos(u) -sin(u);sin(u) cos(u)]. Si tomamos
%a=cos(u) y b=sin(u), queda: R=[a -b;b a]. Así, la ecuación matricial que
%resulta es: RX+t=[ax-by+tx;bx+ay+ty]=[x';y']=X'. Esto puede reacomodarse
%como: [x -y 1 0;y x 0 1]*[a b tx ty]'=[x';y']. Lo cual permite pensar que
%cada punto agrega dos ecuaciones con un mismo vector de variables: [a b tx
%ty]'. Si tenemos 3 puntos o más, esos nos da un SEL de mxn de la forma
%Ax=b, con m>n. Si rank(A)=n, se puede obtener la solución de mínimos
%cuadrados por descomposición SVD.

%PROBLEMA: Se ignora la restricción de que |R|=1. Solución: se fuerza a que
%la matriz obtenida tenga determinante 1 y se recalcula t suponiendo que la
%matriz de rotación es el R normalizado. REVISAR SI HAY UNA FORMA MEJOR DE
%HACER ESTO O SI MÁS O MENOS ALCANZA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N=size(OR1,1);%Cantidad de objetos de referencia
A=zeros(2*N,4);%Defino las matrices para mayor velocidad
b=zeros(2*N,1);
for k=1:N
    %Conversión a polar del k-ésimo objeto de ref ([x,y] =
    %pol2cart(theta,rho)) (rho=módulo, theta=ángulo)
    [xp,yp]=pol2cart(OR1(k,2),OR1(k,1));
    [x,y]=pol2cart(OR2(k,2),OR2(k,1));
    A(2*k-1:2*k,:)=[x -y 1 0;...%Por cada punto se agregan 2 ec
                     y x 0 1];
    b(2*k-1:2*k,1)=[xp;yp];
end
x=SolMinCuadrados(A,b);%Resolución del SEL Ax=b por mínimos cuadrados.

%La matriz de rotación es:
R=[x(1) -x(2);...
   x(2) x(1)];
%Para que la matriz sea efectivamente de rotación, su determinante debería
%ser 1. Forzamos esta condición:
R=R/det(R);
%Tomando ésta como la matriz de rotación, recalculamos t despejando el SEL
%para que sólo las 2 últimas componentes de x sean incógnitas. Las nuevas
%matrices serían:
%A2=A(:,3:4) y b2=b-A(:,1:2)*[R(1,1);R(2,1)]
t=SolMinCuadrados(A(:,3:4),b-A(:,1:2)*[R(1,1);R(2,1)]);

%Convertimos la cámara y los futuros objetos de referencia del mr1 al mr2
%usando R y t: (Observación: C1=t, ya que C2=(0,0))
[theta,rho] = cart2pol(t(1),t(2));%Conversión a polar
C1=[rho;theta];
K=size(ORF2,1);%Cantidad de objetos de referencia nuevos
if K>0
    for k=1:K
        [x,y]=pol2cart(ORF2(k,2),ORF2(k,1));
        Xp=R*[x;y]+t;
        [theta,rho] = cart2pol(Xp(1),Xp(2));%Conversión a polar
        ORF1(k,:)=[rho;theta];
    end
end
end