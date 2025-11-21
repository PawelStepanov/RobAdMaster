function Graph1x1(handles)

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
    
    % Создание кнопки для запуска симуляции
    runButton2 = uibutton(fig, 'push', ...
        'Position', [600 50 220 60], ...
        'Text', 'Построить график МЧ', 'FontSize', 16, ...
        'ButtonPushedFcn', @(btn,event) runSimulation2(ax));
    
    % Кнопка для очистки графика
    uibutton(fig, 'push', 'Position', [900 50 200 60], 'Text', 'Очистить', ...
              'FontSize', 16, 'ButtonPushedFcn', @(btn,event) clearPlot);

    function runSimulation(ax)
        
        global Tmod
        global disturbance
        
        if isfield(handles, 'savedValueKibp') || isfield(handles, 'savedValueOuBP')
            disp('...')
        else
            h = msgbox('Расчет беспоисковым методом отсутсвует или проводилась проверка на всех точках', 'Расчет', 'modal');
        end
        % Передаем в рабочее пространство возмущение и время 
        assignin('base', 'disturbance1', disturbance(1,1));
        assignin('base', 'kp', 0);
        assignin('base', 'ki', handles.savedValueKibp);
        
        numerator = handles.savedValueOuBP{1};
        denominator = handles.savedValueOuBP{2};
        tau = handles.savedValueOuBP{3};
        
        assignin('base', 'numerator', numerator);
        assignin('base', 'denominator', denominator);
        assignin('base', 'tau', tau);
        
        % Запуск Simulink модели
        simIn = Simulink.SimulationInput('SISO_model');
        out = sim(simIn);
        ScopeRobData = get(out, 'ScopeData2'); 

        % Извлечение данных из переменной ScopeRobData (заполненной из Simulink)
        timeData = ScopeRobData.time;
        signalData = ScopeRobData.signals.values;

        % Построение графика в элементе axes
        plot(ax, timeData, signalData, 'r', 'LineWidth', 1.2);
        title(ax, 'Simulation Results');
        xlabel(ax, 'Time (s)');
        ylabel(ax, 'Signal');
        grid(ax, 'on');
    end

    function runSimulation1(ax)
        
        global Tmod
        global disturbance
        
        if isfield(handles, 'savedValueKiP')
            disp('...')
        else
            h = msgbox('Расчет поисковым методом отсутсвует', 'Расчет', 'modal');
        end
        % Передаем в рабочее пространство возмущение и время 
        assignin('base', 'disturbance1', disturbance(1,1));
        assignin('base', 'kp', 0);
        assignin('base', 'ki', handles.savedValueKiP);

        numerator = handles.savedValueOuPp{1};
        denominator = handles.savedValueOuPp{2};
        tau = handles.savedValueOuP{3};
        
        assignin('base', 'numerator', numerator);
        assignin('base', 'denominator', denominator);
        assignin('base', 'tau', tau);
        
        % Запуск Simulink модели
        simIn = Simulink.SimulationInput('SISO_model');
        out = sim(simIn);
        ScopeRobData = get(out, 'ScopeData2'); 

        % Извлечение данных из переменной ScopeRobData (заполненной из Simulink)
        timeData = ScopeRobData.time;
        signalData = ScopeRobData.signals.values;

        % Построение графика в элементе axes
        plot(ax, timeData, signalData, 'r', 'LineWidth', 1.2);
        title(ax, 'Simulation Results');
        xlabel(ax, 'Time (s)');
        ylabel(ax, 'Signal');
        grid(ax, 'on');
    end

    function runSimulation2(ax)
        
        global Tmod
        global disturbance
        
        if isfield(handles, 'savedValueKpMS')
            disp('...')
        else
            h = msgbox('Расчет поисковым методом отсутсвует', 'Расчет', 'modal');
        end
        % Передаем в рабочее пространство возмущение и время 
        assignin('base', 'disturbance1', disturbance(1,1));
        assignin('base', 'kp', handles.savedValueKpMS);
        assignin('base', 'ki', handles.savedValueKiMS);

        numerator = handles.savedValueOuMS{1};
        denominator = handles.savedValueOuMS{2};
        tau = handles.savedValueOuMS{3};
        
        assignin('base', 'numerator', numerator);
        assignin('base', 'denominator', denominator);
        assignin('base', 'tau', tau);
        
        % Запуск Simulink модели
        simIn = Simulink.SimulationInput('SISO_model');
        out = sim(simIn);
        ScopeRobData = get(out, 'ScopeData2'); 

        % Извлечение данных из переменной ScopeRobData (заполненной из Simulink)
        timeData = ScopeRobData.time;
        signalData = ScopeRobData.signals.values;

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