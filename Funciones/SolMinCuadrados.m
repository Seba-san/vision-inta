function [x]=SolMinCuadrados(A,b)
%Dado un SEL de mxn de la forma Ax=b, con m>n. Si rank(A)=n, se puede
%obtener la solución de mínimos cuadrados por descomposición SVD. Esta
%función encuentra dicha solución siguiendo el algoritmo explicado en el
%apéndice 5 de Hartley, R., and A. Zisserman. Multiple View Geometry in
%Computer Vision. Cambridge University Press, 2003.

%(i)Hallar la descomposición SVD de A=UDV'.
[U,D,V]=svd(A);
%(ii)Tomar b'=U'b.
bp=U.'*b;
%(iii)Hallar el vector y cuyas componentes son y(i)=b'(i)/d(i), donde d(i)
%es la i-ésima componente de la diagonal de D.
n=size(A,2);
y=bp(1:n)./diag(D);%Observación: diag(D) devuelve una matriz de nx1.
%(iv)La solución es x=Vy.
x=V*y;%Vector solución del SEL

end