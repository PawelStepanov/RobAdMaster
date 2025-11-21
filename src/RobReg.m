function RobReg(hObject, eventdata, handles)
    
    global name_windown
    global flag_size 
    
    % Создание окна
    fig = figure('Position', [500, 500, 500, 300], 'Name', 'Расчеты', 'NumberTitle', 'off');
    
    uicontrol('Style', 'text', 'Position', [150, 255, 250, 40], 'String', name_windown, ...
        'FontSize', 12, 'FontWeight', 'bold');
    uicontrol('Style', 'text', 'Position', [235, 115, 30, 40], 'String', '-->', 'FontSize', 12, 'FontWeight', 'Bold');
    
    % Создание кнопки для запуска расчета робастного комбинированного
    % регулятора
    uicontrol('Style', 'pushbutton', 'String', 'Комбинированный регулятор', 'FontSize', 10, ...
        'Position', [20, 200, 200, 40], ...
        'Callback', @calculation1);
    if flag_size == 3
        % Создание кнопки для запуска расчета робастного регулятора методом МЧ
        uicontrol('Style', 'pushbutton', 'String', 'Максимальной чувствительности', 'FontSize', 10, ...
            'Position', [20, 125, 220, 40], 'Enable', 'off');
        % Создание кнопки для запуска проверки регулятора на всех точках
        uicontrol('Style', 'pushbutton', 'String', 'Проверка регулятора на всех точках', ...,
            'FontSize', 10, 'Position', [260, 125, 235, 40], 'Enable', 'off');
    else
        % Создание кнопки для запуска расчета робастного регулятора методом МЧ
        uicontrol('Style', 'pushbutton', 'String', 'Максимальной чувствительности', 'FontSize', 10, ...
            'Position', [20, 125, 220, 40], 'Callback', @calculation2);
        % Создание кнопки для запуска проверки регулятора на всех точках
        uicontrol('Style', 'pushbutton', 'String', 'Проверка регулятора на всех точках', ...,
            'FontSize', 10, 'Position', [260, 125, 235, 40], 'Callback', @calculation3);
    end
      
    % Создание кнопки для запуска построения графика для самого трудного ОУ
    % для робастного регулятора
    uicontrol('Style', 'pushbutton', 'String', 'График самого трудного ОУ', ...
        'FontSize', 10, ...
        'Position', [20, 50, 200, 40], ...
        'Callback', @calculation4);
    
    % Кнопка "Назад"
    uicontrol('Style', 'pushbutton', 'Position', [400, 10, 80, 30], 'String', 'Назад', 'FontSize', 12, ...
        'Callback', @(src, event) close(fig));
    
    % Поле для отображения результатов расчетов
    resultText = uicontrol('Style', 'text', 'Position', [240, 200, 500, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    % Поле для отображения результатов расчетов
    resultText2 = uicontrol('Style', 'text', 'Position', [260, 80, 500, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    
    % Функция для выполнения расчета робастного регулятора
    function calculation1(~, ~)
        
        % Создание всплывающего окна с сообщением о начале расчета
        h = msgbox('Расчет робастного регулятора. Пожалуйста, подождите...', 'Расчет', 'modal');
        
        % Вызов функции для расчета автономной составляющей
        [Wvsp_Kp_Rob, Wvsp_Ki_Rob] = RobRegulatorVspomogateliy;
        
        % Вызов функции для расчета вспомогательной состовляющей
        [Wavt_Kp_Rob, Wavt_Ki_Rob] = RobRegulatorAvtonom;
        
        % Вызов функции для расчета комбинированого регулятора
        [Wkp_robast, Wki_robast, criterion_min, ou11_rob, ou12_rob, ou21_rob, ou22_rob] = KombRobReg(Wavt_Ki_Rob, Wavt_Kp_Rob, Wvsp_Kp_Rob, Wvsp_Ki_Rob, handles.savedValue3);
        
        % Сохраняем значение в структуре handles
        handles.savedValue6 = Wkp_robast;
        handles.savedValue7 = Wki_robast;
        handles.savedValueou11 = ou11_rob;
        handles.savedValueou12 = ou12_rob;
        handles.savedValueou21 = ou21_rob;
        handles.savedValueou22 = ou22_rob;
        
        % Обновляем handles
        guidata(hObject, handles);
        
        if handles.savedValue3 == 0.589
            set(resultText, 'String', ['Максимальное ИМК: ', num2str(criterion_min)]);
        elseif handles.savedValue3 == 0.507
            set(resultText, 'String', ['Максимальное быстродействие: ', num2str(criterion_min)]);
        else
            set(resultText, 'String', ['Максимальное ИКК: ', num2str(criterion_min)]);
        end

        % Закрытие всплывающего окна после завершения расчета
        if ishandle(h)  % Проверяем, что окно еще существует
            close(h);
        end
    end
    
    % Функция для выполнения расчета по методу МЧ
    function calculation2(~,~)
        % Создание всплывающего окна с сообщением о начале расчета
        h = msgbox('Расчет методом МЧ. Будет 2 звуковых уведомления. Пожалуйста, подождите...', 'Расчет', 'modal');
        
        % Вызов функции для расчета методом МЧ
        [Wkp_rob, Wki_rob, criterion_min] = MaximumSensitivity2x2(handles.savedValue3);
        
        handles.savedValueWkpMS = Wkp_rob;
        handles.savedValueWkiMS = Wki_rob;
        
        % Обновляем handles
        guidata(hObject, handles);
        
        % Закрытие всплывающего окна после завершения расчета
        if ishandle(h)  % Проверяем, что окно еще существует
            close(h);
        end
    end

    % Функция для проверки регулятора методом МЧ на всех точках
    function calculation3(~,~)
        % Создание всплывающего окна с сообщением о начале расчета
        h = msgbox('Проверка началась. Пожалуйста, подождите...', 'Расчет', 'modal');
        
        flag = 1; % Указываем, что считаем для метода МЧ
       % Вызов функции для проверки номинального регулятора на всех точках
        [ou11_max, ou12_max, ou21_max, ou22_max, criterion_max] = MIMONominalReg(handles.savedValueWkpMS, handles.savedValueWkiMS, handles.savedValue3, flag);
        if handles.savedValue3 == 0.589
            set(resultText2, 'String', ['Максимальное ИМК: ', num2str(round(criterion_max, 4))]);
        elseif handles.savedValue3 == 0.507
            set(resultText2, 'String', ['Максимальное быстродействие: ', num2str(round(criterion_max, 4))]);
        else
            set(resultText2, 'String', ['Максимальное ИКК: ', num2str(round(criterion_max, 4))]);
        end
        
        % Сохраняем значение в структуре handles
        handles.savedValueOu11MS = ou11_max;
        handles.savedValueOu12MS = ou12_max;
        handles.savedValueOu21MS = ou21_max;
        handles.savedValueOu22MS = ou22_max;
        
        % Обновляем handles
        guidata(hObject, handles);
        
        % Закрытие всплывающего окна после завершения расчета
        if ishandle(h) % Проверяем, что окно еще существует
            close(h);
        end
    end
    
    % Функция для построения графика
    function calculation4(~, ~)
        % Вызов функции для построения графика
        Graph(handles);
    end
end