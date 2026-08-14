%% 02_senal_amortiguada.m
% Tarea 2 - Comunicaciones (INTEC)
% Ejercicio: senal senoidal amortiguada
%
% X(t) = e^{-0.1 t} * sen(0.6666 t)
%
% Instrucciones del enunciado: graficar con eje x (tiempo) mostrado de
% 0 a 35 s, eje y limitado a [-1, 1], usando como vector de simulacion
% t = 0:0.1:30 (el eje se dibuja hasta 35 s aunque los datos terminen en
% 30 s, dejando margen visual). Se incluyen titulo con el nombre de la
% senal y unidades en cada eje segun se pide.
%
% Salida: results\images\02_senal_amortiguada.pdf + sidecar .txt

close all;
clear;
clc;
set(0, 'DefaultFigureVisible', 'off');

carpeta_base = fileparts(mfilename('fullpath'));
carpeta_img  = fullfile(carpeta_base, 'results', 'images');
if ~exist(carpeta_img, 'dir'); mkdir(carpeta_img); end

% Vector de tiempo de simulacion segun enunciado: 0:0.1:30
t = 0:0.1:30;
X = exp(-0.1*t) .* sin(0.6666*t);

fig = figure('Name', '02_senal_amortiguada', 'Visible', 'off', 'Position', [100 100 900 500]);
plot(t, X, 'Color', [0 0.447 0.741], 'LineWidth', 1.5);
grid on;
xlim([0 35]);
ylim([-1 1]);
title('Senal senoidal amortiguada: X(t) = e^{-0.1t} sen(0.6666t)');
xlabel('Tiempo (s)');
ylabel('Amplitud (V)');
legend('X(t)', 'Location', 'northeast');

exportar_figura(fig, fullfile(carpeta_img, '02_senal_amortiguada.pdf'), ...
    'Senal senoidal amortiguada X(t) = e^{-0.1t} sen(0.6666t)', ...
    ['Senal exponencial amortiguada: una senoidal de frecuencia angular 0.6666 rad/s ' ...
     'multiplicada por una envolvente exponencial decreciente e^{-0.1t}. Representa el ' ...
     'comportamiento tipico de un sistema de segundo orden subamortiguado (por ejemplo, ' ...
     'la respuesta transitoria de un circuito RLC o de un sistema mecanico-electrico ' ...
     'amortiguado). Vector de simulacion t=0:0.1:30 s; eje de tiempo dibujado hasta ' ...
     '35 s y eje de amplitud fijado a [-1, 1] segun el enunciado.'], ...
    ['Expresion MATLAB: X = exp(-0.1*t).*sin(0.6666*t), t = 0:0.1:30. ' ...
     'xlim([0 35]), ylim([-1 1]) fijados explicitamente. La envolvente decae a ' ...
     'aproximadamente e^{-3}=0.0498 en t=30 s, por lo que la amplitud es casi nula ' ...
     'hacia el final del rango graficado.']);

fprintf('Ejercicio 2 completado. Figura generada en:\n  %s\n', carpeta_img);
