function [ou] = ParametersControlObject

% Формируем параметры ОУ 
global params

% Получение всех полей структуры params
objects = fieldnames(params);
ou = cell(1, numel(objects));

% Цикл для извлечения параметров
for i = 1:numel(objects)
    obj = objects{i};
    numerator = params.(obj).numerator;
    denominator = params.(obj).denominator;
    tau = params.(obj).delay;
    ou{i} = {[numerator], [denominator], [tau]};
end
end