% set_params(): void
% PRE:  MODEL_DIRECTORY, MODEL_NAME already defined in the workspace
% POST: model's variables setted in the workspace, model opened, model's path added to the path variable
% This script initialize the global variables.

global BLOCK;
global GROUP;
global DEBUG;
global OUTPUT_DIR;
global ERROR_DIR;
global RESULT_DIR;
global e;
global d;

% Define OAA parameters
e = 10^-1;
d = 10^-1;

% Define subfolder names
OUTPUT_DIR = MODEL_DIRECTORY + "out/";
ERROR_DIR  = MODEL_DIRECTORY + "err/";
RESULT_DIR = MODEL_DIRECTORY + "res/";

% Enable/Disable saving traces info
DEBUG = true;

% Set Block and Group names
BLOCK = MODEL_NAME + "/ManeuversGUI";
GROUP = "Passing Maneuver";

% Add path to model in the workspace
addpath(MODEL_DIRECTORY);

% Suppress all warnings
warning('off','all')

% Open the file model
open_system(MODEL_NAME, 'loadonly');
