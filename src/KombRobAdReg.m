function [rel_min, rel_max, Kp_max, Ki_max, ou11_max, ou12_max, ou21_max, ou22_max] = KombRobAdReg(Wkp_robast, Wki_robast, Wkp_nominal, Wki_nominal, crit_quality)

% Считаем робастно-адаптивный регулятор

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
relative_diff_total = 0;
criterion_robad_total = 0;
criterion_rob_total = 0;
rel_max = 0;
rel_min = 5000;
step_iter = 0;
alpha = 0;

% Параметры для расчета быстродействия
DT = 0.01;
WOSM = 1;
  
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
    
    Min_criterion_ad = 50000;
                            
    % Перебираем alpha от 0 до 1
    for alpha = alpha: step_alpha: 1
        
        % Считаем параметры регулятора
        kp11 = (alpha * (Wkp_robast(1,1))) + ((1 - alpha) * (Wkp_nominal(1,1)));
        ki11 = (alpha * (Wki_robast(1,1))) + ((1 - alpha) * (Wki_nominal(1,1)));
        assignin('base', 'kp11', kp11);
        assignin('base', 'ki11', ki11);
        
        kp12 = (alpha * (Wkp_robast(1,2))) + ((1 - alpha) * (Wkp_nominal(1,2)));
        ki12 = (alpha * (Wki_robast(1,1))) + ((1 - alpha) * (Wki_nominal(1,2)));
        assignin('base', 'kp12', kp12);
        assignin('base', 'ki12', ki12);
        
        kp21 = (alpha * (Wkp_robast(2,1))) + ((1 - alpha) * (Wkp_nominal(2,1)));
        ki21 = (alpha * (Wki_robast(2,1))) + ((1 - alpha) * (Wki_nominal(2,1)));
        assignin('base', 'kp21', kp21);
        assignin('base', 'ki21', ki21);
        
        kp22 = (alpha * (Wkp_robast(2,2))) + ((1 - alpha) * (Wkp_nominal(2,2)));
        ki22 = (alpha * (Wki_robast(2,2))) + ((1 - alpha) * (Wki_nominal(2,2)));
        assignin('base', 'kp22', kp22);
        assignin('base', 'ki22', ki22);
        if flag_size == 3
            kp13 = (alpha * (Wkp_robast(1,3))) + ((1 - alpha) * (Wkp_nominal(1,3)));
            ki13 = (alpha * (Wki_robast(1,3))) + ((1 - alpha) * (Wki_nominal(1,3)));
            assignin('base', 'kp13', kp13);
            assignin('base', 'ki13', ki13);

            kp23 = (alpha * (Wkp_robast(2,3))) + ((1 - alpha) * (Wkp_nominal(2,3)));
            ki23 = (alpha * (Wki_robast(2,3))) + ((1 - alpha) * (Wki_nominal(2,3)));
            assignin('base', 'kp23', kp23);
            assignin('base', 'ki23', ki23);

            kp31 = (alpha * (Wkp_robast(3,1))) + ((1 - alpha) * (Wkp_nominal(3,1)));
            ki31 = (alpha * (Wki_robast(3,1))) + ((1 - alpha) * (Wki_nominal(3,1)));
            assignin('base', 'kp31', kp31);
            assignin('base', 'ki31', ki31);

            kp32 = (alpha * (Wkp_robast(3,2))) + ((1 - alpha) * (Wkp_nominal(3,2)));
            ki32 = (alpha * (Wki_robast(3,2))) + ((1 - alpha) * (Wki_nominal(3,2)));
            assignin('base', 'kp32', kp32);
            assignin('base', 'ki32', ki32);
    
            kp33 = (alpha * (Wkp_robast(3,3))) + ((1 - alpha) * (Wkp_nominal(3,3)));
            ki33 = (alpha * (Wki_robast(3,3))) + ((1 - alpha) * (Wki_nominal(3,3)));
            assignin('base', 'kp33', kp33);
            assignin('base', 'ki33', ki33);
        end

        % Производим симуляцию
        if flag_size == 3
            simIn = Simulink.SimulationInput('MIMO3x3_model');
        else
            simIn = Simulink.SimulationInput('MIMO_model');
        end
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
                j = 0;
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
            if flag_size == 3
                Kp = [kp11 kp12 kp13; kp21 kp22 kp23; kp31 kp32 kp33];
                Ki = [ki11 ki12 ki13; ki21 ki22 ki23; ki31 ki32 ki33];
            else
                % Параметры Kp
                Kp = [kp11 kp12; kp21 kp22];
                % Параметры Ki
                Ki = [ki11 ki12; ki21 ki22];
            end
        end
    end
                                                    
    % Параметры робастного регулятора 
    kp11 = Wkp_robast(1,1);
    ki11 = Wki_robast(1,1);
    kp12 = Wkp_robast(1,2);
    ki12 = Wki_robast(1,2);
    kp21 = Wkp_robast(2,1);
    ki21 = Wki_robast(2,1);
    kp22 = Wkp_robast(2,2);
    ki22 = Wki_robast(2,2);
    assignin('base', 'kp11', kp11);
    assignin('base', 'ki11', ki11);
    assignin('base', 'kp12', kp12);
    assignin('base', 'ki12', ki12);
    assignin('base', 'kp21', kp21);
    assignin('base', 'ki21', ki21);
    assignin('base', 'kp22', kp22);
    assignin('base', 'ki22', ki22);
    if flag_size == 3
        kp13 = Wkp_robast(1,3);
        ki13 = Wki_robast(1,3);
        kp23 = Wkp_robast(2,3);
        ki23 = Wki_robast(2,3);
        kp31 = Wkp_robast(3,1);
        ki31 = Wki_robast(3,1);
        kp32 = Wkp_robast(3,2);
        ki32 = Wki_robast(3,2);
        kp33 = Wkp_robast(3,3);
        ki33 = Wki_robast(3,3);
        assignin('base', 'kp13', kp13);
        assignin('base', 'ki13', ki13);
        assignin('base', 'kp23', kp23);
        assignin('base', 'ki23', ki23);
        assignin('base', 'kp31', kp31);
        assignin('base', 'ki31', ki31);
        assignin('base', 'kp32', kp32);
        assignin('base', 'ki32', ki32);
        assignin('base', 'kp33', kp33);
        assignin('base', 'ki33', ki33);
    end
    
    % Производим симуляцию
    if flag_size == 3
        simIn = Simulink.SimulationInput('MIMO3x3_model');
    else
        simIn = Simulink.SimulationInput('MIMO_model');
    end
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
            j = 0;
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
                                                
    % Находим максимальную разность критерия качества управления
    if relative_diff >= rel_max
        rel_max = relative_diff;
                                                    
        % Параметры ОУ с максимальной  разницей критерия качества
        % управления
        if flag_size == 3 
            k_max = [numerator11 numerator12 numerator13; numerator21 numerator22 numerator23; ...
                numerator31 numerator32 numerator33];
            T_max = [denominator11 denominator12 denominator13; denominator21 denominator22 denominator23; ...
                denominator31 denominator32 denominator33];
            tau_max = [tau11 tau12 tau13; tau21 tau22 tau23; tau31 tau32 tau33];
            ou13_max = {[numerator13], [denominator13], [tau13]};
            ou23_max = {[numerator23], [denominator23], [tau23]};
            ou31_max = {[numerator31], [denominator31], [tau31]};
            ou32_max = {[numerator32], [denominator32], [tau32]};
            ou33_max = {[numerator33], [denominator33], [tau33]};
        else
            k_max = [numerator11 numerator12; numerator21 numerator22];
            T_max = [denominator11 denominator12; denominator21 denominator22];
            tau_max = [tau11 tau12; tau21 tau22]; 
        end
        ou11_max = {[numerator11], [denominator11], [tau11]};
        ou12_max = {[numerator12], [denominator12], [tau12]};
        ou21_max = {[numerator21], [denominator21], [tau21]};
        ou22_max = {[numerator22], [denominator22], [tau22]};
        Kp_max = Kp;
        Ki_max = Ki;
   end
                                                    
   % Находим минимальную разность критерия качества управления
   if relative_diff < rel_min
       rel_min = relative_diff;
       % Параметры ОУ с максимальной  разницей криетрия качества управления
       if flag_size == 3 
            k_min = [numerator11 numerator12 numerator13; numerator21 numerator22 numerator23; ...
                numerator31 numerator32 numerator33];
            T_min = [denominator11 denominator12 denominator13; denominator21 denominator22 denominator23; ...
                denominator31 denominator32 denominator33];
            tau_min = [tau11 tau12 tau13; tau21 tau22 tau23; tau31 tau32 tau33];
       else
           k_min = [numerator11 numerator12; numerator21 numerator22];
           T_min = [denominator11 denominator12; denominator21 denominator22];
           tau_min = [tau11 tau12; tau21 tau22];  
       end
       Kp_min = Kp;
       Ki_min = Ki;
   end
                                                
   step_iter = step_iter + 1;
   disp(['Шаг итерации: ', num2str(step_iter)]);
