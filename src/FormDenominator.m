function denominator = FormDenominator(T1, T2, T3, flag)
% Функция для формирования знаменателя
    if flag == 1
        denominator = [1 T1 T2];
    else
        if isnan(T2)
            denominator = [T1 1];
        elseif isnan(T3)
            denominator = [T1*T2 T1+T2 1];
        else
            denominator = [T1*T2*T3 T1*T2+T1*T3+T2*T3 T1+T2+T3 1];
        end
    end
end