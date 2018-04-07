% Esta funcion cambia el formato de las mediciones para que sea compatible
% con cualquier algoritmo. Posee el formato que me pidio Marce.
% el formato es: [Identificador N°medicion Cantidad_med angulo rango X Y ... se repite para cada tronco y al final... NuevosTroncos FRAME] rango en centimetros y
% angulo en radianes. Si no se tiene informacion de la medida todos los
% valores son cero de esa medida y si la distancia es justo un outlier,
% sera un NaN.
label='T';
dir='C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Registros_corridas\Datos.txt';
fileID = fopen(dir,'w');
N=size(Distancia,2);
for i=1:N
%     mm=find(~isnan(Distancia{i}(:,1)));
%     t=find(Distancia{i}(mm,1));  
if ~isempty(Distancia{i})
 t=size(Distancia{i},1);  
 
    fprintf(fileID,'%s %d %d',label,i,t);
    for k=1:t
        if k==1
            mydata=[Distancia{i}(k,2) Distancia{i}(k,1) Distancia{i}(k,3) Distancia{i}(k,4)];
        else
            mydata=cat(2,mydata ,[Distancia{i}(k,2) Distancia{i}(k,1) Distancia{i}(k,3) Distancia{i}(k,4)]);
        end
    end
     mydata=cat(2,mydata,[Distancia{i}(k,5) Distancia{i}(k,6)]);
    fprintf(fileID,'% 8.4f',mydata);
    fprintf(fileID,'\r\n');
    %     fwrite(fileID, mydata, 'double')
end
end

fclose(fileID);
type(dir);


