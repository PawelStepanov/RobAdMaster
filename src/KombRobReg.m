function [Wkp_robast, Wki_robast, criterion_min, ou11_rob, ou12_rob, ou21_rob, ou22_rob] = KombRobReg(Wavt_Ki_Rob, Wavt_Kp_Rob, Wvsp_Kp_Rob, Wvsp_Ki_Rob, crit_quality)

% Cчитаем робастный регулятор с перебором ро

% Звуковой файл для сигнализирования окончания работы программы
[y, Fs] = audioread('end.MP3');

global omega11
global omega12
global omega13
global omega21
global omega22
global omega23
global omega31
global omega32
global omega33
global ou11
global ou12
global ou13
global ou21
global ou22
global ou23
global ou31
global ou32
global ou33
global Tmod
global step_ro
global disturbance
global flag_size

global ou13_max
global ou23_max
global ou31_max
global ou32_max
global ou33_max

% Получение всех полей структуры zona_params вызовом функции ZonaControlObject
[omega] = ZonaControlObject;

% Присвоение переменных объектов управления (по необходимости)
if flag_size == 3
    omega11 = omega{1};
    omega12 = omega{2};
    omega13 = omega{3};
    omega21 = omega{4};   
    omega22 = omega{5};
    omega23 = omega{6};
    omega31 = omega{7};
    omega32 = omega{8};  
    omega33 = omega{9};
else
    omega11 = omega{1};
    omega12 = omega{2};
    omega21 = omega{3};
    omega22 = omega{4};   
end

% Передаем в рабочее пространство возмущение
assignin('base', 'disturbance1', disturbance(1,1));
assignin('base', 'disturbance2', disturbance(1,2));
if flag_size == 3
    assignin('base', 'disturbance2', disturbance(1,3));
end

% Вводим параметры ОУ
[k11, k11_2, T1_11, T2_11, T3_11, tau11, flag11] = Parameters(ou11);
[k12, k12_2, T1_12, T2_12, T3_12, tau12, flag12] = Parameters(ou12);
[k21, k21_2, T1_21, T2_21, T3_21, tau21, flag21] = Parameters(ou21);
[k22, k22_2, T1_22, T2_22, T3_22, tau22, flag22] = Parameters(ou22);
if flag_size == 3
    [k13, k13_2, T1_13, T2_13, T3_13, tau13, flag13] = Parameters(ou13);
    [k23, k23_2, T1_23, T2_23, T3_23, tau23, flag23] = Parameters(ou23);
    [k31, k31_2, T1_31, T2_31, T3_31, tau31, flag31] = Parameters(ou31);
    [k32, k32_2, T1_32, T2_32, T3_32, tau32, flag32] = Parameters(ou32);
    [k33, k33_2, T1_33, T2_33, T3_33, tau33, flag33] = Parameters(ou33);
end

% Вводим переменные для перебора параметров
[k11_min, k11_max, k11_step] = DefineBounds(k11, omega11{1}(1,1));
[k11_2_min, k11_2_max, k11_2_step] = DefineBounds(k11_2, omega11{1}(1,1));
[T1_11_min, T1_11_max, T1_11_step] = DefineBounds(T1_11, omega11{2}(1,1));
[T2_11_min, T2_11_max, T2_11_step] = DefineBounds(T2_11, omega11{2}(1,1));
[T3_11_min, T3_11_max, T3_11_step] = DefineBounds(T3_11, omega11{2}(1,1));
[tau11_min, tau11_max, tau11_step] = DefineBounds(tau11, omega11{3});

[k12_min, k12_max, k12_step] = DefineBounds(k12, omega12{1}(1,1));
[k12_2_min, k12_2_max, k12_2_step] = DefineBounds(k12_2, omega12{1}(1,1));
[T1_12_min, T1_12_max, T1_12_step] = DefineBounds(T1_12, omega12{2}(1,1));
[T2_12_min, T2_12_max, T2_12_step] = DefineBounds(T2_12, omega12{2}(1,1));
[T3_12_min, T3_12_max, T3_12_step] = DefineBounds(T3_12, omega12{2}(1,1));
[tau12_min, tau12_max, tau12_step] = DefineBounds(tau12, omega12{3});

[k21_min, k21_max, k21_step] = DefineBounds(k21, omega21{1}(1,1));
[k21_2_min, k21_2_max, k21_2_step] = DefineBounds(k21_2, omega21{1}(1,1));
[T1_21_min, T1_21_max, T1_21_step] = DefineBounds(T1_21, omega21{2}(1,1));
[T2_21_min, T2_21_max, T2_21_step] = DefineBounds(T2_21, omega21{2}(1,1));
[T3_21_min, T3_21_max, T3_21_step] = DefineBounds(T3_21, omega21{2}(1,1));
[tau21_min, tau21_max, tau21_step] = DefineBounds(tau21, omega21{3});

