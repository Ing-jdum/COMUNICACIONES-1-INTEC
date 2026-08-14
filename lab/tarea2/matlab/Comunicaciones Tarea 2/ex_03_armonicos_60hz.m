%% 03_armonicos_60hz.m
% Tarea 2 - Comunicaciones (INTEC)
% Ejercicio: senal electrica de 60 Hz con armonicos
%
% Se simula una senal electrica de 120 V a 60 Hz (fundamental) con sus
% armonicos 2do a 6to, segun las amplitudes dadas en el enunciado:
%   y1 = 120*sin(2*pi*f*t)      -> fundamental
%   y2 = 60*sin(2*pi*2*f*t)     -> 2do armonico
%   y3 = 40*sin(2*pi*3*f*t)     -> 3er armonico
%   y4 = 30*sin(2*pi*4*f*t)     -> 4to armonico
%   y5 = 24*sin(2*pi*5*f*t)     -> 5to armonico
%   y6 = 20*sin(2*pi*6*f*t)     -> 6to armonico
%   ysum = y1+y2+y3+y4+y5+y6
%
% Nota sobre "60 segundos funcionando": el enunciado indica que la senal
% electrica real funciona durante 60 segundos continuos; esto describe
% la duracion conceptual de operacion del equipo electrico, no la
% ventana de tiempo que se grafica. Para que las formas de onda a 60-360
% Hz sean legibles en una figura, se usa la ventana de graficado
% t = 0:0.001:0.1 (0.1 s = 6 ciclos de la fundamental), suficiente para
% apreciar la distorsion armonica. El calculo del espectro (FFT) se
% realiza tambien sobre esta ventana.
%
% Salidas (results\images\, con sidecar .txt cada una):
%   03a_armonicos_individuales.pdf - y1..y6 en subplots separados
%   03b_armonicos_superpuestos.pdf - y1..y6 superpuestos con leyenda
%   03c_senal_suma.pdf             - ysum
%   03d_espectro_ysum.pdf          - FFT de ysum (un solo lado, en Hz)
%
% Ademas se escribe results\03_armonicos_60hz_conclusiones.txt con
% conclusiones sobre armonicos en equipos electricos (distorsion, THD).

close all;
clear;
clc;
set(0, 'DefaultFigureVisible', 'off');

carpeta_base = fileparts(mfilename('fullpath'));
carpeta_img  = fullfile(carpeta_base, 'results', 'images');
carpeta_res  = fullfile(carpeta_base, 'results');
if ~exist(carpeta_img, 'dir'); mkdir(carpeta_img); end
if ~exist(carpeta_res, 'dir'); mkdir(carpeta_res); end

f = 60; % Hz, frecuencia fundamental de la red electrica
% Ventana de graficado (ver nota arriba sobre "60 segundos funcionando")
t = 0:0.001:0.1;

y1 = 120*sin(2*pi*f*t);       % fundamental (120 V)
y2 = 60*sin(2*pi*2*f*t);      % 2do armonico
y3 = 40*sin(2*pi*3*f*t);      % 3er armonico
y4 = 30*sin(2*pi*4*f*t);      % 4to armonico
y5 = 24*sin(2*pi*5*f*t);      % 5to armonico
y6 = 20*sin(2*pi*6*f*t);      % 6to armonico
ysum = y1 + y2 + y3 + y4 + y5 + y6;

colores = [0 0.447 0.741; 0.85 0.325 0.098; 0.929 0.694 0.125; ...
           0.494 0.184 0.556; 0.466 0.674 0.188; 0.301 0.745 0.933];
armonicos = {y1, y2, y3, y4, y5, y6};
etiquetas = {'Fundamental (60 Hz, 120 V)', '2do armonico (120 Hz, 60 V)', ...
             '3er armonico (180 Hz, 40 V)', '4to armonico (240 Hz, 30 V)', ...
             '5to armonico (300 Hz, 24 V)', '6to armonico (360 Hz, 20 V)'};

%% Figura 03a: armonicos individuales en subplots separados, colores distintos
fig = figure('Name', '03a_armonicos_individuales', 'Visible', 'off', 'Position', [100 100 950 900]);
for k = 1:6
    subplot(3,2,k);
    plot(t, armonicos{k}, 'Color', colores(k,:), 'LineWidth', 1.2);
    grid on;
    title(etiquetas{k});
    xlabel('Tiempo (s)'); ylabel('Amplitud (V)');
