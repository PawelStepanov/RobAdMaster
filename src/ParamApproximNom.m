function [k, T, tau]= ParamApproximNom(object)

% Проверяем нужна ли аппроксимация для номинального регулятора

[m,n] = size(object{2});
[mk,nk] = size(object{1});
if nk > 1 || n == 3 || n == 4
    [k, T, tau] = Approximation(object);
else
    k = object{1};
    T = object{2}(1,1);
    tau = object{3};
end  
end