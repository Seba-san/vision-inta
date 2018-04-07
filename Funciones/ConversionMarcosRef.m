function [C1,ORF1]=ConversionMarcosRef(OR1,OR2,ORF2)
%Esta funci�n sirve para realizar conversiones de marcos de referencia en
%el contexto de estimaci�n de posici�n de una c�mara a partir de objetos de
%referencia fijos entre dos imagenes (frame 1 y 2). Los dos marcos de
%referencia son los correspondientes a cada frame (mr1 y mr2, para
%abreviar). Las entradas de la funci�n son: la posici�n de los objetos de
%referencia en cada frame, OR1 para el mr1 y OR2 para el mr2, y la posici�n
%de futuros objetos de referencia en coordenadas del mr2, ORF2. La posici�n
%de la c�mara en el segundo frame es (0,0) en coordenadas del mr2. Se
%pretende estimar las coordenadas de la c�mara en el frame 2 y de los
%futuros obtjetos de referencia seg�n el mr1, C1 y ORF1, respectivamente.
%Para ello se buscan las matrices de rotaci�n y trasalci�n bidimensional
%que convertir�an el mr2 en el mr1, suponiendo que OR1 y OR2 son dos
%representaciones de exactamente los mismos puntos (los objetos de
%referencia son fijos). Tanto los puntos de entradas como los de salidas se
%trabajan en coordenadas polares. OR1 y OR2 son matrices de Nx2, donde N es
%la cantidad de objetos de ref, ORi(k,1) es el m�dulo del k-�simo objeto de
%ref y ORi(k,2) es el �ngulo del mismo (ambos en el marco de ref i).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Explicaci�n de los c�lculos matem�ticos a efectuar: Dado un punto X=(x,y)
%en el mr2, cuya representaci�n en el mr1 es X'=(x',y'), deber�a cumplirse
%que: X'=RX+t, donde t es un vector de traslaci�n: t=(tx,ty), y R es una
%matriz de rotaci�n en 2D: R=[cos(u) -sin(u);sin(u) cos(u)]. Si tomamos
%a=cos(u) y b=sin(u), queda: R=[a -b;b a]. As�, la ecuaci�n matricial que
%resulta es: RX+t=[ax-by+tx;bx+ay+ty]=[x';y']=X'. Esto puede reacomodarse
%como: [x -y 1 0;y x 0 1]*[a b tx ty]'=[x';y']. Lo cual permite pensar que
%cada punto agrega dos ecuaciones con un mismo vector de variables: [a b tx
%ty]'. Si tenemos 3 puntos o m�s, esos nos da un SEL de mxn de la forma
%Ax=b, con m>n. Si rank(A)=n, se puede obtener la soluci�n de m�nimos
%cuadrados por descomposici�n SVD.

%PROBLEMA: Se ignora la restricci�n de que |R|=1. Soluci�n: se fuerza a que
%la matriz obtenida tenga determinante 1 y se recalcula t suponiendo que la
%matriz de rotaci�n es el R normalizado. REVISAR SI HAY UNA FORMA MEJOR DE
%HACER ESTO O SI M�S O MENOS ALCANZA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N=size(OR1,1);%Cantidad de objetos de referencia
A=zeros(2*N,4);%Defino las matrices para mayor velocidad
b=zeros(2*N,1);
for k=1:N
    %Conversi�n a polar del k-�simo objeto de ref ([x,y] =
    %pol2cart(theta,rho)) (rho=m�dulo, theta=�ngulo)
    [xp,yp]=pol2cart(OR1(k,2),OR1(k,1));
    [x,y]=pol2cart(OR2(k,2),OR2(k,1));
    A(2*k-1:2*k,:)=[x -y 1 0;...%Por cada punto se agregan 2 ec
                     y x 0 1];
    b(2*k-1:2*k,1)=[xp;yp];
end
x=SolMinCuadrados(A,b);%Resoluci�n del SEL Ax=b por m�nimos cuadrados.

%La matriz de rotaci�n es:
R=[x(1) -x(2);...
   x(2) x(1)];
%Para que la matriz sea efectivamente de rotaci�n, su determinante deber�a
%ser 1. Forzamos esta condici�n:
R=R/det(R);
%Tomando �sta como la matriz de rotaci�n, recalculamos t despejando el SEL
%para que s�lo las 2 �ltimas componentes de x sean inc�gnitas. Las nuevas
%matrices ser�an:
%A2=A(:,3:4) y b2=b-A(:,1:2)*[R(1,1);R(2,1)]
t=SolMinCuadrados(A(:,3:4),b-A(:,1:2)*[R(1,1);R(2,1)]);

%Convertimos la c�mara y los futuros objetos de referencia del mr1 al mr2
%usando R y t: (Observaci�n: C1=t, ya que C2=(0,0))
[theta,rho] = cart2pol(t(1),t(2));%Conversi�n a polar
C1=[rho;theta];
K=size(ORF2,1);%Cantidad de objetos de referencia nuevos
if K>0
    for k=1:K
        [x,y]=pol2cart(ORF2(k,2),ORF2(k,1));
        Xp=R*[x;y]+t;
        [theta,rho] = cart2pol(Xp(1),Xp(2));%Conversi�n a polar
        ORF1(k,:)=[rho;theta];
    end
end
end