[k22_min, k22_max, k22_step] = DefineBounds(k22, omega22{1}(1,1));
[k22_2_min, k22_2_max, k22_2_step] = DefineBounds(k22_2, omega22{1}(1,1));
[T1_22_min, T1_22_max, T1_22_step] = DefineBounds(T1_22, omega22{2}(1,1));
[T2_22_min, T2_22_max, T2_22_step] = DefineBounds(T2_22, omega22{2}(1,1));
[T3_22_min, T3_22_max, T3_22_step] = DefineBounds(T3_22, omega22{2}(1,1));
[tau22_min, tau22_max, tau22_step] = DefineBounds(tau22, omega22{3});

if flag_size == 3
    [k13_min, k13_max, k13_step] = DefineBounds(k13, omega13{1}(1,1));
    [k13_2_min, k13_2_max, k13_2_step] = DefineBounds(k13_2, omega13{1}(1,1));
    [T1_13_min, T1_13_max, T1_13_step] = DefineBounds(T1_13, omega13{2}(1,1));
    [T2_13_min, T2_13_max, T2_13_step] = DefineBounds(T2_13, omega13{2}(1,1));
    [T3_13_min, T3_13_max, T3_13_step] = DefineBounds(T3_13, omega13{2}(1,1));
    [tau13_min, tau13_max, tau13_step] = DefineBounds(tau13, omega13{3});

    [k23_min, k23_max, k23_step] = DefineBounds(k23, omega23{1}(1,1));
    [k23_2_min, k23_2_max, k23_2_step] = DefineBounds(k23_2, omega23{1}(1,1));
    [T1_23_min, T1_23_max, T1_23_step] = DefineBounds(T1_23, omega23{2}(1,1));
    [T2_23_min, T2_23_max, T2_23_step] = DefineBounds(T2_23, omega23{2}(1,1));
    [T3_23_min, T3_23_max, T3_23_step] = DefineBounds(T3_23, omega23{2}(1,1));
    [tau23_min, tau23_max, tau23_step] = DefineBounds(tau23, omega23{3});

    [k31_min, k31_max, k31_step] = DefineBounds(k31, omega31{1}(1,1));
    [k31_2_min, k31_2_max, k31_2_step] = DefineBounds(k31_2, omega31{1}(1,1));
    [T1_31_min, T1_31_max, T1_31_step] = DefineBounds(T1_31, omega31{2}(1,1));
    [T2_31_min, T2_31_max, T2_31_step] = DefineBounds(T2_31, omega31{2}(1,1));
    [T3_31_min, T3_31_max, T3_31_step] = DefineBounds(T3_31, omega31{2}(1,1));
    [tau31_min, tau31_max, tau31_step] = DefineBounds(tau31, omega31{3});

    [k32_min, k32_max, k32_step] = DefineBounds(k32, omega32{1}(1,1));
    [k32_2_min, k32_2_max, k32_2_step] = DefineBounds(k32_2, omega32{1}(1,1));
    [T1_32_min, T1_32_max, T1_32_step] = DefineBounds(T1_32, omega32{2}(1,1));
    [T2_32_min, T2_32_max, T2_32_step] = DefineBounds(T2_32, omega32{2}(1,1));
    [T3_32_min, T3_32_max, T3_32_step] = DefineBounds(T3_32, omega32{2}(1,1));
    [tau32_min, tau32_max, tau32_step] = DefineBounds(tau32, omega32{3});  
    
    [k33_min, k33_max, k33_step] = DefineBounds(k33, omega33{1}(1,1));
    [k33_2_min, k33_2_max, k33_2_step] = DefineBounds(k33_2, omega33{1}(1,1));
    [T1_33_min, T1_33_max, T1_33_step] = DefineBounds(T1_33, omega33{2}(1,1));
    [T2_33_min, T2_33_max, T2_33_step] = DefineBounds(T2_33, omega33{2}(1,1));
    [T3_33_min, T3_33_max, T3_33_step] = DefineBounds(T3_33, omega33{2}(1,1));
    [tau33_min, tau33_max, tau33_step] = DefineBounds(tau33, omega33{3}); 
    
    % Создаем сетку значений параметров
    [k11_grid, k11_2_grid, k12_grid, k12_2_grid, k13_grid, k13_2_grid, k21_grid, k21_2_grid, k22_grid, k22_2_grid, ... 
        k23_grid, k23_2_grid, k31_grid, k31_2_grid, k32_grid, k32_2_grid, k33_grid, k33_2_grid, T1_11_grid, T2_11_grid, T3_11_grid, ...
        T1_12_grid, T2_12_grid, T3_12_grid, T1_13_grid, T2_13_grid, T3_13_grid, T1_21_grid, T2_21_grid, T3_21_grid, ...
        T1_22_grid, T2_22_grid, T3_22_grid, T1_23_grid, T2_23_grid, T3_23_grid, T1_31_grid, T2_31_grid, T3_31_grid, ...
        T1_32_grid, T2_32_grid, T3_32_grid, T1_33_grid, T2_33_grid, T3_33_grid, tau11_grid, tau12_grid, tau13_grid, ...
        tau21_grid, tau22_grid, tau23_grid, tau31_grid, tau32_grid, tau33_grid] = ndgrid(...
        k11_min:k11_step:k11_max, k11_2_min:k11_2_step:k11_2_max, k12_min:k12_step:k12_max, k12_2_min:k12_2_step:k12_2_max, ...
        k13_min:k13_step:k13_max, k13_2_min:k13_2_step:k13_2_max, k21_min:k21_step:k21_max, k21_2_min:k21_2_step:k21_2_max, ... 
        k22_min:k22_step:k22_max, k22_2_min:k22_2_step:k22_2_max, k23_min:k23_step:k23_max, k23_2_min:k23_2_step:k23_2_max, ...
        k31_min:k31_step:k31_max, k31_2_min:k31_2_step:k31_2_max, k32_min:k32_step:k32_max, k32_2_min:k32_2_step:k32_2_max, ...
        k33_min:k33_step:k33_max, k33_2_min:k33_2_step:k33_2_max, T1_11_min:T1_11_step:T1_11_max, T2_11_min:T2_11_step:T2_11_max, ...
        T3_11_min:T3_11_step:T3_11_max, T1_12_min:T1_12_step:T1_12_max, T2_12_min:T2_12_step:T2_12_max, T3_12_min:T3_12_step:T3_12_max, ...
        T1_13_min:T1_13_step:T1_13_max, T2_13_min:T2_13_step:T2_13_max, T3_13_min:T3_13_step:T3_13_max, T1_21_min:T1_21_step:T1_21_max, ...
        T2_21_min:T2_21_step:T2_21_max, T3_21_min:T3_21_step:T3_21_max, T1_22_min:T1_22_step:T1_22_max, T2_22_min:T2_22_step:T2_22_max, ...
        T3_22_min:T3_22_step:T3_22_max, T1_23_min:T1_23_step:T1_23_max, T2_23_min:T2_23_step:T2_23_max, T3_23_min:T3_23_step:T3_23_max, ...
        T1_31_min:T1_31_step:T1_31_max, T2_31_min:T2_31_step:T2_31_max, T3_31_min:T3_31_step:T3_31_max, T1_32_min:T1_32_step:T1_32_max, ...
        T2_32_min:T2_32_step:T2_32_max, T3_32_min:T3_32_step:T3_32_max, T1_33_min:T1_33_step:T1_33_max, T2_33_min:T2_33_step:T2_33_max, ...
        T3_33_min:T3_33_step:T3_33_max, tau11_min:tau11_step:tau11_max, tau12_min:tau12_step:tau12_max, tau13_min:tau13_step:tau13_max, ...
        tau21_min:tau21_step:tau21_max, tau22_min:tau22_step:tau22_max, tau23_min:tau23_step:tau23_max, tau31_min:tau31_step:tau31_max, ...
        tau32_min:tau32_step:tau32_max, tau33_min:tau33_step:tau33_max);
