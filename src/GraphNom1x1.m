function GraphNom1x1(handles)

    % Создание окна для интерфейса
    fig = uifigure('Name', 'Simulink Scope Plot', 'Position', [100 100 1200 600]);

    % Добавление осей для отображения графика
    ax = axes('Parent', fig, 'Position', [0.1, 0.4, 0.85, 0.55]);
    
    % Создание кнопки для запуска симуляции
    runButton = uibutton(fig, 'push', ...
        'Position', [100 50 220 60], ...
        'Text', 'Построить график беспоиск', 'FontSize', 16, ...
        'ButtonPushedFcn', @(btn,event) runSimulation(ax));

    % Создание кнопки для запуска симуляции
    runButton1 = uibutton(fig, 'push', ...
        'Position', [350 50 220 60], ...
        'Text', 'Построить график поиск', 'FontSize', 16, ...
        'ButtonPushedFcn', @(btn,event) runSimulation1(ax));
    
    % Кнопка для очистки графика
    uibutton(fig, 'push', 'Position', [900 50 200 60], 'Text', 'Очистить', ...
              'FontSize', 16, 'ButtonPushedFcn', @(btn,event) clearPlot);

    function runSimulation(ax)
        
        global ou11
        global Tmod
        global disturbance
        
        if isfield(handles, 'savedValueKibpnom')
            disp('...')
        else
            h = msgbox('Расчет беспоисковым методом отсутсвует', 'Расчет', 'modal');
        end
        
        % Передаем в рабочее пространство возмущение и время 
        assignin('base', 'disturbance1', disturbance(1,1));
        assignin('base', 'kp', 0);
        assignin('base', 'ki', handles.savedValueKibpnom); 
        
        numerator = ou11{1};
        denominator = ou11{2};
        tau = ou11{3};
        
        assignin('base', 'numerator', numerator);
        assignin('base', 'denominator', denominator);
        assignin('base', 'tau', tau);
        
        % Запуск Simulink модели
        simIn = Simulink.SimulationInput('SISO_model');
        out = sim(simIn);
        ScopeNomData = get(out, 'ScopeData2'); 

        % Извлечение данных из переменной ScopeRobData (заполненной из Simulink)
        timeData = ScopeNomData.time;
        signalData = ScopeNomData.signals.values;

        % Построение графика в элементе axes
        plot(ax, timeData, signalData, 'r', 'LineWidth', 1.2);
        title(ax, 'Simulation Results');
        xlabel(ax, 'Time (s)');
        ylabel(ax, 'Signal');
        grid(ax, 'on');
    end

    function runSimulation1(ax)
        
        global ou11
        global Tmod
        global disturbance
        
        if isfield(handles, 'savedValueKiPnom')
            disp('...')
        else
            h = msgbox('Расчет поисковым методом отсутсвует', 'Расчет', 'modal');
        end
        % Передаем в рабочее пространство возмущение и время 
        assignin('base', 'disturbance1', disturbance(1,1));
        assignin('base', 'kp', 0);
        assignin('base', 'ki', handles.savedValueKiPnom);

        numerator = ou11{1};
        denominator = ou11{2};
        tau = ou11{3};
        
        assignin('base', 'numerator', numerator);
        assignin('base', 'denominator', denominator);
        assignin('base', 'tau', tau);
        
        % Запуск Simulink модели
        simIn = Simulink.SimulationInput('SISO_model');
        out = sim(simIn);
        ScopeNomData = get(out, 'ScopeData2'); 

        % Извлечение данных из переменной ScopeRobData (заполненной из Simulink)
        timeData = ScopeNomData.time;
        signalData = ScopeNomData.signals.values;

        % Построение графика в элементе axes
        plot(ax, timeData, signalData, 'r', 'LineWidth', 1.2);
        title(ax, 'Simulation Results');
        xlabel(ax, 'Time (s)');
        ylabel(ax, 'Signal');
        grid(ax, 'on');
    end

    % Функция для очистки графика
    function clearPlot(~, ~)
        cla(ax);  % Очистка осей
    end
end