end
 
% Находим среднюю разность критерия качества управления
criterion_avg_rel = relative_diff_total / step_iter;

% Находим среднее значение критерия качества управления
criterion_avg_robad = criterion_robad_total / step_iter;
criterion_avg_rob = criterion_rob_total / step_iter;

% Переносим значение в файл эксель
xlswrite('values.xlsx', {mat2str(Kp_max)}, 'B69:B69')
xlswrite('values.xlsx', {mat2str(Ki_max)}, 'C69:C69')
xlswrite('values.xlsx', {mat2str(Kp_min)}, 'B71:B71')
xlswrite('values.xlsx', {mat2str(Ki_min)}, 'C71:C71')
if crit_quality == 0.589
    xlswrite('values.xlsx', rel_min, 'B108:B108')
    xlswrite('values.xlsx', rel_max, 'A108:A108')
    xlswrite('values.xlsx', criterion_avg_rel, 'C108:C108')
    xlswrite('values.xlsx', criterion_avg_robad, 'D108:D108')
    xlswrite('values.xlsx', criterion_avg_rob, 'E108:E108')
elseif crit_quality == 0.507
    xlswrite('values.xlsx', rel_min, 'B111:B111')
    xlswrite('values.xlsx', rel_max, 'A111:A111')
    xlswrite('values.xlsx', criterion_avg_rel, 'C111:C111')
    xlswrite('values.xlsx', criterion_avg_robad, 'D111:D111')
    xlswrite('values.xlsx', criterion_avg_rob, 'E111:E111')
