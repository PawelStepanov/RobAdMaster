function TwoGraph1x1(handles)

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
        % Передаем в рабочее пространство возмущение и время
        assignin('base', 'Tmod', Tmod);
        assignin('base', 'disturbance1', disturbance(1,1));

        % Получаем параметры регулятора
        kp = handles.savedValueKpMS;
        ki = handles.savedValueKiMS;
        
        numerator = handles.savedValueOURobAd{1};
        denominator = handles.savedValueOURobAd{2};
        tau = handles.savedValueOURobAd{3};

        % Записываем переменные в базовое рабочее пространство
        assignin('base', 'numerator', numerator);
        assignin('base', 'denominator', denominator);
        assignin('base', 'tau', tau);
        assignin('base', 'kp', kp);
        assignin('base', 'ki', ki);

        % Запуск Simulink модели
        simIn = Simulink.SimulationInput('SISO_model');
        out = sim(simIn);
        ScopeRobData = get(out, 'ScopeData2'); 

        % Извлечение данных из переменной ScopeRobData (заполненной из Simulink)
        timeData = ScopeRobData.time;
        signalData = ScopeRobData.signals.values;
        
        % Получаем параметры регулятора
        kp = handles.savedValueKpRobAd;
        ki = handles.savedValueKiRobAd;

        % Передаем параметры регулятора в рабочее пространство
        assignin('base', 'kp', kp);
        assignin('base', 'ki', ki);
        
        % Запуск Simulink модели
        simIn = Simulink.SimulationInput('SISO_model');
        out = sim(simIn);
        ScopeRobAdData = get(out, 'ScopeData2'); 

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
        cla(ax2);  % Очистка осей
    end
end