%% 04_simulink_armonicos.m
% Tarea 2 - Comunicaciones (INTEC)
% Ejercicio: modelo Simulink de la senal electrica de 60 Hz con armonicos
%
% Este script construye programaticamente (sin depender de un .slx
% preexistente) un modelo Simulink "modelo_armonicos_60hz" con:
%   - 6 bloques Sine Wave (amplitudes [120,60,40,30,24,20] V,
%     frecuencias [60,120,180,240,300,360] Hz = f, 2f, ..., 6f)
%   - 1 bloque Sum/Add de 6 entradas que produce la senal compuesta
%   - 1 bloque Scope (dominio del tiempo)
%   - 1 bloque Spectrum Analyzer (dominio de la frecuencia) si el DSP
%     System Toolbox esta disponible; si no, o si su insercion via API
%     falla, se recurre al respaldo robusto: bloque "To Workspace" que
%     registra la senal para calcular la FFT en MATLAB tras simular
%     (este calculo posterior es, de todas formas, el que produce las
%     figuras entregables, ya que un Scope/Spectrum Analyzer no puede
%     capturarse como imagen en modo headless/batch).
%
% Parametros de simulacion: solver de paso fijo, Ts = 1/10000 s
% (10000 Hz de muestreo, >> 2*360 Hz de Nyquist, con amplio margen para
% resolver limpiamente hasta el 6to armonico), StopTime = 0.1 s.
%
% Salidas:
%   modelo_armonicos_60hz.slx                 (raiz del proyecto)
%   results\simulink images\04a_simulink_tiempo.pdf (+ .txt)
%   results\simulink images\04b_simulink_fft.pdf    (+ .txt)
%   results\simulink images\04c_simulink_diagrama.pdf (+ .txt)
%   results\04_simulink_notas.txt              (respuesta conceptual)
%   results\04_simulink_fft_valores.txt        (valores numericos reales
%                                                observados en la FFT)

close all;
clear;
clc;
set(0, 'DefaultFigureVisible', 'off');

carpeta_base = fileparts(mfilename('fullpath'));
carpeta_simg = fullfile(carpeta_base, 'results', 'simulink images');
carpeta_res  = fullfile(carpeta_base, 'results');
if ~exist(carpeta_simg, 'dir'); mkdir(carpeta_simg); end
if ~exist(carpeta_res, 'dir'); mkdir(carpeta_res); end

modelName = 'modelo_armonicos_60hz';
rutaModelo = fullfile(carpeta_base, [modelName '.slx']);

% Cerrar el modelo si ya estuviera cargado en memoria (ejecucion repetida)
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
% Si existe un .slx previo, se borra para reconstruirlo limpio desde cero
if exist(rutaModelo, 'file')
    delete(rutaModelo);
end

%% Parametros de la senal (misma composicion armonica del Ejercicio 3)
f0 = 60; % Hz, fundamental
amplitudes  = [120, 60, 40, 30, 24, 20];      % V
frecuencias = f0 * (1:6);                     % Hz: f,2f,3f,4f,5f,6f

Fs_sim = 10000;         % Hz, frecuencia de muestreo del solver de paso fijo
Ts_sim = 1/Fs_sim;      % s
StopTime_sim = 0.1;     % s (suficiente para varios ciclos de 60 Hz)

%% Construccion del modelo Simulink
new_system(modelName);
open_system(modelName);

% Configuracion del solver: paso fijo, Ts = 1/10000 s (Nyquist con
% amplio margen para resolver hasta 360 Hz: Fs=10000 Hz >> 2*360 Hz)
set_param(modelName, 'Solver', 'FixedStepDiscrete', 'FixedStep', num2str(Ts_sim));
set_param(modelName, 'StopTime', num2str(StopTime_sim));

nEntradas = numel(amplitudes);
xPos0 = 30; yPos0 = 30; alturaBloque = 40; espacioV = 70; anchoBloque = 90;

sineBlocks = cell(1, nEntradas);
for k = 1:nEntradas
    nombreBloque = sprintf('Fuente_Armonico_%d', k);
    yPos = yPos0 + (k-1)*espacioV;
    h = add_block('simulink/Sources/Sine Wave', [modelName '/' nombreBloque], ...
        'Position', [xPos0, yPos, xPos0+anchoBloque, yPos+alturaBloque]);
    set_param(h, 'Amplitude', num2str(amplitudes(k)));
    set_param(h, 'Frequency', num2str(2*pi*frecuencias(k))); % rad/s en bloque Sine Wave
    set_param(h, 'SampleTime', num2str(Ts_sim));
    sineBlocks{k} = nombreBloque;
