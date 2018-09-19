function [res, y_z, n] = SRAplus(e, d, MODEL_NAME, BLOCK, GROUP, DEBUG, SAVE_TRACE_RES, OUTPUT_DIR)
% SRAplus(  e: real in (0,1], d: real in (0,1], 
%           MODEL_NAME: string, BLOCK: string, GROUP: string, 
%           DEBUG: boolean, OUTPUT_DIR: directory path) : res: boolean, y_z: real in [0,1], n: int
% This script is an extended version of SRA with hypotesis testing to avoid that the random variable Z gives always 0 implying non-termination.
% The booelan output value 'res' represents the termination mode: correct termination with apprximation y_z (res=true), or termination by 
% hypotesis testing (res=false). Finally, the script return the number of simulation required (n).

    %Compute SRA bound
    Y   = 4 * (exp(1)-2) * log(2/d) / (e^2);
    Y_1 = 1 + (1+e) * Y;
    %Compute hypotesis testing bound
    M = log(d) / log(1-e);

    %If debug is enabled, print the variables
    if DEBUG
        info = sprintf('[SRA+ Info] Starting SRA+. Y=%d, M=%d.\nCompute S=S+Z up to reach Y. If S=0 after M iteration we can use hypotesys testing.',Y_1,M);
        disp(info);
    end
    
    S = 0;
    N = 0;
    while S <= Y_1 
        if S==0 && N>=M
            break
        end
        Z_n = sim_and_get_result(MODEL_NAME, BLOCK, GROUP, SAVE_TRACE_RES, OUTPUT_DIR);
        S = S + Z_n;
        N = N + 1;
        if DEBUG
            info=sprintf("[SRA+ Debug] Sim result: %d\t Sum: %d\tN: %d\tY_1: %d", Z_n, S, N, Y_1);
            disp(info);
        end
    end
    
    %Set the flag res to distinguish the termination mode
    if S==0
        res = false;
        y_z = 0;
        n   = M;
        info = sprintf('[SRA+ Info] All traces give result 0.'); 
    else
        res = true;
        y_z = S/N;
        n   = N;
        info = sprintf('[SRA+ Info] y_z approximation is %0.5f.', y_z);
    end

    %If Debug is enabled, print the result information
    if DEBUG
        disp(info);
    end 
end
