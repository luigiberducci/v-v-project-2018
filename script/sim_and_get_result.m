function y = sim_and_get_result(MODEL_NAME, BLOCK, GROUP, DEBUG, OUTPUT_DIR)
%SIM_AND_GET_RESULT Run simulation and return the last value of monitor
%   input:  -
%   output: boolean 0/1
%
%   PRE:    model must be already open
%           var MODEL_NAME correctly setted
%           path MODEL_DIR alredy added to workspace
    if DEBUG==true
        t0 = tic;
    end
    
    new_trace;
    [t, x, m] = sim(MODEL_NAME);
    wxl = size(m);
    last= wxl(1);
    y = m(last);

    if DEBUG==true
        [TIME, DATA_T] = signalbuilder(BLOCK, 'GET', 'Throttle', GROUP);
        [TIME, DATA_B] = signalbuilder(BLOCK, 'GET', 'Brake', GROUP);

        tf = toc(t0);
        V = [DATA_T DATA_B tf y];
        dlmwrite( OUTPUT_DIR+'all_simulations.csv', V, 'delimiter', ',', '-append', 'precision', 5 );
    end
end