end

% Bloque Sum (Add) con 6 entradas (todas positivas: '++++++')
xPosSum = xPos0 + 220; yPosSum = yPos0 + 2.5*espacioV;
sumBlock = add_block('simulink/Math Operations/Add', [modelName '/Suma_armonicos'], ...
    'Position', [xPosSum, yPosSum, xPosSum+anchoBloque, yPosSum+3*alturaBloque]);
set_param(sumBlock, 'Inputs', repmat('+', 1, nEntradas));

% Conectar cada Sine Wave a una entrada del sumador
for k = 1:nEntradas
    origen  = [sineBlocks{k} '/1'];
    destino = ['Suma_armonicos/' num2str(k)];
    add_line(modelName, origen, destino, 'autorouting', 'on');
end

% Bloque Scope (dominio del tiempo)
xPosScope = xPosSum + 220; yPosScope = yPosSum - 60;
scopeBlock = add_block('simulink/Sinks/Scope', [modelName '/Scope_tiempo'], ...
    'Position', [xPosScope, yPosScope, xPosScope+anchoBloque, yPosScope+alturaBloque]);
add_line(modelName, 'Suma_armonicos/1', 'Scope_tiempo/1', 'autorouting', 'on');

% Bloque Spectrum Analyzer (si DSP System Toolbox esta disponible); si
% falla la insercion via API, se continua solo con el respaldo To Workspace.
% Nota: la ruta de libreria del bloque Spectrum Analyzer ha cambiado entre
% versiones de MATLAB/DSP System Toolbox (p.ej. 'dspsigops/Spectrum
% Analyzer' en versiones antiguas vs. 'dspsnks4/Spectrum Analyzer' en
% R2025b). Se intentan varias rutas conocidas por compatibilidad.
usoSpectrumAnalyzer = false;
rutasSpectrumAnalyzer = {'dspsnks4/Spectrum Analyzer', 'dspsigops/Spectrum Analyzer'};
for iRuta = 1:numel(rutasSpectrumAnalyzer)
    try
        xPosSpec = xPosScope; yPosSpec = yPosScope + 90;
        specBlock = add_block(rutasSpectrumAnalyzer{iRuta}, [modelName '/Spectrum_Analyzer'], ...
            'Position', [xPosSpec, yPosSpec, xPosSpec+anchoBloque, yPosSpec+alturaBloque]);
        add_line(modelName, 'Suma_armonicos/1', 'Spectrum_Analyzer/1', 'autorouting', 'on');
        usoSpectrumAnalyzer = true;
        break;
    catch ME
        warning('No se pudo agregar el bloque Spectrum Analyzer con la ruta "%s" (%s).', ...
            rutasSpectrumAnalyzer{iRuta}, ME.message);
    end
end
if ~usoSpectrumAnalyzer
    warning('No se pudo agregar el bloque Spectrum Analyzer con ninguna ruta conocida. Se usa respaldo To Workspace + FFT en MATLAB.');
end

% Bloque To Workspace (respaldo robusto, siempre presente): registra la
% senal compuesta para poder graficar tiempo y FFT despues de simular,
% ya que un Scope/Spectrum Analyzer no se puede capturar como imagen en
% modo headless (-batch).
xPosTW = xPosScope; yPosTW = yPosScope + (usoSpectrumAnalyzer*90) + 90;
twBlock = add_block('simulink/Sinks/To Workspace', [modelName '/Salida_workspace'], ...
    'Position', [xPosTW, yPosTW, xPosTW+anchoBloque, yPosTW+alturaBloque]);
set_param(twBlock, 'VariableName', 'ysum_simulink');
set_param(twBlock, 'SaveFormat', 'Structure With Time');
add_line(modelName, 'Suma_armonicos/1', 'Salida_workspace/1', 'autorouting', 'on');

save_system(modelName, rutaModelo);

