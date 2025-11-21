function [Wkp_nominal, Wki_nominal, criterion_min] = KombRegNominalOU(Wavt_Ki_Nom, Wavt_Kp_Nom, Wvsp_Kp_Nom, Wvsp_Ki_Nom, crit_quality)

% Считаем комбинированый номинальный многомерный регулятор

% Звуковой файл для сигнализирования окончания работы программы
[y, Fs] = audioread('end.MP3');

global disturbance 
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
global flag_size

% Передаем в рабочее пространство возмущение
assignin('base', 'disturbance1', disturbance(1,1));
assignin('base', 'disturbance2', disturbance(1,2));
if flag_size == 3
    assignin('base', 'disturbance2', disturbance(1,3));
    
    [k, k2, T1, T2, T3, tau13, flag] = Parameters(ou13);
    numerator13 = FormNumerator(k, k2);
    denominator13 = FormDenominator(T1, T2, T3, flag);
    assignin('base', 'numerator13', numerator13);
    assignin('base', 'denominator13', denominator13);
    assignin('base', 'tau13', tau13);

    [k, k2, T1, T2, T3, tau23, flag] = Parameters(ou23);
    numerator23 = FormNumerator(k, k2);
    denominator23 = FormDenominator(T1, T2, T3, flag);
    assignin('base', 'numerator23', numerator23);
    assignin('base', 'denominator23', denominator23);
    assignin('base', 'tau23', tau23);

    [k, k2, T1, T2, T3, tau31, flag] = Parameters(ou31);
    numerator31 = FormNumerator(k, k2);
    denominator31 = FormDenominator(T1, T2, T3, flag);
    assignin('base', 'numerator31', numerator31);
    assignin('base', 'denominator31', denominator31);
    assignin('base', 'tau31', tau31);
    
    [k, k2, T1, T2, T3, tau32, flag] = Parameters(ou32);
    numerator32 = FormNumerator(k, k2);
    denominator32 = FormDenominator(T1, T2, T3, flag);
    assignin('base', 'numerator32', numerator32);
    assignin('base', 'denominator32', denominator32);
    assignin('base', 'tau32', tau32);
    
    [k, k2, T1, T2, T3, tau33, flag] = Parameters(ou33);
    numerator33 = FormNumerator(k, k2);
    denominator33 = FormDenominator(T1, T2, T3, flag);
    assignin('base', 'numerator33', numerator33);
    assignin('base', 'denominator33', denominator33);
    assignin('base', 'tau33', tau33);
else
    % Параметры объекта 1 1
    [k, k2, T1, T2, T3, tau11, flag] = Parameters(ou11);
    numerator11 = FormNumerator(k, k2);
    denominator11 = FormDenominator(T1, T2, T3, flag);
    assignin('base', 'numerator11', numerator11);
    assignin('base', 'denominator11', denominator11);
    assignin('base', 'tau11', tau11);

    % Параметры объекта 1 2
    [k, k2, T1, T2, T3, tau12, flag] = Parameters(ou12);
    numerator12 = FormNumerator(k, k2);
    denominator12 = FormDenominator(T1, T2, T3, flag);
    assignin('base', 'numerator12', numerator12);
    assignin('base', 'denominator12', denominator12);
    assignin('base', 'tau12', tau12);

    % Параметры объекта 2 1 
    [k, k2, T1, T2, T3, tau21, flag] = Parameters(ou21);
    numerator21 = FormNumerator(k, k2);
    denominator21 = FormDenominator(T1, T2, T3, flag);
    assignin('base', 'numerator21', numerator21);
    assignin('base', 'denominator21', denominator21);
    assignin('base', 'tau21', tau21);

    % Параметры объекта 2 2 
    [k, k2, T1, T2, T3, tau22, flag] = Parameters(ou22);
    numerator22 = FormNumerator(k, k2);
    denominator22 = FormDenominator(T1, T2, T3, flag);
    assignin('base', 'numerator22', numerator22);
    assignin('base', 'denominator22', denominator22);
    assignin('base', 'tau22', tau22);
