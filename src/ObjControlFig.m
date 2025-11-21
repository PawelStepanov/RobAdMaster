function varargout = ObjControlFig(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ObjControlFig_OpeningFcn, ...
                   'gui_OutputFcn',  @ObjControlFig_OutputFcn, ...
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


% --- Executes just before ObjControlFig is made visible.
function ObjControlFig_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ObjControlFig_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)

global rows
global cols
% Получение выбранного значения из pop-up menu
contents = cellstr(get(hObject, 'String')); % Все варианты
selectedOption = contents{get(hObject, 'Value')}; %Выбранный вариант

% Очистка предыдущих полей ввода
delete(findall(handles.uipanel1, 'Style', 'pushbutton'));
    
% Определение размера матрица в зависимости от выбора
switch selectedOption
    case '1x1'
        rows = 1;
        cols = 1;
    case '2x2'
        rows = 2;
        cols = 2;
    case '3x3'
        rows = 3;
        cols = 3;
    otherwise
        rows = 0;
        cols = 0;
end

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
        uicontrol('Parent', handles.uipanel1, 'Style', 'pushbutton', ...
            'String', buttonName, ...
            'Position', [startX + (j-1)*spacing, startY - (i-1)*spacing, width, height], ...
            'Callback', @(src,event) openWindowObjParam(hObject, eventdata, handles, buttonName), ...
            'Tag', buttonName);
    end
end

guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Функция, открывающая новое окно при нажатии на кнопку
function openWindowObjParam(hObject, eventdata, handles, buttonName)

% Открытие нового окна
ObjectParameters(hObject, eventdata, handles, buttonName);


% --- Executes on button press in buttonBack.
function buttonBack_Callback(hObject, eventdata, handles)

% Вызов функции закрытия окна
closeWindow(ObjControlFig)


function closeWindow(ObjControlFig)


% Закрыть окно
close(ObjControlFig);
