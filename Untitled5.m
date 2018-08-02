% Plotear en alturas por curiosidad

for i=1:size(Distancia,2)
    for q=1:size(Distancia{i}(:,1),1)
        h=(Distancia{i}(q,4)-367.7980)*Distancia{i}(q,1)/692.9640;
        plot(Distancia{i}(q,3),h,'bx')
        hold on
    end
    hold off
    pause()
end


for i=1:size(Distancia,2)
    for q=1:size(Distancia{i}(:,1),1)
        h=100*692.9640/Distancia{i}(q,1);
        plot(Distancia{i}(q,3),h,'bx')
        hold on
    end
    hold off
    pause()
end
