function [K, T, tau] = Approximation(ou)
% Выполняем аппроксимацию без учета зоны неопределеннсоти

% Параметры объекта управления
[k, k2, T1, T2, T3, tau, flag] = Parameters(ou);

% Вызываем функцию для формирования деноминатора
denominator = FormDenominator(T1, T2, T3, flag);

% Вызываем функцию для формирования нумератора
numerator = FormNumerator(k, k2);

% Время моделирования
Tmod = 500;

% Аппроксимация
Kob = 0;
Tob = 0;
Tauob = 0;

%время моделирования
Tmod = 500;
                
% tf - передаточная функция вида tf(числитель, [знаменатель], 'OutputDelay', запаздывание)
obj = tf(numerator, denominator,'OutputDelay',tau);
Tfinal = Tmod; 
dt = 1; 
time = 0:dt:Tfinal; 
u = ones((Tfinal+1),1); 
u(1,1) = 0; 
y = step(obj,time); 
data = iddata(y,u,dt); 
                
% Type выбирвем P1D (инерционное звено первого порядка с запаздыванием)
typicalobj = idproc('P1D','Td',{'max',500});
approxobj = pem(data,typicalobj,'InitialState','Zero');
                
% Параметры аппроксимированного объекта
Kob = approxobj.Kp.value; 
Tob = approxobj.Tp1.value; 
Tauob = approxobj.Td.value + dt; 
                
% Параметры аппроксимированного объекта
K = Kob;
T = Tob;
tau = Tauob;

end