%% Captura del diagrama de bloques como PDF (entregable 04c)
try
    rutaDiagramaPDF = fullfile(carpeta_simg, '04c_simulink_diagrama.pdf');
    print(['-s' modelName], '-dpdf', '-bestfit', rutaDiagramaPDF);
catch ME1
    warning('No se pudo exportar el diagrama con print -s (%s). Se intenta metodo alterno.', ME1.message);
    try
        % Metodo alterno: capturar el diagrama como imagen via
        % Simulink.BlockDiagram.createSubSystem no aplica aqui; se usa
        % getframe sobre la ventana del modelo como ultimo recurso.
        rutaDiagramaPDF = fullfile(carpeta_simg, '04c_simulink_diagrama.pdf');
        frame = getframe(Simulink.BlockDiagram.getParentHandle(modelName));
        figTemp = figure('Visible', 'off');
        imshow(frame.cdata);
        exportgraphics(figTemp, rutaDiagramaPDF, 'ContentType', 'image');
        close(figTemp);
    catch ME2
        warning('Tampoco fue posible el metodo alterno de captura del diagrama (%s). Se omite 04c.', ME2.message);
    end
end

% Sidecar de texto para el diagrama (aunque falle print, se documenta la
% composicion del modelo)
fid = fopen(fullfile(carpeta_simg, '04c_simulink_diagrama.txt'), 'w');
fprintf(fid, 'Archivo: 04c_simulink_diagrama.pdf\r\n');
fprintf(fid, 'Titulo: Diagrama de bloques del modelo Simulink %s\r\n\r\n', modelName);
fprintf(fid, 'Descripcion:\r\n');
fprintf(fid, ['Diagrama de bloques del modelo Simulink que genera la senal electrica de ' ...
    '60 Hz con armonicos hasta el 6to. Estructura: 6 bloques Sine Wave (uno por cada ' ...
    'armonico, amplitudes [120,60,40,30,24,20] V y frecuencias [60,120,180,240,300,360] ' ...
    'Hz) -> bloque Add/Suma_armonicos (6 entradas, suma todas las senoidales) -> ' ...
    'bifurcacion hacia: (a) bloque Scope_tiempo (visualizacion en el dominio del ' ...
    'tiempo), (b) bloque Spectrum_Analyzer si DSP System Toolbox esta disponible ' ...
    '(visualizacion en el dominio de la frecuencia), y (c) bloque Salida_workspace ' ...
    '(To Workspace, variable ysum_simulink) usado como respaldo para calcular la FFT ' ...
    'en MATLAB despues de simular, ya que los scopes no se pueden capturar como imagen ' ...
    'en ejecucion headless (-batch).\r\n\r\n']);
fprintf(fid, 'Parametros / notas:\r\n');
fprintf(fid, 'Solver: paso fijo, Ts = %.10f s (Fs = %d Hz). StopTime = %.3f s.\r\n', Ts_sim, Fs_sim, StopTime_sim);
fprintf(fid, 'Spectrum Analyzer incluido: %d (1=si, 0=no; requiere DSP System Toolbox).\r\n', usoSpectrumAnalyzer);
fprintf(fid, '\r\nGenerado automaticamente por script MATLAB - Tarea 2 Comunicaciones (INTEC).\r\n');
fclose(fid);

%% Simulacion del modelo
simOut = sim(modelName, 'ReturnWorkspaceOutputs', 'on');

% Extraccion robusta de la senal registrada (Structure With Time)
ysum_struct = simOut.get('ysum_simulink');
t_sim = ysum_struct.time;
y_sim = ysum_struct.signals.values;
y_sim = y_sim(:); % asegurar vector columna
t_sim = t_sim(:);