else
    % Создаем сетку значений параметров
    [k11_grid, k11_2_grid, k12_grid, k12_2_grid, k21_grid, k21_2_grid, k22_grid, k22_2_grid, ... 
        T1_11_grid, T2_11_grid, T3_11_grid, T1_12_grid, T2_12_grid, T3_12_grid, ...
        T1_21_grid, T2_21_grid, T3_21_grid, T1_22_grid, T2_22_grid, T3_22_grid, ...
        tau11_grid, tau12_grid, tau21_grid, tau22_grid] = ndgrid(...
        k11_min:k11_step:k11_max, k11_2_min:k11_2_step:k11_2_max, k12_min:k12_step:k12_max, k12_2_min:k12_2_step:k12_2_max, ...
        k21_min:k21_step:k21_max, k21_2_min:k21_2_step:k21_2_max, k22_min:k22_step:k22_max, k22_2_min:k22_2_step:k22_2_max, ...
        T1_11_min:T1_11_step:T1_11_max, T2_11_min:T2_11_step:T2_11_max, T3_11_min:T3_11_step:T3_11_max, T1_12_min:T1_12_step:T1_12_max, ...
        T2_12_min:T2_12_step:T2_12_max, T3_12_min:T3_12_step:T3_12_max, T1_21_min:T1_21_step:T1_21_max, T2_21_min:T2_21_step:T2_21_max, ...
        T3_21_min:T3_21_step:T3_21_max, T1_22_min:T1_22_step:T1_22_max, T2_22_min:T2_22_step:T2_22_max, T3_22_min:T3_22_step:T3_22_max, ...
        tau11_min:tau11_step:tau11_max, tau12_min:tau12_step:tau12_max, tau21_min:tau21_step:tau21_max, tau22_min:tau22_step:tau22_max);
