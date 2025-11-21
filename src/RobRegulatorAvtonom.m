function [Wavt_Kp_Rob, Wavt_Ki_Rob] = RobRegulatorAvtonom

% Расчет робастного автономного регулятора комбинированным методом

global a
global omega11
global omega22
global omega33
global ou11
global ou22
global ou33
global flag_size

% Получение всех полей структуры zona_params вызовом функции ZonaControlObject
[omega] = ZonaControlObject;
if flag_size == 3
    omega11 = omega{1};
    omega22 = omega{5};
    omega33 = omega{9};
    K33 = (1 + omega33{1}(1,1)) * ou33{1}(1,1);
else
    omega11 = omega{1};
    omega22 = omega{4};
end

% Расчитываем параметры 11 и 22
K11 = (1 + omega11{1}(1,1)) * ou11{1}(1,1);
K22 = (1 + omega22{1}(1,1)) * ou22{1}(1,1);

% Проверяем нужна ли аппроксимация
[k, T11, tau11] = ParamApproximRob(ou11, omega11);
[k, T22, tau22] = ParamApproximRob(ou22, omega22);
if flag_size == 3
    [k, T33, tau33] = ParamApproximRob(ou33, omega33);
    % Автономная П-составляющая
    Wavt_Kp_Rob = [((a*T11)/(K11*tau11)) 0 0; 0 ((a*T22)/(K22*tau22)) 0; ...
        0 0 ((a*T33)/(K33*tau33))];

    % Автономная И-составляющая
    Wavt_Ki_Rob = [(a/(K11*tau11)) 0 0; 0 (a/(K22*tau22)) 0; ...
        0 0 (a/(K33*tau33))];
else
    % Автономная П-составляющая
    Wavt_Kp_Rob = [((a*T11)/(K11*tau11)) 0; 0 ((a*T22)/(K22*tau22))];

    % Автономная И-составляющая
    Wavt_Ki_Rob = [(a/(K11*tau11)) 0; 0 (a/(K22*tau22))];
end
end