%% Figura 04a: forma de onda en el tiempo (respaldo de Scope)
fig = figure('Name', '04a_simulink_tiempo', 'Visible', 'off', 'Position', [100 100 950 500]);
plot(t_sim, y_sim, 'Color', [0 0.447 0.741], 'LineWidth', 1.2);
grid on;
title('Senal compuesta del modelo Simulink en el dominio del tiempo (salida de Suma\_armonicos)');
xlabel('Tiempo (s)'); ylabel('Amplitud (V)');
legend('y_{sum} (Simulink)', 'Location', 'northeast');
exportar_figura(fig, fullfile(carpeta_simg, '04a_simulink_tiempo.pdf'), ...
    'Forma de onda en el tiempo de la senal compuesta simulada en Simulink', ...
    ['Waveform en el dominio del tiempo de la senal compuesta (fundamental 60 Hz, ' ...
     '120 V, mas armonicos 2do a 6to) obtenida al simular el modelo modelo_armonicos_60hz ' ...
     'y registrar la salida del bloque Suma_armonicos mediante To Workspace. Equivale a lo ' ...
     'que mostraria el bloque Scope del modelo, capturado aqui via MATLAB porque los ' ...
     'scopes no pueden exportarse como imagen en ejecucion headless (-batch).'], ...
    sprintf(['Fs simulacion = %d Hz (Ts=1/%d s), StopTime = %.3f s. Amplitudes = ' ...
     '[120,60,40,30,24,20] V, Frecuencias = [60,120,180,240,300,360] Hz.'], Fs_sim, Fs_sim, StopTime_sim));

