function [Wavt_Kp_Nom, Wavt_Ki_Nom] = NomRegulatorAvtonom

% Расчет номинального автономного регулятора комбинированным методом
global a
global ou11
global ou22
global ou33
global flag_size

% Расчитываем параметры 11 и 22
% Проверяем нужна ли аппроксимация
[K11, T11, tau11] = ParamApproximNom(ou11);
[K22, T22, tau22] = ParamApproximNom(ou22);
if flag_size == 3
    [K33, T33, tau33] = ParamApproximNom(ou33);
    % Автономная П-составляющая
    Wavt_Kp_Nom = [((a*T11)/(K11*tau11)) 0 0; 0 ((a*T22)/(K22*tau22)) 0; ...
        0 0 ((a*T33)/(K33*tau33))]
    % Автономная И-составляющая
    Wavt_Ki_Nom = [(a/(K11*tau11)) 0 0; 0 (a/(K22*tau22)) 0; ...
        0 0 (a/(K33*tau33))]
else
    % Автономная П-составляющая
    Wavt_Kp_Nom = [((a*T11)/(K11*tau11)) 0; 0 ((a*T22)/(K22*tau22))]

    % Автономная И-составляющая
    Wavt_Ki_Nom = [(a/(K11*tau11)) 0; 0 (a/(K22*tau22))]
end

end