function [res, y, n_sra, n_oaa_1, n_oaa_2, t_sra, t_oaa_1, t_oaa_2, t_tot] = OAA(e, d, MODEL_NAME, BLOCK, GROUP, DEBUG, OUTPUT_DIR)
%OAA return approximation of mu
%   input:  error margin e in (0,1]
%           confidence ratio d in (0,1]
%           random vars Z indip. and ident. distributed (computed online)
%           MODEL_NAME, BLOCK, GROUP simulation variables
%           DEBUG enable or disable information printing
%   output: y approximation of sampler's goodness.

t_0=tic;

%Compute the OAA's variables
Y = 4 * (exp(1)-2) * log(2/d) / (e^2);
Y_2 = 2 * (1+sqrt(e)) * (1+2*sqrt(e)) * (1+log(3/2)/log(2/d)) * Y;

ee = min( 1/2, sqrt(e) );
dd = d/3;

info = sprintf('[OAA Info] Launching SRA+ with e=%d, d=%d ...', ee, dd); 
if DEBUG
    disp(info);
end

%t_sra_0=tic();

%Run SRA+
[res, y_z, nn] = SRAplus( ee, dd, MODEL_NAME, BLOCK, GROUP, DEBUG, OUTPUT_DIR );

t_sra=toc(t_0);

if res==true
    %SRA+ returns an approximation y_z
    info = sprintf('[OAA Info] SRA+ terminates and returns an approximation of y_z. %d\t%s\t%0.5f', nn, string(res), y_z); 
    if DEBUG
        disp(info);
    end

    %First iterative phase
    % t_1 = tic();
    N1 = ceil( Y_2 * e * y_z );
    S = 0;

    info = sprintf('[OAA Info] First iterative phase, N=%d. (Y_2=%0.5f,e=%0.5f,y_z=%0.5f)', N1, Y_2, e, y_z); 
    if DEBUG
        disp(info);
    end
    
    for i=1:N1
        Z_i = sim_and_get_result(MODEL_NAME, BLOCK, GROUP, DEBUG, OUTPUT_DIR);
        Z_j = sim_and_get_result(MODEL_NAME, BLOCK, GROUP, DEBUG, OUTPUT_DIR);
        S = S + ((Z_i-Z_j)^2 / 2);
        if DEBUG
            info=sprintf("[OAA Debug] Sim result: %d %d\t Sum: %d\tN: %d\ti:%d", Z_i, Z_j, S, N1, i);
            disp(info);
        end
 
    end
    p_z = max(S/N1, (e * y_z));

    t_oaa_1 = toc(t_0)-t_sra;

    %Second iterative phase
    %t_2 = tic();
    N2 = ceil( Y_2 * p_z / (y_z^2) );
    S = 0;
    
    info = sprintf('[OAA Info] Second iterative phase, N=%d.', N2); 
    if DEBUG
        disp(info);
    end

    for i = 1:N2
        Z_i = sim_and_get_result(MODEL_NAME, BLOCK, GROUP, DEBUG, OUTPUT_DIR);
        S = S + Z_i;
        if DEBUG
            info=sprintf("[OAA Debug] Sim result: %d\t Sum: %d\tN: %d\ti: %d", Z_i, S, N2, i);
            disp(info);
        end
    end
    t_oaa_2 = toc(t_0)-t_oaa_1;

    res = true;
    y = S/N2;
    n_sra = nn;
    n_oaa_1 = N1;
    n_oaa_2 = N2;
    %t_sra t_oaa_1 t_oaa_2 already computed
    t_tot = toc(t_0);

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

    res = false;
    y   = 0;
    n_sra = nn;
    n_oaa_1 = 0;
    n_oaa_2 = 0;
    t_oaa_1 = 0;
    t_oaa_2 = 0;
    t_tot = toc(t_0);

%    result = [0 t_sra_0 t_sra res y]
end
