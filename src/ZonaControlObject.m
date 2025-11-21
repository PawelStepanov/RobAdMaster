function [omega] = ZonaControlObject

global zona_params

% Получение всех полей структуры params
objects = fieldnames(zona_params);
omega = cell(1, numel(objects));

% Цикл для извлечения параметров
for i = 1:numel(objects)
    obj = objects{i};
    numerator_zona = zona_params.(obj).numerator;
    denominator_zona = zona_params.(obj).denominator;
    tau_zona = zona_params.(obj).delay;
    omega{i} = {[numerator_zona], [denominator_zona], [tau_zona]};
end
end