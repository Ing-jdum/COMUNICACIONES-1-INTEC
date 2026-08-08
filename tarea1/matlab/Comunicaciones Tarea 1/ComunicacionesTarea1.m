%% SIMULACIÓN Y ANÁLISIS DE SEÑALES DTMF EN MATLAB
clear; clc; close all;

%% 1. PARÁMETROS GENERALES Y MAPEO DTMF
Fs = 8000;                  % Frecuencia de muestreo (8 kHz estándar telefónico)
duracion_tonos = 0.25;      % Duración estándar por tono (250 ms)
duracion_silencio = 0.05;   % Silencio entre tonos (50 ms)

% Frecuencias de grupo bajo y alto (Hz)
f_bajas = [697, 770, 852, 941];
f_altas = [1209, 1336, 1477, 1633];

% Matriz de dígitos
teclado = ['1','2','3','A';
           '4','5','6','B';
           '7','8','9','C';
           '*','0','#','D'];

% Cadena de prueba a simular
secuencia_marcado = '582A*';

%% 2. GENERACIÓN Y ANÁLISIS EN EL DOMINIO DEL TIEMPO Y FRECUENCIA
t_tono = 0:1/Fs:(duracion_tonos - 1/Fs);
t_silencio = 0:1/Fs:(duracion_silencio - 1/Fs);
silencio = zeros(size(t_silencio));

senal_completa = [];
digito_objetivo = '5'; % Dígito individual para análisis detallado
dtmf_objetivo = [];

for k = 1:length(secuencia_marcado)
    c = secuencia_marcado(k);
    [row, col] = find(teclado == c);
    f_L = f_bajas(row);
    f_H = f_altas(col);
    
    % Generar tono DTMF: x(t) = sin(2*pi*f_L*t) + sin(2*pi*f_H*t)
    tono = sin(2*pi*f_L*t_tono) + sin(2*pi*f_H*t_tono);
    
    if c == digito_objetivo
        dtmf_objetivo = tono;
        f_baja_real = f_L;
        f_alta_real = f_H;
    end
    
    senal_completa = [senal_completa, tono, silencio]; %#ok<AGROW>
end

% Reproducir y guardar archivo .wav
sound(dtmf_objetivo, Fs);
audiowrite('tono_dtmf_5.wav', dtmf_objetivo, Fs);
audiowrite('llamada_completa.wav', senal_completa, Fs);

% --- Graficación: Dominio del Tiempo ---
figure('Name', 'Señales en el Tiempo');
subplot(2,1,1);
plot(t_tono(1:200)*1000, dtmf_objetivo(1:200), 'b', 'LineWidth', 1.5);
title(['Dígito Individual: "', digito_objetivo, '" (Primeros 200 Muestras)']);
xlabel('Tiempo (ms)'); ylabel('Amplitud'); grid on;

t_total = (0:length(senal_completa)-1)/Fs;
subplot(2,1,2);
plot(t_total, senal_completa, 'r');
title(['Señal de Secuencia Completa: "', secuencia_marcado, '"']);
xlabel('Tiempo (s)'); ylabel('Amplitud'); grid on;

% --- Graficación: Análisis Espectral FFT ---
N = length(dtmf_objetivo);
fft_digito = abs(fft(dtmf_objetivo))/N;
f = (0:N-1)*(Fs/N);

% Tomar solo la primera mitad del espectro (hasta Fs/2)
f_mitad = f(1:floor(N/2));
espectro_mitad = 2 * fft_digito(1:floor(N/2));

figure('Name', 'Análisis Espectral (FFT)');
plot(f_mitad, espectro_mitad, 'LineWidth', 1.5);
xlim([0 2000]); xlabel('Frecuencia (Hz)'); ylabel('Magnitud');
title(['Espectro FFT del Dígito "', digito_objetivo, '"']); grid on;

% Detección de picos en FFT
[picos, locs] = findpeaks(espectro_mitad, f_mitad, 'MinPeakHeight', 0.5);
fprintf('--- RESULTADOS TEÓRICOS VS SIMULADOS (Dígito %s) ---\n', digito_objetivo);
fprintf('Frecuencia Baja Teórica: %.1f Hz | Detectada: %.1f Hz | Error: %.2f%%\n', ...
    f_baja_real, locs(1), abs(locs(1)-f_baja_real)/f_baja_real*100);
fprintf('Frecuencia Alta Teórica: %.1f Hz | Detectada: %.1f Hz | Error: %.2f%%\n\n', ...
    f_alta_real, locs(2), abs(locs(2)-f_alta_real)/f_alta_real*100);

