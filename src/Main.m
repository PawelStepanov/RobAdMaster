clc;
clear all;

global K
global ou11
global ou12
global ou13
global ou21
global ou22
global ou23
global ou31
global ou32
global ou33
global a
global omega
global omega_din
global Tmod
global params
global zona_params
global step_alpha
global step_ro
global extreme_nominal
global disturbance 
global flag_size

extreme_nominal = 0;
step_alpha = 0.1;
step_ro = 0.1;
disturbance = [1 1 1];

% Создание структуры для хранения параметров
params = struct();
zona_params = struct();

% Время моделирования
Tmod = 100;

% Коэффициент 
a = 0.739;

% Зона неопределенности
omega = 0.1;
omega_din = 0.4;

ou11 = {[], [], []};
ou12 = {[], [], []};
ou13 = {[], [], []};
ou21 = {[], [], []};
ou22 = {[], [], []};
ou23 = {[], [], []};
ou31 = {[], [], []};
ou32 = {[], [], []};
ou33 = {[], [], []};
K = [];

flag_size = 0;

MainMenu;