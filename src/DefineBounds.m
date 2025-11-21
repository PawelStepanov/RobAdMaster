function [min_val, max_val, step_val] = DefineBounds(param, omega)
% Функция для определения границ параметров
    global extreme_nominal
    if param < 0
        min_val = (1 + omega) * param;
        max_val = (1 - omega) * param;
    else
        min_val = (1 - omega) * param;
        max_val = (1 + omega) * param;
    end
    
    if extreme_nominal == 1
        step_val = (abs(max_val - min_val))/2;
    else
        step_val = abs(max_val - min_val);
    end
    % Если параметр не изменяется ставим шаг = 1, чтобы происходил перебор
    if step_val == 0
        step_val = 1;
    end
end