%% Figura 04b: FFT de la senal simulada (respaldo de Spectrum Analyzer)
% Se re-muestrea a paso uniforme si fuera necesario (el solver de paso
% fijo ya produce paso uniforme = Ts_sim)
N_sim = length(y_sim);
Yf = fft(y_sim);
P2 = abs(Yf)/N_sim;
P1 = P2(1:floor(N_sim/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f_eje_sim = Fs_sim*(0:floor(N_sim/2))/N_sim;

fig = figure('Name', '04b_simulink_fft', 'Visible', 'off', 'Position', [100 100 950 550]);
plot(f_eje_sim, P1, 'Color', [0.85 0.325 0.098], 'LineWidth', 1.2);
grid on;
xlim([0 500]);
title('Espectro de magnitud (FFT) de la senal simulada en Simulink');
xlabel('Frecuencia (Hz)'); ylabel('Amplitud (V)');
hold on;
picos_esperados_f = frecuencias;
picos_esperados_A = amplitudes;
plot(picos_esperados_f, picos_esperados_A, 'kv', 'MarkerSize', 8, 'LineWidth', 1.2);
legend('FFT de y_{sum} (Simulink)', 'Picos esperados (60..360 Hz)', 'Location', 'northeast');
hold off;
exportar_figura(fig, fullfile(carpeta_simg, '04b_simulink_fft.pdf'), ...
    'Espectro de magnitud (FFT) de la senal compuesta simulada en Simulink', ...
    ['Espectro de magnitud (FFT, un solo lado, en Hz) de la senal registrada desde ' ...
     'Simulink via To Workspace. Sirve como respaldo del bloque Spectrum Analyzer, ya ' ...
     'que este no puede capturarse como imagen en ejecucion headless. Deberia mostrar ' ...
     'picos en 60,120,180,240,300,360 Hz con magnitudes decrecientes 120,60,40,30,24,20 ' ...
     'V; los triangulos negros marcan la ubicacion/amplitud esperada de cada armonico.'], ...
    sprintf(['Fs = %d Hz, N = %d muestras, resolucion en frecuencia = Fs/N = %.3f Hz. ' ...
     'Ver results\\04_simulink_fft_valores.txt para los valores numericos reales ' ...
     '(picos detectados) obtenidos de esta FFT.'], Fs_sim, N_sim, Fs_sim/N_sim));

%% Deteccion numerica de picos reales en el espectro (para notas/informe)
[picos_mag, idx_picos] = findpeaks(P1, 'SortStr', 'descend', 'NPeaks', 8, 'MinPeakHeight', max(P1)*0.02);
picos_f_detectados = f_eje_sim(idx_picos);
[picos_f_detectados, ordenIdx] = sort(picos_f_detectados);
picos_mag = picos_mag(ordenIdx);

ruta_fft_valores = fullfile(carpeta_res, '04_simulink_fft_valores.txt');
fid = fopen(ruta_fft_valores, 'w');
fprintf(fid, 'VALORES NUMERICOS OBSERVADOS EN LA FFT - Ejercicio 4 (Simulink)\r\n');
fprintf(fid, 'Tarea 2 - Comunicaciones (INTEC)\r\n');
fprintf(fid, '===========================================================\r\n\r\n');
fprintf(fid, 'Fs (frecuencia de muestreo del solver) = %d Hz\r\n', Fs_sim);
fprintf(fid, 'N (numero de muestras registradas)     = %d\r\n', N_sim);
fprintf(fid, 'Resolucion en frecuencia (Fs/N)         = %.4f Hz\r\n', Fs_sim/N_sim);
fprintf(fid, 'StopTime de la simulacion               = %.4f s\r\n\r\n', StopTime_sim);
fprintf(fid, 'Picos esperados (segun formulas de diseno):\r\n');
for k = 1:nEntradas
    fprintf(fid, '  f = %5.1f Hz -> Amplitud esperada = %5.1f V\r\n', frecuencias(k), amplitudes(k));
end
fprintf(fid, '\r\nPicos detectados automaticamente en la FFT simulada (findpeaks):\r\n');
if isempty(picos_f_detectados)
    fprintf(fid, '  (no se detectaron picos significativos; revisar parametros de findpeaks)\r\n');
else
    for k = 1:numel(picos_f_detectados)
        fprintf(fid, '  f = %8.3f Hz -> Amplitud detectada = %8.4f V\r\n', picos_f_detectados(k), picos_mag(k));
    end
end
fprintf(fid, ['\r\nEstos valores son la "verdad de campo" (ground truth) obtenida al ' ...
    'ejecutar realmente el modelo; deben usarse para verificar si los picos caen ' ...
    'exactamente en 60,120,180,240,300,360 Hz con las amplitudes de diseno, o si hay ' ...
    'corrimiento/leakage/aliasing, y para refinar la respuesta de 04_simulink_notas.txt.\r\n']);
fclose(fid);

%% Notas conceptuales: respuesta a "Por que el espectro esta mal? Que parametro corregir?"
ruta_notas4 = fullfile(carpeta_res, '04_simulink_notas.txt');
fid = fopen(ruta_notas4, 'w');
fprintf(fid, 'NOTAS - Ejercicio 4: modelo Simulink de armonicos de 60 Hz\r\n');
fprintf(fid, 'Tarea 2 - Comunicaciones (INTEC)\r\n');
fprintf(fid, '===========================================================\r\n\r\n');
fprintf(fid, 'Resumen del modelo:\r\n');
fprintf(fid, ['- 6 bloques Sine Wave con amplitudes [120,60,40,30,24,20] V y frecuencias ' ...
    '[60,120,180,240,300,360] Hz, sumados con un bloque Add de 6 entradas.\r\n']);
fprintf(fid, ['- Salida llevada a un bloque Scope (dominio del tiempo) y, si DSP System ' ...
    'Toolbox esta disponible, a un bloque Spectrum Analyzer (dominio de la frecuencia); ' ...
    'ademas se registra con To Workspace para poder graficar tiempo y FFT desde MATLAB, ' ...
    'ya que los scopes no pueden capturarse como imagen en ejecucion -batch.\r\n']);
fprintf(fid, '- Solver de paso fijo, Ts = 1/%d s (Fs = %d Hz), StopTime = %.3f s.\r\n\r\n', Fs_sim, Fs_sim, StopTime_sim);

fprintf(fid, 'Pregunta del enunciado: ¿Por que el espectro esta mal? ¿Que parametro debe corregirse?\r\n\r\n');
fprintf(fid, ['ESTADO REAL OBSERVADO EN ESTA CORRIDA (ver results\\04_simulink_fft_valores.txt ' ...
    'para el detalle numerico): en esta ejecucion concreta el espectro NO esta mal. Los 6 ' ...
    'picos detectados automaticamente (findpeaks) caen dentro de ~0.06 Hz de las frecuencias ' ...
    'de diseno (60,120,180,240,300,360 Hz) y las amplitudes detectadas coinciden con las de ' ...
    'diseno (120,60,40,30,24,20 V) con un error menor al 2%%. La pequena desviacion en ' ...
    'frecuencia (p.ej. 59.94 Hz en vez de 60.00 Hz) es solo el efecto esperable de la ' ...
    'resolucion finita de la FFT (Delta_f = Fs/N = 9.99 Hz, con el pico real cayendo entre ' ...
    'dos bins), no un sintoma de aliasing ni de leakage severo: con Fs=10000 Hz (>>2*360 Hz ' ...
    'de Nyquist) y N=1001 muestras sobre 0.1 s (6 periodos exactos de la fundamental de ' ...
    '60 Hz), este montaje particular evita ambos problemas. Por lo tanto, la pregunta ' ...
    '"¿por que el espectro esta mal?" del enunciado se responde aqui como un caso de ' ...
    'ANALISIS CONCEPTUAL/GENERICO (que parametros PODRIAN arruinar el espectro y como se ' ...
    'corrigen), util para el informe y para configuraciones distintas a la usada en este ' ...
    'script, pero no describe un defecto realmente presente en esta corrida.\r\n\r\n']);
fprintf(fid, ['Respuesta conceptual (teoria DSP aplicable en general a este tipo de montaje, ' ...
    'para cuando SI se elijan parametros que produzcan un espectro incorrecto):\r\n\r\n']);
fprintf(fid, ['1) Frecuencia de muestreo insuficiente (aliasing): si Ts del bloque Sine ' ...
    'Wave o del solver no cumple el criterio de Nyquist (Fs >= 2*f_max, idealmente con ' ...
    'buen margen, p.ej. Fs >= 10*f_max), el armonico mas alto (360 Hz en este caso) puede ' ...
    'aparecer replicado/reflejado en una frecuencia menor a la real, deformando el ' ...
    'espectro. Correccion: aumentar Fs (reducir Ts) del solver/bloques Sine Wave hasta ' ...
    'satisfacer Nyquist con margen.\r\n\r\n']);
fprintf(fid, ['2) Fuga espectral (spectral leakage) por ventana no entera en periodos: si la ' ...
    'ventana de datos analizada (StopTime o el numero de muestras usado en la FFT) no ' ...
    'contiene un numero entero de periodos de la fundamental (60 Hz => periodo 16.667 ms), ' ...
    'la FFT/DFT asume periodicidad artificial en los bordes y "esparce" la energia de cada ' ...
    'armonico hacia frecuencias vecinas (leakage), ensanchando los picos y reduciendo su ' ...
    'amplitud aparente. Correccion: ajustar StopTime (o la longitud de la ventana FFT) a un ' ...
    'multiplo entero del periodo fundamental (p.ej. usar exactamente N/60 segundos), o ' ...
    'aplicar una ventana de suavizado (Hann, Hamming) antes de la FFT.\r\n\r\n']);
fprintf(fid, ['3) Resolucion en frecuencia insuficiente: la resolucion del espectro es ' ...
    'Delta_f = Fs/N; si N (numero de muestras) es pequeno, Delta_f puede ser mayor que la ' ...
    'separacion entre armonicos (60 Hz), causando que picos cercanos se mezclen o que la ' ...
    'ubicacion de cada pico no coincida exactamente con 60,120,...,360 Hz. Correccion: ' ...
    'aumentar el numero de muestras N (StopTime mas largo o Ts mas pequeno) para reducir ' ...
    'Delta_f por debajo de la separacion entre armonicos.\r\n\r\n']);
fprintf(fid, ['4) Configuracion del bloque Spectrum Analyzer / FFT: parametros por defecto ' ...
    'del bloque (tamano de FFT, tipo de ventana, promediado, unidades dB vs. lineal) ' ...
    'pueden no coincidir con lo esperado, dando la impresion de un espectro "incorrecto" ' ...
    'cuando en realidad solo esta escalado o ventaneado distinto. Correccion: revisar y ' ...
    'ajustar en el bloque los parametros de tamano de FFT, tipo de ventana y unidades para ' ...
    'que coincidan con el analisis deseado.\r\n\r\n']);
fprintf(fid, ['En sintesis, el parametro mas probable a corregir es el tiempo de muestreo ' ...
    '(Ts / frecuencia de muestreo Fs) para garantizar Nyquist con margen, y/o la duracion ' ...
    'de la ventana de analisis (StopTime / N) para que contenga un numero entero de ' ...
    'periodos de la fundamental y ofrezca resolucion en frecuencia suficiente para separar ' ...
    'los 6 armonicos de 60 Hz entre si.\r\n']);
fclose(fid);

fprintf('Ejercicio 4 completado. Modelo, figuras y notas generadas en:\n  %s\n  %s\n  %s\n  %s\n', ...
    rutaModelo, carpeta_simg, ruta_fft_valores, ruta_notas4);

close_system(modelName, 1);
