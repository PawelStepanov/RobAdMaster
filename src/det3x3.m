% Объект OR
%K = [0.66 -0.61 -0.0049; 1.11 -2.36 -0.01; -34.68 46.2 0.87];
% Объект T1
%K = [-1.986 5.984 0.422; 0.0204 2.38 0.513; 0.374 -9.811 -2.368];
% Объект Т4
%K = [-1.986 5.24 5.984; 0.374 -11.3 -9.811; 0.0204 -0.33 2.38];
% Объект SM
K = [103.5 75.44 71.28; 115.2 121.3 108.4; -174.8 -147.3 185.6];
omega = 0.0845;
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

% Вывод результатов
fprintf('Минимальный определитель: %.4f\n', min_det);
fprintf('Максимальный определитель: %.4f\n', max_det);

detK_min = K(1,1)*(1-omega) * K(2,2)*(1-omega) * K(3,3)*(1-omega) + ...
    K(1,2)*(1-omega) * K(2,3)*(1+omega) * K(3,1)*(1-omega) + ...
    K(1,3)*(1+omega) * K(2,1)*(1-omega) * K(3,2)*(1+omega) - ...
    K(3,1)*(1-omega) * K(2,2)*(1-omega) * K(1,3)*(1+omega) - ...
    K(3,2)*(1+omega) * K(2,3)*(1+omega) * K(1,1)*(1-omega) - ...
    K(3,3)*(1-omega) * K(2,1)*(1-omega) * K(1,2)*(1-omega);

detK_max = K(1,1)*(1+omega) * K(2,2)*(1+omega) * K(3,3)*(1+omega) + ...
    K(1,2)*(1+omega) * K(2,3)*(1-omega) * K(3,1)*(1+omega) + ...
    K(1,3)*(1-omega) * K(2,1)*(1+omega) * K(3,2)*(1-omega) - ...
    K(3,1)*(1+omega) * K(2,2)*(1+omega) * K(1,3)*(1-omega) - ...
    K(3,2)*(1-omega) * K(2,3)*(1-omega) * K(1,1)*(1+omega) - ...
    K(3,3)*(1+omega) * K(2,1)*(1+omega) * K(1,2)*(1+omega);

% Вывод результатов
%fprintf('Минимальный определитель: %.4f\n', detK_min);
%fprintf('Максимальный определитель: %.4f\n', detK_max);

% Вычисление ?*
%num = sqrt(K11*K22*K33) - sqrt(K21*K32*K13) - sqrt(K31*K12*K23);
%den = sqrt(K11*K22*K33) + sqrt(K21*K32*K13) + sqrt(K31*K12*K23);
%delta_star = num / den;
     
% Вывод результата
%fprintf('Значение ?^*: %.4f\n', delta_star);

% Вычисление ?*
%num = sqrt(K11*K22*K33) + sqrt(K21*K32*K13) + sqrt(K31*K12*K23);
%den = sqrt(K11*K22*K33) + sqrt(K21*K32*K13) + sqrt(K31*K12*K23);
%delta_star = num / den;

% Вывод результата
%fprintf('Значение ?^*: %.4f\n', delta_star);

% Числитель и знаменатель для вычисления delta_star
numerator = K(1,1) * K(2,2) * K(3,3) + K(1,2) * K(2,3) * K(3,1) + K(1,3) * K(2,1) * K(3,2);
denominator = K(1,1) * K(2,3) * K(3,2) + K(1,2) * K(2,1) * K(3,3) + K(1,3) * K(2,2) * K(3,1);

% Вычисление delta_star
delta_star = (1 - sqrt(numerator / denominator)) / (1 + sqrt(numerator / denominator));
% Вывод результата
fprintf('Значение ?^*: %.4f\n', delta_star);

% Вычисление delta_star_min
delta_star_min = (sqrt(numerator / denominator) - 1) / (sqrt(numerator / denominator) + 1);
% Вывод результата
fprintf('Значение ?^*: %.4f\n', delta_star);

% Вычисление значений A, B, C, D, E, F
A = K(1,1) * K(2,2) * K(3,3);
B = K(1,2) * K(2,3) * K(3,1);
C = K(1,3) * K(2,1) * K(3,2);
D = K(1,3) * K(2,2) * K(3,1);
E = K(1,1) * K(2,3) * K(3,2);
F = K(1,2) * K(2,1) * K(3,3);

% Вычисление коэффициента k
k = (D + E + F) / (A + B + C);

% Вычисление delta*
delta_star = (1 - k^(1/3)) / (1 + k^(1/3));
% Вывод результата
fprintf('Значение ?^*: %.4f\n', delta_star);

% Формулы для ?K_max и ?K_min
k11 = K(1,1); k12 = K(1,2); k13 = K(1,3);
k21 = K(2,1); k22 = K(2,2); k23 = K(2,3);
k31 = K(3,1); k32 = K(3,2); k33 = K(3,3);