end
sgtitle('Armonicos individuales de una senal electrica de 60 Hz (120 V fundamental)', 'FontWeight', 'bold');
exportar_figura(fig, fullfile(carpeta_img, '03a_armonicos_individuales.pdf'), ...
    'Armonicos individuales (1ro a 6to) de una senal electrica de 60 Hz', ...
    ['Seis subgraficas, una por cada armonico de una senal electrica con fundamental ' ...
     '120 V a 60 Hz: fundamental (60 Hz, 120 V), 2do (120 Hz, 60 V), 3ro (180 Hz, 40 V), ' ...
     '4to (240 Hz, 30 V), 5to (300 Hz, 24 V) y 6to (360 Hz, 20 V), cada uno con color ' ...
     'distinto. Ventana de tiempo graficada: t=0:0.001:0.1 s (6 ciclos de la fundamental).'], ...
    ['Formulas: yk = Ak*sin(2*pi*k*f*t), f=60 Hz, k=1..6, ' ...
     'Ak=[120,60,40,30,24,20] V respectivamente.']);

%% Figura 03b: armonicos superpuestos en un solo eje, con leyenda
fig = figure('Name', '03b_armonicos_superpuestos', 'Visible', 'off', 'Position', [100 100 950 550]);
hold on;
for k = 1:6
    plot(t, armonicos{k}, 'Color', colores(k,:), 'LineWidth', 1.2);
end
hold off;
grid on;
title('Armonicos 1ro a 6to superpuestos (senal electrica de 60 Hz)');
xlabel('Tiempo (s)'); ylabel('Amplitud (V)');
legend(etiquetas, 'Location', 'eastoutside');
exportar_figura(fig, fullfile(carpeta_img, '03b_armonicos_superpuestos.pdf'), ...
    'Armonicos 1ro a 6to superpuestos en un mismo eje', ...
    ['Los seis armonicos (fundamental a 6to) superpuestos en un mismo grafico, cada ' ...
     'uno con color distinto identificado en la leyenda, para comparar visualmente sus ' ...
     'amplitudes y frecuencias relativas. Ventana: t=0:0.001:0.1 s.'], ...
    'Mismas formulas que en 03a. Amplitudes decrecientes: 120,60,40,30,24,20 V.');

%% Figura 03c: senal suma (resultante distorsionada)
fig = figure('Name', '03c_senal_suma', 'Visible', 'off', 'Position', [100 100 950 500]);
plot(t, ysum, 'Color', [0.635 0.078 0.184], 'LineWidth', 1.4);
grid on;
title('Senal resultante: suma de fundamental + armonicos 2do a 6to (ysum)');
xlabel('Tiempo (s)'); ylabel('Amplitud (V)');
legend('y_{sum} = y_1+y_2+y_3+y_4+y_5+y_6', 'Location', 'northeast');
exportar_figura(fig, fullfile(carpeta_img, '03c_senal_suma.pdf'), ...
    'Senal resultante ysum = suma de fundamental + 5 armonicos', ...
    ['Forma de onda resultante de sumar la fundamental de 60 Hz (120 V) con sus ' ...
     'armonicos 2do a 6to. La forma ya no es una senoidal pura: presenta distorsion ' ...
     'armonica tipica de cargas no lineales en sistemas electricos (ej. variadores de ' ...
     'frecuencia, fuentes conmutadas, balastros electronicos). Ventana: t=0:0.001:0.1 s.'], ...
    'Expresion MATLAB: ysum = y1+y2+y3+y4+y5+y6.');

%% Figura 03d: espectro de magnitud (FFT, un solo lado, en Hz) de ysum
Fs = 1/(t(2)-t(1));  % 1000 Hz
Nfft = length(t);
Yf = fft(ysum);
P2 = abs(Yf)/Nfft;
P1 = P2(1:floor(Nfft/2)+1);
P1(2:end-1) = 2*P1(2:end-1);  % espectro de un solo lado
f_eje = Fs*(0:floor(Nfft/2))/Nfft;