end

ro = 0;
ro_min = 0;
criterion_min = 500000;

% Параметры для расчета быстродействия
DT = 0.01;
WOSM = 1;

% Перебираем ro до 1
for ro = ro: step_ro: 1

    % Считаем параметры регулятора 
    kp11 = (ro * (Wavt_Kp_Nom(1,1))) + ((1 - ro) * (Wvsp_Kp_Nom(1,1)));
    ki11 = (ro *  (Wavt_Ki_Nom(1,1))) + ((1 - ro) * (Wvsp_Kp_Nom(1,1)));
    assignin('base', 'kp11', kp11);
    assignin('base', 'ki11', ki11);

    kp12 = (1 - ro) * (Wvsp_Kp_Nom(1,2));
    ki12 = (1 - ro) * (Wvsp_Ki_Nom(1,2));
    assignin('base', 'kp12', kp12);
    assignin('base', 'ki12', ki12);
    
    kp21 = (1 - ro) * (Wvsp_Kp_Nom(2,1));
    ki21 = (1 - ro) * (Wvsp_Ki_Nom(2,1));
    assignin('base', 'kp21', kp21);
    assignin('base', 'ki21', ki21);
    
    kp22 = ro * (Wavt_Kp_Nom(2,2)) + ((1 - ro) * (Wvsp_Kp_Nom(2,2)));
    ki22 = ro * (Wavt_Ki_Nom(2,2)) + ((1 - ro) * (Wvsp_Ki_Nom(2,2)));
    assignin('base', 'kp22', kp22);
    assignin('base', 'ki22', ki22);
    
    if flag_size == 3
        kp13 = (ro * (Wavt_Kp_Nom(1,3))) + ((1 - ro) * (Wvsp_Kp_Nom(1,3)));
        ki13 = (ro *  (Wavt_Ki_Nom(1,3))) + ((1 - ro) * (Wvsp_Kp_Nom(1,3)));
        assignin('base', 'kp13', kp13);
        assignin('base', 'ki13', ki13);
        
        kp23 = (ro * (Wavt_Kp_Nom(2,3))) + ((1 - ro) * (Wvsp_Kp_Nom(2,3)));
        ki23 = (ro *  (Wavt_Ki_Nom(2,3))) + ((1 - ro) * (Wvsp_Kp_Nom(2,3)));
        assignin('base', 'kp21', kp23);
        assignin('base', 'ki21', ki23);
        
        kp31 = (ro * (Wavt_Kp_Nom(3,1))) + ((1 - ro) * (Wvsp_Kp_Nom(3,1)));
        ki31 = (ro *  (Wavt_Ki_Nom(3,1))) + ((1 - ro) * (Wvsp_Kp_Nom(3,1)));
        assignin('base', 'kp31', kp31);
        assignin('base', 'ki31', ki31);
    
        kp32 = (ro * (Wavt_Kp_Nom(3,2))) + ((1 - ro) * (Wvsp_Kp_Nom(3,2)));
        ki32 = (ro *  (Wavt_Ki_Nom(3,2))) + ((1 - ro) * (Wvsp_Kp_Nom(3,2)));
        assignin('base', 'kp32', kp32);
        assignin('base', 'ki32', ki32);
    
        kp33 = (ro * (Wavt_Kp_Nom(3,3))) + ((1 - ro) * (Wvsp_Kp_Nom(3,3)));
        ki33 = (ro *  (Wavt_Ki_Nom(3,3))) + ((1 - ro) * (Wvsp_Kp_Nom(3,3)));
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
                                                
    % Находим минимальное значение критерия качества управления
    if criterion < criterion_min
        criterion_min = criterion;
        ro_min = ro;
    end
end
 
if crit_quality == 0.589
    disp(['Минимальное ИМК :', num2str(criterion_min)])
    xlswrite('results.xlsx', criterion_min, 'E6:E6')