else
    xlswrite('values.xlsx', rel_min, 'B105:B105')
    xlswrite('values.xlsx', rel_max, 'A105:A105')
    xlswrite('values.xlsx', criterion_avg_rel, 'C105:C105')
    xlswrite('values.xlsx', criterion_avg_robad, 'D105:D105')
    xlswrite('values.xlsx', criterion_avg_rob, 'E105:E105')
end

xlswrite('values.xlsx', {mat2str(k_max(1,1))}, 'B75:B75')
xlswrite('values.xlsx', {mat2str(T_max(1,1))}, 'B76:B76')
xlswrite('values.xlsx', {mat2str(tau_max(1,1))}, 'B77:B77')

xlswrite('values.xlsx', {mat2str(k_max(1,2))}, 'B78:B78')
xlswrite('values.xlsx', {mat2str(T_max(1,2))}, 'B79:B79')
xlswrite('values.xlsx', {mat2str(tau_max(1,2))}, 'B80:B80')

xlswrite('values.xlsx', {mat2str(k_max(2,1))}, 'B84:B84')
xlswrite('values.xlsx', {mat2str(T_max(2,1))}, 'B85:B85')
xlswrite('values.xlsx', {mat2str(tau_max(2,1))}, 'B86:B86')

xlswrite('values.xlsx', {mat2str(k_max(2,2))}, 'B87:B87')
xlswrite('values.xlsx', {mat2str(T_max(2,2))}, 'B88:B88')
xlswrite('values.xlsx', {mat2str(tau_max(2,2))}, 'B89:B89')

