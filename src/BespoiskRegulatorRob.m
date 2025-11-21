function [Ki_rob] = BespoiskRegulatorRob(crit_quality)

% Расчитываем робастный регулятор при помощи беспоискового метода (по
% формулам)

% Звуковой файл для сигнализирования окончания работы программы
[y, Fs] = audioread('end.MP3');

global ou11

% Получение всех полей структуры zona_params вызовом функции ZonaControlObject
[omega] = ZonaControlObject;

% Присвоение переменных объектов управления (по необходимости)
omega11 = omega{1};

k_v = (1 + omega11{1}(1,1)) * ou11{1}(1,1);
tau_v = (1 + omega11{3}) * ou11{3};
% Проверяем какой у нас ОУ (колебательный или апериодический)
[m,n] = size(ou11{2});
if ou11{2}(1,1) == 1 && n == 3
    b_v = (1 + omega11{2}(1,1)) * ou11{2}(1,2);
    c_n = (1 - omega11{2}(1,2)) * ou11{2}(1,3);
    
    Ki_rob = crit_quality * c_n/(k_v*(tau_v + pi / sqrt(c_n - (b_v.^2 / 4))));
else
    if n == 3
        T1_v = (1 + omega11{2}(1,1)) * ou11{2}(1,1);
        T2_v = (1 + omega11{2}(1,2)) * ou11{2}(1,1);
    elseif n == 2
        T1_v = (1 + omega11{2}(1,1)) * ou11{2}(1,1);
        T2_v = 0;
    end
    
    Ki_rob = crit_quality/(k_v*(tau_v + T1_v + T2_v));
end

% Переносим значение в файл эксель
xlswrite('results.xlsx', Ki_rob, 2, 'B26:B26')

% Звуковой сигнал
sound(y, Fs)
end