%% 01_senales_analogas.m
% Tarea 2 - Comunicaciones (INTEC)
% Ejercicio: "Graficas senales analogas"
%
% Objetivo: graficar 12 senales indicadas en la guia de la tarea,
% discretizarlas (stem) y hallar su Transformada de Fourier (FFT) para
% observar el espectro de magnitud (y fase quando aplique). Cada senal
% (items 1-9, 11, 12) se presenta en una figura con 4 subgraficas:
%   (1) senal continua (plot)
%   (2) version discretizada (stem)
%   (3) espectro de magnitud (fft + fftshift)
%   (4) espectro de fase o zoom del espectro (segun convenga)
% El item 10 es una secuencia discreta pura (no continua), por lo que se
% muestra unicamente con stem + FFT de la secuencia. El item 12 es un
% caso especial de "movimientoarmonicos1" con 3 subgraficas (Y1, Y2, Z).
%
% Requisitos cumplidos: uso de plot, subplot, stem y fft/fftshift (la
% "Fourier" pedida en el enunciado se implementa con la FFT de MATLAB,
% no con una funcion literalmente llamada Fourier).
%
% Todas las figuras se exportan como PDF vectorial a
% results\images\01_item##_*.pdf con su sidecar .txt de descripcion
% (ver exportar_figura.m). Al final se escribe un archivo de notas con
% las interpretaciones/supuestos usados para los items ambiguos.

close all;
clear;
clc;
set(0, 'DefaultFigureVisible', 'off');

carpeta_base = fileparts(mfilename('fullpath'));
carpeta_img  = fullfile(carpeta_base, 'results', 'images');
carpeta_res  = fullfile(carpeta_base, 'results');
if ~exist(carpeta_img, 'dir'); mkdir(carpeta_img); end
if ~exist(carpeta_res, 'dir'); mkdir(carpeta_res); end

% Vector de tiempo base indicado en el enunciado
t = 0:0.001:2;
Fs = 1/0.001;           % frecuencia de muestreo equivalente (1000 Hz)
N  = length(t);
f_eje = (-N/2:N/2-1) * (Fs/N);   % eje de frecuencias para fftshift

notas = {}; % acumulador de notas/supuestos para el archivo de resumen

%% Item 1: 1 - sen(2*X*t), X = 2  (interpretacion: "1 menos sen(2*x*t)")
% Interpretacion: el enunciado "1-sen(2xt); X=2" se lee como
% "1 - sen(2*x*t)" (uno menos la funcion seno), con la constante X
% multiplicando el argumento del seno (no la amplitud del seno), ya que
% la notacion "2xt" agrupa el factor 2, la constante X y la variable t
% como argumento completo. Se documenta este supuesto por su ambiguedad.
X1 = 2;
x1 = 1 - sin(2*X1*t);
fig = graficar_4paneles(t, x1, '01_item01_uno_menos_sen', ...
    'x_1(t) = 1 - sen(2 X t), X=2', [0 0.447 0.741], 'fase');
exportar_figura(fig, fullfile(carpeta_img, '01_item01_uno_menos_sen.pdf'), ...
    'Item 1: x1(t) = 1 - sen(2*X*t), X=2', ...
    ['Senal x1(t) = 1 - sin(2*2*t) evaluada en t = 0:0.001:2 s. Se muestran ' ...
     '4 paneles: senal continua, version discretizada (stem), magnitud del ' ...
     'espectro (FFT) y fase del espectro.'], ...
    ['Expresion MATLAB: x1 = 1 - sin(2*X1*t), con X1 = 2. Interpretacion: ' ...
     'el "1-" del enunciado es el termino constante (1 menos la funcion seno), ' ...
     'y X multiplica el argumento del seno (2*X*t), no la amplitud.']);
