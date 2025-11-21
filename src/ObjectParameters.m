function ObjectParameters(hObject, eventdata, handles, buttonName)

% Открыть новое окно для ввода значений
newWindow = figure('Name', ['Введите параметры для ' buttonName], 'Position', [300, 300, 400, 250]);
    
% Поле для ввода нумератора (можно ввести массив, разделенный пробелами или запятыми)
uicontrol('Style', 'text', 'Position', [50, 180, 100, 20], 'String', 'Числитель ПФ: ');
numeratorEdit = uicontrol('Style', 'edit', 'Position', [160, 180, 150, 20], 'Tag', 'numeratorEdit');

% Поле для ввода деноминатора (можно ввести массив)
uicontrol('Style', 'text', 'Position', [50, 130, 100, 20], 'String', 'Знаменатель ПФ: ');
denominatorEdit = uicontrol('Style', 'edit', 'Position', [160, 130, 150, 20], 'Tag', 'denominatorEdit');

% Поле для ввода запаздывания (можно ввести массив)
uicontrol('Style', 'text', 'Position', [50, 80, 100, 20], 'String', 'Запаздывание');
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

global params

% Получение значений из полей
numerator = str2num(get(findobj(newWindow, 'Tag', 'numeratorEdit'), 'String'));
denominator = str2num(get(findobj(newWindow, 'Tag', 'denominatorEdit'), 'String'));
delay = str2double(get(findobj(newWindow, 'Tag', 'delayEdit'), 'String'));

% Проверка корректности введенных данных
if isempty(numerator) || isempty(denominator) || isempty(delay)
    errordlg('Введите корректные числовые значения!', 'Ошибка');
    return;
end

% Сохранение значений в структуру params в зависимости от кнопки
params.(buttonName).numerator = numerator;
params.(buttonName).denominator = denominator;
params.(buttonName).delay = delay;

% Закрытие окна после сохранения
close(newWindow);

% Вывод для проверки
disp(['Значения для ', buttonName, ':']);
disp(['Нумератор: ', num2str(numerator)]);
disp(['Деноминатор: ', num2str(denominator)]);
disp(['Запаздывание: ', num2str(delay)]);


% Функция отмены
function closeWindowWithoutSaving(newWindow)

% Закрыть окно без сохранения
disp('Ввод отменен.');
close(newWindow);
