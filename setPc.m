function [img_dir]=setPc(Compu)
% Esta funcion setea las carpetas necesarias para correr cualquier codigo
% Entradas posibles "server" o "vaio"
if strcmp(Compu,'server')
    cd 'C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Proyectos\programasMatlab'
    addpath('C:\Users\sebasan.SERVER1\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Funciones')
    img_dir= 'D:\Datasets\Salidas_de_Campo_INTA\25Ene2017\prueba9\partidas\image';
end
if strcmp(Compu,'vaio')
    cd 'C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab';
    addpath('C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Funciones')
    %  img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas';
    img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas\image';
    %img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas\image';
end
if strcmp(Compu,'lenovo')
    cd '/home/seba/Dropbox/Facultad/CIN/Proyectos/programasMatlab';
    addpath('/home/seba/Dropbox/Facultad/CIN/Proyectos/programasMatlab/Funciones')
    %  img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas';
    img_dir= '/media/seba/Datos/Facultad_bk/Becas/CIN/TRABAJo/Dataset/partidas/image';
    %img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\prueba11\Partidas\image';
end
end