end

% Перебор всех комбинаций параметров
num_combinations = numel(k11_grid);
step_iter = 0;
Min_max_criterion = 50000;
ro = 0;
ro_min_max = 0;
i = 1;
step_total = 0;

% Параметры для расчета быстродействия
DT = 0.01;
WOSM = 1;

% Перебираем ro до 1
for ro = ro: step_ro: 1
    
    % Считаем параметры регулятора и передаем их в рабочее пространство
    kp11 = (ro * (Wavt_Kp_Rob(1,1))) + ((1 - ro) * (Wvsp_Kp_Rob(1,1)));
    ki11 = (ro *  (Wavt_Ki_Rob(1,1))) + ((1 - ro) * (Wvsp_Kp_Rob(1,1)));
    assignin('base', 'kp11', kp11);
    assignin('base', 'ki11', ki11);

    kp12 = (1 - ro) * (Wvsp_Kp_Rob(1,2));
    ki12 = (1 - ro) * (Wvsp_Ki_Rob(1,2));
    assignin('base', 'kp12', kp12);
    assignin('base', 'ki12', ki12);
    
    kp21 = (1 - ro) * (Wvsp_Kp_Rob(2,1));
    ki21 = (1 - ro) * (Wvsp_Ki_Rob(2,1));
    assignin('base', 'kp21', kp21);
    assignin('base', 'ki21', ki21);
    
    kp22 = ro * (Wavt_Kp_Rob(2,2)) + ((1 - ro) * (Wvsp_Kp_Rob(2,2)));
    ki22 = ro * (Wavt_Ki_Rob(2,2)) + ((1 - ro) * (Wvsp_Ki_Rob(2,2)));
    assignin('base', 'kp22', kp22);
    assignin('base', 'ki22', ki22);
    
    if flag_size == 3
        kp13 = (1 - ro) * Wvsp_Kp_Rob(1, 3);
        ki13 = (1 - ro) * Wvsp_Ki_Rob(1, 3);
        assignin('base', 'kp13', kp13);
        assignin('base', 'ki13', ki13);

        kp23 = (1 - ro) * Wvsp_Kp_Rob(2,3);
        ki23 = (1 - ro) * Wvsp_Ki_Rob(2,3);
        assignin('base', 'kp23', kp23);
        assignin('base', 'ki23', ki23);

        kp31 = (1 - ro) * Wvsp_Kp_Rob(3,1);
        ki31 = (1 - ro) * Wvsp_Ki_Rob(3,1);
        assignin('base', 'kp31', kp31);
        assignin('base', 'ki31', ki31);

        kp32 = (1 - ro) * Wvsp_Kp_Rob(3,2);
        ki32 = (1 - ro) * Wvsp_Ki_Rob(3,2);
        assignin('base', 'kp32', kp32);
        assignin('base', 'ki32', ki32);
    
        kp33 = (ro * Wavt_Kp_Rob(3,3)) + ((1 - ro) * Wvsp_Kp_Rob(3,3));
        ki33 = (ro * Wavt_Ki_Rob(3,3)) + ((1 - ro) * Wvsp_Kp_Rob(3,3));
        assignin('base', 'kp33', kp33);
        assignin('base', 'ki33', ki33);

        % Параметры Kp
        Kp = [kp11 kp12 kp13; kp21 kp22 kp23; kp31 kp32 kp33];
        % Параметры Ki
        Ki = [ki11 ki12 ki13; ki21 ki22 ki23; ki31 ki32 ki33];
    else    
        % Параметры Kp
        Kp = [kp11 kp12; kp21 kp22];
        % Параметры Ki
        Ki = [ki11 ki12; ki21 ki22];
    end
    
    criterion_max = 0;

    % Перебираем параметры ОУ
    for idx = 1:num_combinations
        % Получаем значения параметров для данной комбинации
        k11 = k11_grid(idx);
        k11_2 = k11_2_grid(idx);
        k12 = k12_grid(idx);
        k12_2 = k12_2_grid(idx);
        k21 = k21_grid(idx);
        k21_2 = k21_2_grid(idx);
        k22 = k22_grid(idx);
        k22_2 = k22_2_grid(idx);
        T1_11 = T1_11_grid(idx);
        T2_11 = T2_11_grid(idx);
        T3_11 = T3_11_grid(idx);
        T1_12 = T1_12_grid(idx);
        T2_12 = T2_12_grid(idx);
        T3_12 = T3_12_grid(idx);
        T1_21 = T1_21_grid(idx);
        T2_21 = T2_21_grid(idx);
        T3_21 = T3_21_grid(idx);
        T1_22 = T1_22_grid(idx);
        T2_22 = T2_22_grid(idx);
        T3_22 = T3_22_grid(idx);
        tau11 = tau11_grid(idx);
        tau12 = tau12_grid(idx);
        tau21 = tau21_grid(idx);
        tau22 = tau22_grid(idx);
        if flag_size == 3
            k13 = k13_grid(idx);
            k13_2 = k13_2_grid(idx);
            k23 = k23_grid(idx);
            k23_2 = k23_2_grid(idx);
            k31 = k31_grid(idx);
            k31_2 = k31_2_grid(idx);
            k32 = k32_grid(idx);
            k32_2 = k32_2_grid(idx);
            k33 = k33_grid(idx);
            k33_2 = k33_2_grid(idx);
            T1_13 = T1_13_grid(idx);
            T2_13 = T2_13_grid(idx);
            T3_13 = T3_13_grid(idx);
            T1_23 = T1_23_grid(idx);
            T2_23 = T2_23_grid(idx);
            T3_23 = T3_23_grid(idx);
            T1_31 = T1_31_grid(idx);
            T2_31 = T2_31_grid(idx);
            T3_31 = T3_31_grid(idx);
            T1_32 = T1_32_grid(idx);
            T2_32 = T2_32_grid(idx);
            T3_32 = T3_32_grid(idx);
            T1_33 = T1_33_grid(idx);
            T2_33 = T2_33_grid(idx);
            T3_33 = T3_33_grid(idx);
            tau13 = tau13_grid(idx);
            tau23 = tau23_grid(idx);
            tau31 = tau31_grid(idx);
            tau32 = tau32_grid(idx);
            tau33 = tau33_grid(idx);
        
            % Записываем переменные в базовое рабочее пространство
            assignin('base', 'tau13', tau13);
            assignin('base', 'tau23', tau23);
            assignin('base', 'tau31', tau31);
            assignin('base', 'tau32', tau32);
            assignin('base', 'tau33', tau33);
            % Вызываем функцию для формирования нумератора
            numerator13 = FormNumerator(k13, k13_2);
            numerator23 = FormNumerator(k23, k23_2);
            numerator31 = FormNumerator(k31, k31_2);
            numerator32 = FormNumerator(k32, k32_2);
            numerator33 = FormNumerator(k33, k33_2);
    
            % Записываем переменные в базовое рабочее пространство
            assignin('base', 'numerator13', numerator13);
            assignin('base', 'numerator23', numerator23);
            assignin('base', 'numerator31', numerator31);
            assignin('base', 'numerator32', numerator32);
            assignin('base', 'numerator33', numerator33);
    
            % Вызываем функцию для формирования деноминатора
            denominator13 = FormDenominator(T1_13, T2_13, T3_13, flag13);
            denominator23 = FormDenominator(T1_23, T2_23, T3_23, flag23);
            denominator31 = FormDenominator(T1_31, T2_31, T3_31, flag31);
            denominator32 = FormDenominator(T1_32, T2_32, T3_32, flag32);
            denominator33 = FormDenominator(T1_33, T2_33, T3_33, flag33);
    
            % Записываем переменные в базовое рабочее пространство
            assignin('base', 'denominator13', denominator13);
            assignin('base', 'denominator23', denominator23);
            assignin('base', 'denominator31', denominator31);
            assignin('base', 'denominator32', denominator32);
            assignin('base', 'denominator33', denominator33);
        end
        
        % Передаем запаздывание в рабочее пространство
        assignin('base', 'tau11', tau11);
        assignin('base', 'tau12', tau12);
        assignin('base', 'tau21', tau21);
        assignin('base', 'tau22', tau22);
    
        numerator11 = FormNumerator(k11, k11_2);
        numerator12 = FormNumerator(k12, k12_2);
        numerator21 = FormNumerator(k21, k21_2);
        numerator22 = FormNumerator(k22, k22_2);
        
        % Передаем нумератор в рабочее пространство
        assignin('base', 'numerator11', numerator11);
        assignin('base', 'numerator12', numerator12);
        assignin('base', 'numerator21', numerator21);
        assignin('base', 'numerator22', numerator22);

        denominator11 = FormDenominator(T1_11, T2_11, T3_11, flag11);
        denominator12 = FormDenominator(T1_12, T2_12, T3_12, flag12);
        denominator21 = FormDenominator(T1_21, T2_21, T3_21, flag21);
        denominator22 = FormDenominator(T1_22, T2_22, T3_22, flag22);
        
        % Передаем деноминатор в рабочее пространство
        assignin('base', 'denominator11', denominator11);
        assignin('base', 'denominator12', denominator12);
        assignin('base', 'denominator21', denominator21);
        assignin('base', 'denominator22', denominator22);
               
        % Производим симуляцию
        if flag_size == 3
            simIn = Simulink.SimulationInput('MIMO3x3_model');
        else
            simIn = Simulink.SimulationInput('MIMO_model');
        end
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
                j = 0;
                while abs(X(N-j)) <= 0.05*WOSM
                    Nreg = N-j;
                    j = j+1;
                end
                criterion = Nreg * DT;
            end
        else
            criterion = get(out,"simout");
        end
                                                
        % Находим максимальный критерий качества управления
        if criterion > criterion_max
            criterion_max = criterion;
            if flag_size == 3
                % Параметры ОУ с максимальным критерием качества управления
                k = [numerator11 numerator12 numerator13; numerator21 numerator22 numerator23; ...
                    numerator31 numerator32 numerator33];
                T = [denominator11 denominator12 denominator13; denominator21 denominator22 denominator23; ...
                    denominator31 denominator32 denominator33];
                tau = [tau11 tau12 tau13; tau21 tau22 tau23; tau31 tau32 tau33];
                ou13_max = {[numerator13], [denominator13], [tau13]};
                ou23_max = {[numerator23], [denominator23], [tau23]};
                ou31_max = {[numerator31], [denominator31], [tau31]};
                ou32_max = {[numerator32], [denominator32], [tau32]};
                ou33_max = {[numerator33], [denominator33], [tau33]};
            else
                % Параметры ОУ с максимальным критерием качества управления
                k = [numerator11 numerator12; numerator21 numerator22];
                T = [denominator11 denominator12; denominator21 denominator22];
                tau = [tau11 tau12; tau21 tau22];
            end
            ou11_max = {[numerator11], [denominator11], [tau11]};
            ou12_max = {[numerator12], [denominator12], [tau12]};
            ou21_max = {[numerator21], [denominator21], [tau21]};
            ou22_max = {[numerator22], [denominator22], [tau22]};
        end
        
        step_total = step_total + 1;
        step_iter = step_iter + 1;
        disp(['Шаг итерации: ', num2str(step_iter)]);
        disp(['Всего итерации: ', num2str(step_total)]);                           
    end
    
    % Создание массива ро
    ro_array(i) = ro;
    
    % Создание массива Кp
    Kp11_array(i) = Kp(1, 1);
    Kp12_array(i) = Kp(1, 2);
    Kp21_array(i) = Kp(2, 1);
    Kp22_array(i) = Kp(2, 2);
    
    % Создание массива Ki
    Ki11_array(i) = Ki(1, 1);
    Ki12_array(i) = Ki(1, 2);
    Ki21_array(i) = Ki(2, 1);
    Ki22_array(i) = Ki(2, 2);
    
    % Создание массива максимальных критериев качетсва управления
    criterion_max_array(i) = criterion_max;
    
    % Создание массива параметров ОУ с максимальным критерием качества
    % управления
    K11_array(i) = {mat2str(k(1, 1))};
    K12_array(i) = {mat2str(k(1, 2))};
    K21_array(i) = {mat2str(k(2, 1))};
    K22_array(i) = {mat2str(k(2, 2))};
    
    T11_array(i) = {mat2str(T(1, 1))};
    T12_array(i) = {mat2str(T(1, 2))};
    T21_array(i) = {mat2str(T(2, 1))};
    T22_array(i) = {mat2str(T(2, 2))};
        
    tau11_array(i) = tau(1, 1);
    tau12_array(i) = tau(1, 2);
    tau21_array(i) = tau(2, 1);
    tau22_array(i) = tau(2, 2);
    if flag_size == 3
        % Создание массива Кp
        Kp13_array(i) = Kp(1, 3);
        Kp23_array(i) = Kp(2, 3);
        Kp31_array(i) = Kp(3, 1);
        Kp32_array(i) = Kp(3, 2);
        Kp33_array(i) = Kp(3, 3);
    
        % Создание массива Ki
        Ki13_array(i) = Ki(1, 3);
        Ki23_array(i) = Ki(2, 3);
        Ki31_array(i) = Ki(3, 1);
        Ki32_array(i) = Ki(3, 2);
        Ki33_array(i) = Ki(3, 3);
   
        % Создание массива параметров ОУ с максимальным критерием качества
        % управления
        K13_array(i) = {mat2str(k(1, 3))};
        K23_array(i) = {mat2str(k(2, 3))};
        K31_array(i) = {mat2str(k(3, 1))};
        K32_array(i) = {mat2str(k(3, 2))};
        K33_array(i) = {mat2str(k(3, 3))};
    
        T13_array(i) = {mat2str(T(1, 3))};
        T23_array(i) = {mat2str(T(2, 3))};
        T31_array(i) = {mat2str(T(3, 1))};
        T32_array(i) = {mat2str(T(3, 2))};
        T33_array(i) = {mat2str(T(3, 3))};
        
        tau13_array(i) = tau(1, 3);
        tau23_array(i) = tau(2, 3);
        tau31_array(i) = tau(3, 1);
        tau32_array(i) = tau(3, 2);
        tau33_array(i) = tau(3, 3);
    end
    
    i = i + 1;
    
    % Находим минимаксное значение ИКК
    if criterion_max < Min_max_criterion
        Min_max_criterion = criterion_max;
        
        % Значение ро при минимаксном ИКК
        ro_min_max = ro;
        
        if flag_size == 3
            ou13_min_max = ou13_max;
            ou23_min_max = ou23_max;
            ou31_min_max = ou31_max;
            ou32_min_max = ou32_max;
            ou33_min_max = ou33_max;
        end
        % Параметры самого трудного ОУ для робастного регулятора
        ou11_min_max = ou11_max;
        ou12_min_max = ou12_max;
        ou21_min_max = ou21_max;
        ou22_min_max = ou22_max;
    end