%% 3. ADICIÓN DE RUIDO BLANCO (AWGN)
snr_niveles = [30, 20, 10, 0];
figure('Name', 'Efecto de Ruido AWGN en FFT');

for i = 1:length(snr_niveles)
    snr = snr_niveles(i);
    senal_ruido = awgn(dtmf_objetivo, snr, 'measured');
    
    fft_ruido = 2*abs(fft(senal_ruido))/N;
    
    subplot(2,2,i);
    plot(f_mitad, fft_ruido(1:floor(N/2)), 'k');
    xlim([500 1800]); grid on;
    title(['SNR = ', num2str(snr), ' dB']);
    xlabel('Frecuencia (Hz)'); ylabel('Magnitud');
end

%% 4. VARIACIÓN DE LA DURACIÓN DEL TONO Y RESOLUCIÓN ESPECTRAL
duraciones = [0.050, 0.100, 0.250, 0.500]; % 50ms, 100ms, 250ms, 500ms
figure('Name', 'Variación de Duración del Tono');

for k = 1:length(duraciones)
    dur = duraciones(k);
    t_var = 0:1/Fs:(dur - 1/Fs);
    tono_var = sin(2*pi*f_baja_real*t_var) + sin(2*pi*f_alta_real*t_var);
    
    N_v = length(tono_var);
    fft_v = 2*abs(fft(tono_var))/N_v;
    f_v = (0:N_v-1)*(Fs/N_v);
    
    subplot(2,2,k);
    plot(f_v(1:floor(N_v/2)), fft_v(1:floor(N_v/2)), 'b', 'LineWidth', 1.2);
    xlim([500 1800]); grid on;
    title(sprintf('Duración: %.0f ms (\\Deltaf = %.1f Hz)', dur*1000, 1/dur));
    xlabel('Frecuencia (Hz)'); ylabel('Magnitud');
end

%% 5. DECODIFICADOR AUTOMÁTICO DE DÍGITOS DTMF
fprintf('--- DECODIFICACIÓN AUTOMÁTICA DE LA SECUENCIA ---\n');
muestras_tono = length(t_tono);
muestras_silencio = length(t_silencio);
paso = muestras_tono + muestras_silencio;
num_digitos = length(secuencia_marcado);

for idx = 1:num_digitos
    inicio = (idx - 1) * paso + 1;
    fin = inicio + muestras_tono - 1;
    segmento = senal_completa(inicio:fin);
    
    % FFT del segmento
    N_seg = length(segmento);
    fft_seg = 2*abs(fft(segmento))/N_seg;
    f_seg = (0:N_seg-1)*(Fs/N_seg);
    
    % Filtrado del rango de búsqueda DTMF (600 Hz - 1600 Hz)
    idx_rango = find(f_seg >= 600 & f_seg <= 1700);
    f_sub = f_seg(idx_rango);
    fft_sub = fft_seg(idx_rango);
    
    % Identificar picos principales
    [~, locs_p] = findpeaks(fft_sub, f_sub, 'MinPeakHeight', 0.4, 'SortStr', 'descend');
    picos_det = sort(locs_p(1:2));
    
    f_L_det = picos_det(1);
    f_H_det = picos_det(2);
    
    % Identificar posición en la matriz DTMF por aproximación
    [~, r_idx] = min(abs(f_bajas - f_L_det));
    [~, c_idx] = min(abs(f_altas - f_H_det));
    digito_estimado = teclado(r_idx, c_idx);
    
    fprintf('Dígito %d: Teórico="%c" | Det=[%.1f Hz, %.1f Hz] | Estimado="%c"\n', ...
        idx, secuencia_marcado(idx), f_L_det, f_H_det, digito_estimado);
end

%% 6. SIMULACIÓN DE ATENUACIÓN DE LÍNEA (-6 dB, -12 dB, -20 dB)
atenuaciones_dB = [0, -6, -12, -20];
figure('Name', 'Efecto de Atenuación de Línea');

for a = 1:length(atenuaciones_dB)
    db = atenuaciones_dB(a);
    factor = 10^(db/20); % Conversión de dB a ganancia lineal
    dtmf_atenuado = dtmf_objetivo * factor;
    
    subplot(2,2,a);
    plot(t_tono*1000, dtmf_atenuado, 'r');
    ylim([-2.5 2.5]); grid on;
    title(['Atenuación: ', num2str(db), ' dB (Factor: ', num2str(factor, '%.3f'), ')']);
    xlabel('Tiempo (ms)'); ylabel('Amplitud');
end