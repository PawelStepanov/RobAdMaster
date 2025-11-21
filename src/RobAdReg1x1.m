function RobAdReg1x1(hObject, eventdata, handles)

    % Создание окна
    fig = figure('Position', [500, 500, 500, 200], 'Name', 'Расчеты', 'NumberTitle', 'off');
    
    uicontrol('Style', 'text', 'Position', [150, 155, 250, 40], 'String', 'Расчет робастно-адаптивного регулятора 1x1', ...
        'FontSize', 12, 'FontWeight', 'bold');
    
    % Создание кнопки для запуска расчета робастно-адаптивного регулятора
    uicontrol('Style', 'pushbutton', 'String', 'Робастно-адаптивный регулятор', 'FontSize', 10, ...
        'Position', [20, 100, 200, 40], ...
        'Callback', @calculation1);
    
    % Создание кнопки для запуска построения графика для ОУ, у которого
    % самая большая разница между робастными и робастно-адаптивными
    % настройками
    uicontrol('Style', 'pushbutton', 'String', 'График', ...
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

        if isfield(handles, 'savedValueKpMSNom') && isfield(handles, 'savedValueKiMSNom')
            disp('Номинальный регулятор уже был расчитан')
        else
            disp('Начат расчет номинального регулятора')
            % Создание всплывающего окна с сообщением о начале расчета
            h = msgbox('Расчет номинального регулятора. Пожалуйста, подождите...', 'Расчет', 'modal');

            % Функция вызова расчета методом МЧ
            [kp_rob, ki_rob, criterion_min, kp_nom, ki_nom] = MaximumSensitivity1x1(handles.savedValue3);
            
            % Сохраняем значение в структуре handles
            handles.savedValueKpMSNom = kp_nom;
            handles.savedValueKiMSNom = ki_nom;
            % Обновляем handles
            guidata(hObject, handles);
            
            % Закрытие всплывающего окна после завершения расчета
            if ishandle(h)  % Проверяем, что окно еще существует
                close(h);
            end
        end
        
        if isfield(handles, 'savedValueKpMS') && isfield(handles, 'savedValueKiMS')
            disp('Робастный регулятор уже был расчитан')
        else
            disp('Начат расчет робастного регулятора')
            % Создание всплывающего окна с сообщением о начале расчета
            h = msgbox('Расчет робастного регулятора. Пожалуйста, подождите...', 'Расчет', 'modal');
            
            % Функция вызова расчета методом МЧ
            [kp_rob, ki_rob, criterion_min, kp_nom, ki_nom] = MaximumSensitivity1x1(handles.savedValue3);
            
            % Сохраняем значение в структуре handles
            handles.savedValueKpMS = kp_rob;
            handles.savedValueKiMS = ki_rob;
            % Обновляем handles
            guidata(hObject, handles);
            
            % Закрытие всплывающего окна после завершения расчета
            if ishandle(h)  % Проверяем, что окно еще существует
                close(h);
            end
        end
        
        if isfield(handles, 'savedValueKpMS') && isfield(handles, 'savedValueKiMS') && isfield(handles, 'savedValueKpMSNom') && isfield(handles, 'savedValueKiMSNom')
            disp('Начат расчет робастно-адаптивного регулятора')
            % Создание всплывающего окна с сообщением о начале расчета
            h = msgbox('Расчет робастно-адпативного регулятора. Пожалуйста, подождите...', 'Расчет', 'modal');
            
            % Вызов функции для расчета робастно-адаптивного регулятора
            [rel_min, rel_max, Kp_robad, Ki_robad, ou_robad] = RobAdRegSISO(handles.savedValueKpMS, handles.savedValueKiMS, handles.savedValueKpMSNom, ... 
                handles.savedValueKiMSNom, handles.savedValue3);
            
            % Закрытие всплывающего окна после завершения расчета
            if ishandle(h)  % Проверяем, что окно еще существует
                close(h);
            end
        end
        
        % Сохраняем значение в структуре handles
        handles.savedValueKpRobAd = Kp_robad;
        handles.savedValueKiRobAd = Ki_robad;
        handles.savedValueOURobAd = ou_robad;

        % Обновляем handles
        guidata(hObject, handles);
        
        set(resultText, 'String', ['Максимальная разница: ', num2str(rel_max)]);
        set(resultText1, 'String', ['Минимальная разница: ',  num2str(rel_min)]);
    end

    % Функция для выполнения второго расчета
    function calculation2(~, ~)
        
        % Вызов функции для построения графика
        TwoGraph1x1(handles);
    end
end