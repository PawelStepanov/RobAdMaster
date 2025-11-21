function [rel_min, rel_max, Kp_max, Ki_max, ou_max] = RobAdRegSISO(Kp_rob, Ki_rob, Kp_nom, Ki_nom, crit_quality)

% Звуковой файл для сигнализирования окончания работы программы
[y, Fs] = audioread('end.MP3');

global ou11
global Tmod
global disturbance
global step_alpha

% Передаем в рабочее пространство возмущение и время моделирования
assignin('base', 'disturbance1', disturbance(1,1));
assignin('base', 'Tmod', Tmod);

% Получение всех полей структуры zona_params вызовом функции ZonaControlObject
[omega] = ZonaControlObject;
% Присвоение переменных объектов управления (по необходимости)
omega11 = omega{1};

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

alpha = 0;
relative_diff_total = 0;
criterion_robad_total = 0;
criterion_rob_total = 0;
rel_max = 0;
rel_min = 5000;
step_iter = 0;

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
    
    Min_criterion_ad = 50000;
    
    % Перебираем alpha от 0 до 1
    
    for alpha = alpha: step_alpha: 1
        
        % Считаем параметры регулятора
        kp = (alpha * (Kp_rob)) + ((1 - alpha) * (Kp_nom));
        ki = (alpha *  (Ki_rob)) + ((1 - alpha) * (Ki_nom));
        assignin('base', 'kp', kp);
        assignin('base', 'ki', ki);
        
        % Настройка симуляции
        simIn = Simulink.SimulationInput('SISO_model');   
        simIn = simIn.setVariable('numerator', numerator);
        simIn = simIn.setVariable('denominator', denominator);
        simIn = simIn.setVariable('tau', tau);   
        
        % Производим симуляцию  
        out = sim(simIn);
        % Проверяем какой у нас критерий качества
        if crit_quality == 0.589
            criterion_ad = get(out, "simout1");
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
                criterion_ad = Nreg * DT;
            end
        else
            criterion_ad = get(out,"simout");
        end
        
        if criterion_ad < Min_criterion_ad
            Min_criterion_ad = criterion_ad;
            % Параметры Kp
            Kp = kp;
            % Параметры Ki
            Ki = ki;
        end
    end
    
    % Параметры робастного регулятора
    kp = Kp_rob;
    ki = Ki_rob;
    assignin('base', 'kp', kp);
    assignin('base', 'ki', ki);
    
    % Настройка симуляции
    simIn = Simulink.SimulationInput('SISO_model');   
    simIn = simIn.setVariable('numerator', numerator);
    simIn = simIn.setVariable('denominator', denominator);
    simIn = simIn.setVariable('tau', tau);   
    
    % Производим симуляцию  
    out = sim(simIn);
    % Проверяем какой у нас критерий качества
    if crit_quality == 0.589
        criterion_rob = get(out, "simout1");
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
            criterion_rob = Nreg * DT;
        end
    else
        criterion_rob = get(out,"simout");
    end    
    
    relative_diff = ((criterion_rob - Min_criterion_ad) / Min_criterion_ad) * 100;
    relative_diff_total = relative_diff_total + relative_diff;
    criterion_robad_total = criterion_robad_total + Min_criterion_ad;
    criterion_rob_total = criterion_rob_total + criterion_rob;
    
    % Находим максимальную разность ИКК
    if relative_diff >= rel_max
        rel_max = relative_diff;
        
        % Параметры ОУ с максимальной  разницей ИКК
        k_max = [numerator];
        T_max = [denominator];
        tau_max = [tau];
        ou_max = {[numerator], [denominator], [tau]};
        
        Kp_max = Kp;
        Ki_max = Ki;
    end
    
    % Находим минимальную разность ИКК
    if relative_diff < rel_min
        rel_min = relative_diff;
        
        % Параметры ОУ с минимальной  разницей ИКК
        k_min = [numerator];
        T_min = [denominator];
        tau_min = [tau];
        
        Kp_min = Kp;
        Ki_min = Ki;
    end
    
    step_iter = step_iter + 1;
    disp(['Шаг итерации: ', num2str(step_iter)]);
end
    
% Находим среднюю разность ИКК
criterion_avg_rel = relative_diff_total / step_iter;

