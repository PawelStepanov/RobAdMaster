function [kp_rob, ki_rob, criterion_min, kp_nom, ki_nom] = MaximumSensitivity1x1(crit_quality)

% Считаем методом максимальной чувствительности регулятор в кандидаты на
% робастный 

% Звуковой файл для сигнализирования окончания работы программы
[y, Fs] = audioread('end.MP3');

global ou11
global Tmod
global disturbance

% Проверяем нужна ли аппроксимация и если нужна возвращаем параметры
% аппроксимированого ОУ
[k, T, tau]= ParamApproximNom(ou11);

%     ВСПОМОГАТЕЛЬНЫЙ РЕГУЛЯТОР
Wvsp_Kp_nom = inv(k) * crit_quality * (min(T)/ max(tau));
Wvsp_Ki_nom = inv(k) * (crit_quality/max(tau));

%     АВТОНОМНЫЙ РЕГУЛЯТОР
Wavt_Kp_nom = ((crit_quality*T)/(k*tau));
Wavt_Ki_nom = (crit_quality/(k*tau));

% Формируем исходный ОУ
numerator_orig = [ou11{1}];
denominator_orig = [ou11{2}];
tau_orig = [ou11{3}];

% Записываем переменные в базовое рабочее пространство
assignin('base', 'numerator', numerator_orig);
assignin('base', 'denominator', denominator_orig);
assignin('base', 'tau', tau_orig);
assignin('base', 'Tmod', Tmod);
assignin('base', 'disturbance1', disturbance(1,1));

% Чтобы найти минимальный критерий
criterion_min = 500000000000000;

% Параметры для расчета быстродействия
DT = 0.01;
WOSM = 1;
ro_min = 0;

%    СЧИТАЕМ РЕГУЛЯТОР КОМПЕНСАЦИОННЫМ МЕТОДОМ
for ro = 0:0.1:1
    kp = (ro * (Wavt_Kp_nom)) + ((1 - ro) * (Wvsp_Kp_nom));
    ki = (ro * (Wavt_Ki_nom)) + ((1 - ro) * (Wvsp_Ki_nom));
    
    % Записываем переменные в базовое рабочее пространство
    assignin('base', 'kp', kp);
    assignin('base', 'ki', ki);
    % Настройка симуляции
    simIn = Simulink.SimulationInput('SISO_model');
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
    if criterion < criterion_min
        criterion_min = criterion;
        ro_min = ro;
    end
end

% Считаем параметры регулятора
kp = (ro_min * (Wavt_Kp_nom)) + ((1 - ro_min) * (Wvsp_Kp_nom));
ki = (ro_min * (Wavt_Ki_nom)) + ((1 - ro_min) * (Wvsp_Ki_nom));
kp_nom = kp;
ki_nom = ki;

assignin('base', 'kp', kp);
assignin('base', 'ki', ki);

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

% Номинальные значения параметров
nominal_values  = [k, k2, T1, T2, T3, tau];

% Границы параметров: каждая строка содержит нижнюю и верхнюю границу
bounds = [
    k_min, k_max;  
    k2_min, k2_max;  
    T1_min, T1_max;  
    T2_min, T2_max;
    T3_min, T3_max;
    tau_min, tau_max
];

% Количество параметров
n_params = length(nominal_values);
% Массив для хранения значений критериев и параметров
criteria = [];
parametr = [];
% Самые чувствительные параметры
sensitivity_values = nominal_values;

