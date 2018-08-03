function [Parametros]=CargarParametros(FRAME,FRAME_Fin,pc)
[izq,der]=setPc(pc);
Parametros.img_dir_der=dir(der);
Parametros.img_dir_izq=dir(izq);
cellSize = [8 8];
hogFeatureSize = 6336;
Parametros.Caracteristicas={cellSize hogFeatureSize};
Parametros.Ventana=[140 95];% Alto ancho
Parametros.Solapamiento=0.95;% % porcentaje de solapamiento entre ventanas
load('SVMq976.mat') ;% Cargar el clasificador
load('Camara_Parametros.mat');load('Polinomio.mat'); % Carga los parametros de la camara y el polinomio de ajuste
Parametros.SizeImg=[720 1280];
Parametros.classifier=SVMq976.ClassificationSVM; % Cargar el algoritmo del clasificador
%load('SVMq95.mat') ;% Cargar el clasificador
%classifier=SVMq95.ClassificationSVM; % Cargar el algoritmo del clasificador
Parametros.IMAGENES=0;Parametros.h = fspecial('disk',1);
Parametros.Camara=Camara;
Parametros.Polinomio.p=p;
Parametros.Polinomio.S=S;
try
Parametros.Polinomio.mu=[44.8489;10.7531]; % No me dejaba poner Parametros.Polinomio.mu=mu
catch ME
    disp('Nose porque no anda')
    disp(ME)
end
Parametros.FRAME=FRAME;
Parametros.Hcamara=180; % La camra esta mas o menos a 180Cm del suelo
Parametros.FRAME_Fin=FRAME_Fin;
end