notas{end+1} = sprintf(['Item 1: x1(t) = 1 - sin(2*X*t), X=2 -> MATLAB: x1 = 1 - sin(2*X1*t). ' ...
    'Supuesto: "1-sen(2xt)" se interpreto como "1 menos sen(2*x*t)" (resta de un ' ...
    'valor constante 1 y la funcion seno), con X multiplicando el argumento (2*X*t).']);

%% Item 2: Sa(2*X*t), X = 2.4  (funcion de muestreo Sa(u) = sin(u)/u)
% MATLAB sinc(u) = sin(pi*u)/(pi*u) (normalizado), mientras que la
% funcion de muestreo clasica Sa(u) = sin(u)/u no tiene el factor pi.
% Para obtener Sa(2*X*t) usando sinc de MATLAB se hace el cambio de
% variable u = 2*X*t y se evalua sinc(u/pi), ya que
% sinc(u/pi) = sin(pi*(u/pi))/(pi*(u/pi)) = sin(u)/u = Sa(u).
X2 = 2.4;
u2 = 2*X2*t;
x2 = sinc(u2/pi);
fig = graficar_4paneles(t, x2, '01_item02_Sa', ...
    'x_2(t) = Sa(2 X t), X=2.4', [0.85 0.325 0.098], 'zoom');
exportar_figura(fig, fullfile(carpeta_img, '01_item02_Sa.pdf'), ...
    'Item 2: x2(t) = Sa(2*X*t), X=2.4 (funcion de muestreo)', ...
    ['Funcion de muestreo (Sa, sinc no normalizada) Sa(2*X*t) con X=2.4, ' ...
     'evaluada en t = 0:0.001:2 s. Paneles: senal continua, stem, magnitud FFT ' ...
     'y zoom del espectro en bajas frecuencias.'], ...
    ['Expresion MATLAB: x2 = sinc(2*X2*t/pi), X2=2.4. Nota: sinc de MATLAB esta ' ...
     'normalizada (sinc(u)=sin(pi u)/(pi u)); se divide el argumento entre pi para ' ...
     'recuperar la funcion de muestreo clasica Sa(u) = sin(u)/u.']);
notas{end+1} = sprintf(['Item 2: x2(t) = Sa(2*X*t), X=2.4 -> MATLAB: x2 = sinc(2*X2*t/pi). ' ...
    'Supuesto: se uso sinc() normalizada de MATLAB (sinc(u)=sin(pi u)/(pi u)) y se ' ...
    'ajusto el argumento dividiendo entre pi para obtener Sa(u)=sin(u)/u.']);

%% Item 3: Real(e^{-j X t}), X = 3
X3 = 3;
x3 = real(X3*exp(-1j*t));  % = X3*cos(t)
fig = graficar_4paneles(t, x3, '01_item03_real_exp', ...
    'x_3(t) = Real(X e^{-jt}), X=3', [0.929 0.694 0.125], 'fase');
exportar_figura(fig, fullfile(carpeta_img, '01_item03_real_exp.pdf'), ...
    'Item 3: x3(t) = Real(X*e^{-jt}), X=3', ...
    ['Parte real de la exponencial compleja X*e^{-jt}, equivalente a X*cos(t), ' ...
     'con X=3, evaluada en t=0:0.001:2 s.'], ...
    'Expresion MATLAB: x3 = real(X3*exp(-1j*t)), X3=3. Resultado algebraico: x3(t)=3*cos(t).');

%% Item 4: Imag(e^{-j X t}), X = 3
X4 = 3;
x4 = imag(X4*exp(-1j*t));  % = -X4*sin(t)
fig = graficar_4paneles(t, x4, '01_item04_imag_exp', ...
    'x_4(t) = Imag(X e^{-jt}), X=3', [0.494 0.184 0.556], 'fase');
exportar_figura(fig, fullfile(carpeta_img, '01_item04_imag_exp.pdf'), ...
    'Item 4: x4(t) = Imag(X*e^{-jt}), X=3', ...
    ['Parte imaginaria de la exponencial compleja X*e^{-jt}, equivalente a ' ...
     '-X*sen(t), con X=3, evaluada en t=0:0.001:2 s.'], ...
    'Expresion MATLAB: x4 = imag(X4*exp(-1j*t)), X4=3. Resultado algebraico: x4(t)=-3*sin(t).');

