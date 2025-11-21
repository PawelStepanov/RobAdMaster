function [Wkp_rob, Wki_rob, criterion_min] = MaximumSensitivity2x2(crit_quality)

% Считаем методом максимальной чувствительности регулятор в кандидаты на
% робастный 

global ou11
global ou12
global ou21
global ou22
global Tmod
global disturbance

%     ВСПОМОГАТЕЛЬНЫЙ РЕГУЛЯТОР
[Wvsp_Kp_Nom, Wvsp_Ki_Nom] = NomRegulatorVspomogateliy;

%     АВТОНОМНЫЙ РЕГУЛЯТОР
[Wavt_Kp_Nom, Wavt_Ki_Nom] = NomRegulatorAvtonom;

%    СЧИТАЕМ РЕГУЛЯТОР КОМБИНИРОВАННЫМ МЕТОДОМ
[Wkp_nominal, Wki_nominal, criterion_min] = KombRegNominalOU(Wavt_Ki_Nom, Wavt_Kp_Nom, Wvsp_Kp_Nom, Wvsp_Ki_Nom, crit_quality);

% Считаем параметры регулятора
kp11 = Wkp_nominal(1,1);
ki11 = Wki_nominal(1,1);

kp12 = Wkp_nominal(1,2);
ki12 = Wki_nominal(1,2);

kp21 = Wkp_nominal(2,1);
ki21 = Wki_nominal(2,1);

kp22 = Wkp_nominal(2,2);
ki22 = Wki_nominal(2,2);

assignin('base', 'Tmod', Tmod);
assignin('base', 'disturbance1', disturbance(1,1));
assignin('base', 'disturbance2', disturbance(1,2));
assignin('base', 'kp11', kp11);
assignin('base', 'ki11', ki11);
assignin('base', 'kp12', kp12);
assignin('base', 'ki12', ki12);
assignin('base', 'kp21', kp21);
assignin('base', 'ki21', ki21);
assignin('base', 'kp22', kp22);
assignin('base', 'ki22', ki22);

% Получение всех полей структуры zona_params вызовом функции ZonaControlObject
[omega] = ZonaControlObject;
% Присвоение переменных объектов управления (по необходимости)
omega11 = omega{1};
omega12 = omega{2};
omega21 = omega{3};
omega22 = omega{4};

% Вводим параметры ОУ
[k11, k11_2, T1_11, T2_11, T3_11, taumax11, flag11] = Parameters(ou11);
[k12, k12_2, T1_12, T2_12, T3_12, tau12, flag12] = Parameters(ou12);
[k21, k21_2, T1_21, T2_21, T3_21, tau21, flag21] = Parameters(ou21);
[k22, k22_2, T1_22, T2_22, T3_22, taumax22, flag22] = Parameters(ou22);
% Вводим переменные для перебора параметров
[k11_min, k11_max, k11_step] = DefineBounds(k11, omega11{1}(1,1));
[k11_2_min, k11_2_max, k11_2_step] = DefineBounds(k11_2, omega11{1}(1,1));
[T1_11_min, T1_11_max, T1_11_step] = DefineBounds(T1_11, omega11{2}(1,1));
[T2_11_min, T2_11_max, T2_11_step] = DefineBounds(T2_11, omega11{2}(1,1));
[T3_11_min, T3_11_max, T3_11_step] = DefineBounds(T3_11, omega11{2}(1,1));
[tau11_min, tau11_max, tau11_step] = DefineBounds(taumax11, omega11{3});

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
[tau22_min, tau22_max, tau22_step] = DefineBounds(taumax22, omega22{3});

% Номинальные значения параметров
nominal_values  = [k11, k11_2, T1_11, T2_11, T3_11, taumax11, k12, k12_2, T1_12, T2_12, T3_12, tau12 ...,
    k21, k21_2, T1_21, T2_21, T3_21, tau21, k22, k22_2, T1_22, T2_22, T3_22, taumax22];

