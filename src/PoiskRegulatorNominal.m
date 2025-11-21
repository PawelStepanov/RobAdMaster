function [ki_crit_min, criterion_min] = PoiskRegulatorNominal(crit_quality)

% Поиск робастного И-регулятора 

% Звуковой файл для сигнализирования окончания работы программы
[y, Fs] = audioread('end.MP3');

global Tmod
global ou11
global disturbance

% Передаем в рабочее пространство возмущение
assignin('base', 'disturbance1', disturbance(1,1));
% Передаем в рабочее пространство параметры регулятора
assignin('base', 'kp', 0);

tau = ou11{3};
[m,n] = size(ou11{1});
if n == 2
    k = ou11{1}(1,1);
    k2 = ou11{1}(1,2);
    numerator = [k*k2 k];
else
    k = ou11{1}(1,1);
    numerator = [k];
end
% Проверяем какой у нас ОУ (колебательный или апериодический)
[m,n] = size(ou11{2});
if ou11{2}(1,1) == 1 && n == 3
    denominator = [1 ou11{2}(1,2) ou11{2}(1,3)];
else
    if n == 3
        T1 = ou11{2}(1,1);
        T2 = ou11{2}(1,2);
        denominator = [T1*T2 T1+T2 1];
    elseif n == 4
        T1 = ou11{2}(1,1);
        T2 = ou11{2}(1,2);
        T3 = ou11{2}(1,3);
        denominator = [T1*T2*T3 T1*T2+T1*T3+T2*T3 T1+T2+T3 1];
    else
        denominator = [ou11{2}(1,1) 1];
    end
end

assignin('base', 'numerator', numerator);
assignin('base', 'denominator', denominator);
assignin('base', 'tau', tau);

N = 100;
% Поиск Ki
% Ki верхняя граница
ki_max = (crit_quality)/(k*tau);
% Шаг моделирования Ki
ki_step = ki_max/N;

criterion_min = 100000;
step_iter = 0;
i = 1;

for ki = 0:ki_step:ki_max
    
    % Записываем переменные в базовое рабочее пространство
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
    
    ki_crit = ki;
    if ki_crit == ki_max
        ki_max = ki_max * 0.1 + ki_max;
    end
    % Находим минимальное значение критерия качества управления
    if criterion < criterion_min
        criterion_min = criterion;
        ki_crit_min = ki;
    end

    % Создание массива Ки
    Ki_array(i) = ki_crit;
    
    % Создание массива максимальных критериев
    criterion_array(i) = criterion;
    
    i = i + 1;
    
    step_iter = step_iter + 1;
    disp(['Шаг итерации: ', num2str(step_iter)])
end

% Переносим значение в файл эксель
xlswrite('results.xlsx', Ki_array, 'A11:CW11')
xlswrite('results.xlsx', ki_crit_min(1), 'B20:B20')
if crit_quality == 0.589
    xlswrite('results.xlsx', criterion_array, 'A15:CW15')
    xlswrite('results.xlsx', criterion_min(1), 'D19:D19')
elseif crit_quality == 0.507
    xlswrite('results.xlsx', criterion_array, 'A17:CW17')
    xlswrite('results.xlsx', criterion_min(1), 'F19:F19')
else
    xlswrite('results.xlsx', criterion_array, 'A13:CW13')
    xlswrite('results.xlsx', criterion_min(1), 'B19:B19')
end
% Выводим значения в командную строку
if crit_quality == 0.589
    disp(['Мниимальное ИМК :', num2str(criterion_min)])
elseif crit_quality == 0.507
    disp(['Мниимальное быстродействие :', num2str(criterion_min)])
else
    disp(['Мниимальное ИКК :', num2str(criterion_min)])
end
disp(['Ki, при котором достигается минимальный критерий: ', num2str(ki_crit_min)])

% Звуковой сигнал
sound(y, Fs)
end