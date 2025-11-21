function [Ki_nom, criterion] = BespoiskRegulatorNominal(crit_quality)

% Расчитываем робастный регулятор при помощи беспоискового метода (по
% формулам)

% Звуковой файл для сигнализирования окончания работы программы
[y, Fs] = audioread('end.MP3');

global Tmod
global ou11
global disturbance

% Передаем в рабочее пространство возмущение
assignin('base', 'disturbance1', disturbance(1,1));
% Передаем в рабочее пространство параметры регулятора
assignin('base', 'kp', 0);

% Параметры объекта управления
[k, k2, T1, T2, T3, tau, flag] = Parameters(ou11);

% Вызываем функцию для формирования нумератора
numerator = FormNumerator(k, k2);

% Проверяем какой у нас ОУ (колебательный или апериодический)
[m,n] = size(ou11{2});
if ou11{2}(1,1) == 1 && n == 3
    b = ou11{2}(1,2);
    c = ou11{2}(1,3);
    denominator = [1 b c];
    Ki_nom = crit_quality * c/(k*(tau + pi / sqrt(c - (b.^2 / 4))));
else
    if n == 3
        T1 = ou11{2}(1,1);
        T2 = ou11{2}(1,1);
        denominator = [T1*T2 T1+T2 1];
    elseif n == 2
        T1 = ou11{2}(1,1);
        T2 = 0;
        denominator = [T1 1];
    end
    
    Ki_nom = crit_quality/(k*(tau + T1 + T2));
end

% Параметры для расчета быстродействия
DT = 0.01;
WOSM = 1;

assignin('base', 'numerator', numerator);
assignin('base', 'denominator', denominator);
assignin('base', 'tau', tau);

% Записываем переменные в базовое рабочее пространство
assignin('base', 'ki', Ki_nom);
    
% Настройка симуляции
simIn = Simulink.SimulationInput('SISO_model');
simIn = simIn.setVariable('numerator', numerator);
simIn = simIn.setVariable('denominator', denominator);
simIn = simIn.setVariable('tau', tau);
    
% Производим симуляцию  
out = sim(simIn);
% Проверяем какой у нас критерий качества
if crit_quality == 0.589
    criterion = get(out, "simout1");
elseif crit_quality == 0.507
    X = get(out, "simout2");
        
    % Расчет длительности переходного процесса
    N = length(X); % Длина массива X
    if abs(X(N)) > 0.05*WOSM
        disp('Переходный процесс не закончен')
        Nreg = N;
    else
        j=0;
        while abs(X(N-j)) <= 0.05*WOSM
            Nreg = N-j;
            j = j+1;
        end
        criterion = Nreg * DT;
    end
else
    criterion = get(out,"simout");
end

% Переносим значение в файл эксель
xlswrite('results.xlsx', Ki_nom, 2, 'B4:B4')
if crit_quality == 0.589
    xlswrite('results.xlsx', criterion, 2, 'B6:B6')
elseif crit_quality == 0.507
    xlswrite('results.xlsx', criterion, 2, 'B7:B7')
else
    xlswrite('results.xlsx', criterion, 2, 'B5:B5')
end
    
% Звуковой сигнал
sound(y, Fs)
end