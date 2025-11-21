function RobAdReg(hObject, eventdata, handles)
    
    global name_windown
    % Создание окна
    fig = figure('Position', [500, 500, 500, 200], 'Name', 'Расчеты', 'NumberTitle', 'off');
    
    uicontrol('Style', 'text', 'Position', [150, 155, 250, 40], 'String', name_windown, ...
        'FontSize', 12, 'FontWeight', 'bold');
    
    % Создание кнопки для запуска расчета робастно-адаптивного регулятора
    uicontrol('Style', 'pushbutton', 'String', 'Робастно-адаптивный регулятор', 'FontSize', 10, ...
        'Position', [20, 100, 200, 40], ...
        'Callback', @calculation1);
    
    % Создание кнопки для запуска построения графика для ОУ, у которого
    % самая большая разница между робастными и робастно-адаптивными
    % настройками
    uicontrol('Style', 'pushbutton', 'String', 'Переходный процесс', ...
        'FontSize', 10, ...
        'Position', [20, 50, 200, 40], ...
        'Callback', @calculation2);
    
    % Кнопка "Назад"
    uicontrol('Style', 'pushbutton', 'Position', [400, 10, 80, 30], 'String', 'Назад', 'FontSize', 12, ...
        'Callback', @(src, event) close(fig));
    
    % Поле для отображения результатов расчетов
    resultText = uicontrol('Style', 'text', 'Position', [240, 100, 500, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    % Поле для отображения результатов расчетов
    resultText1 = uicontrol('Style', 'text', 'Position', [240, 80, 500, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    
    % Функция для выполнения расчета робастного регулятора
    function calculation1(~, ~)

        if isfield(handles, 'savedValue4') && isfield(handles, 'savedValue5')
            disp('Номинальный регулятор уже был расчитан')
        else
            disp('Начат расчет номинального регулятора')
            % Создание всплывающего окна с сообщением о начале расчета
            h = msgbox('Расчет номинального регулятора. Пожалуйста, подождите...', 'Расчет', 'modal');
            
            % Вызов функции для расчета автономной составляющей
            [Wavt_Kp_Nom, Wavt_Ki_Nom] = NomRegulatorAvtonom;
            % Вызов функции для расчета вспомогательной состовляющей
            [Wvsp_Kp_Nom, Wvsp_Ki_Nom] = NomRegulatorVspomogateliy;
            % Вызов функции для расчета комбинированого регулятора
            [Wkp_nominal, Wki_nominal, criterion_min] = KombRegNominalOU(Wavt_Ki_Nom, Wavt_Kp_Nom, Wvsp_Kp_Nom, Wvsp_Ki_Nom, handles.savedValue3);
            
            % Сохраняем значение в структуре handles
            handles.savedValue4 = Wkp_nominal;
            handles.savedValue5 = Wki_nominal; 
            % Обновляем handles
            guidata(hObject, handles);
            
            % Закрытие всплывающего окна после завершения расчета
            if ishandle(h)  % Проверяем, что окно еще существует
                close(h);
            end
        end
        
        if isfield(handles, 'savedValue6') && isfield(handles, 'savedValue7')
            disp('Робастный регулятор уже был расчитан')
        else
            disp('Начат расчет робастного регулятора')
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
            % Обновляем handles
            guidata(hObject, handles);
            
            % Закрытие всплывающего окна после завершения расчета
            if ishandle(h)  % Проверяем, что окно еще существует
                close(h);
            end
        end
        
        if isfield(handles, 'savedValue6') && isfield(handles, 'savedValue7') && isfield(handles, 'savedValue4') && isfield(handles, 'savedValue5')
            disp('Начат расчет робастно-адаптивного регулятора')
            % Создание всплывающего окна с сообщением о начале расчета
            h = msgbox('Расчет робастно-адпативного регулятора. Пожалуйста, подождите...', 'Расчет', 'modal');
            
            % Вызов функции для расчета комбинированого регулятора
            [rel_min, rel_max, Wkp_max_road, Wki_max_robad, ou11_robad, ou12_robad, ou21_robad, ou22_robad] = KombRobAdReg(handles.savedValue6, handles.savedValue7, ...
                handles.savedValue4, handles.savedValue5, handles.savedValue3);
            
            % Закрытие всплывающего окна после завершения расчета
            if ishandle(h)  % Проверяем, что окно еще существует
                close(h);
            end
        end
        
        % Сохраняем значение в структуре handles
        handles.savedValue8 = Wkp_max_road;
        handles.savedValue9 = Wki_max_robad;
        handles.savedValueou11 = ou11_robad;
        handles.savedValueou12 = ou12_robad;
        handles.savedValueou21 = ou21_robad;
        handles.savedValueou22 = ou22_robad;

        % Обновляем handles
        guidata(hObject, handles);
        
        set(resultText, 'String', ['Максимальная разница: ', num2str(rel_max)]);
        set(resultText1, 'String', ['Минимальная разница: ',  num2str(rel_min)]);
    end

    % Функция для выполнения второго расчета
    function calculation2(~, ~)
        
        % Вызов функции для построения графика
        TwoGraph(handles.savedValueou11, handles.savedValueou12, handles.savedValueou21, handles.savedValueou22, handles.savedValue8, ...
            handles.savedValue9, handles.savedValue6, handles.savedValue7);
    end
end