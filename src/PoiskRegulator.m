function [Ki_criterion_minmax, minmax_criterion, ou11_minmax] = PoiskRegulator(crit_quality, Ki_rob_bespoisk)

% Поиск робастного И-регулятора 

% Звуковой файл для сигнализирования окончания работы программы
[y, Fs] = audioread('end.MP3');

global Tmod
global ou11
global disturbance

% Получение всех полей структуры zona_params вызовом функции ZonaControlObject
[omega] = ZonaControlObject;

% Присвоение переменных объектов управления (по необходимости)
omega11 = omega{1};
 
% Передаем в рабочее пространство возмущение
assignin('base', 'disturbance1', disturbance(1,1));

% Передаем в рабочее пространство параметры регулятора
assignin('base', 'kp', 0);
assignin('base', 'ki', Ki_rob_bespoisk);

% Вводим параметры ОУ
[k, k2, T1, T2, T3, tau, flag] = Parameters(ou11);

% Вводим переменные для перебора параметров
[k_min, k_max, k_step] = DefineBounds(k, omega11{1}(1,1));
[k2_min, k2_max, k2_step] = DefineBounds(k2, omega11{1}(1,1));
[T1_min, T1_max, T1_step] = DefineBounds(T1, omega11{2}(1,1));
[k,j] = size(ou11{2});
if j == 3
    [T2_min, T2_max, T2_step] = DefineBounds(T2, omega11{2}(1,2));
else
    [T2_min, T2_max, T2_step] = DefineBounds(T2, omega11{2}(1,1));
end
[T3_min, T3_max, T3_step] = DefineBounds(T3, omega11{2}(1,1));
[tau_min, tau_max, tau_step] = DefineBounds(tau, omega11{3});

% Создаем сетку значений параметров
[k_grid, k2_grid, T1_grid, T2_grid, T3_grid, tau_grid] = ndgrid(...
    k_min:k_step:k_max, k2_min:k2_step:k2_max, T1_min:T1_step:T1_max, T2_min:T2_step:T2_max,...
    T3_min:T3_step:T3_max, tau_min:tau_step:tau_max);

% Перебор всех комбинаций параметров
num_combinations = numel(k_grid);
% Шаг деления
N = 100;

% Поиск Ki
% Шаг моделирования Ki
ki_step = Ki_rob_bespoisk/N;
% Ki верхняя граница
ki_max = Ki_rob_bespoisk * 2;
% Ki нижняя граница
ki_min = Ki_rob_bespoisk;

minmax_criterion = 10000; % Вводим для того, чтобы получить minmax критерий             
step_total = 0;
step_iter = 0;
i = 1;

for ki = ki_min:ki_step:ki_max
    
    criterion_max = 0;
    
    assignin('base', 'ki', ki);
    
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
    
        % Записываем переменные в базовое рабочее пространство
        assignin('base', 'numerator', numerator);
        assignin('base', 'denominator', denominator);
        assignin('base', 'tau', tau);
    
        % Настройка симуляции
        simIn = Simulink.SimulationInput('SISO_model');
        simIn = simIn.setVariable('numerator', numerator);
        simIn = simIn.setVariable('denominator', denominator);
        simIn = simIn.setVariable('tau', tau);
    
        % Производим симуляцию  
        out = sim(simIn);
        % Проверяем какой у нас критерий качества
        if crit_quality == 0.589
            criterion = get(out, "simout1");
        elseif crit_quality == 0.507
            X = get(out, "simout2");
        
            % Расчет длительности переходного процесса
            N = length(X); % Длина массива X
            if abs(X(N)) > 0.05*WOSM
                disp('Переходный процесс не закончен')
                Nreg = N;
            else
                j=0;
                while abs(X(N-j)) <= 0.05*WOSM
                    Nreg = N-j;
                    j = j+1;
                end
                criterion = Nreg * DT;
            end
        else
            criterion = get(out,"simout");
        end
        
        % Находим максимальное значение критерия качества управления и соотсвествующий ему ОУ
        if criterion > criterion_max
            criterion_max = criterion;
            k_max = [numerator];
            T_max = [denominator];
            tau_max = [tau];
            ou11_max = {[numerator], [denominator], [tau]};       
        end
                    
        step_total = step_total + 1;
        step_iter = step_iter + 1;
        disp(['Шаг итерации: ', num2str(step_iter)])
        disp(['Всего итераций: ', num2str(step_total)])
    end
    
    % Создание массива Ки
    Ki_array(i) = ki;
    
    % Создание массива максимальных критериев
    criterion_max_array(i) = criterion_max;
    
    % Создание массива параметров ОУ с максимальным критерием
    K_array(i) = {mat2str(k_max)};
    denominator_array(i) = {mat2str(T_max)}; 
    tau_array(i) = tau_max;
    
    i = i + 1;
    
    % Ищем минимаксное значение критерия и Ki
    if criterion_max < minmax_criterion
        minmax_criterion = criterion_max;        
        Ki_criterion_minmax = ki;
    end
    
    % Если условие выполняется сдвигаем верхнюю границу на шаг
    if ki == ki_max && criterion_max == minmax_criterion
        ki_max = ki_max + ki_step;
        ou11_minmax = ou11_max;
    end
    
    disp('Следующая итерация')
    step_iter = 0;
end

% Переносим значение в файл эксель
xlswrite('values.xlsx', Ki_array, 'B38:CX38')
xlswrite('values.xlsx', Ki_criterion_minmax(1), 'B48:B48')
xlswrite('values.xlsx', K_array, 'B40:CX40')
xlswrite('values.xlsx', denominator_array, 'B41:CX41')
xlswrite('values.xlsx', tau_array, 'B42:CX42')
if crit_quality == 0.589
    xlswrite('values.xlsx', criterion_max_array, 'B44:CX44')
    xlswrite('values.xlsx', minmax_criterion(1), 'D47:D47')
elseif crit_quality == 0.507
    xlswrite('values.xlsx', criterion_max_array, 'B45:CX45')
    xlswrite('values.xlsx', minmax_criterion(1), 'F47:F47')
else
    xlswrite('values.xlsx', criterion_max_array, 'B43:CX43')
    xlswrite('values.xlsx', minmax_criterion(1), 'B47:B47')
end
% Выводим значения в командную строку
if crit_quality == 0.589
    disp(['Минимаксное ИМК :', num2str(minmax_criterion)])
elseif crit_quality == 0.507
    disp(['Минимаксное быстродействие :', num2str(minmax_criterion)])
else
    disp(['Минимаксное ИКК :', num2str(minmax_criterion)])
end
disp(['Ki, при котором достигается минимаксный критерий: ', num2str(Ki_criterion_minmax)])

% Звуковой сигнал
sound(y, Fs)
end