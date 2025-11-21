function  omega = MaxZonaDet
% Функция находит максимальную возможную зону неопределенности для ОУ
% размерностью 3х3. Для этого они перебирает зону неопределенности от 0 до
% 1 и считает все варианты детерминантов одновременно с этим находит
% максимальный и минимальный детерминант

global K

for omega = 0:0.001:1
    %omega = 0.0845;
    % Задаем диапазоны значений элементов матрицы (min и max для каждого элемента)
    K_max = K.*(1+omega);
    K_min = K.*(1-omega);

    % Размерность матрицы
    n = size(K_min, 1);

    % Для сохранения матриц
    A_min_det_matrix = zeros(n, n);
    A_max_det_matrix = zeros(n, n);

    % Генерация всех комбинаций крайних значений
    num_combinations = 2^(n^2);
    determinants = zeros(num_combinations, 1);

    % Перебор всех комбинаций
    for i = 0:num_combinations-1
        % Генерируем бинарный вектор для текущей комбинации
        binary_comb = dec2bin(i, n^2) - '0';
        % Формируем матрицу для текущей комбинации
        A_current = zeros(n, n);
        for j = 1:n^2
            row = ceil(j / n);
            col = mod(j-1, n) + 1;
            if binary_comb(j) == 0
                A_current(row, col) = K_min(row, col);
            else
                A_current(row, col) = K_max(row, col);
            end
        end
        % Вычисляем определитель текущей матрицы
        determinants(i+1) = det(A_current);
    
        % Проверяем, является ли текущий определитель минимальным или максимальным
        if determinants(i+1) == min(determinants(1:i+1))
            A_min_det_matrix = A_current;
        end
        if determinants(i+1) == max(determinants(1:i+1))
            A_max_det_matrix = A_current;
        end
    end

    % Нахождение минимального и максимального определителя
    min_det = min(determinants);
    max_det = max(determinants);
    
    if min_det > 0 && max_det < 0 || min_det < 0 && max_det > 0
        break
    end
end

% Вывод результатов
fprintf('Минимальный определитель: %.4f\n', min_det);
fprintf('Максимальный определитель: %.4f\n', max_det);
fprintf('Зона неопределенности: %.4f\n', omega);
end