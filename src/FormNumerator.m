function numerator = FormNumerator(k, k_2)
% Функция для формирования числителя
    if isnan(k_2)
        numerator = [k];
    else
        numerator = [k*k_2 k];
    end
end