function [Wvsp_Kp_Nom, Wvsp_Ki_Nom] = NomRegulatorVspomogateliy

% Расчет номинального всопомогательного регулятора комбинированным методом
global ou11
global ou12
global ou13
global ou21
global ou22
global ou23
global ou31
global ou32
global ou33
global K
global a
global flag_size

% Рассчитываем минимальные Т и максимальные Тау
% Проверяем нужна ли аппроксимация
[K11, Tmin11, taumax11] = ParamApproximNom(ou11);
[K12, Tmin12, taumax12] = ParamApproximNom(ou12);
[K21, Tmin21, taumax21] = ParamApproximNom(ou21);
[K22, Tmin22, taumax22] = ParamApproximNom(ou22);
if flag_size == 3
    [K13, Tmin13, taumax13] = ParamApproximNom(ou13);
    [K23, Tmin23, taumax23] = ParamApproximNom(ou23);
    [K31, Tmin31, taumax31] = ParamApproximNom(ou31);
    [K32, Tmin32, taumax32] = ParamApproximNom(ou32);
    [K33, Tmin33, taumax33] = ParamApproximNom(ou33);
    
    T = [Tmin11 Tmin12 Tmin13 Tmin21 Tmin22 Tmin23 Tmin31 Tmin32 Tmin33];
    tau = [taumax11 taumax12 taumax13 taumax21 taumax22 taumax23 ...
        taumax31 taumax32 taumax33];
    K = [K11 K12 K13; K21 K22 K23; K31 K32 K33];
    C = inv(K);
    
    % Вспомогательная П-составляющая
    Wvsp_Kp_Nom = C * a * (min(T)/ max(tau))
    
    % Вспомогательная И-составляющая
    Wvsp_Ki_Nom = C * (a/max(tau))
else
    T = [Tmin11 Tmin12 Tmin21 Tmin22];
    tau = [taumax11 taumax12 taumax21 taumax22];
    K = [K11 K12; K21 K22];
    C = inv(K);
    
    % Вспомогательная П-составляющая
    Wvsp_Kp_Nom = C * a * (min(T)/ max(tau))
    
    % Вспомогательная И-составляющая
    Wvsp_Ki_Nom = C * (a/max(tau))
end
end