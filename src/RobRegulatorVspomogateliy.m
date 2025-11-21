function [Wvsp_Kp_Rob, Wvsp_Ki_Rob] = RobRegulatorVspomogateliy

% Расчет робастного всопомогательного регулятора комбинированным методом
global ou11
global ou12
global ou13
global ou21
global ou22
global ou23
global ou31
global ou32
global ou33
global omega11
global omega12
global omega13
global omega21
global omega22
global omega23
global omega31
global omega32
global omega33
global K
global a
global flag_size

% Получение всех полей структуры zona_params вызовом функции ZonaControlObject
[omega] = ZonaControlObject;
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

% Рассчитываем минимальные Т и максимальные Тау
% Проверяем нужна ли аппроксимация
[K11, Tmin11, taumax11] = ParamApproximRob(ou11, omega11);
[K12, Tmin12, taumax12] = ParamApproximRob(ou12, omega12);
[K21, Tmin21, taumax21] = ParamApproximRob(ou21, omega21);
[K22, Tmin22, taumax22] = ParamApproximRob(ou22, omega22);
if flag_size == 3
    [K13, Tmin13, taumax13] = ParamApproximRob(ou13, omega13);
    [K23, Tmin23, taumax23] = ParamApproximRob(ou23, omega23);
    [K31, Tmin31, taumax31] = ParamApproximRob(ou31, omega31);
    [K32, Tmin32, taumax32] = ParamApproximRob(ou32, omega32);
    [K33, Tmin33, taumax33] = ParamApproximRob(ou33, omega33);
    
    T = [Tmin11 Tmin12 Tmin13 Tmin21 Tmin22 Tmin23 Tmin31 Tmin32 Tmin33];
    tau = [taumax11 taumax12 taumax13 taumax21 taumax22 taumax23 ...
        taumax31 taumax32 taumax33];
    K = [K11 K12 K13; K21 K22 K23; K31 K32 K33];
    C = inv(K);
    
    % Вспомогательная П-составляющая
    Wvsp_Kp_Rob = C * a * (min(T)/ max(tau));

    % Вспомогательная И-составляющая
    Wvsp_Ki_Rob = C * (a/max(tau));
else
    T = [Tmin11 Tmin12 Tmin21 Tmin22];
    tau = [taumax11 taumax12 taumax21 taumax22];
    K = [K11 K12; K21 K22];
    C = inv(K);
    
    % Вспомогательная П-составляющая
    Wvsp_Kp_Rob = C * a * (min(T)/ max(tau));

    % Вспомогательная И-составляющая
    Wvsp_Ki_Rob = C * (a/max(tau));
end
end