%% Item 5: escalon unitario u(t)
% Se muestra tanto sobre el vector base t (>=0, solo se ve el valor 1)
% como sobre un vector simetrico -1:0.001:1 para apreciar el salto.
t_u = -1:0.001:1;
u_t = double(t_u > 0);   % logica: 0 para t<0, 1 para t>0 (u(0) no definido -> se deja 0)
fig = figure('Name', '01_item05_escalon', 'Visible', 'off', 'Position', [100 100 900 700]);
subplot(2,2,1);
plot(t_u, u_t, 'Color', [0.466 0.674 0.188], 'LineWidth', 1.4);
grid on; ylim([-0.2 1.2]);
title('Escalon unitario u(t) en t = -1:0.001:1');
xlabel('Tiempo (s)'); ylabel('Amplitud');

subplot(2,2,2);
paso = 20;
stem(t_u(1:paso:end), u_t(1:paso:end), 'Color', [0.466 0.674 0.188], 'MarkerFaceColor', [0.466 0.674 0.188]);
grid on; ylim([-0.2 1.2]);
title('u(t) discretizado (stem)');
xlabel('Tiempo (s)'); ylabel('Amplitud');

subplot(2,2,3);
u_base = double(t > 0); % version sobre el vector de tiempo base del ejercicio (t>=0)
plot(t, u_base, 'Color', [0.301 0.745 0.933], 'LineWidth', 1.4);
grid on; ylim([-0.2 1.2]);
title('u(t) sobre t = 0:0.001:2 (rango base del ejercicio)');
xlabel('Tiempo (s)'); ylabel('Amplitud');

subplot(2,2,4);
Nu = length(t_u);
Fsu = 1/(t_u(2)-t_u(1));
Uf = fftshift(fft(u_t));
fu = (-Nu/2:Nu/2-1)*(Fsu/Nu);
plot(fu, abs(Uf)/Nu, 'Color', [0.635 0.078 0.184], 'LineWidth', 1.1);
grid on;
title('Espectro de magnitud (FFT) de u(t)');
xlabel('Frecuencia (Hz)'); ylabel('|U(f)| (normalizado)');
sgtitle('Item 5: escalon unitario u(t)', 'FontWeight', 'bold');
exportar_figura(fig, fullfile(carpeta_img, '01_item05_escalon.pdf'), ...
    'Item 5: escalon unitario u(t)', ...
    ['Funcion escalon unitario u(t) = 0 para t<0, 1 para t>0, implementada con ' ...
     'indexado logico (t>0). Se muestra sobre un rango simetrico -1:0.001:1 s para ' ...
     'apreciar el salto, sobre el rango base 0:0.001:2 s del ejercicio, su version ' ...
     'discretizada (stem) y su espectro de magnitud (FFT).'], ...
    'Expresion MATLAB: u_t = double(t_u > 0). u(0) se definio como 0 por convencion de indexado estricto (t>0).');

%% Item 6: tren de pulsos cuadrados +-5 V, periodo 1 s
periodo6 = 1; % s
x6 = 5*square(2*pi*(1/periodo6)*t);
fig = graficar_4paneles(t, x6, '01_item06_cuadrada', ...
    'Tren de pulsos cuadrados +-5 V, T=1 s', [0.85 0.098 0.325], 'fase');
exportar_figura(fig, fullfile(carpeta_img, '01_item06_cuadrada.pdf'), ...
    'Item 6: tren de pulsos cuadrados +5/-5 V, periodo 1 s', ...
    ['Onda cuadrada que alterna entre +5 V y -5 V con periodo de 1 s, generada con ' ...
     'la funcion square() del Signal Processing Toolbox escalada a 5 V, evaluada en ' ...
     't=0:0.001:2 s (2 ciclos completos).'], ...
    'Expresion MATLAB: x6 = 5*square(2*pi*(1/1)*t). Frecuencia fundamental = 1 Hz.');

