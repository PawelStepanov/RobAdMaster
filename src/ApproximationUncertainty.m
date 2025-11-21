function [T, tau] = ApproximationUncertainty(ou, omega)
% Функция выполняет аппроксимацию ОУ. Принимает массив с параметрами ОУ и
% размер зоны неопределенности. Возвращает результат аппроксимации 

% Параметры объекта управления
[k, k2, T1, T2, T3, tau, flag] = Parameters(ou);

% Вводим переменные для перебора параметров
[k_min, k_max, k_step] = DefineBounds(k, omega{1}(1,1));
[k2_min, k2_max, k2_step] = DefineBounds(k2, omega{1}(1,1));
[T1_min, T1_max, T1_step] = DefineBounds(T1, omega{2}(1,1));
[k,j] = size(ou{2});
if j == 3
    [T2_min, T2_max, T2_step] = DefineBounds(T2, omega{2}(1,2));
else
    [T2_min, T2_max, T2_step] = DefineBounds(T2, omega{2}(1,1));
end
[T3_min, T3_max, T3_step] = DefineBounds(T3, omega{2}(1,1));
[tau_min, tau_max, tau_step] = DefineBounds(tau, omega{3});

% Время моделирования
Tmod = 500;

% Аппроксимация
Kob = 0;
Tob = 0;
Tauob = 0;

% Создаем сетку значений параметров
[k_grid, k2_grid, T1_grid, T2_grid, T3_grid, tau_grid] = ndgrid(...
    k_min:k_step:k_max, k2_min:k2_step:k2_max, T1_min:T1_step:T1_max, T2_min:T2_step:T2_max, ...
    T3_min:T3_step:T3_max, tau_min:tau_step:tau_max);

% Перебор всех комбинаций параметров
num_combinations = numel(k_grid);

% Переменная для массива
i = 1;

% Перебираем параметры ОУ
for idx = 1:num_combinations
    % Получаем значения параметров для данной комбинации
    k = k_grid(idx);
    k2 = k2_grid(idx);
    T1 = T1_grid(idx);
    T2 = T2_grid(idx);
    T3 = T3_grid(idx);
    tau = tau_grid(idx);
    
    % Вызываем функцию для формирования деноминатора
    denominator = FormDenominator(T1, T2, T3, flag);
    % Вызываем функцию для формирования нумератора
    numerator = FormNumerator(k, k2);
    
    % tf - передаточная функция вида tf(числитель, [знаменатель], 'OutputDelay', запаздывание)
    obj = tf(numerator,denominator,'OutputDelay',tau);
    Tfinal = Tmod; 
    dt = 1; 
    time = 0:dt:Tfinal; 
    u = ones((Tfinal+1),1); 
    u(1,1) = 0; 
    y = step(obj,time); 
    data = iddata(y,u,dt); 
                
    % Type выбирвем P1D (инерционное звено первого порядка с запаздыванием)
    typicalobj = idproc('P1D','Td',{'max',500});
    approxobj = pem(data,typicalobj,'InitialState','Zero');
                
    % Параметры аппроксимированного объекта
    Kob = approxobj.Kp.value; 
    Tob = approxobj.Tp1.value; 
    Tauob = approxobj.Td.value + dt; 
                
    % Параметры аппроксимированного объекта
    K_array(i) = Kob;
    T_array(i) = Tob;
    tau_array(i) = Tauob;
                
    i = i + 1;
end

% Ищем минимум и максимум Т и тау для расчета регулятора компенсационным
% методом
T = min(T_array);
tau = max(tau_array);

end