elseif crit_quality == 0.507
    disp(['Минимальное быстродействие :', num2str(criterion_min)])
    xlswrite('results.xlsx', criterion_min, 'F6:F6')
else
    disp(['Минимальное ИКК :', num2str(criterion_min)])
    xlswrite('results.xlsx', criterion_min, 'D6:D6')
end
disp(['ро: ', num2str(ro_min)])
xlswrite('results.xlsx', ro_min, 'H6:H6')
disp('Параметры регулятора при минимальном ро:')

kp11 = (ro_min * (Wavt_Kp_Nom(1,1))) + ((1 - ro_min) * (Wvsp_Kp_Nom(1,1)));
ki11 = (ro_min *  (Wavt_Ki_Nom(1,1))) + ((1 - ro_min) * (Wvsp_Kp_Nom(1,1)));

kp12 = (1 - ro_min) * (Wvsp_Kp_Nom(1,2));
ki12 = (1 - ro_min) * (Wvsp_Ki_Nom(1,2));

kp21 = (1 - ro_min) * (Wvsp_Kp_Nom(2,1));
ki21 = (1 - ro_min) * (Wvsp_Ki_Nom(2,1));

kp22 = ro_min * (Wavt_Kp_Nom(2,2)) + ((1 - ro_min) * (Wvsp_Kp_Nom(2,2)));
ki22 = ro_min * (Wavt_Ki_Nom(2,2)) + ((1 - ro_min) * (Wvsp_Ki_Nom(2,2)));

if flag_size == 3
    kp13 = (ro_min * (Wavt_Kp_Nom(1,3))) + ((1 - ro_min) * (Wvsp_Kp_Nom(1,3)));
    ki13 = (ro_min *  (Wavt_Ki_Nom(1,3))) + ((1 - ro_min) * (Wvsp_Kp_Nom(1,3)));
    
    kp23 = (ro_min * (Wavt_Kp_Nom(2,3))) + ((1 - ro_min) * (Wvsp_Kp_Nom(2,3)));
    ki23 = (ro_min *  (Wavt_Ki_Nom(2,3))) + ((1 - ro_min) * (Wvsp_Kp_Nom(2,3)));
    
    kp31 = (ro_min * (Wavt_Kp_Nom(3,1))) + ((1 - ro_min) * (Wvsp_Kp_Nom(3,1)));
    ki31 = (ro_min *  (Wavt_Ki_Nom(3,1))) + ((1 - ro_min) * (Wvsp_Kp_Nom(3,1)));
    
    kp32 = (ro_min * (Wavt_Kp_Nom(3,2))) + ((1 - ro_min) * (Wvsp_Kp_Nom(3,2)));
    ki32 = (ro_min *  (Wavt_Ki_Nom(3,2))) + ((1 - ro_min) * (Wvsp_Kp_Nom(3,2)));
    
    kp33 = (ro_min * (Wavt_Kp_Nom(3,3))) + ((1 - ro_min) * (Wvsp_Kp_Nom(3,3)));
    ki33 = (ro_min *  (Wavt_Ki_Nom(3,3))) + ((1 - ro_min) * (Wvsp_Kp_Nom(3,3)));
    
    Wkp_nominal = [kp11 kp12 kp13; kp21 kp22 kp23; kp31 kp32 kp33]
    Wki_nominal = [ki11 ki12 ki13; ki21 ki22 ki23; ki31 ki32 ki33]
else
    Wkp_nominal = [kp11 kp12; kp21 kp22]
    Wki_nominal = [ki11 ki12; ki21 ki22]
end

% Переносим значение в файл эксель
xlswrite('results.xlsx', {mat2str(Wkp_nominal)}, 'B5:B5')
xlswrite('results.xlsx', {mat2str(Wki_nominal)}, 'B6:B6')

% Звуковой сигнал
sound(y, Fs)
end