xlswrite('values.xlsx', {mat2str(k_min(1,1))}, 'C75:C75')
xlswrite('values.xlsx', {mat2str(T_min(1,1))}, 'C76:C76')
xlswrite('values.xlsx', {mat2str(tau_min(1,1))}, 'C77:C77')

xlswrite('values.xlsx', {mat2str(k_min(1,2))}, 'C78:C78')
xlswrite('values.xlsx', {mat2str(T_min(1,2))}, 'C79:C79')
xlswrite('values.xlsx', {mat2str(tau_min(1,2))}, 'C80:C80')

xlswrite('values.xlsx', {mat2str(k_min(2,1))}, 'C84:C84')
xlswrite('values.xlsx', {mat2str(T_min(2,1))}, 'C85:C85')
xlswrite('values.xlsx', {mat2str(tau_min(2,1))}, 'C86:C86')

xlswrite('values.xlsx', {mat2str(k_min(2,2))}, 'C87:C87')
xlswrite('values.xlsx', {mat2str(T_min(2,2))}, 'C88:C88')
xlswrite('values.xlsx', {mat2str(tau_min(2,2))}, 'C89:C89')
if flag_size == 3
    xlswrite('values.xlsx', {mat2str(k_max(1,3))}, 'B81:B81')
    xlswrite('values.xlsx', {mat2str(T_max(1,3))}, 'B82:B82')
    xlswrite('values.xlsx', {mat2str(tau_max(1,3))}, 'B83:B83')

    xlswrite('values.xlsx', {mat2str(k_max(2,3))}, 'B90:B90')
    xlswrite('values.xlsx', {mat2str(T_max(2,3))}, 'B91:B91')
    xlswrite('values.xlsx', {mat2str(tau_max(2,3))}, 'B92:B92')

    xlswrite('values.xlsx', {mat2str(k_max(3,1))}, 'B93:B93')
    xlswrite('values.xlsx', {mat2str(T_max(3,1))}, 'B94:B94')
    xlswrite('values.xlsx', {mat2str(tau_max(3,1))}, 'B95:B95')

    xlswrite('values.xlsx', {mat2str(k_max(3,2))}, 'B96:B96')
    xlswrite('values.xlsx', {mat2str(T_max(3,2))}, 'B97:B97')
    xlswrite('values.xlsx', {mat2str(tau_max(3,2))}, 'B98:B98')
    
    xlswrite('values.xlsx', {mat2str(k_max(3,3))}, 'B99:B99')
    xlswrite('values.xlsx', {mat2str(T_max(3,3))}, 'B100:B100')
    xlswrite('values.xlsx', {mat2str(tau_max(3,3))}, 'B101:B101')

    xlswrite('values.xlsx', {mat2str(k_min(1,3))}, 'C81:C81')
    xlswrite('values.xlsx', {mat2str(T_min(1,3))}, 'C82:C82')
    xlswrite('values.xlsx', {mat2str(tau_min(1,3))}, 'C83:C83')

    xlswrite('values.xlsx', {mat2str(k_min(2,3))}, 'C90:C90')
    xlswrite('values.xlsx', {mat2str(T_min(2,3))}, 'C91:C91')
    xlswrite('values.xlsx', {mat2str(tau_min(2,3))}, 'C92:C92')

    xlswrite('values.xlsx', {mat2str(k_min(3,1))}, 'C93:C93')
    xlswrite('values.xlsx', {mat2str(T_min(3,1))}, 'C94:C94')
    xlswrite('values.xlsx', {mat2str(tau_min(3,1))}, 'C95:C95')

    xlswrite('values.xlsx', {mat2str(k_min(3,2))}, 'C96:C96')
    xlswrite('values.xlsx', {mat2str(T_min(3,2))}, 'C97:C97')
    xlswrite('values.xlsx', {mat2str(tau_min(3,2))}, 'C98:C98')
    
    xlswrite('values.xlsx', {mat2str(k_min(3,2))}, 'C99:C99')
    xlswrite('values.xlsx', {mat2str(T_min(3,2))}, 'C100:C100')
    xlswrite('values.xlsx', {mat2str(tau_min(3,2))}, 'C101:C101')
end
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