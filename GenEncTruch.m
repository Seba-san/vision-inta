function enc=GenEncTruch(enc,M,ang,sig)
% Esta funcion arma la extencion time, data1 y data2 de la estructura enc
%enc.steps.data1

% Considero movimiento en diagonal
%M(1) es la diferencial
%M(2) es la comun
if nargin<3
% Rad=norm(M(1),M(2));
[fi,Rad]=cart2pol(M(1),M(2));
fi=fi/2;
% Primero gira: considerando una Base Line de 1m y unos radios de ruedas
% dados por rl=1=rr. La distancia recorrida en forma diferencial sera "fi" en radianes
enc.steps(1).data1=enc.steps(20).data1;
enc.steps(1).data2=enc.steps(20).data2;
%Giro
for i=2:10
%     if fi>0
        enc.steps(i).data1=-fi/9+ enc.steps(i-1).data1;
        enc.steps(i).data2= fi/9+enc.steps(i-1).data2;
%     else
%        enc.steps(i).data1=-fi/9+ enc.steps(i-1).data1;
%         enc.steps(i).data2= fi/9+enc.steps(i-1).data2;        
%     end
end
% Desplazamiento
for i=11:20
    enc.steps(i).data1=Rad/10+enc.steps(i-1).data1;
    enc.steps(i).data2=Rad/10+enc.steps(i-1).data2;   
end
else
    enc=GenEncTruch2(enc,M,ang,sig);
end

end

%
% sl = (to.posl - from.posl)*rl;
% sr = (to.posr - from.posr)*rr;
% dxR = (sr + sl) / 2; % Desplazamiento hacia adelante
% dthetaR = (sr - sl) / b;% diferencias en angulo de giro
% dxW = dxR * cos(from.theta + dthetaR/2);
% dyW = dxR * sin(from.theta + dthetaR/2);


%
function enc=GenEncTruch2(enc,M,ang,sig)
if nargin<4
    sig=1;
    
end
[fi,Rad]=cart2pol(M(1),M(2));
fi=fi/2;
% Primero gira: considerando una Base Line de 1m y unos radios de ruedas
% dados por rl=1=rr. La distancia recorrida en forma diferencial sera "fi" en radianes
enc.steps(1).data1=enc.steps(20).data1;
enc.steps(1).data2=enc.steps(20).data2;

        for i=2:7
            enc.steps(i).data1=-sig*fi/6+ enc.steps(i-1).data1;
            enc.steps(i).data2= sig*fi/6+enc.steps(i-1).data2;
         
        end
        % Desplazamiento
        for i=8:15
            enc.steps(i).data1=sig*Rad/8+enc.steps(i-1).data1;
            enc.steps(i).data2=sig*Rad/8+enc.steps(i-1).data2;
                       
        end             
         % Giro_Invertido
         fi=fi+ang/2;
        for i=16:20
            enc.steps(i).data1=sig*fi/5+enc.steps(i-1).data1;
            enc.steps(i).data2=-sig*fi/5+enc.steps(i-1).data2;
           
        end        
end