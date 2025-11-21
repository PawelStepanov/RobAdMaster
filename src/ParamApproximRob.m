function [k, T, tau] = ParamApproximRob(object, omega)

% Рассчитываем минимальные Т и максимальные Тау
% Проверяем нужна ли аппроксимация для робастного регулятора

[m,n] = size(object{2});
[mk,nk] = size(object{1});

if nk > 1 || n == 3 || n == 4
    [T, tau] = ApproximationUncertainty(ou, omega);
else
    T = (1 - omega{2}(1,1)) * object{2}(1,1);
    tau = (1 + omega{3}) * object{3};
    k = omega{1}(1,1);
end
end