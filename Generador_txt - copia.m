% Esta funcion cambia el formato de las mediciones para que sea compatible
% con cualquier algoritmo.
% el formato es: [label N°medicion Cantidad_med rango angulo...] rango en centimetros y
% angulo en radianes
label='T';
dir='C:\Users\seba\Dropbox\Facultad\CIN\Proyectos\programasMatlab\Registros_corridas\Data.txt';
fileID = fopen(dir,'w');
N=size(Distancia,2);
for i=1:N
    if ~isempty(Distancia{i})
    mm=find(~isnan(Distancia{i}(:,1)));
    t=find(Distancia{i}(mm,1));    
    fprintf(fileID,'%s %d %d',label,i*1000,numel(t));
    for k=1:numel(t)
        % hay que pasar los datos de distancia a cartesianos
        [X Y]=pol2cart(Distancia{i}(mm(t(k)),2)+pi/2,Distancia{i}(mm(t(k)),1)); 
        Y=Y/100;X=X/100;
        if k==1
            mydata=[X Y];
        else
            mydata=cat(2,mydata ,[X Y]);
        end
    end
    fprintf(fileID,' % 8.4f',mydata);
    fprintf(fileID,'\r\n');
    end
    %     fwrite(fileID, mydata, 'double')
end

fclose(fileID);
type(dir);


