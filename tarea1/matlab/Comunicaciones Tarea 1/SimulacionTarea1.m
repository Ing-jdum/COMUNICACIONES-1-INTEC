clear; clc;

modelName = 'mi_modelo_dtmf';

if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
new_system(modelName);
open_system(modelName);

% Add Blocks
add_block('simulink/Sources/Sine Wave', [modelName, '/Frecuencia_Baja'], 'Position', [50, 50, 100, 90]);
add_block('simulink/Sources/Sine Wave', [modelName, '/Frecuencia_Alta'], 'Position', [50, 130, 100, 170]);
add_block('simulink/Math Operations/Add', [modelName, '/Sumador'], 'Position', [160, 90, 190, 130]);
add_block('simulink/Discrete/Zero-Order Hold', [modelName, '/Canal_Muestreo'], 'Position', [220, 95, 260, 125]);
add_block('simulink/Sinks/Scope', [modelName, '/Osciloscopio'], 'Position', [330, 60, 370, 100]);
add_block('dspsnks4/Spectrum Analyzer', [modelName, '/Analizador_Espectro'], 'Position', [330, 130, 370, 170]);

% Configure Time-Based Sine Waves with Discrete Sample Time
set_param([modelName, '/Frecuencia_Baja'], 'SineType', 'Time based', 'Frequency', '2*pi*770', 'SampleTime', '1/8000');
set_param([modelName, '/Frecuencia_Alta'], 'SineType', 'Time based', 'Frequency', '2*pi*1336', 'SampleTime', '1/8000');
set_param([modelName, '/Canal_Muestreo'], 'SampleTime', '1/8000');

% Connect Lines
add_line(modelName, 'Frecuencia_Baja/1', 'Sumador/1', 'autorouting', 'on');
add_line(modelName, 'Frecuencia_Alta/1', 'Sumador/2', 'autorouting', 'on');
add_line(modelName, 'Sumador/1', 'Canal_Muestreo/1', 'autorouting', 'on');
add_line(modelName, 'Canal_Muestreo/1', 'Osciloscopio/1', 'autorouting', 'on');
add_line(modelName, 'Canal_Muestreo/1', 'Analizador_Espectro/1', 'autorouting', 'on');

% Run Simulation
set_param(modelName, 'StopTime', '0.25');
save_system(modelName);
sim(modelName);