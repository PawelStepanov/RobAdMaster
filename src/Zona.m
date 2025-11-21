function Zona(hObject, eventdata, handles)

    % Создание окна
    fig = figure('Position', [500, 500, 500, 200], 'Name', 'Расчеты', 'NumberTitle', 'off');
    
    uicontrol('Style', 'text', 'Position', [125, 160, 250, 40], 'String', 'Зона неопределенности статических коэффициентов', ...
        'FontSize', 12, 'FontWeight', 'bold');
    
    % Создание кнопки для запуска расчета возможной зоны неопределенности
    uicontrol('Style', 'pushbutton', 'String', 'Возможная зона', 'FontSize', 10, ...
        'Position', [20, 100, 140, 40], ...
        'Callback', @calculation1);
    
    % Создание кнопки для запуска расчета необходимых и достаточных условий
    hButton = uicontrol('Style', 'pushbutton', 'String', 'Необходимые и достаточные условия', ...
        'FontSize', 10, 'Position', [20, 50, 235, 40], ...
        'Enable', 'off', 'Callback', @calculation2);
    
    % Кнопка "Назад"
    uicontrol('Style', 'pushbutton', 'Position', [400, 10, 80, 30], 'String', 'Назад', 'FontSize', 12, ...
        'Callback', @(src, event) close(fig));

    guidata(hObject, handles)
    
    % Поле для отображения результатов расчетов
    resultText = uicontrol('Style', 'text', 'Position', [180, 90, 200, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    
    % Поле для отображения результатов расчетов
    resultText1 = uicontrol('Style', 'text', 'Position', [260, 47, 270, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    
    % Функция для выполнения первого расчета
    function calculation1(~, ~)
        global K
        if length(K) == 2
            % Пример расчета
            result = MaxZonaUncertaintyStaticCoef;
            hButton.Enable = 'on';
        else
            result = MaxZonaDet;
        end
        set(resultText, 'String', ['Результат: ', num2str(result)]);
    end

    % Функция для выполнения второго расчета
    function calculation2(~, ~)
        
        % Пример расчета
        [omegamax, omegacherta, conditions] = NecessarySufficientConditions;
        result = conditions; 
        set(resultText1, 'String', [result]);
    end
end