% Границы параметров: каждая строка содержит нижнюю и верхнюю границу
bounds = [
    k11_min, k11_max;  
    k11_2_min, k11_2_max;  
    T1_11_min, T1_11_max;  
    T2_11_min, T2_11_max;
    T3_11_min, T3_11_max;
    tau11_min, tau11_max;
    k12_min, k12_max;  
    k12_2_min, k12_2_max;  
    T1_12_min, T1_12_max;  
    T2_12_min, T2_12_max;
    T3_12_min, T3_12_max;
    tau12_min, tau12_max;
    k21_min, k21_max;  
    k21_2_min, k21_2_max;  
    T1_21_min, T1_21_max;  
    T2_21_min, T2_21_max;
    T3_21_min, T3_21_max;
    tau21_min, tau21_max;
    k22_min, k22_max;  
    k22_2_min, k22_2_max;  
    T1_22_min, T1_22_max;  
    T2_22_min, T2_22_max;
    T3_22_min, T3_22_max;
    tau22_min, tau22_max
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

        % Вызываем функцию для формирования нумератора и деноминатора
        numerator11 = FormNumerator(current_params(1), current_params(2));
        denominator11 = FormDenominator(current_params(3), current_params(4), current_params(5), flag11);
        
        numerator12 = FormNumerator(current_params(7), current_params(8));
        denominator12 = FormDenominator(current_params(9), current_params(10), current_params(11), flag12);
        
        numerator21 = FormNumerator(current_params(13), current_params(14));
        denominator21 = FormDenominator(current_params(15), current_params(16), current_params(17), flag21);
        
        numerator22 = FormNumerator(current_params(19), current_params(20));
        denominator22 = FormDenominator(current_params(21), current_params(22), current_params(23), flag22);
        
        % Записываем переменные в базовое рабочее пространство
        assignin('base', 'numerator11', numerator11);
        assignin('base', 'denominator11', denominator11);
        assignin('base', 'tau11', current_params(6));
        assignin('base', 'numerator12', numerator12);
        assignin('base', 'denominator12', denominator12);
        assignin('base', 'tau12', current_params(12));
        assignin('base', 'numerator21', numerator21);
        assignin('base', 'denominator21', denominator21);
        assignin('base', 'tau21', current_params(18));
        assignin('base', 'numerator22', numerator22);
        assignin('base', 'denominator22', denominator22);
        assignin('base', 'tau22', current_params(24));

        % Настройка симуляции
        simIn = Simulink.SimulationInput('MIMO_model');
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
object11 = ou11;
numerator = FormNumerator(sensitivity_values(1), sensitivity_values(2));
denominator = FormDenominator(sensitivity_values(3), sensitivity_values(4), sensitivity_values(5), flag11);
tau = [sensitivity_values(6)];
object11{1} = numerator;
object11{2} = denominator;
object11{3} = tau;

object12 = ou12;
numerator = FormNumerator(sensitivity_values(7), sensitivity_values(8));
denominator = FormDenominator(sensitivity_values(9), sensitivity_values(10), sensitivity_values(11), flag12);
tau = [sensitivity_values(12)];
object12{1} = numerator;
object12{2} = denominator;
object12{3} = tau;

object21 = ou21;
numerator = FormNumerator(sensitivity_values(13), sensitivity_values(14));
denominator = FormDenominator(sensitivity_values(15), sensitivity_values(16), sensitivity_values(17), flag21);
tau = [sensitivity_values(18)];
object21{1} = numerator;
object21{2} = denominator;
object21{3} = tau;

object22 = ou22;
numerator = FormNumerator(sensitivity_values(19), sensitivity_values(20));
denominator = FormDenominator(sensitivity_values(21), sensitivity_values(22), sensitivity_values(23), flag22);
tau = [sensitivity_values(24)];
object22{1} = numerator;
object22{2} = denominator;
object22{3} = tau;

% Проверяем нужна ли аппроксимация и если нужна возвращаем параметры
% аппроксимированого ОУ
[K11, Tmin11, taumax11] = ParamApproximNom(object11);
[K12, Tmin12, taumax12] = ParamApproximNom(object12);
[K21, Tmin21, taumax21] = ParamApproximNom(object21);
[K22, Tmin22, taumax22] = ParamApproximNom(object22);

%     ВСПОМОГАТЕЛЬНЫЙ РЕГУЛЯТОР
T = [Tmin11 Tmin12 Tmin21 Tmin22];
tau = [taumax11 taumax12 taumax21 taumax22];
K = [ou11{1}(1,1) ou12{1}(1,1); ou21{1}(1,1) ou22{1}(1,1)];

Wvsp_Kp_rob = [inv(K) * crit_quality * (min(T)/ max(tau))];
Wvsp_Ki_rob = [inv(K) * (crit_quality/max(tau))];

%     АВТОНОМНЫЙ РЕГУЛЯТОР
Wavt_Kp_rob = [((crit_quality*Tmin11)/(K11*taumax11)) 0; 0 ((crit_quality*Tmin22)/(K22*taumax22))];
Wavt_Ki_rob = [(crit_quality/(K11*taumax11)) 0; 0 (crit_quality/(K22*taumax22))];

%    СЧИТАЕМ РЕГУЛЯТОР ПОДОЗРИТЕЛЬНЫЙ НА РОБАСТНОСТЬ
[Wkp_rob, Wki_rob, criterion_min] = KombRegNominalOU(Wavt_Ki_rob, Wavt_Kp_rob, Wvsp_Kp_rob, Wvsp_Ki_rob, crit_quality);

% Получаем кандидата на робастный регулятор и соотвествующие ему значение
% криетрия
Wkp_rob;
Wki_rob;
disp(['Значения критерия: ', num2str(criterion_min)])

% Переносим значение в файл эксель
xlswrite('results.xlsx', {mat2str(Wkp_rob)}, 'B53:B53')
xlswrite('results.xlsx', {mat2str(Wki_rob)}, 'B54:B54')
% Далее необходимо перейти к проверки данного регулятора на всех точках

end