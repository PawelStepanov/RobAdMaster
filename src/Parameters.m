function [k, k2, T1, T2, T3, tau, flag] = Parameters(object)

% Функция для формирования параметров
    
    tau = object{3};
    [m,n] = size(object{1});
    if n == 2
        k = object{1}(1,1);
        k2 = object{1}(1,2);
    else
        k = object{1};
        k2 = nan;
    end
    % Проверяем колебательнй или апериодический ОУ
    [m,n] = size(object{2});
    if object{2}(1,1) == 1 && n == 3
        T1 = object{2}(1,2); % Параметр b
        T2 = object{2}(1,3); % Параметр c
        T3 = nan;
        flag = 1; % Отмечаем, что у нас колебательный ОУ
    else
        if n == 3
            T1 = object{2}(1,1);
            T2 = object{2}(1,2);
            T3 = nan;
            flag = 0;
        elseif n == 4
            T1 = object{2}(1,1);
            T2 = object{2}(1,2);
            T3 = object{2}(1,3);
            flag = 0;
        else
            T1 = object{2}(1,1);
            T2 = nan;
            T3 = nan;
            flag = 0;
        end
    end
end