%% Item 7: -5*sen(5*t).*exp(3.5*t), X mencionado como 2j (ver nota de ambiguedad)
% El enunciado indica X=2j para este item, pero la formula dada ya es
% real-valuada tal como se escribe (-5 sen(5t) e^{3.5t}); no hay un
% "hueco" claro donde insertar X sin alterar la naturaleza real de la
% senal ni contradecir el resto de la formula. Se opta por no aplicar
% una escala compleja (que produciria una senal compleja fuera del
% patron de las demas figuras reales) y en su lugar se grafica la
% expresion tal cual, indicando expresamente la ambiguedad en el
% comentario y en las notas. Es una senal que crece exponencialmente
% (modulada por exp(3.5 t)); esto es intencional segun el enunciado.
x7 = -5*sin(5*t).*exp(3.5*t);
fig = graficar_4paneles(t, x7, '01_item07_exp_creciente', ...
    'x_7(t) = -5 sen(5t) e^{3.5t}', [0.098 0.325 0.85], 'zoom');
exportar_figura(fig, fullfile(carpeta_img, '01_item07_exp_creciente.pdf'), ...
    'Item 7: x7(t) = -5*sin(5t)*exp(3.5t)', ...
    ['Seno modulado por una exponencial creciente exp(3.5t), lo que produce una ' ...
     'senal de amplitud creciente en el rango t=0:0.001:2 s. Se grafica senal ' ...
     'continua, stem, magnitud FFT (zoom en bajas frecuencias por el ensanchamiento ' ...
     'espectral causado por el crecimiento exponencial).'], ...
    ['Expresion MATLAB: x7 = -5*sin(5*t).*exp(3.5*t). Ambiguedad: el enunciado indica ' ...
     '"X=2j" para este item, pero la formula dada ya es real y no deja un lugar claro ' ...
     'donde insertar una escala compleja sin contradecir la expresion. Se decidio NO ' ...
     'aplicar X y graficar la expresion literal, documentando esta ambiguedad.']);
notas{end+1} = sprintf(['Item 7: -5*sen(5t)*e^{3.5t}, X=2j (enunciado) -> se grafico la formula ' ...
    'literal sin aplicar X, pues la formula ya es real-valuada y no hay una posicion ' ...
    'natural para insertar una escala compleja sin contradecir la expresion dada. ' ...
    'Ambiguedad documentada.']);

%% Item 8: abs(cos(2*t) .* exp(-j*t)), X = 1.5
X8 = 1.5;
x8 = X8*abs(cos(2*t).*exp(-1j*t));
fig = graficar_4paneles(t, x8, '01_item08_abs_cos_exp', ...
    'x_8(t) = X |cos(2t) e^{-jt}|, X=1.5', [0.466 0.674 0.188], 'fase');
exportar_figura(fig, fullfile(carpeta_img, '01_item08_abs_cos_exp.pdf'), ...
    'Item 8: x8(t) = X*abs(cos(2t)*e^{-jt}), X=1.5', ...
    ['Magnitud del producto entre cos(2t) y la exponencial compleja e^{-jt}, escalada ' ...
     'por X=1.5. Como |e^{-jt}|=1 para todo t real, el resultado equivale a X*|cos(2t)|. ' ...
     'Evaluada en t=0:0.001:2 s.'], ...
    'Expresion MATLAB: x8 = X8*abs(cos(2*t).*exp(-1j*t)), X8=1.5.');

