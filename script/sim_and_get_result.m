function y = sim_and_get_result(MODEL_NAME, BLOCK, GROUP, DEBUG, OUTPUT_DIR)
% sim_and_get_result( MODEL_NAME: string, BLOCK: strin, GROUP: string, DEBUG: boolean, OUTPUT_DIR: directory path ): boolean
% PRE:  model already open, MODEL_NAME, MODEL_DIRECTORY already defined in the workspace
% POST: -
% This function runs a simulation on the model generating a random input trace and return a boolean value
% which represents the difference of output: if 0 the outputs of regular and mutated model are equal, if 1 the output differ.
    
    if DEBUG==true
        t0 = tic;
    end
    
    new_trace;
    [t, x, m] = sim(MODEL_NAME);

    % Take only the last value from the monitor. Since we implement the sustain, it is sufficient.
    wxl = size(m);
    last= wxl(1);
    y = m(last);

    if DEBUG==true
        [TIME, DATA_T] = signalbuilder(BLOCK, 'GET', 'Throttle', GROUP);
        [TIME, DATA_B] = signalbuilder(BLOCK, 'GET', 'Brake', GROUP);

        tf  = toc(t0);
        V   = [ DATA_T DATA_B tf y ];
        dlmwrite( OUTPUT_DIR+'all_simulations.csv', V, 'delimiter', ',', '-append', 'precision', 5 );
    end
end
