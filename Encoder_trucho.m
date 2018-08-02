% Truchada de encoder


label='E';
dir='C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Registros_corridas\ENC1.txt';
fileID = fopen(dir,'w');
N=8000;
des=5.23e-3*0;%desvio considerando un 10% como maximo por paso
for i=1:N 
    ruido=randn(2,1)*des;
    fprintf(fileID,'%s %d %d',label,i*50);  
   mydata=[pi/20*i+ruido(1) pi/20*i+ruido(2)]; % Parte de suponer que siempre va para adelante
    fprintf(fileID,' % 8.4f',mydata);
    fprintf(fileID,'\r\n');
    %     fwrite(fileID, mydata, 'double')
end

fclose(fileID);
type(dir);

