function NominalReg(hObject, eventdata, handles)
    
    global name_windown
    % Создание окна
    fig = figure('Position', [500, 500, 700, 250], 'Name', 'Расчеты', 'NumberTitle', 'off');
    
    uicontrol('Style', 'text', 'Position', [225, 200, 250, 40], 'String', name_windown, ...
        'FontSize', 12, 'FontWeight', 'bold');
    
    % Создание кнопки для запуска расчета номинального комбинированного
    % регулятора
    uicontrol('Style', 'pushbutton', 'String', 'Комбинированный регулятор', 'FontSize', 10, ...
        'Position', [20, 130, 200, 40], ...
        'Callback', @calculation1);
    
    % Создание кнопки для запуска проверки регулятора на всех точках
    uicontrol('Style', 'pushbutton', 'String', 'Проверка регулятора на всех точках', ...
        'FontSize', 10, ...
        'Position', [20, 70, 235, 40], ...
        'Callback', @calculation2);
    
    % Создание кнопки для запуска построения графика для самого трудного ОУ
    % для номинального регулятора
    uicontrol('Style', 'pushbutton', 'String', 'График самого трудного ОУ', ...
        'FontSize', 10, ...
        'Position', [20, 10, 200, 40], ...
        'Callback', @calculation3);
    
    % Кнопка "Назад"
    uicontrol('Style', 'pushbutton', 'Position', [600, 10, 80, 30], 'String', 'Назад', 'FontSize', 12, ...
        'Callback', @(src, event) close(fig));
    
    % Поле для отображения результатов расчетов
    resultText = uicontrol('Style', 'text', 'Position', [270, 160, 500, 20], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    resultText1 = uicontrol('Style', 'text', 'Position', [270, 130, 500, 20], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    resultText2 = uicontrol('Style', 'text', 'Position', [270, 60, 270, 40], ...
        'String', '', 'FontSize', 12, 'HorizontalAlignment', 'left');
    
    % Функция для выполнения первого расчета
    function calculation1(~, ~)
        
        % Создание всплывающего окна с сообщением о начале расчета
        h = msgbox('Расчет начался. Пожалуйста, подождите...', 'Расчет', 'modal');
        
        % Вызов функции для расчета автономной составляющей
        [Wavt_Kp_Nom, Wavt_Ki_Nom] = NomRegulatorAvtonom;
        
        % Вызов функции для расчета вспомогательной состовляющей
        [Wvsp_Kp_Nom, Wvsp_Ki_Nom] = NomRegulatorVspomogateliy;
        
        % Вызов функции для расчета комбинированого регулятора
        [Wkp_nominal, Wki_nominal, criterion_min] = KombRegNominalOU(Wavt_Ki_Nom, Wavt_Kp_Nom, Wvsp_Kp_Nom, Wvsp_Ki_Nom, handles.savedValue3);
        
        % Сохраняем значение в структуре handles
        handles.savedValue4 = Wkp_nominal;
        handles.savedValue5 = Wki_nominal;
        
        set(resultText, 'String', ['П: ', mat2str(round(Wkp_nominal,6))]);
        set(resultText1, 'String', ['И: ', mat2str(round(Wki_nominal,6))]);
        % Закрытие всплывающего окна после завершения расчета
        if ishandle(h)  % Проверяем, что окно еще существует
            close(h);
        end
    end

    % Функция для выполнения второго расчета
    function calculation2(~, ~)
        
        h = msgbox('Расчет начался. Пожалуйста, подождите...', 'Расчет', 'modal');
        
        flag = 0; % Указываем, что считаем номинальный регулятор
        % Вызов функции для проверки номинального регулятора на всех точках
        [ou11_max, ou12_max, ou21_max, ou22_max, criterion_max] = MIMONominalReg(handles.savedValue4, handles.savedValue5, handles.savedValue3, flag);
        if handles.savedValue3 == 0.589
            set(resultText2, 'String', ['Максимальное ИМК: ', num2str(criterion_max)]);
        elseif handles.savedValue3 == 0.507
            set(resultText2, 'String', ['Максимальное быстродействие: ', num2str(criterion_max)]);
        else
            set(resultText2, 'String', ['Максимальное ИКК: ', num2str(criterion_max)]);
        end
        
        % Сохраняем значение в структуре handles
        handles.savedValueou11 = ou11_max;
        handles.savedValueou12 = ou12_max;
        handles.savedValueou21 = ou21_max;
        handles.savedValueou22 = ou22_max;
        
        % Обновляем handles
        guidata(hObject, handles)
        
        % Закрытие всплывающего окна после завершения расчета
        if ishandle(h)  % Проверяем, что окно еще существует
            close(h);
        end
    end

    % Функция для выполнения второго расчета
    function calculation3(~, ~)
        % Вызов функции для построения графика
        Graph(handles.savedValueou11, handles.savedValueou12, handles.savedValueou21, handles.savedValueou22, handles.savedValue4, handles.savedValue5);
    end
end