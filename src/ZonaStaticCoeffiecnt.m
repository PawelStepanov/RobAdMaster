function [znak] = ZonaStaticCoeffiecnt

global K

omega_start = 0;
omega_step = 0.1;
omega_end = 1;

znak_plus = 0;
znak_minus = 0;

% Вычисляем максимальный и минимальный детерминант матрицы
% статических коэффициентов

for omega_start = omega_start: omega_step: omega_end
    
det_k1 = -abs(K(1,1)) * abs(K(2,2)) * (1-omega_start).^2 + abs(K(2,1)) * abs(K(1,2)) * (1+omega_start).^2;
det_k2 = -abs(K(1,1)) * abs(K(2,2)) * (1+omega_start).^2 + abs(K(2,1)) * abs(K(1,2)) * (1-omega_start).^2;
det_k3 = -abs(K(1,1)) * abs(K(2,2)) * (1-omega_start).^2 + abs(K(2,1)) * abs(K(1,2)) * (1-omega_start).^2;
det_k4 = -abs(K(1,1)) * abs(K(2,2)) * (1+omega_start).^2 + abs(K(2,1)) * abs(K(1,2)) * (1+omega_start).^2;
    
det = [det_k1 det_k2 det_k3 det_k4];

det_k_max = max(det);
vpa(det_k_max, 4);

det_k_min = min(det);
vpa(det_k_min, 4);
    
if det_k_max > 0 && det_k_min > 0
    znak_plus = 1;
else
    znak_minus = -1;
end
    
if det_k_max > 0 && det_k_min < 0 || det_k_max < 0 && det_k_min > 0
    if znak_plus == 1 && det_k_min < 0
        znak = 'Знаки поменялись у detmin'
        break
    elseif znak_plus == 1 && det_k_max < 0
        znak = 'Знаки поменялись у detmax'
        break
    end
    if znak_minus == -1 && det_k_min > 0
        znak = 'Знаки поменялись у detmin'
        break
    elseif znak_minus == -1 && det_k_max > 0
        znak = 'Знаки поменялись у detmax'
        break
    end
end
end
end