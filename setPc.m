function [img_dir_izq, img_dir_der]=setPc(Compu)
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
    cd '/media/seba/Datos/Dropbox/CIN/Proyectos/programasMatlab';
    addpath('/media/seba/Datos/Dropbox/CIN/Proyectos/programasMatlab/Funciones')
    %  img_dir= 'E:\Facultad\Becas\CIN\TRABAJo\Dataset\partidas';
    img_dir_izq='/media/seba/Datos/Facultad_bk/Tesis/Mediciones_abril/Izq/'
    img_dir_der='/media/seba/Datos/Facultad_bk/Tesis/Mediciones_abril/Der/'
    
end
end