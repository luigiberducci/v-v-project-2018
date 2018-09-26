% test_matlab_works(): void
% PRE:  -
% POST: -
% This matlab script call the function used in the project to verify that everything works fine.

try
    info=sprintf("[Info] Taking the init time\t\t...");
    disp(info);
    % Init time
    t0=tic;
    info=sprintf("[Info] Taking the init time\t\tDONE");
    disp(info);

    % Definition of global variables
    info=sprintf("[Info] Declaring global variables\t...");
    disp(info);

    global MODEL_DIRECTORY;
    global MODEL_NAME;
    global BLOCK;
    global GROUP;
    global SAVE_TRACE_RES;
    global OUTPUT_DIR;

    MODEL_DIRECTORY="../model/out/table_change_DOWN_TABLE_4_1_True_8/";
    MODEL_NAME="main_model_DOWN_TABLE_4_1_True_8";
    BLOCK = MODEL_NAME+"/ManeuversGUI";
    GROUP = "Passing Maneuver";
    SAVE_TRACE_RES = true;
    OUTPUT_DIR = "../out/";

    info=sprintf("[Info] Declaring global variables\tDONE");
    disp(info);

    % Configuration of path
    info=sprintf("[Info] Adding model dir to path\t\t...");
    disp(info);
    
    addpath(MODEL_DIRECTORY);

    info=sprintf("[Info] Adding model dir to path\t\tDONE");
    disp(info);

    % Configuration of path
    info=sprintf("[Info] Disable warnings\t\t\t...");
    disp(info);
    
    warning('off','all');

    info=sprintf("[Info] Disable warnings\t\t\tDONE");
    disp(info);


    % Open the system from the model file
    info=sprintf("[Info] Opening the model\t\t...");
    disp(info);

    open_system(MODEL_NAME, 'loadonly');
    
    info=sprintf("[Info] Opening the model\t\tDONE");
    disp(info);

    % Generation of trace
    info=sprintf("[Info] Generating a new trace randomly\t...");
    disp(info);
    new_trace;
    info=sprintf("[Info] Generating a new trace randomly\tDONE");
    disp(info);
    
    % Simulation the model according with the trace
    info=sprintf("[Info] Simulate the model 1\t\t...");
    disp(info);
    sim_and_get_result(MODEL_NAME, BLOCK, GROUP, SAVE_TRACE_RES, OUTPUT_DIR);  
    info=sprintf("[Info] Simulate the model 1\t\tDONE");
    disp(info);
    info=sprintf("[Info] Simulate the model 2\t\t...");
    disp(info);
    sim_and_get_result(MODEL_NAME, BLOCK, GROUP, SAVE_TRACE_RES, OUTPUT_DIR);  
    info=sprintf("[Info] Simulate the model 2\t\tDONE");
    disp(info);

    % Close the system
    info=sprintf("[Info] Closing the model\t\t...");
    disp(info);
    
    close_system(MODEL_NAME);
    
    info=sprintf("[Info] Closing the model\t\tDONE");
    disp(info);

    % Finish time
    info=sprintf("[Info] Compute the overall time\t\t...");
    disp(info);
    tf=toc(t0);
    info=sprintf("[Info] Compute the overall time\t\t%0.2f", tf);
    disp(info);

    % Clear the workspace
    info=sprintf("[Info] Clearing the workspace\t\t...");
    disp(info);

    clear;
    
    info=sprintf("[Info] Clearing the workspace\t\tDONE");
    disp(info);
catch ME
    info=sprintf("\n\n[Error] Test terminates with an exception: %s", ME. message);
    disp(info);
    exit;
end
