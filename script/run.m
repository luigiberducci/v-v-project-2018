% run(): void
% PRE:  MODEL_DIRECTORY, MODEL_NAME, RESULT_DIR already defined in the workspace 
% POST: OAA results written in RESULT_DIR/result.csv
% This script runs OAA algorithm on the current model.

% Set init time
t0 = tic;

% Set simulation parameters
set_params;

% Run Optimal Approximation Algorithm
try
    [res, y, n_sra, n_oaa_1, n_oaa_2, t_sra, t_oaa_1, t_oaa_2, t_tot] = OAA(e, d, MODEL_NAME, BLOCK, GROUP, DEBUG, OUTPUT_DIR);
catch ME
    tf=toc(t0);
    info=sprintf("[Error] Execution terminates with an exception: %s ", ME.message);
    disp(info);
    info=sprintf("[Info] Abort the execution on %s / %s after %0.2f seconds", MODEL_DIRECTORY, MODEL_NAME, tf);
    disp(info);
    exit;
end
% Compute elapsed time
tf = toc(t0);

% Print to the result file
fid = fopen( RESULT_DIR+'result.csv', 'a' );
fprintf( fid, '%s,%s,%0.5f,%0.5f,%0.5f,%0.5f,%0.5f,%0.5f,%d,%d,%d,%d,%0.5f\n', string(datetime), MODEL_DIRECTORY, e, d, t_sra, t_oaa_1, t_oaa_2, t_tot, n_sra, n_oaa_1, n_oaa_2, res, y);
fclose( fid );

% Print total elapsed time
info=sprintf("[Info] Execution terminates in %0.2f seconds", tf);
disp(info);

% Close the model and free the MATLAB workspace
free_all;