fig = figure('Name', '03d_espectro_ysum', 'Visible', 'off', 'Position', [100 100 950 550]);
plot(f_eje, P1, 'Color', [0 0.447 0.741], 'LineWidth', 1.3);
grid on;
xlim([0 500]);
title('Espectro de magnitud (FFT, un solo lado) de y_{sum}');
xlabel('Frecuencia (Hz)'); ylabel('Amplitud (V)');
hold on;
picos_esperados_f = [60 120 180 240 300 360];
picos_esperados_A = [120 60 40 30 24 20];
plot(picos_esperados_f, picos_esperados_A, 'rv', 'MarkerSize', 8, 'LineWidth', 1.2);
legend('Espectro FFT de y_{sum}', 'Picos esperados (60,120,...,360 Hz)', 'Location', 'northeast');
hold off;
exportar_figura(fig, fullfile(carpeta_img, '03d_espectro_ysum.pdf'), ...
    'Espectro de magnitud (FFT, un solo lado) de la senal resultante ysum', ...
    ['Espectro de magnitud de un solo lado (en Hz) de la senal resultante ysum, ' ...
     'calculado con fft() sobre la ventana t=0:0.001:0.1 s (Fs=1000 Hz). Debe mostrar ' ...
     'picos en 60, 120, 180, 240, 300 y 360 Hz con magnitudes decrecientes 120, 60, 40, ' ...
     '30, 24 y 20 V respectivamente, confirmando la composicion armonica de la senal. ' ...
     'Los triangulos rojos marcan la ubicacion y amplitud esperadas de cada armonico ' ...
     'segun las formulas originales.'], ...
    ['Fs = 1000 Hz, Nfft = 101 muestras (ventana 0:0.001:0.1). Espectro normalizado y ' ...
     'convertido a un solo lado (factor 2 en frecuencias intermedias). Resolucion en ' ...
     'frecuencia = Fs/Nfft ~ 9.9 Hz.']);

%% Conclusiones sobre armonicos en equipos electricos
ruta_conclusiones = fullfile(carpeta_res, '03_armonicos_60hz_conclusiones.txt');
fid = fopen(ruta_conclusiones, 'w');
fprintf(fid, 'CONCLUSIONES - Ejercicio 3: armonicos en una senal electrica de 60 Hz\r\n');
fprintf(fid, 'Tarea 2 - Comunicaciones (INTEC)\r\n');
fprintf(fid, '===========================================================\r\n\r\n');
fprintf(fid, ['1. La presencia de armonicos (multiplos enteros de la frecuencia fundamental ' ...
    'de 60 Hz) distorsiona la forma de onda senoidal pura de la red electrica; la senal ' ...
    'resultante (ysum) deja de ser una senoidal limpia y adquiere una forma con picos y ' ...
    'valles adicionales, tipica de cargas no lineales (variadores de frecuencia, fuentes ' ...
    'conmutadas, balastros electronicos, rectificadores).\r\n\r\n']);
fprintf(fid, ['2. Esta distorsion se cuantifica con la Distorsion Armonica Total (THD, Total ' ...
    'Harmonic Distortion), definida como la razon entre el valor RMS de todos los ' ...
    'armonicos (excluyendo la fundamental) y el valor RMS de la fundamental. En este caso, ' ...
    'con amplitudes 120,60,40,30,24,20 V, el THD es considerable dado que el 2do armonico ' ...
    'por si solo ya representa el 50%% de la fundamental, lo que en un sistema real ' ...
    'indicaria un nivel de distorsion fuera de los limites recomendados por normas como ' ...
    'IEEE 519.\r\n\r\n']);
fprintf(fid, ['3. Un alto contenido armonico en equipos electricos provoca sobrecalentamiento ' ...
    'de conductores y transformadores (perdidas adicionales por efecto skin y corrientes de ' ...
    'Foucault), interferencia electromagnetica en equipos de comunicaciones cercanos, y ' ...
    'errores en instrumentos de medicion que asumen una onda puramente senoidal; por ello ' ...
    'en instalaciones electricas reales se emplean filtros de armonicos y se limita el THD ' ...
    'mediante normativa.\r\n']);
fclose(fid);

fprintf('Ejercicio 3 completado. Figuras y conclusiones generadas en:\n  %s\n  %s\n', carpeta_img, ruta_conclusiones);
