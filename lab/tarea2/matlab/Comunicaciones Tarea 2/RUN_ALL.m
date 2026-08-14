%% RUN_ALL.m
% Tarea 2 - Comunicaciones (INTEC)
% Driver principal: ejecuta en orden los 4 scripts de la tarea y reporta
% progreso. Pensado para correr completo con:
%   matlab -batch "run('RUN_ALL.m')"
%
% Cada script se lanza en su PROPIO proceso MATLAB (via system + matlab
% -batch), no con run() en el mismo workspace: cada script hace 'clear'
% al inicio, lo cual borraria las variables de este driver (k, total,
% lista de scripts) si se ejecutaran en el mismo workspace. Lanzarlos
% como procesos independientes evita ese problema y ademas es mas fiel
% a como se ejecutaria cada script por separado.

clc;

carpeta_base = fileparts(mfilename('fullpath'));
cd(carpeta_base);

scripts = { ...
    'ex_01_senales_analogas.m', ...
    'ex_02_senal_amortiguada.m', ...
    'ex_03_armonicos_60hz.m', ...
    'ex_04_simulink_armonicos.m' ...
};

fprintf('=====================================================\n');
fprintf('Tarea 2 - Comunicaciones (INTEC) - Ejecucion completa\n');
fprintf('=====================================================\n\n');

total_scripts = numel(scripts);
matlab_exe = fullfile(matlabroot, 'bin', 'matlab.exe');

for k = 1:total_scripts
    nombreScript = scripts{k};
    fprintf('[%d/%d] Ejecutando %s ...\n', k, total_scripts, nombreScript);
    tInicio = tic;

    comando = sprintf('"%s" -batch "cd(''%s''); run(''%s'')"', ...
        matlab_exe, carpeta_base, nombreScript);
    [estado, salida] = system(comando);
    duracion = toc(tInicio);

    disp(salida);
    if estado ~= 0
        fprintf(2, '[%d/%d] ERROR en %s (codigo %d)\n\n', k, total_scripts, nombreScript, estado);
        error('RUN_ALL:scriptFallo', 'Fallo el script %s', nombreScript);
    else
        fprintf('[%d/%d] %s completado en %.2f s.\n\n', k, total_scripts, nombreScript, duracion);
    end
end

fprintf('=====================================================\n');
fprintf('Pipeline completo. Revisar carpeta results\\ para figuras\n');
fprintf('(PDF + sidecar .txt) y notas de conclusiones.\n');
fprintf('=====================================================\n');
