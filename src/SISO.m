function [ou11_max, criterion_max] = SISO(handles, flag)

% Применяем расчитанный робастный регулятор для всех точек зоны неопределенности

% Звуковой файл для сигнализирования окончания работы программы
[y, Fs] = audioread('end.MP3');

global ou11
global Tmod
global disturbance 

% Получение всех полей структуры zona_params вызовом функции ZonaControlObject
[omega] = ZonaControlObject;

% Присвоение переменных объектов управления (по необходимости)
omega11 = omega{1};
 
% Передаем в рабочее пространство возмущение
assignin('base', 'disturbance1', disturbance(1,1));

if flag == 1
    % Передаем в рабочее пространство параметры регулятора
    assignin('base', 'kp', handles.savedValueKpMS);
    assignin('base', 'ki', handles.savedValueKiMS);
else
    % Передаем в рабочее пространство параметры регулятора
    assignin('base', 'kp', 0);
    assignin('base', 'ki', handles.savedValueKibp);
end

crit_quality = handles.savedValue3;
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
    k_min:k_step:k_max, k2_min:k2_step:k2_max, T1_min:T1_step:T1_max, T2_min:T2_step:T2_max, ...
    T3_min:T3_step:T3_max, tau_min:tau_step:tau_max);

% Перебор всех комбинаций параметров
num_combinations = numel(k_grid);
criterion_max = 0;
step_iter = 0;
criterion_sum = 0;

% Параметры для расчета быстродействия
DT = 0.01;
WOSM = 1;

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
    
    criterion_sum = criterion_sum + criterion;
    
    % Находим максимальное значения критерия качества управления и соотсвествующий ему ОУ
    if criterion > criterion_max
        criterion_max = criterion;
        k_max = [numerator];
        T_max = [denominator];
        tau_max = [tau];
        ou11_max = {[numerator], [denominator], [tau]};
    end
    
    step_iter = step_iter + 1;
    disp(['Шаг итерации: ', num2str(step_iter)]);
end

criterion_avg = criterion_sum / step_iter;
if flag == 1
    % Выводим значения в командную строку
    if crit_quality == 0.589
        disp(['Максимальное ИМК: ', num2str(criterion_max)])
        disp(['Среднее ИМК: ', num2str(criterion_avg)])
        xlswrite('results.xlsx', criterion_max, 2, 'B55:B55')
        xlswrite('results.xlsx', criterion_avg, 2, 'D55:D55')
    elseif crit_quality == 0.507
        disp(['Максимальное быстродействие :', num2str(criterion_max)])
        disp(['Среднее быстродействие: ', num2str(criterion_avg)])
        xlswrite('results.xlsx', criterion_max, 2, 'B56:B56')
        xlswrite('results.xlsx', criterion_avg, 2, 'D56:D56')
    else
        disp(['Максимальное ИКК :', num2str(criterion_max)])
        disp(['Среднее ИКК: ', num2str(criterion_avg)])
        xlswrite('results.xlsx', criterion_max, 2, 'B54:B54')
        xlswrite('results.xlsx', criterion_avg, 2, 'D54:D54')
    end
else
    % Выводим значения в командную строку
    if crit_quality == 0.589
        disp(['Максимальное ИМК: ', num2str(criterion_max)])
        disp(['Среднее ИМК: ', num2str(criterion_avg)])
        xlswrite('results.xlsx', criterion_max, 2, 'B28:B28')
        xlswrite('results.xlsx', criterion_avg, 2, 'D28:D28')
    elseif crit_quality == 0.507
        disp(['Максимальное быстродействие :', num2str(criterion_max)])
        disp(['Среднее быстродействие: ', num2str(criterion_avg)])
        xlswrite('results.xlsx', criterion_max, 2, 'B29:B29')
        xlswrite('results.xlsx', criterion_avg, 2, 'D29:D29')
    else
        disp(['Максимальное ИКК :', num2str(criterion_max)])
        disp(['Среднее ИКК: ', num2str(criterion_avg)])
        xlswrite('results.xlsx', criterion_max, 2, 'B27:B27')
        xlswrite('results.xlsx', criterion_avg, 2, 'D27:D27')
    end
end
disp('Самый трудный ОУ:')
k_max
T_max
tau_max
if flag == 1
    % Переносим значение в файл эксель
    xlswrite('results.xlsx', {mat2str(k_max(1,1))}, 2, 'B59:B59')
    xlswrite('results.xlsx', {mat2str(T_max(1,1))}, 2, 'B60:B60')
    xlswrite('results.xlsx', tau_max(1,1), 2, 'B61:B61')
else
    % Переносим значение в файл эксель
    xlswrite('results.xlsx', {mat2str(k_max(1,1))}, 2, 'B32:B32')
    xlswrite('results.xlsx', {mat2str(T_max(1,1))}, 2, 'B33:B33')
    xlswrite('results.xlsx', tau_max(1,1), 2, 'B34:B34')
end
% Звуковой сигнал
sound(y, Fs)
end