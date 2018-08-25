e=10^-1;
d=10^-1;

%Set init time
t0 = tic;

%Set simulation parameters
set_params;

%Run Optimal Approximation Algorithm
%SRAplus(e, d, MODEL_NAME, BLOCK, GROUP, DEBUG);
[res, y, n_sra, n_oaa_1, n_oaa_2, t_sra, t_oaa_1, t_oaa_2, t_tot] = OAA(e, d, MODEL_NAME, BLOCK, GROUP, DEBUG, OUTPUT_DIR);

%Compute elapsed time
tf = toc(t0);

%Print to the result file
fid = fopen( RESULT_DIR+'result.csv', 'a' );
fprintf( fid, '%s,%s,%0.5f,%0.5f,%0.5f,%0.5f,%0.5f,%0.5f,%d,%d,%d,%d,%0.5f\n', string(datetime), MODEL_DIRECTORY, e, d, t_sra, t_oaa_1, t_oaa_2, t_tot, n_sra, n_oaa_1, n_oaa_2, res, y);
fclose( fid );

%Print elapsed time
info=sprintf("[Info] Execution terminates in %0.2f seconds", tf);
disp(info);

%Free workspace
free_all;