% Находим среднее значение ИКК
criterion_avg_robad = criterion_robad_total / step_iter;
criterion_avg_rob = criterion_rob_total / step_iter;

% Переносим значение в файл эксель
xlswrite('values.xlsx', Kp_max, 'B68:B68')
xlswrite('values.xlsx', Ki_max, 'C68:C68')
xlswrite('values.xlsx', Kp_min, 'B70:B70')
xlswrite('values.xlsx', Ki_min, 'C70:C70')

% Переносим значение в файл эксель
xlswrite('values.xlsx', {mat2str(Kp_max)}, 'B54:B54')
xlswrite('values.xlsx', {mat2str(Ki_max)}, 'C54:C54')
xlswrite('values.xlsx', {mat2str(Kp_min)}, 'B56:B56')
xlswrite('values.xlsx', {mat2str(Ki_min)}, 'C56:C56')
if crit_quality == 0.589
    xlswrite('values.xlsx', rel_min, 'B83:B83')
    xlswrite('values.xlsx', rel_max, 'A83:A83')
    xlswrite('values.xlsx', criterion_avg_rel, 'C83:C83')
    xlswrite('values.xlsx', criterion_avg_robad, 'D83:D83')
    xlswrite('values.xlsx', criterion_avg_rob, 'E83:E83')
elseif crit_quality == 0.507
    xlswrite('values.xlsx', rel_min, 'B86:B86')
    xlswrite('values.xlsx', rel_max, 'A86:A86')
    xlswrite('values.xlsx', criterion_avg_rel, 'C86:C86')
    xlswrite('values.xlsx', criterion_avg_robad, 'D86:D86')
    xlswrite('values.xlsx', criterion_avg_rob, 'E86:E86')
else
    xlswrite('values.xlsx', rel_min, 'B80:B80')
    xlswrite('values.xlsx', rel_max, 'A80:A80')
    xlswrite('values.xlsx', criterion_avg_rel, 'C80:C80')
    xlswrite('values.xlsx', criterion_avg_robad, 'D80:D80')
    xlswrite('values.xlsx', criterion_avg_rob, 'E80:E80')
end

xlswrite('values.xlsx', {mat2str(k_max(1,1))}, 'B74:B74')
xlswrite('values.xlsx', {mat2str(T_max(1,1))}, 'B75:B75')
xlswrite('values.xlsx', tau_max(1,1), 'B76:B76')

xlswrite('values.xlsx', {mat2str(k_min(1,1))}, 'C74:C74')
xlswrite('values.xlsx', {mat2str(T_min(1,1))}, 'C75:C75')
xlswrite('values.xlsx', tau_min(1,1), 'C76:C76')

% Выводим значения в командную строку
if crit_quality == 0.589
    disp(['Минимальная разность ИМК: ', num2str(rel_min)]);
    disp(['Максимальная разность ИМК: ', num2str(rel_max)]);
    disp(['Средняя разность ИМК: ', num2str(criterion_avg_rel)]);
    disp(['Среднее значение ИМК робастно-адаптивного регулятора: ', num2str(criterion_avg_robad)])
    disp(['Среднее значение ИМК робастного регулятора: ', num2str(criterion_avg_rob)])
elseif crit_quality == 0.507
    disp(['Минимальная разность быстродействия: ', num2str(rel_min)]);
    disp(['Максимальная разность быстродействия: ', num2str(rel_max)]);
    disp(['Средняя разность быстродействия: ', num2str(criterion_avg_rel)]);
    disp(['Среднее значение быстродействия робастно-адаптивного регулятора: ', num2str(criterion_avg_robad)])
    disp(['Среднее значение быстродействия робастного регулятора: ', num2str(criterion_avg_rob)])
else
    disp(['Минимальная разность ИКК: ', num2str(rel_min)]);
    disp(['Максимальная разность ИКК: ', num2str(rel_max)]);
    disp(['Средняя разность ИКК: ', num2str(criterion_avg_rel)]);
    disp(['Среднее значение ИКК робастно-адаптивного регулятора: ', num2str(criterion_avg_robad)])
    disp(['Среднее значение ИКК робастного регулятора: ', num2str(criterion_avg_rob)])
end
% Звуковой сигнал
sound(y, Fs)
end