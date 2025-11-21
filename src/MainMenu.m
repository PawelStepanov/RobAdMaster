function varargout = MainMenu(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @MainMenu_OutputFcn, ...
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


% --- Executes just before MainMenu is made visible.
function MainMenu_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = MainMenu_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in pushbuttonObjContr.
function pushbuttonObjContr_Callback(hObject, eventdata, handles)

% Вызова окна параметров ОУ
ObjControlFig;


% --- Executes on button press in buttonZona.
function buttonZona_Callback(hObject, eventdata, handles)

global params
global K

fields = fieldnames(params);
if length(fields) == 4
    % Параметры статических коэффициентов
    K = [params.h11.numerator params.h12.numerator; params.h21.numerator params.h22.numerator];
elseif length(fields) == 9
    K = [params.h11.numerator params.h12.numerator params.h13.numerator; params.h21.numerator ... 
        params.h22.numerator params.h23.numerator; params.h31.numerator params.h32.numerator params.h33.numerator];
end

% Вызываем окно для расчета зоны неопределенности 
Zona(hObject, eventdata, handles);


function TmodEdit_Callback(hObject, eventdata, handles)

% Сохраняем значение из поля ввода
inputText = get(hObject, 'String');
handles.inputValue1 = str2double(inputText);

% Обновляем handles
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function TmodEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ZonaUncertText_Callback(hObject, eventdata, handles)

% Сохраняем значение из поля ввода
inputText = get(hObject, 'String');
handles.inputValue2 = str2double(inputText);

% Обновляем handles
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ZonaUncertText_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in criterionPopupMenu.
function criterionPopupMenu_Callback(hObject, eventdata, handles)

global a

% Получение выбранного значения из pop-up menu
contents = cellstr(get(hObject, 'String')); % Все варианты
selectedOption = contents{get(hObject, 'value')}; % Выбранный вариант
   
% Определение параметра альфа в зависимости от критерия качества управления
switch selectedOption
    case 'ИКК'
        a = 0.739;
    case 'ИМК'
        a = 0.589;
    case 'Быстродействие'
        a = 0.507;
    otherwise
        a = 0;
        
handles.inputValue3 = a;

% Обновляем handles
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function criterionPopupMenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonSaveSettings.
function buttonSaveSettings_Callback(hObject, eventdata, handles)

global Tmod
global a

% Получаем значение из текстового поля TmodEdit
inputTmod = get(handles.TmodEdit, 'String');

% Преобразуем в число, если необходимо
numericValueTmod = str2double(inputTmod);
Tmod = numericValueTmod;

% Сохраняем значение в структуре handles
handles.savedValue1 = numericValueTmod;
handles.savedValue3 = a;

% Обновляем handles
guidata(hObject, handles);

% Обновляем текст в текстовом поле
set(handles.TmodEdit, 'String', num2str(handles.savedValue1));


% --- Executes on button press in buttonExtendedSettings.
function buttonExtendedSettings_Callback(hObject, eventdata, handles)

% Вызов окна расширенных настроек 
figureExtendedSettings;

% --- Executes on button press in buttonNominalReg.
function buttonNominalReg_Callback(hObject, eventdata, handles)

global ou11
global ou12
global ou13
global ou21
global ou22
global ou23
global ou31
global ou32
global ou33
global name_windown
global flag_size

% Получение всех полей структуры params вызовом функции ParametersControlObject
[ou] = ParametersControlObject;

% Присвоение переменных объектов управления (по необходимости)
if length(ou) == 4
    ou11 = ou{1};
    ou12 = ou{2};
    ou21 = ou{3};
    ou22 = ou{4};
    name_windown = 'Расчет номинального регулятора 2x2';
    % Вызываем окно для расчета номинального2х2 регулятора
    NominalReg(hObject, eventdata, handles)
elseif length(ou) == 9
    ou11 = ou{1};
    ou12 = ou{2};
    ou13 = ou{3};
    ou21 = ou{4};
    ou22 = ou{5};
    ou23 = ou{6};
    ou31 = ou{7};
    ou32 = ou{8};
    ou33 = ou{9};
    name_windown = 'Расчет номинального регулятора 3x3';
    flag_size = 3;
    % Вызываем окно для расчета номинального3х3 регулятора
    NominalReg(hObject, eventdata, handles)
else
    ou11 = ou{1};
    
    % Вызываем окно для расчета номинального1х1 регулятора
    NominalReg1x1(hObject, eventdata, handles)
end

% --- Executes on button press in buttonRobReg.
function buttonRobReg_Callback(hObject, eventdata, handles)

global ou11
global ou12
global ou13
global ou21
global ou22
global ou23
global ou31
global ou32
global ou33
global name_windown
global flag_size

% Получение всех полей структуры params вызовом функции ParametersControlObject
[ou] = ParametersControlObject;

% Присвоение переменных объектов управления (по необходимости)
if length(ou) == 4
    ou11 = ou{1};
    ou12 = ou{2};
    ou21 = ou{3};
    ou22 = ou{4};
    name_windown = 'Расчет робастного регулятора 2x2';
    % Вызываем окно для расчета робастного многомерного регулятора
    RobReg(hObject, eventdata, handles)
elseif length(ou) == 9
    ou11 = ou{1};
    ou12 = ou{2};
    ou13 = ou{3};
    ou21 = ou{4};
    ou22 = ou{5};
    ou23 = ou{6};
    ou31 = ou{7};
    ou32 = ou{8};
    ou33 = ou{9};
    name_windown = 'Расчет робастного регулятора 3x3';
    flag_size = 3;
    % Вызываем окно для расчета робастного многомерного регулятора
    RobReg(hObject, eventdata, handles)
else
    ou11 = ou{1};    
    % Вызываем окно для расчета робастного одномерного регулятора
    RobReg1x1(hObject, eventdata, handles)
    
end


% --- Executes on button press in buttonRobAdaptReg.
function buttonRobAdaptReg_Callback(hObject, eventdata, handles)

global ou11
global ou12
global ou13
global ou21
global ou22
global ou23
global ou31
global ou32
global ou33
global name_windown
global flag_size

% Получение всех полей структуры params вызовом функции ParametersControlObject
[ou] = ParametersControlObject;

if length(ou) == 4
    
    % Присвоение переменных объектов управления (по необходимости)
    ou11 = ou{1};
    ou12 = ou{2};
    ou21 = ou{3};
    ou22 = ou{4};
    name_windown = 'Расчет робастно-адаптивного регулятора 2x2';
    % Вызываем окно для расчета многомерного робастно-адаптивного регулятора
    RobAdReg(hObject, eventdata, handles)
elseif length(ou) == 9
    ou11 = ou{1};
    ou12 = ou{2};
    ou13 = ou{3};
    ou21 = ou{4};
    ou22 = ou{5};
    ou23 = ou{6};
    ou31 = ou{7};
    ou32 = ou{8};
    ou33 = ou{9};
    name_windown = 'Расчет робастно-адаптивного регулятора 3x3';
    flag_size = 3;
    % Вызываем окно для расчета многомерного робастно-адаптивного регулятора
    RobAdReg(hObject, eventdata, handles)
else
    ou11 = ou{1};
    
    % Вызываем окно для расчета одномерного робастно-адаптивного регулятора
    RobAdReg1x1(hObject, eventdata, handles)
end

% --------------------------------------------------------------------
function develop_Callback(hObject, eventdata, handles)

open('About.fig');


% --------------------------------------------------------------------
function about_Callback(hObject, eventdata, handles)

msgbox('Документация в разработке','Справка','modal');