%% Item 9: sen(2*t)/(2*t), con limite en t=0 (L'Hopital -> 1)
u9 = 2*t;
x9 = zeros(size(t));
idx0 = (u9 == 0);
x9(~idx0) = sin(u9(~idx0)) ./ u9(~idx0);
x9(idx0) = 1; % limite por L'Hopital: lim_{u->0} sen(u)/u = 1
fig = graficar_4paneles(t, x9, '01_item09_sinc_manual', ...
    'x_9(t) = sen(2t)/(2t)', [0.635 0.078 0.184], 'zoom');
exportar_figura(fig, fullfile(carpeta_img, '01_item09_sinc_manual.pdf'), ...
    'Item 9: x9(t) = sin(2t)/(2t)', ...
    ['Funcion tipo sinc sen(2t)/(2t), con el valor en t=0 fijado en 1 mediante el ' ...
     'limite de L''Hopital (evita division 0/0). Evaluada en t=0:0.001:2 s.'], ...
    ['Expresion MATLAB: x9 = sin(2*t)./(2*t), con correccion explicita x9(t=0)=1. ' ...
     'Nota: no se uso sinc() de MATLAB directamente para dejar explicito el manejo ' ...
     'del limite pedido en el enunciado ("Sen(2xt)/2xt").']);
notas{end+1} = sprintf(['Item 9: x9(t) = sin(2t)/(2t) -> MATLAB: x9 = sin(2*t)./(2*t) con ' ...
    'x9(0)=1 por limite de L''Hopital (evita 0/0). No se aplico ninguna constante X ' ...
    'adicional pues el enunciado no especifica una para este item.']);

%% Item 10: secuencia discreta x[n] = {1 en n=1, 2 en n=0, 0 en otro caso}
n10 = -3:3;
x10 = zeros(size(n10));
x10(n10 == 0) = 2;
x10(n10 == 1) = 1;

fig = figure('Name', '01_item10_secuencia', 'Visible', 'off', 'Position', [100 100 900 500]);
subplot(1,2,1);
stem(n10, x10, 'filled', 'Color', [0 0.447 0.741], 'LineWidth', 1.2);
grid on;
title('Secuencia discreta x[n]');
xlabel('n (muestra)'); ylabel('Amplitud');
xlim([-3.5 3.5]); ylim([-0.5 2.5]);

subplot(1,2,2);
Nfft10 = 64; % zero-padding para una FFT con mejor resolucion visual
X10 = fftshift(fft(x10, Nfft10));
f10 = (-Nfft10/2:Nfft10/2-1)/Nfft10; % frecuencia normalizada (ciclos/muestra)
plot(f10, abs(X10), 'Color', [0.85 0.325 0.098], 'LineWidth', 1.2);
grid on;
title('FFT de x[n] (zero-padded a 64 puntos)');
xlabel('Frecuencia normalizada (ciclos/muestra)'); ylabel('|X(f)|');
sgtitle('Item 10: secuencia discreta x[n]={1 en n=1, 2 en n=0}', 'FontWeight', 'bold');
exportar_figura(fig, fullfile(carpeta_img, '01_item10_secuencia.pdf'), ...
    'Item 10: secuencia discreta x[n] = {2 en n=0, 1 en n=1, 0 resto}', ...
    ['Secuencia discreta definida por partes (no es una senal de tiempo continuo), ' ...
     'graficada con stem sobre n=-3:3, y su FFT con zero-padding a 64 puntos para ' ...
     'visualizar el espectro con mejor resolucion.'], ...
    'Expresion MATLAB: x10(n=0)=2, x10(n=1)=1, resto 0. FFT calculada con fft(x10,64).');
notas{end+1} = ['Item 10: secuencia discreta x[n] (n=1->1, n=0->2, resto 0). Se trata como ' ...
    'secuencia de tiempo discreto pura (no continua): se omiten los paneles de plot ' ...
    'continuo y se muestran solo stem + FFT con zero-padding (64 puntos).'];

%% Item 11: onda diente de sierra (sawtooth), duracion 15 s
t11 = 0:0.001:15;
x11 = sawtooth(2*pi*1*t11); % 1 Hz por defecto, periodo 1 s, usando sawtooth()
fig = graficar_4paneles(t11, x11, '01_item11_sawtooth', ...
    'Onda diente de sierra (sawtooth), 15 s', [0.929 0.694 0.125], 'zoom');
exportar_figura(fig, fullfile(carpeta_img, '01_item11_sawtooth.pdf'), ...
    'Item 11: onda diente de sierra (sawtooth), duracion 15 s', ...
    ['Onda diente de sierra generada con la funcion sawtooth() de MATLAB, frecuencia ' ...
     '1 Hz, evaluada en un vector de tiempo propio t=0:0.001:15 s (15 segundos de ' ...
     'duracion) tal como pide el enunciado.'], ...
    'Expresion MATLAB: x11 = sawtooth(2*pi*1*t11), t11 = 0:0.001:15.');
notas{end+1} = ['Item 11: se uso sawtooth(2*pi*f*t) con f=1 Hz (no especificada en el ' ...
    'enunciado, solo la duracion de 15 s); se documenta la frecuencia elegida como supuesto.'];

%% Item 12: suma de dos senoides (movimientoarmonicos1)
% Y1 = A*sen(5*omega*t); Y2 = 1.2*A*sen(4*omega*t); Z = Y1+Y2
% omega = 2*pi*f, f = 100 Hz, t = 0:0.001:1.5
% Supuesto: el enunciado no fija el valor de A explicitamente; se asume
% A = 1 (amplitud unitaria de referencia), documentado aqui y en el
% archivo de notas.
A12 = 1;
f12 = 100;
omega12 = 2*pi*f12;
t12 = 0:0.001:1.5;
Y1 = A12*sin(5*omega12*t12);
Y2 = 1.2*A12*sin(4*omega12*t12);
Z  = Y1 + Y2;

fig = figure('Name', '01_item12_movimientoarmonicos1', 'Visible', 'off', 'Position', [100 100 900 800]);
subplot(3,1,1);
plot(t12, Y1, 'Color', [0 0.447 0.741], 'LineWidth', 1.1);
grid on;
title('Y_1 = A sen(5 \omega t), A=1, f=100 Hz');
xlabel('Tiempo (s)'); ylabel('Amplitud');

subplot(3,1,2);
plot(t12, Y2, 'Color', [0.85 0.325 0.098], 'LineWidth', 1.1);
grid on;
title('Y_2 = 1.2 A sen(4 \omega t), A=1, f=100 Hz');
xlabel('Tiempo (s)'); ylabel('Amplitud');

subplot(3,1,3);
plot(t12, Z, 'Color', [0.494 0.184 0.556], 'LineWidth', 1.1);
grid on;
title('Z = Y_1 + Y_2 (movimientoarmonicos1)');
xlabel('Tiempo (s)'); ylabel('Amplitud');

sgtitle('Item 12: suma de dos senoidales de distinta frecuencia y amplitud (movimientoarmonicos1)', 'FontWeight', 'bold');
exportar_figura(fig, fullfile(carpeta_img, '01_item12_movimientoarmonicos1.pdf'), ...
    'Item 12: movimientoarmonicos1 - Y1, Y2 y Z=Y1+Y2', ...
    ['Dos senoidales de distinta frecuencia y amplitud: Y1=A*sen(5*omega*t) y ' ...
     'Y2=1.2*A*sen(4*omega*t), con omega=2*pi*f, f=100 Hz, A=1, graficadas cada una ' ...
     'en su propio panel junto con la senal resultante Z=Y1+Y2, sobre t=0:0.001:1.5 s. ' ...
     'Corresponde al "movimientoarmonicos1" del enunciado.'], ...
    ['Expresion MATLAB: Y1=A*sin(5*omega*t), Y2=1.2*A*sin(4*omega*t), Z=Y1+Y2, ' ...
     'omega=2*pi*f, f=100, A=1 (supuesto, no especificado en el enunciado).']);
notas{end+1} = ['Item 12: A no esta especificada en el enunciado; se asumio A=1 como ' ...
    'amplitud de referencia. f=100 Hz y omega=2*pi*f segun se indica.'];

%% Archivo de notas/resumen con expresiones e interpretaciones
ruta_notas = fullfile(carpeta_res, '01_senales_analogas_notas.txt');
fid = fopen(ruta_notas, 'w');
fprintf(fid, 'NOTAS Y SUPUESTOS - Ejercicio 1: Graficas senales analogas\r\n');
fprintf(fid, 'Tarea 2 - Comunicaciones (INTEC)\r\n');
fprintf(fid, '===========================================================\r\n\r\n');
fprintf(fid, ['Vector de tiempo base: t = 0:0.001:2 (excepto item 10, discreto en n, ' ...
    'y item 11, que usa t=0:0.001:15 por duracion explicita de 15 s).\r\n\r\n']);
for k = 1:numel(notas)
    fprintf(fid, '%s\r\n\r\n', notas{k});
end
fprintf(fid, ['Items sin ambiguedad relevante (3, 4, 5, 6, 8, 10, 11) se implementaron ' ...
    'de forma directa siguiendo la formula y la constante X dadas en el enunciado.\r\n']);
fclose(fid);

fprintf('Ejercicio 1 completado. Figuras y notas generadas en:\n  %s\n  %s\n', carpeta_img, ruta_notas);

%% Funciones locales (deben ir al final del archivo en un script MATLAB)

function fig = graficar_4paneles(t, x, nombreFig, tituloSenal, colorLinea, modoPanel4)
    % Grafica 4 subplots: senal continua, stem, magnitud FFT y fase/zoom.
    % modoPanel4: 'fase' (fase del espectro) o 'zoom' (zoom del espectro)
    if nargin < 6
        modoPanel4 = 'fase';
    end
    fig = figure('Name', nombreFig, 'Visible', 'off', 'Position', [100 100 900 700]);

    N = length(x);
    Fs = 1/(t(2) - t(1));
    X  = fftshift(fft(x));
    f  = (-N/2:N/2-1) * (Fs/N);

    % Panel 1: senal continua
    subplot(2,2,1);
    plot(t, x, 'Color', colorLinea, 'LineWidth', 1.2);
    grid on;
    title(['Senal continua: ' tituloSenal]);
    xlabel('Tiempo (s)'); ylabel('Amplitud');

    % Panel 2: version discretizada (stem) - se usa un submuestreo para
    % que el stem sea legible (cada 20 muestras aprox.)
    paso = max(1, floor(N/100));
    subplot(2,2,2);
    stem(t(1:paso:end), x(1:paso:end), 'Color', colorLinea, 'MarkerFaceColor', colorLinea);
    grid on;
    title(['Senal discretizada (stem): ' tituloSenal]);
    xlabel('Tiempo (s)'); ylabel('Amplitud');

    % Panel 3: magnitud del espectro (FFT)
    subplot(2,2,3);
    plot(f, abs(X)/N, 'Color', colorLinea, 'LineWidth', 1.1);
    grid on;
    title('Espectro de magnitud (FFT)');
    xlabel('Frecuencia (Hz)'); ylabel('|X(f)| (normalizado)');

    % Panel 4: fase o zoom
    subplot(2,2,4);
    if strcmp(modoPanel4, 'fase')
        plot(f, angle(X), 'Color', colorLinea, 'LineWidth', 1.1);
        grid on;
        title('Espectro de fase (FFT)');
        xlabel('Frecuencia (Hz)'); ylabel('Fase (rad)');
    else
        % zoom en torno a 0 Hz para ver detalle de bajas frecuencias
        idx_zoom = abs(f) <= 10;
        plot(f(idx_zoom), abs(X(idx_zoom))/N, 'Color', colorLinea, 'LineWidth', 1.1);
        grid on;
        title('Espectro de magnitud (zoom, |f|<=10 Hz)');
        xlabel('Frecuencia (Hz)'); ylabel('|X(f)| (normalizado)');
    end

    sgtitle(tituloSenal, 'FontWeight', 'bold');
end