end

% Переносим значение в файл эксель
xlswrite('values.xlsx', ro_array, 'B17:L17')
xlswrite('values.xlsx', ro_array, 'O17:Y17')

xlswrite('values.xlsx', K11_array, 'B18:L18')
xlswrite('values.xlsx', T11_array, 'B19:L19')
xlswrite('values.xlsx', tau11_array, 'B20:L20')

xlswrite('values.xlsx', K12_array, 'B21:L21')
xlswrite('values.xlsx', T12_array, 'B22:L22')
xlswrite('values.xlsx', tau12_array, 'B23:L23')

xlswrite('values.xlsx', K21_array, 'B27:L27')
xlswrite('values.xlsx', T21_array, 'B28:L28')
xlswrite('values.xlsx', tau21_array, 'B29:L29')

xlswrite('values.xlsx', K22_array, 'B30:L30')
xlswrite('values.xlsx', T22_array, 'B31:L31')
xlswrite('values.xlsx', tau22_array, 'B32:L32')

if flag_size == 3
    xlswrite('values.xlsx', K13_array, 'B24:L24')
    xlswrite('values.xlsx', T13_array, 'B25:L25')
    xlswrite('values.xlsx', tau13_array, 'B26:L26')

    xlswrite('values.xlsx', K23_array, 'B33:L33')
    xlswrite('values.xlsx', T23_array, 'B34:L34')
    xlswrite('values.xlsx', tau23_array, 'B35:L35')

    xlswrite('values.xlsx', K31_array, 'B36:L36')
    xlswrite('values.xlsx', T31_array, 'B37:L37')
    xlswrite('values.xlsx', tau31_array, 'B38:L38')

    xlswrite('values.xlsx', K32_array, 'B39:L39')
    xlswrite('values.xlsx', T32_array, 'B40:L40')
    xlswrite('values.xlsx', tau32_array, 'B41:L41')
    
    xlswrite('values.xlsx', K33_array, 'B42:L42')
    xlswrite('values.xlsx', T33_array, 'B43:L43')
    xlswrite('values.xlsx', tau33_array, 'B44:L44')
