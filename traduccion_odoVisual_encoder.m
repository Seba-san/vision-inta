%traduccion_odoVisual_encoder

clc;clear all
label='E';
dir='C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Registros_corridas\ENC1.txt';
fileID = fopen(dir,'w');
load('E:\Facultad\Becas\CIN\TRABAJo\Programas\Matlab\Datos\DatosSeba_50_a_699.mat')
L=size(LocationGlobal,1);
Izq=0;Der=0;
for m=1:L
    if mod(m,2)==0
        M(1)=LocationGlobal{m}(1);M(2)=LocationGlobal{m}(3);
        R=OrientationGlobal{m}; eul = Rotacion2eul(R);ang=eul(2); % No esta incorporado la correccion de la orientacion
        [fi,Rad]=cart2pol(M(2),M(1));
        fi=fi/2;     
        if m==2
            fprintf(fileID,'%s %d %d',label,0);
            mydata=[Izq Der];
            fprintf(fileID,' % 8.4f',mydata);
            fprintf(fileID,'\r\n');      
        end
        %Giro
        for i=1:7
            Izq=-fi/7+Izq;
            Der= fi/7+Der;
            fprintf(fileID,'%s %d %d',label,i*50+(m/2-1)*20*50);
            mydata=[Izq Der];
            fprintf(fileID,' % 8.4f',mydata);
            fprintf(fileID,'\r\n');      
%             i*50+(m/2-1)*20
        end
        % Desplazamiento
        for i=8:15
            Izq=Rad/8+Izq;
            Der=Rad/8+Der;
            fprintf(fileID,'%s %d %d',label,i*50+(m/2-1)*20*50);
            mydata=[Izq Der];
            fprintf(fileID,' % 8.4f',mydata);
            fprintf(fileID,'\r\n');          
%             i*50+(m/2-1)*20
        end             
         % Giro_Invertido
         fi=fi+ang/2;
        for i=16:20
            Izq=fi/5+Izq;
            Der=-fi/5+Der;
            fprintf(fileID,'%s %d %d',label,i*50+(m/2-1)*20*50);
            mydata=[Izq Der];
            fprintf(fileID,' % 8.4f',mydata);
            fprintf(fileID,'\r\n');     
%             i*50+(m/2-1)*20
        end                   

%     pause()
    end
end
fclose(fileID);
type(dir);
% [enc.steps.data1 enc.steps.data2]'
