function TwoGraph(ou11_robad, ou12_robad, ou21_robad, ou22_robad, Wkp_max_road, Wki_max_robad, Wkp_robast, Wki_robast)

    % Создание окна для интерфейса
    fig = uifigure('Name', 'Simulink Scope Plot', 'Position', [100 100 1200 900]);

    % Добавление осей для отображения графика
    ax = axes('Parent', fig, 'Position', [0.1, 0.55, 0.85, 0.35]);
    ax2 = axes('Parent', fig, 'Position', [0.1, 0.1, 0.85, 0.35]);
    
    % Создание кнопки для запуска симуляции
    runButton = uibutton(fig, 'push', ...
        'Position', [50 20 200 40], ...
        'Text', 'Построить график', 'FontSize', 16, ...
        'ButtonPushedFcn', @(btn,event) runSimulation(ax));
    
    % Кнопка для очистки графика
    uibutton(fig, 'push', 'Position', [950 20 200 40], 'Text', 'Очистить', ...
              'FontSize', 16, 'ButtonPushedFcn', @(btn,event) clearPlot);

    function runSimulation(ax)
        
        global Tmod
        global disturbance
        global flag_size
        global ou13_max
        global ou23_max
        global ou31_max
        global ou32_max
        global ou33_max
        % Передаем в рабочее пространство возмущение и время
        assignin('base', 'Tmod', Tmod);
        assignin('base', 'disturbance1', disturbance(1,1));
        assignin('base', 'disturbance2', disturbance(1,2));
        if flag_size == 3
            assignin('base', 'disturbance2', disturbance(1,3));
            
            % Получаем параметры Кр из массива
            kp13 = Wkp_robast(1, 3);
            kp23 = Wkp_robast(2, 3);
            kp31 = Wkp_robast(3, 1);
            kp32 = Wkp_robast(3, 2);
            kp33 = Wkp_robast(3, 3);
            
            % Получаем параметры Кi из массива
            ki13 = Wki_robast(1, 3);
            ki23 = Wki_robast(2, 3);
            ki31 = Wki_robast(3, 1);
            ki32 = Wki_robast(3, 2);
            ki33 = Wki_robast(3, 3);
            
            % Вводим параметры ОУ
            [k13, k13_2, T1_13, T2_13, T3_13, tau13, flag13] = Parameters(ou13_max);
            [k23, k23_2, T1_23, T2_23, T3_23, tau23, flag23] = Parameters(ou23_max);
            [k31, k31_2, T1_31, T2_31, T3_31, tau31, flag31] = Parameters(ou31_max);
            [k32, k32_2, T1_32, T2_32, T3_32, tau32, flag32] = Parameters(ou32_max);
            [k33, k33_2, T1_33, T2_33, T3_33, tau33, flag33] = Parameters(ou33_max);
        
            % Вызываем функцию для формирования нумератора
            numerator13 = FormNumerator(k13, k13_2);
            numerator23 = FormNumerator(k23, k23_2);
            numerator31 = FormNumerator(k31, k31_2);
            numerator32 = FormNumerator(k32, k32_2);
            numerator33 = FormNumerator(k33, k33_2);
    
            % Записываем переменные в базовое рабочее пространство
            assignin('base', 'numerator13', numerator13);
            assignin('base', 'numerator23', numerator23);
            assignin('base', 'numerator31', numerator31);
            assignin('base', 'numerator32', numerator32);
            assignin('base', 'numerator33', numerator33);
    
            % Вызываем функцию для формирования деноминатора
            denominator13 = FormDenominator(T1_13, T2_13, T3_13, flag13);
            denominator23 = FormDenominator(T1_23, T2_23, T3_23, flag23);
            denominator31 = FormDenominator(T1_31, T2_31, T3_31, flag31);
            denominator32 = FormDenominator(T1_32, T2_32, T3_32, flag32);
            denominator33 = FormDenominator(T1_33, T2_33, T3_33, flag33);
    
            % Записываем переменные в базовое рабочее пространство
            assignin('base', 'denominator13', denominator13);
            assignin('base', 'denominator23', denominator23);
            assignin('base', 'denominator31', denominator31);
            assignin('base', 'denominator32', denominator32);
            assignin('base', 'denominator33', denominator33);
            
            % Передаем параметры регулятора в рабочее пространство
            assignin('base', 'kp13', kp13);
            assignin('base', 'ki13', ki13);
            assignin('base', 'kp23', kp23);
            assignin('base', 'ki23', ki23);
            assignin('base', 'kp31', kp31);
            assignin('base', 'ki31', ki31);
            assignin('base', 'kp32', kp32);
            assignin('base', 'ki32', ki32);
            assignin('base', 'kp33', kp33);
            assignin('base', 'ki33', ki33);
        
            % Передаем запаздывание в рабочее пространство
            assignin('base', 'tau13', tau13);
            assignin('base', 'tau23', tau23);
            assignin('base', 'tau31', tau31);
            assignin('base', 'tau32', tau32);
            assignin('base', 'tau33', tau33);
        end
        % Получаем параметры Кр из массива
        kp11 = Wkp_robast(1, 1);
        kp12 = Wkp_robast(1, 2);
        kp21 = Wkp_robast(2, 1);
        kp22 = Wkp_robast(2, 2);

        % Получаем параметры Кi из массива
        ki11 = Wki_robast(1, 1);
        ki12 = Wki_robast(1, 2);
        ki21 = Wki_robast(2, 1);
        ki22 = Wki_robast(2, 2);

        % Вводим параметры ОУ
        [k11, k11_2, T1_11, T2_11, T3_11, tau11, flag11] = Parameters(ou11_robad);
        [k12, k12_2, T1_12, T2_12, T3_12, tau12, flag12] = Parameters(ou12_robad);
        [k21, k21_2, T1_21, T2_21, T3_21, tau21, flag21] = Parameters(ou21_robad);
        [k22, k22_2, T1_22, T2_22, T3_22, tau22, flag22] = Parameters(ou22_robad);
        
        % Вызываем функцию для формирования нумератора
        numerator11 = FormNumerator(k11, k11_2);
        numerator12 = FormNumerator(k12, k12_2);
        numerator21 = FormNumerator(k21, k21_2);
        numerator22 = FormNumerator(k22, k22_2);

        % Записываем переменные в базовое рабочее пространство
        assignin('base', 'numerator11', numerator11);
        assignin('base', 'numerator12', numerator12);
        assignin('base', 'numerator21', numerator21);
        assignin('base', 'numerator22', numerator22);
    
        % Вызываем функцию для формирования деноминатора
        denominator11 = FormDenominator(T1_11, T2_11, T3_11, flag11);
        denominator12 = FormDenominator(T1_12, T2_12, T3_12, flag12);
        denominator21 = FormDenominator(T1_21, T2_21, T3_21, flag21);
        denominator22 = FormDenominator(T1_22, T2_22, T3_22, flag22);
    
        % Записываем переменные в базовое рабочее пространство
        assignin('base', 'denominator11', denominator11);
        assignin('base', 'denominator12', denominator12);
        assignin('base', 'denominator21', denominator21);
        assignin('base', 'denominator22', denominator22);

        % Передаем параметры регулятора в рабочее пространство
        assignin('base', 'kp11', kp11);
        assignin('base', 'ki11', ki11);
        assignin('base', 'kp12', kp12);
        assignin('base', 'ki12', ki12);
        assignin('base', 'kp21', kp21);
        assignin('base', 'ki21', ki21);
        assignin('base', 'kp22', kp22);
        assignin('base', 'ki22', ki22);
       
        % Передаем запаздывание в рабочее пространство
        assignin('base', 'tau11', tau11);
        assignin('base', 'tau12', tau12);
        assignin('base', 'tau21', tau21);
        assignin('base', 'tau22', tau22);
        
        % Передаем нуменатор в рабочее пространство
        assignin('base', 'numerator11', numerator11);
        assignin('base', 'numerator12', numerator12);
        assignin('base', 'numerator21', numerator21);
        assignin('base', 'numerator22', numerator22);
        
        % Передаем деноминатор в рабочее пространство
        assignin('base', 'denominator11', denominator11);
        assignin('base', 'denominator12', denominator12);
        assignin('base', 'denominator21', denominator21);
        assignin('base', 'denominator22', denominator22);
        
        % Запуск Simulink модели
        if flag_size == 3
            simIn = Simulink.SimulationInput('MIMO3x3_model');
        else
            simIn = Simulink.SimulationInput('MIMO_model');
        end
        out = sim(simIn);
        ScopeRobData = get(out, 'ScopeData1'); 

        % Извлечение данных из переменной ScopeRobData (заполненной из Simulink)
        timeData = ScopeRobData.time;
        signalData = ScopeRobData.signals.values;
        
        if flag_size == 3
            % Получаем параметры Кр из массива
            kp13 = Wkp_max_road(1, 3);
            kp23 = Wkp_max_road(2, 3);
            kp31 = Wkp_max_road(3, 1);
            kp32 = Wkp_max_road(3, 2);
            kp33 = Wkp_max_road(3, 3);
            
            % Получаем параметры Кi из массива
            ki13 = Wki_max_robad(1, 3);
            ki23 = Wki_max_robad(2, 3);
            ki31 = Wki_max_robad(3, 1);
            ki32 = Wki_max_robad(3, 2);
            ki33 = Wki_max_robad(3, 3);
            
            % Передаем параметры регулятора в рабочее пространство
            assignin('base', 'kp13', kp13);
            assignin('base', 'ki13', ki13);
            assignin('base', 'kp23', kp23);
            assignin('base', 'ki23', ki23);
            assignin('base', 'kp31', kp31);
            assignin('base', 'ki31', ki31);
            assignin('base', 'kp32', kp32);
            assignin('base', 'ki32', ki32);
            assignin('base', 'kp33', kp33);
            assignin('base', 'ki33', ki33);
        end
        % Получаем параметры Кр из массива
        kp11 = Wkp_max_road(1, 1);
        kp12 = Wkp_max_road(1, 2);
        kp21 = Wkp_max_road(2, 1);
        kp22 = Wkp_max_road(2, 2);
        
        % Получаем параметры Кi из массива
        ki11 = Wki_max_robad(1, 1);
        ki12 = Wki_max_robad(1, 2);
        ki21 = Wki_max_robad(2, 1);
        ki22 = Wki_max_robad(2, 2);

        % Передаем параметры регулятора в рабочее пространство
        assignin('base', 'kp11', kp11);
        assignin('base', 'ki11', ki11);
        assignin('base', 'kp12', kp12);
        assignin('base', 'ki12', ki12);
        assignin('base', 'kp21', kp21);
        assignin('base', 'ki21', ki21);
        assignin('base', 'kp22', kp22);
        assignin('base', 'ki22', ki22);
        
        % Запуск Simulink модели
        if flag_size == 3
            simIn = Simulink.SimulationInput('MIMO3x3_model');
        else
            simIn = Simulink.SimulationInput('MIMO_model');
        end
        out = sim(simIn);
        ScopeRobAdData = get(out, 'ScopeData1'); 

        % Извлечение данных из переменной ScopeRobData (заполненной из Simulink)
        timeAdData = ScopeRobAdData.time;
        signalAdData = ScopeRobAdData.signals.values;

        % Построение графика в элементе axes
        plot(ax, timeData, signalData, 'r', 'LineWidth', 1.2);
        title(ax, 'Робастный регулятор');
        xlabel(ax, 'Time (s)');
        ylabel(ax, 'Signal');
        grid(ax, 'on');
        
        % Построение графика в элементе axes
        plot(ax2, timeAdData, signalAdData, 'r', 'LineWidth', 1.2);
        title(ax2, 'Робастно-адаптивный регулятор');
        xlabel(ax2, 'Time (s)');
        ylabel(ax2, 'Signal');
        grid(ax2, 'on');
    end

    % Функция для очистки графика
    function clearPlot(~, ~)
        cla(ax);  % Очистка осей
    end
end