% free_all(): void
% PRE:  MODEL_NAME already defined in the workspace
% POST: MODEL_NAME closed, MATLAB workspace empty

close_system(MODEL_NAME);   %Close the model
clear;                      %Clear the workspace
