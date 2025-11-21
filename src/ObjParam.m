function varargout = ObjParam(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ObjParam_OpeningFcn, ...
                   'gui_OutputFcn',  @ObjParam_OutputFcn, ...
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


% --- Executes just before ObjParam is made visible.
function ObjParam_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for ObjParam
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ObjParam_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;


function NumeratorEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function NumeratorEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DenominatorEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function DenominatorEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TauEdit_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function TauEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)

% Вызов функции сохранения параметров
saveParameters(ObjParam, handles)


function saveParameters(ObjParam, handles)

global buttonName;
global params;

% Получение значений из полей
numerator = str2double(get(findobj(ObjParam, 'Tag', 'NumeratorEdit'), 'String'));
denominator = str2mat(get(findobj(ObjParam, 'Tag', 'DenominatorEdit'), 'String'));
delay = str2double(get(findobj(ObjParam, 'Tag', 'TauEdit'), 'String'));

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
close(ObjParam);

% Вывод для проверки
disp(['Значения для ', buttonName, ':']);
disp(['Нумератор: ', num2str(numerator)]);
disp(['Деноминатор: ', num2str(denominator)]);
disp(['Запаздывание: ', num2str(delay)]);


% --- Executes on button press in buttonCloseWindow.
function buttonCloseWindow_Callback(hObject, eventdata, handles)

% Вызов функции закрытия окна
closeWindowWithoutSaving(ObjParam)

function closeWindowWithoutSaving(ObjParam)

% Закрыть окно без сохранения
close(ObjParam);