end

if crit_quality == 0.589
    xlswrite('values.xlsx', criterion_max_array, 'B47:L47')
elseif crit_quality == 0.507
    xlswrite('values.xlsx', criterion_max_array, 'B48:L48')
else
    xlswrite('values.xlsx', criterion_max_array, 'B46:L46')
end
xlswrite('values.xlsx', Min_max_criterion(1), 'B49:B49')
xlswrite('values.xlsx', ro_min_max(1), 'B50:B50')

xlswrite('values.xlsx', Kp11_array, 'O18:Y18')
xlswrite('values.xlsx', Kp12_array, 'O19:Y19')
xlswrite('values.xlsx', Kp21_array, 'O21:Y21')
xlswrite('values.xlsx', Kp22_array, 'O22:Y22')

xlswrite('values.xlsx', Ki11_array, 'O27:Y27')
xlswrite('values.xlsx', Ki12_array, 'O28:Y28')
xlswrite('values.xlsx', Ki21_array, 'O30:Y30')
xlswrite('values.xlsx', Ki22_array, 'O31:Y31')
if flag_size == 3
    xlswrite('values.xlsx', Kp13_array, 'O20:Y20')
    xlswrite('values.xlsx', Kp23_array, 'O23:Y23')
    xlswrite('values.xlsx', Kp31_array, 'O24:Y24')
    xlswrite('values.xlsx', Kp32_array, 'O25:Y25')
    xlswrite('values.xlsx', Kp33_array, 'O26:Y26')

    xlswrite('values.xlsx', Ki13_array, 'O29:Y29')
    xlswrite('values.xlsx', Ki23_array, 'O32:Y32')
    xlswrite('values.xlsx', Ki31_array, 'O33:Y33')
    xlswrite('values.xlsx', Ki32_array, 'O34:Y34')
    xlswrite('values.xlsx', Ki33_array, 'O35:Y35')
