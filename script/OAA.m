function [res, y, n_sra, n_oaa_1, n_oaa_2, t_sra, t_oaa_1, t_oaa_2, t_tot] = OAA(e, d, MODEL_NAME, BLOCK, GROUP, DEBUG, SAVE_TRACE_RES, OUTPUT_DIR)
% OAA(  e: real in (0,1],
%       d: real in (0,1],
%       MODEL_NAME: string,
%       BLOCK: string,
%       GROUP: string,
%       DEBUG: boolean ): res: bool, y: real in [0,1], n_sra: int, n_oaa_1: int, n_oaa_2: int, t_sra: seconds, t_oaa_1: seconds, t_oaa_2: seconds, t_tot: seconds
% The OAA returns an approximation of sensitivity with an error of order (1+-e) and a confidence 1-d. 
% The current implementation takes some variable used for manage the simulation of model (MODEL_NAME, BLOCK, GROUP)
% and returns some debug information such the number of simulations executed during the SRA phase (n_sra),
% during the first iterative phase (n_oaa_1) and the second iterative phase (n_oaa_2). Finally the script returns the
% partial elapsed time for each phase and the total elapsed time.
% The output variable 'res' represents the correct termination with the associated approximation y (res=true)
% or the termination by hypotesis testing (res=false).

t_0=tic;

%Compute the OAA's variables
Y   = 4 * (exp(1)-2) * log(2/d) / (e^2);
Y_2 = 2 * (1+sqrt(e)) * (1+2*sqrt(e)) * (1+log(3/2)/log(2/d)) * Y;

ee  = min( 1/2, sqrt(e) );
dd  = d/3;

info= sprintf('[OAA Info] Launching SRA+ with e=%d, d=%d ...', ee, dd); 
if DEBUG
    disp(info);
end

% SRA phase
[res, y_z, nn] = SRAplus( ee, dd, MODEL_NAME, BLOCK, GROUP, DEBUG, SAVE_TRACE_RES, OUTPUT_DIR );

% Take partial elapsed time
t_sra=toc(t_0);

% Check the termination mode of SRAplus
if res==true
    %SRA+ returns an approximation y_z
    info = sprintf('[OAA Info] SRA+ terminates and returns an approximation of y_z. %d\t%s\t%0.5f', nn, string(res), y_z); 
    if DEBUG
        disp(info);
    end

    % First iterative phase
    N1 = ceil( Y_2 * e * y_z );
    S = 0;

    info = sprintf('[OAA Info] First iterative phase, N=%d. (Y_2=%0.5f,e=%0.5f,y_z=%0.5f)', N1, Y_2, e, y_z); 
    if DEBUG
        disp(info);
    end
    
    for i=1:N1
        Z_i = sim_and_get_result(MODEL_NAME, BLOCK, GROUP, SAVE_TRACE_RES, OUTPUT_DIR);
        Z_j = sim_and_get_result(MODEL_NAME, BLOCK, GROUP, SAVE_TRACE_RES, OUTPUT_DIR);
        S = S + ((Z_i-Z_j)^2 / 2);
        if DEBUG
            info=sprintf("[OAA Debug] Sim result: %d %d\t Sum: %d\tN: %d\ti:%d", Z_i, Z_j, S, N1, i);
            disp(info);
        end
 
    end
    p_z = max(S/N1, (e * y_z));

    t_oaa_1 = toc(t_0)-t_sra;

    % Second iterative phase
    N2 = ceil( Y_2 * p_z / (y_z^2) );
    S = 0;
    
    info = sprintf('[OAA Info] Second iterative phase, N=%d.', N2); 
    if DEBUG
        disp(info);
    end

    for i = 1:N2
        Z_i = sim_and_get_result(MODEL_NAME, BLOCK, GROUP, SAVE_TRACE_RES, OUTPUT_DIR);
        S = S + Z_i;
        if DEBUG
            info=sprintf("[OAA Debug] Sim result: %d\t Sum: %d\tN: %d\ti: %d", Z_i, S, N2, i);
            disp(info);
        end
    end
    t_oaa_2 = toc(t_0)-t_oaa_1;

    res     = true;
    y       = S/N2;
    n_sra   = nn;
    n_oaa_1 = N1;
    n_oaa_2 = N2;
    %t_sra t_oaa_1 t_oaa_2 already computed
    t_tot   = toc(t_0);

    info = sprintf('[OAA Info] Sampler goodness is %d.', y); 
    if DEBUG
        disp(info);
    end
else
    %SRA+ terminates by hypotesis testing
    info = sprintf('[OAA Info] SRA+ terminates with hypotesis testing.'); 
    if DEBUG
        disp(info);
    end

    res     = false;
    y       = 0;
    n_sra   = nn;
    n_oaa_1 = 0;
    n_oaa_2 = 0;
    t_oaa_1 = 0;
    t_oaa_2 = 0;
    t_tot   = toc(t_0);
end
