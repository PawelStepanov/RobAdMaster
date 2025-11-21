function ObjectZona(hObject, eventdata, handles, buttonName)

% Открыть новое окно для ввода значений
newWindow = figure('Name', ['Введите параметры для ' buttonName], 'Position', [300, 300, 400, 250]);
    
% Поле для ввода зоны для нумератора (можно ввести массив, разделенный пробелами или запятыми)
uicontrol('Style', 'text', 'Position', [40, 180, 110, 20], 'String', 'Зона числителя ПФ: ');
numeratorEdit = uicontrol('Style', 'edit', 'Position', [160, 180, 150, 20], 'Tag', 'numeratorEdit');

% Поле для ввода зоны для деноминатора (можно ввести массив)
uicontrol('Style', 'text', 'Position', [30, 130, 120, 20], 'String', 'Зона Знаменателя ПФ: ');
denominatorEdit = uicontrol('Style', 'edit', 'Position', [160, 130, 150, 20], 'Tag', 'denominatorEdit');

% Поле для ввода зоны для запаздывания (можно ввести массив)
uicontrol('Style', 'text', 'Position', [40, 80, 110, 20], 'String', 'Зона запаздывания');
delayEdit = uicontrol('Style', 'edit', 'Position', [160, 80, 150, 20], 'Tag', 'delayEdit');

% Кнопка "Сохранить"
uicontrol('Style', 'pushbutton', 'Position', [100, 30, 80, 30], 'String', 'Сохранить', ...
    'Callback', @(src, event) saveParameters(newWindow, numeratorEdit, denominatorEdit, delayEdit, buttonName));

% Кнопка "Отмена"
uicontrol('Style', 'pushbutton', 'Position', [200, 30, 80, 30], 'String', 'Отмена', ...
    'Callback', @(src, event) close(newWindow));

guidata(hObject, handles)


% Функция сохранения параметров
function saveParameters(newWindow, numeratorEdit, denominatorEdit, delayEdit, buttonName)

global zona_params

% Получение значений из полей
numeratorZona = str2num(get(findobj(newWindow, 'Tag', 'numeratorEdit'), 'String'));
denominatorZona = str2num(get(findobj(newWindow, 'Tag', 'denominatorEdit'), 'String'));
delayZona = str2double(get(findobj(newWindow, 'Tag', 'delayEdit'), 'String'));

% Проверка корректности введенных данных
if isempty(numeratorZona) || isempty(denominatorZona) || isempty(delayZona)
    errordlg('Введите корректные числовые значения!', 'Ошибка');
    return;
end

% Сохранение значений в структуру params в зависимости от кнопки
zona_params.(buttonName).numerator = numeratorZona;
zona_params.(buttonName).denominator = denominatorZona;
zona_params.(buttonName).delay = delayZona;

% Закрытие окна после сохранения
close(newWindow);

% Вывод для проверки
disp(['Значения для ', buttonName, ':']);
disp(['Зона нумератора: ', num2str(numeratorZona)]);
disp(['Зона деноминатора: ', num2str(denominatorZona)]);
disp(['Зона запаздывания: ', num2str(delayZona)]);


% Функция отмены
function closeWindowWithoutSaving(newWindow)

% Закрыть окно без сохранения
disp('Ввод отменен.');
close(newWindow);