end
    

% Выводим значения в командную строку
if crit_quality == 0.589
    disp(['Минимаксное ИМК :', num2str(Min_max_criterion)])
elseif crit_quality == 0.507
    disp(['Минимаксное быстродействие :', num2str(Min_max_criterion)])
else
    disp(['Минимаксное ИКК :', num2str(Min_max_criterion)])
end
disp(['Значение ro при котором получаем минимаксное значение критерия: ', num2str(ro_min_max)])

kp11 = (ro_min_max * (Wavt_Kp_Rob(1,1))) + ((1 - ro_min_max) * (Wvsp_Kp_Rob(1,1)));
ki11 = (ro_min_max *  (Wavt_Ki_Rob(1,1))) + ((1 - ro_min_max) * (Wvsp_Kp_Rob(1,1)));

kp12 = (1 - ro_min_max) * (Wvsp_Kp_Rob(1,2));
ki12 = (1 - ro_min_max) * (Wvsp_Ki_Rob(1,2));

kp21 = (1 - ro_min_max) * (Wvsp_Kp_Rob(2,1));
ki21 = (1 - ro_min_max) * (Wvsp_Ki_Rob(2,1));

kp22 = ro_min_max * (Wavt_Kp_Rob(2,2)) + ((1 - ro_min_max) * (Wvsp_Kp_Rob(2,2)));
ki22 = ro_min_max * (Wavt_Ki_Rob(2,2)) + ((1 - ro_min_max) * (Wvsp_Ki_Rob(2,2)));

