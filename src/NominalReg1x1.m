function NominalReg1x1(hObject, eventdata, handles)

    % Создание окна
    fig = figure('Position', [500, 500, 500, 300], 'Name', 'Расчеты', 'NumberTitle', 'off');
    
    uicontrol('Style', 'text', 'Position', [130, 255, 250, 40], 'String', 'Расчет номинального регулятора 1x1', ...
        'FontSize', 12, 'FontWeight', 'bold');
    
    % Создание кнопки для запуска расчета робастного беспоиского
    % регулятора
    uicontrol('Style', 'pushbutton', 'String', 'Беспоисковый метод', 'FontSize', 10, ...
        'Position', [20, 200, 200, 40], ...
        'Callback', @calculation1);
    
    % Создание кнопки для запуска расчета робастного регулятора поисковым
    % методом
    uicontrol('Style', 'pushbutton', 'String', 'Поисковый метод', ...
        'FontSize', 10, ...
        'Position', [20, 100, 200, 40], ...
        'Callback', @calculation2);

    % Создание кнопки для запуска построения графика переходного процесса при номинальном регуляторе
    uicontrol('Style', 'pushbutton', 'String', 'График переходного процесса', ...
        'FontSize', 10, ...
        'Position', [20, 10, 200, 40], ...
        'Callback', @calculation3);
    
    % Кнопка "Назад"
    uicontrol('Style', 'pushbutton', 'Position', [400, 10, 80, 30], 'String', 'Назад', 'FontSize', 12, ...
        'Callback', @(src, event) close(fig));
    
    % Поле для отображения результатов расчетов
    resultText = uicontrol('Style', 'text', 'Position', [250, 200, 500, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    resultText1 = uicontrol('Style', 'text', 'Position', [250, 180, 500, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    resultText2 = uicontrol('Style', 'text', 'Position', [250, 102, 270, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    resultText3 = uicontrol('Style', 'text', 'Position', [250, 82, 270, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    
    % Функция для выполнения расчета робастного регулятора беспоиском
    function calculation1(~, ~)
        
        % Создание всплывающего окна с сообщением о начале расчета
        h = msgbox('Расчет беспоисковым методом. Пожалуйста, подождите...', 'Расчет', 'modal');
        
        % Вызов функции для расчета регулятора беспоисковым методом
        [Ki_nom_bespoisk, criterion] = BespoiskRegulatorNominal(handles.savedValue3);
        
        % Сохраняем значение в структуре handles
        handles.savedValueKibpnom = Ki_nom_bespoisk;
        
        % Обновляем handles
        guidata(hObject, handles);

        set(resultText, 'String', ['И: ', num2str(Ki_nom_bespoisk)]);
        if handles.savedValue3 == 0.589
            set(resultText1, 'String', ['ИМК: ', num2str(criterion)]);
        elseif handles.savedValue3 == 0.507
            set(resultText1, 'String', ['Быстродействие: ', num2str(criterion)]);
        else
            set(resultText1, 'String', ['ИКК: ', num2str(criterion)]);
        end
        % Закрытие всплывающего окна после завершения расчета
        if ishandle(h)  % Проверяем, что окно еще существует
            close(h);
        end
    end

    % Функция для расчета номинального регулятора поисковым способом
    function calculation2(~, ~)
        
        disp('Начат расчет номинального регулятора поисковым методом')
        % Создание всплывающего окна с сообщением о начале расчета
        h = msgbox('Расчет номинального регулятора поиском. Пожалуйста, подождите...', 'Расчет', 'modal');
        
        % Вызов функции для расчета регулятора поиском
        [Ki_criterion_min, min_criterion] = PoiskRegulatorNominal(handles.savedValue3);
        
        set(resultText2, 'String', ['И: ', num2str(Ki_criterion_min)]);
        if handles.savedValue3 == 0.589
            set(resultText3, 'String', ['Минимальное ИМК: ', num2str(min_criterion)]);
        elseif handles.savedValue3 == 0.507
            set(resultText3, 'String', ['Минимальное быстродействие: ', num2str(min_criterion)]);
        else
            set(resultText3, 'String', ['Минимальное ИКК: ', num2str(min_criterion)]);
        end
        
        % Сохраняем значение в структуре handles
        handles.savedValueKiPnom = Ki_criterion_min;
        % Обновляем handles
        guidata(hObject, handles);
        
        % Закрытие всплывающего окна после завершения расчета
        if ishandle(h)  % Проверяем, что окно еще существует
            close(h);
        end 
    end

    % Функция для выполнения построения графиков
    function calculation3(~, ~)
        % Вызов функции для построения графика
        GraphNom1x1(handles);
    end

end