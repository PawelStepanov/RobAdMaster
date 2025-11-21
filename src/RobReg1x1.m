function RobReg1x1(hObject, eventdata, handles)

    % Создание окна
    fig = figure('Position', [500, 300, 500, 400], 'Name', 'Расчеты', 'NumberTitle', 'off');
    
    uicontrol('Style', 'text', 'Position', [130, 355, 250, 40], 'String', 'Расчет робастного регулятора 1x1', ...
        'FontSize', 12, 'FontWeight', 'bold');
    uicontrol('Style', 'text', 'Position', [225, 290, 30, 40], 'String', '--->', 'FontSize', 12, 'FontWeight', 'bold');
    uicontrol('Style', 'text', 'Position', [235, 90, 30, 40], 'String', '-->', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Создание кнопки для запуска расчета робастного беспоиского
    % регулятора
    uicontrol('Style', 'pushbutton', 'String', 'Беспоисковый метод', 'FontSize', 10, ...
        'Position', [20, 300, 200, 40], ...
        'Callback', @calculation1);
    
    % Создание кнопки для запуска проверки регулятора на всех точках
    uicontrol('Style', 'pushbutton', 'String', 'Проверка регулятора на всех точках', ...
        'FontSize', 10, ...
        'Position', [260, 300, 235, 40], ...
        'Enable', 'on', ...
        'Callback', @calculation2);
    
    % Создание кнопки для запуска расчета робастного регулятора поисковым
    % методом
    uicontrol('Style', 'pushbutton', 'String', 'Поисковый метод', ...
        'FontSize', 10, ...
        'Position', [20, 200, 200, 40], ...
        'Callback', @calculation3);
    
    % Создание кнопки для запуска расчета робастного регулятора методом МЧ
    uicontrol('Style', 'pushbutton', 'String', 'Максимальной чувствительности', ...
        'FontSize', 10, 'Position', [20, 100, 220, 40], ...
        'Callback', @calculation4);
    
    % Создание кнопки для запуска проверки регулятора на всех точках
    uicontrol('Style', 'pushbutton', 'String', 'Проверка регулятора на всех точках', ...
        'FontSize', 10, ...
        'Position', [260, 100, 235, 40], ...
        'Enable', 'on', ...
        'Callback', @calculation5);
    
    % Создание кнопки для запуска построения графика для самого трудного ОУ
    % для робастного регулятора
    button1 = uicontrol('Style', 'pushbutton', 'String', 'График самого трудного ОУ', ...
        'FontSize', 10, ...
        'Position', [20, 10, 200, 40], ...
        'Enable', 'on', ...
        'Callback', @calculation6);
    
    % Кнопка "Назад"
    uicontrol('Style', 'pushbutton', 'Position', [400, 10, 80, 30], 'String', 'Назад', 'FontSize', 12, ...
        'Callback', @(src, event) close(fig));
    
    % Поле для отображения результатов расчетов
    resultText = uicontrol('Style', 'text', 'Position', [55, 250, 500, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    resultText1 = uicontrol('Style', 'text', 'Position', [260, 250, 270, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    resultText2 = uicontrol('Style', 'text', 'Position', [250, 202, 270, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    resultText3 = uicontrol('Style', 'text', 'Position', [250, 182, 270, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    resultText4 = uicontrol('Style', 'text', 'Position', [40, 80, 100, 20], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    resultText5 = uicontrol('Style', 'text', 'Position', [40, 60, 100, 20], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    resultText6 = uicontrol('Style', 'text', 'Position', [260, 60, 270, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    
    % Функция для выполнения расчета робастного регулятора беспоиском
    function calculation1(~, ~)
        
        % Создание всплывающего окна с сообщением о начале расчета
        h = msgbox('Расчет беспоисковым методом. Пожалуйста, подождите...', 'Расчет', 'modal');
        
        % Вызов функции для расчета регулятора беспоисковым методом
        [Ki_rob_bespoisk] = BespoiskRegulatorRob(handles.savedValue3);
        
        % Сохраняем значение в структуре handles
        handles.savedValueKibp = Ki_rob_bespoisk;
        
        % Обновляем handles
        guidata(hObject, handles);

        set(resultText, 'String', ['И: ', num2str(Ki_rob_bespoisk)]);
        % Закрытие всплывающего окна после завершения расчета
        if ishandle(h)  % Проверяем, что окно еще существует
            close(h);
        end
    end

    % Функция для выполнения проверки беспоиского регулятора на всех точках
    function calculation2(~, ~)
        
        % Создание всплывающего окна с сообщением о начале расчета
        h = msgbox('Проверка началась. Пожалуйста, подождите...', 'Расчет', 'modal');
        flag = 0;
        % Вызов функции для проверки беспоиского регулятора на всех точках
        [ou11_max, criterion_max] = SISO(handles, flag);
        if handles.savedValue3 == 0.589
            set(resultText1, 'String', ['Максимальное ИМК: ', num2str(criterion_max)]);
        elseif handles.savedValue3 == 0.507
            set(resultText1, 'String', ['Максимальное быстродействие: ', num2str(criterion_max)]);
        else
            set(resultText1, 'String', ['Максимальное ИКК: ', num2str(criterion_max)]);
        end
        % Сохраняем значение в структуре handles
        handles.savedValueOuBP = ou11_max;
        
        % Обновляем handles
        guidata(hObject, handles)
        
        % Закрытие всплывающего окна после завершения расчета
        if ishandle(h) % Проверяем, что окно еще существует
            close(h);
        end
    end

    % Функция для расчета робастного регулятора поисковым способом
    function calculation3(~, ~)
        if isfield(handles, 'savedValueKibp')
            disp('Робастный регулятор беспоиском уже был расчитан')
        else
        % Создание всплывающего окна с сообщением о начале расчета
        h = msgbox('Расчет беспоисковым методом. Пожалуйста, подождите...', 'Расчет', 'modal');
        
        % Вызов функции для расчета регулятора беспоисковым методом
        [Ki_rob_bespoisk] = BespoiskRegulatorRob(handles.savedValue3);
        
        % Сохраняем значение в структуре handles
        handles.savedValueKiBP = Ki_rob_bespoisk;
        % Обновляем handles
        guidata(hObject, handles);
        
        set(resultText, 'String', ['Значение Ki: ', num2str(Ki_rob_bespoisk)]);
        
        % Закрытие всплывающего окна после завершения расчета
        if ishandle(h)  % Проверяем, что окно еще существует
            close(h);
        end            
        end
        disp('Начат расчет робастно регулятора поисковым методом')
        % Создание всплывающего окна с сообщением о начале расчета
        h = msgbox('Расчет робастно регулятора поиском. Пожалуйста, подождите...', 'Расчет', 'modal');
        
        % Вызов функции для расчета регулятора поиском
        [Ki_criterion_minmax, minmax_criterion, ou_minmax] = PoiskRegulator(handles.savedValue3, handles.savedValueKibp);
        
        set(resultText2, 'String', ['И: ', num2str(Ki_criterion_minmax)]);
        if handles.savedValue3 == 0.589
            set(resultText3, 'String', ['Максимальное ИМК: ', num2str(minmax_criterion)]);
        elseif handles.savedValue3 == 0.507
            set(resultText3, 'String', ['Максимальное быстродействие: ', num2str(minmax_criterion)]);
        else
            set(resultText3, 'String', ['Максимальное ИКК: ', num2str(minmax_criterion)]);
        end
        
        % Сохраняем значение в структуре handles
        handles.savedValueOuP = ou_minmax;
        handles.savedValueKiP = Ki_criterion_minmax;
        % Обновляем handles
        guidata(hObject, handles);
        
        % Закрытие всплывающего окна после завершения расчета
        if ishandle(h)  % Проверяем, что окно еще существует
            close(h);
        end 
    end

    % Функция для расчета регулятора методом МЧ
    function calculation4(~,~)
        
        % Создание всплывающего окна с сообщением о начале расчета
        h = msgbox('Расчет методом МЧ. Пожалуйста, подождите...', 'Расчет', 'modal');
        
        % Функция вызова расчета методом МЧ
        [kp_rob, ki_rob, criterion_min, kp_nom, ki_nom] = MaximumSensitivity1x1(handles.savedValue3);
        set(resultText4, 'String', ['П: ', num2str(kp_rob)])
        set(resultText5, 'String', ['И: ', num2str(ki_rob)])
        
        % Сохраняем значение в структуре handles
        handles.savedValueKpMS = kp_rob;
        handles.savedValueKiMS = ki_rob;
        handles.savedValueKpMSNom = kp_nom;
        handles.savedValueKiMSNom = ki_nom;
        % Обновляем handles
        guidata(hObject, handles);
        
        % Закрытие всплывающего окна после завершения расчета
        if ishandle(h)  % Проверяем, что окно еще существует
            close(h);
        end 
    end

    % Функция для проверки регулятора по методу МЧ на всех точках
    function calculation5(~,~)
        
        % Создание всплывающего окна с сообщением о начале расчета
        h = msgbox('Проверка началась. Пожалуйста, подождите...', 'Расчет', 'modal');
        flag = 1;
        % Вызов функции для проверки беспоиского регулятора на всех точках
        [ou11_max, criterion_max] = SISO(handles, flag);
        if handles.savedValue3 == 0.589
            set(resultText6, 'String', ['Максимальное ИМК: ', num2str(criterion_max)]);
        elseif handles.savedValue3 == 0.507
            set(resultText6, 'String', ['Максимальное быстродействие: ', num2str(criterion_max)]);
        else
            set(resultText6, 'String', ['Максимальное ИКК: ', num2str(criterion_max)]);
        end
        % Сохраняем значение в структуре handles
        handles.savedValueOuMS = ou11_max;
        
        % Обновляем handles
        guidata(hObject, handles)
        
        % Закрытие всплывающего окна после завершения расчета
        if ishandle(h) % Проверяем, что окно еще существует
            close(h);
        end
    end

    % Функция для построения графика
    function calculation6(~, ~)
        % Вызов функции для построения графика
        Graph1x1(handles);
    end
end