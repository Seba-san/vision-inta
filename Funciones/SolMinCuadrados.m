function [x]=SolMinCuadrados(A,b)
%Dado un SEL de mxn de la forma Ax=b, con m>n. Si rank(A)=n, se puede
%obtener la soluci�n de m�nimos cuadrados por descomposici�n SVD. Esta
%funci�n encuentra dicha soluci�n siguiendo el algoritmo explicado en el
%ap�ndice 5 de Hartley, R., and A. Zisserman. Multiple View Geometry in
%Computer Vision. Cambridge University Press, 2003.

%(i)Hallar la descomposici�n SVD de A=UDV'.
[U,D,V]=svd(A);
%(ii)Tomar b'=U'b.
bp=U.'*b;
%(iii)Hallar el vector y cuyas componentes son y(i)=b'(i)/d(i), donde d(i)
%es la i-�sima componente de la diagonal de D.
n=size(A,2);
y=bp(1:n)./diag(D);%Observaci�n: diag(D) devuelve una matriz de nx1.
%(iv)La soluci�n es x=Vy.
x=V*y;%Vector soluci�n del SEL

end