% Проходим по каждому параметру
for param_idx = 1:n_params
    % Пропускаем параметр, если его номинальное значение или границы равны nan
    if isnan(nominal_values(param_idx)) || bounds(param_idx, 1) == bounds(param_idx, 2)
        criteria = [criteria; nan];
        criteria = [criteria; nan];
        parametr = [parametr; nan];
        parametr = [parametr; nan];
        continue;  % Переходим к следующему параметру
    end
    
    % Для каждой границы параметра (нижняя и верхняя)
    for boundary_idx = 1:2
        
        % Копируем номинальные значения параметров     
        current_params = nominal_values;
        
        % Заменяем только один параметр на его границу
        current_params(param_idx) = bounds(param_idx, boundary_idx);
        
        % Вызываем функцию для формирования нумератора
        numerator = FormNumerator(current_params(1), current_params(2));
        % Вызываем функцию для формирования деноминатора
        denominator = FormDenominator(current_params(3), current_params(4), current_params(5), flag);
        
        % Записываем переменные в базовое рабочее пространство
        assignin('base', 'numerator', numerator);
        assignin('base', 'denominator', denominator);
        assignin('base', 'tau', current_params(6));

        % Настройка симуляции
        simIn = Simulink.SimulationInput('SISO_model');
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
       criteria = [criteria; ((criterion - criterion_min)/criterion_min) * 100];
       parametr = [parametr; current_params(param_idx)];
    end

    if criteria(param_idx*2-1) < 0 && criteria(param_idx*2) < 0
        continue; % Переходим к следующему параметру
    elseif criteria(param_idx*2-1) > criteria(param_idx*2)
        sensitivity_values(param_idx) = parametr(param_idx*2-1);
    elseif criteria(param_idx*2-1) < criteria(param_idx*2)
        sensitivity_values(param_idx) = parametr(param_idx*2);
    end
end

% Формируем ОУ с наиболее чувствительными параметрами
object = ou11;
numerator = FormNumerator(sensitivity_values(1), sensitivity_values(2));
denominator = FormDenominator(sensitivity_values(3), sensitivity_values(4), sensitivity_values(5), flag);
tau = [sensitivity_values(6)];
object{1} = numerator;
object{2} = denominator;
object{3} = tau;

% Проверяем нужна ли аппроксимация и если нужна возвращаем параметры
% аппроксимированого ОУ
[k_rob, T_rob, tau_rob]= ParamApproximNom(object);

% Записываем исходные переменные в базовое рабочее пространство
assignin('base', 'numerator', numerator_orig);
assignin('base', 'denominator', denominator_orig);
assignin('base', 'tau', tau_orig);
criterion_min = 500000000000000;

%     ВСПОМОГАТЕЛЬНЫЙ РЕГУЛЯТОР
Wvsp_Kp_rob = inv(k_rob) * crit_quality * (min(T_rob)/ max(tau_rob));
Wvsp_Ki_rob = inv(k_rob) * (crit_quality/max(tau_rob));

%     АВТОНОМНЫЙ РЕГУЛЯТОР
Wavt_Kp_rob = ((crit_quality*T_rob)/(k_rob*tau_rob));
Wavt_Ki_rob = (crit_quality/(k_rob*tau_rob));

%    СЧИТАЕМ РЕГУЛЯТОР ПОДОЗРИТЕЛЬНЫЙ НА РОБАСТНОСТЬ
for ro = 0:0.1:1
    kp = (ro * (Wavt_Kp_rob)) + ((1 - ro) * (Wvsp_Kp_rob));
    ki = (ro * (Wavt_Ki_rob)) + ((1 - ro) * (Wvsp_Ki_rob));
    
    assignin('base', 'kp', kp);
    assignin('base', 'ki', ki);
    % Настройка симуляции
    simIn = Simulink.SimulationInput('SISO_model');
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
    if criterion < criterion_min
        criterion_min = criterion;
        ro_min = ro;
    end
end

% Получаем кандидата на робастный регулятор и соотвествующие ему значение
% криетрия
kp_rob = (ro_min * (Wavt_Kp_rob)) + ((1 - ro_min) * (Wvsp_Kp_rob));
ki_rob = (ro_min * (Wavt_Ki_rob)) + ((1 - ro_min) * (Wvsp_Ki_rob));
disp(['П: ', num2str(kp_rob)])
disp(['И: ', num2str(ki_rob)])
disp(['Значения критерия: ', num2str(criterion_min)])

% Переносим значение в файл эксель
xlswrite('results.xlsx', kp_rob, 2, 'B52:B52')
xlswrite('results.xlsx', ki_rob, 2, 'B53:B53')
% Далее необходимо перейти к проверки данного регулятора на всех точках

% Звуковой сигнал
sound(y, Fs)
end