% Формула для максимального определителя
max_det = ...
    K(1,1)*(1+omega) * ((K(2,2)*(1+omega) * K(3,3)*(1+omega)) - (K(2,3)*(1-omega) * K(3,2)*(1-omega))) - ...
    K(1,2)*(1-omega) * ((K(2,1)*(1-omega) * K(3,3)*(1+omega)) - (K(2,3)*(1+omega) * K(3,1)*(1-omega))) + ...
    K(1,3)*(1+omega) * ((K(2,1)*(1+omega) * K(3,2)*(1+omega)) - (K(2,2)*(1-omega) * K(3,1)*(1-omega)));

% Формула для минимального определителя
min_det = ...
    K(1,1)*(1-omega) * ((K(2,2)*(1-omega) * K(3,3)*(1-omega)) - (K(2,3)*(1+omega) * K(3,2)*(1+omega))) - ...
    K(1,2)*(1+omega) * ((K(2,1)*(1+omega) * K(3,3)*(1-omega)) - (K(2,3)*(1-omega) * K(3,1)*(1+omega))) + ...
    K(1,3)*(1-omega) * ((K(2,1)*(1-omega) * K(3,2)*(1-omega)) - (K(2,2)*(1+omega) * K(3,1)*(1+omega)));
% Вывод результатов
fprintf('Максимальный определитель: %.4f\n', max_det);
fprintf('Минимальный определитель: %.4f\n', min_det);

% Вычисление промежуточных значений
Delta11 = k11 * abs(k22 * k33 - k23 * k32);
Delta12 = k12 * abs(k21 * k33 - k23 * k31);
Delta13 = k13 * abs(k21 * k32 - k22 * k31);

% Вычисление радиуса робастной управляемости
delta_star = (sqrt(Delta11) - sqrt(Delta12 + Delta13)) / ...
             (sqrt(Delta11) + sqrt(Delta12 + Delta13));
% Вывод результата
fprintf('Значение ?^*: %.4f\n', delta_star);

% Вычисление предельного радиуса робастной сверхустойчивости
delta_star = 1 / max(sum(abs(K), 2) ./ abs(diag(K)));

% Вывод результата
fprintf('Предельный радиус робастной сверхустойчивости: ?* = %.4f\n', delta_star);

% Вычисление определителя
DeltaK = det(K);

% Формулы для \widetilde{\varphi}_i(\omega)
phi1 = @(omega) omega * (abs(K(1,1)) * (abs(K(2,2)) + abs(K(2,3))) + ...
                         abs(K(1,2)) * (abs(K(2,1)) + abs(K(2,3))) + ...
                         abs(K(1,3)) * (abs(K(2,1)) + abs(K(2,2))));

phi2 = @(omega) omega * (abs(K(2,2)) * (abs(K(1,1)) + abs(K(1,3))) + ...
                         abs(K(2,1)) * (abs(K(1,2)) + abs(K(1,3))) + ...
                         abs(K(2,3)) * (abs(K(1,1)) + abs(K(1,2))));

phi3 = @(omega) omega * (abs(K(3,3)) * (abs(K(1,1)) + abs(K(1,2))) + ...
                         abs(K(3,1)) * (abs(K(1,2)) + abs(K(1,3))) + ...
                         abs(K(3,2)) * (abs(K(1,1)) + abs(K(1,3))));

% Вычисление \bar{\omega}
omega_bar = abs(DeltaK) / max([phi1(1), phi2(1), phi3(1)]);

% Вывод результата
fprintf('Предельное значение радиуса робастной сверхустойчивости: \\bar{\\omega} = %.4f\n', omega_bar);

% Вычисляем диагональные элементы и суммы элементов по строкам
diag_K = abs(diag(K));
row_sums = sum(abs(K), 2) - diag_K;

% Проверяем условие диагональной доминантности
is_superstable = all(diag_K > row_sums);

% Вывод результатов
if is_superstable
    disp('Матрица K является робастно сверхустойчивой.');
else
    disp('Матрица K НЕ является робастно сверхустойчивой.');
end

% Отображение деталей
for i = 1:3
    fprintf('Для строки %d: |k_%d%d| = %.2f, Сумма = %.2f\n', ...
        i, i, i, diag_K(i), row_sums(i));
end

omega = 0;
omega_din = 0;
omega_din_tau = 0;
a = 0.739;
T_min = (1-omega_din) * 3.25;
tau_max = (1+omega_din_tau) * 9.4;

Wp_car = inv(K)*a*(T_min/tau_max)
Wi_car = inv(K)*(a/tau_max)

Wp_avt = [a*6.7/(K(1,1)*2.6) 0 0; ...
    0 a*5/(K(2,2)*3) 0; ...
    0 0 a*11.7943/(K(3,3)*1)]
Wi_avt = [a/(K(1,1)*2.6) 0 0; ...
    0 a/(K(2,2)*3) 0;...
    0 0 a/(K(3,3)*1)]