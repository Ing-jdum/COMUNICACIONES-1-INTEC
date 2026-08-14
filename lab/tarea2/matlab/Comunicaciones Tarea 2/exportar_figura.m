function exportar_figura(fig, ruta_pdf, titulo, descripcion, parametros)
%EXPORTAR_FIGURA Exporta una figura a PDF vectorial y crea un sidecar .txt
%   exportar_figura(fig, ruta_pdf, titulo, descripcion, parametros)
%
%   Esta funcion centraliza el proceso de exportacion requerido para
%   todas las figuras de la Tarea 2 (Comunicaciones, INTEC):
%     1. Exporta la figura 'fig' como PDF vectorial en 'ruta_pdf'
%        usando exportgraphics (ContentType 'vector').
%     2. Crea un archivo de texto plano con el mismo nombre base
%        (extension .txt, misma carpeta) que describe el contenido de
%        la figura: titulo, descripcion, parametros/senal representada.
%        Esto sustituye a metadatos PDF embebidos (XMP), ya que MATLAB
%        no ofrece una forma robusta y pura de escribir metadatos PDF;
%        el archivo sidecar es el mecanismo elegido para que un agente
%        redactor del informe -que no ejecuta MATLAB- pueda entender
%        cada figura solo leyendo el .txt.
%
%   Entradas:
%     fig         - handle de figura (figure(...))
%     ruta_pdf    - ruta completa del archivo .pdf de salida
%     titulo      - texto corto (nombre de la figura / senal)
%     descripcion - texto largo explicando que muestra la figura
%     parametros  - (opcional) texto adicional con parametros numericos,
%                   expresiones matematicas usadas, supuestos, etc.

    if nargin < 5
        parametros = '';
    end

    % Asegurar carpeta de destino
    [carpeta, nombre, ~] = fileparts(ruta_pdf);
    if ~exist(carpeta, 'dir')
        mkdir(carpeta);
    end

    % Exportar como PDF vectorial
    exportgraphics(fig, ruta_pdf, 'ContentType', 'vector');

    % Crear sidecar .txt con mismo nombre base
    ruta_txt = fullfile(carpeta, [nombre '.txt']);
    fid = fopen(ruta_txt, 'w');
    if fid == -1
        warning('No se pudo crear el archivo sidecar: %s', ruta_txt);
        return;
    end
    fprintf(fid, 'Archivo: %s\r\n', [nombre '.pdf']);
    fprintf(fid, 'Titulo: %s\r\n', titulo);
    fprintf(fid, '\r\n');
    fprintf(fid, 'Descripcion:\r\n%s\r\n', descripcion);
    if ~isempty(parametros)
        fprintf(fid, '\r\n');
        fprintf(fid, 'Parametros / notas:\r\n%s\r\n', parametros);
    end
    fprintf(fid, '\r\n');
    fprintf(fid, 'Generado automaticamente por script MATLAB - Tarea 2 Comunicaciones (INTEC).\r\n');
    fclose(fid);
end
