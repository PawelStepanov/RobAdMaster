function varargout = figureExtendedSettings(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @figureExtendedSettings_OpeningFcn, ...
                   'gui_OutputFcn',  @figureExtendedSettings_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before figureExtendedSettings is made visible.
function figureExtendedSettings_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = figureExtendedSettings_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in buttonSeeOU.
function buttonSeeOU_Callback(hObject, eventdata, handles)

global rows
global cols

% Получение выбранного значения из pop-up menu
contents = cellstr(get(hObject, 'String')); % Все варианты
selectedOption = contents{get(hObject, 'Value')}; %Выбранный вариант

% Очистка предыдущих полей ввода
delete(findall(handles.uipanelMatrixZon, 'Style', 'pushbutton'));
    
% Установки для расположения  полей ввода
startX = 35; % Начальная Х позиция
startY = 130; % Начальная У позиция
spacing = 60; % Промежуток между полями
width = 50; % Ширина поля ввода
height = 30; % Высота поля ввода

% Динамическое создание полей для ввода в сетке
for i = 1:rows
    for j = 1:cols
        buttonName = ['h' num2str(i) num2str(j)]; % Имя кнопки
        uicontrol('Parent', handles.uipanelMatrixZon, 'Style', 'pushbutton', ...
            'String', buttonName, ...
            'Position', [startX + (j-1)*spacing, startY - (i-1)*spacing, width, height], ...
            'Callback', @(src,event) openWindowObjParam(hObject, eventdata, handles, buttonName), ...
            'Tag', buttonName);
    end
end

guidata(hObject, handles)


% Функция, открывающая новое окно при нажатии на кнопку
function openWindowObjParam(hObject, eventdata, handles, buttonName)

% Открытие нового окна
ObjectZona(hObject, eventdata, handles, buttonName);


% --- Executes during object creation, after setting all properties.
function popupmenuSize_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStepRo_Callback(hObject, eventdata, handles)

global step_ro

% Получаем значение из поля editStepRo
inputEditStepRo = get(handles.editStepRo, 'String');

% Преобразуем в число, если необходимо
numericValueStepRo = str2double(inputEditStepRo);
step_ro = numericValueStepRo;

% Сохраняем значение в структуре handles
handles.savedValueStepRo = numericValueStepRo;

% Обновляем handles
guidata(hObject, handles);

% Обновляем текст в текстовом поле
set(handles.editStepRo, 'String', num2str(handles.savedValueStepRo));

% --- Executes during object creation, after setting all properties.
function editStepRo_CreateFcn(hObject, eventdata, handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStepAlpha_Callback(hObject, eventdata, handles)

global step_alpha

% Получаем значение из поля editStepRo
inputEditStepAlpha = get(handles.editStepAlpha, 'String');

% Преобразуем в число, если необходимо
numericValueStepAlpha = str2double(inputEditStepAlpha);
step_alpha = numericValueStepAlpha;

% Сохраняем значение в структуре handles
handles.savedValueStepAlpha = numericValueStepAlpha;

% Обновляем handles
guidata(hObject, handles);

% Обновляем текст в текстовом поле
set(handles.editStepAlpha, 'String', num2str(handles.savedValueStepAlpha));


% --- Executes during object creation, after setting all properties.
function editStepAlpha_CreateFcn(hObject, eventdata, handles)


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxYes.
function checkboxYes_Callback(hObject, eventdata, handles)

global extreme_nominal

extreme_nominal = get(hObject, 'Value');  % Получение значения checkbox (0 или 1)
if extreme_nominal == 1
    disp('Checkbox is checked.');
else
    disp('Checkbox is not checked.');
end


function editDisturbance_Callback(hObject, eventdata, handles)

global disturbance

% Получаем значение из поля editDisturbance
inputEditdisturbance = get(handles.editDisturbance, 'String');

% Преобразуем в число, если необходимо
numericValueDisturbance = str2num(inputEditdisturbance);
disturbance = numericValueDisturbance;

% Сохраняем значение в структуре handles
handles.savedValueDisturbance = numericValueDisturbance;

% Обновляем handles
guidata(hObject, handles);

% Обновляем текст в текстовом поле
set(handles.editDisturbance, 'String', num2str(handles.savedValueDisturbance));


% --- Executes during object creation, after setting all properties.
function editDisturbance_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonBackSettings.
function buttonBackSettings_Callback(hObject, eventdata, handles)

% Вызов функции закрытия окна
closeWindow(figureExtendedSettings)


function closeWindow(figureExtendedSettings)

% Закрыть окно
close(figureExtendedSettings);