if flag_size == 3
        kp13 = (1 - ro_min_max) * Wvsp_Kp_Rob(1, 3);
        ki13 = (1 - ro_min_max) * Wvsp_Ki_Rob(1, 3);

        kp23 = (1 - ro_min_max) * Wvsp_Kp_Rob(2,3);
        ki23 = (1 - ro_min_max) * Wvsp_Ki_Rob(2,3);
        
        kp31 = (1 - ro_min_max) * Wvsp_Kp_Rob(3,1);
        ki31 = (1 - ro_min_max) * Wvsp_Ki_Rob(3,1);

        kp32 = (1 - ro_min_max) * Wvsp_Kp_Rob(3,2);
        ki32 = (1 - ro_min_max) * Wvsp_Ki_Rob(3,2);
    
        kp33 = (ro_min_max * Wavt_Kp_Rob(3,3)) + ((1 - ro_min_max) * Wvsp_Kp_Rob(3,3));
        ki33 = (ro_min_max * Wavt_Ki_Rob(3,3)) + ((1 - ro_min_max) * Wvsp_Kp_Rob(3,3)); 
        
        Wkp_robast = [kp11 kp12 kp13; kp21 kp22 kp23; kp31 kp32 kp33]
        Wki_robast = [ki11 ki12 ki13; ki21 ki22 ki23; ki31 ki32 ki33]
        
        ou13_max = ou13_min_max;
        ou23_max = ou23_min_max;
        ou31_max = ou31_min_max;
        ou32_max = ou32_min_max;
        ou33_max = ou33_min_max;
else
    Wkp_robast = [kp11 kp12; kp21 kp22]
    Wki_robast = [ki11 ki12; ki21 ki22]
end
criterion_min = Min_max_criterion;
ou11_rob = ou11_min_max;
ou12_rob = ou12_min_max;
ou21_rob = ou21_min_max;
ou22_rob = ou22_min_max;

% Переносим значение в файл эксель
xlswrite('results.xlsx', {mat2str(Wkp_robast)}, 'O38:O38')
xlswrite('results.xlsx', {mat2str(Wki_robast)}, 'O39:O39')

% Звуковой сигнал
sound(y, Fs)
end