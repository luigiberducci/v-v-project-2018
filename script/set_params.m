%global MODEL_DIRECTORY;
%global MODEL_NAME;
global BLOCK;
global GROUP;
global DEBUG;
global OUTPUT_DIR;
global ERROR_DIR;
global RESULT_DIR;

%MODEL_DIRECTORY = "~/Simulink/model/autotrans/out"; %Output directory for disturbed models
%MODEL_NAME = "twin_autotrans_disturbed";   %Disturbed model
%MODEL_NAME = "twin_sldemo_autotrans";       %Normal model, twin without disturbance
%MODEL_DIRECTORY = "~/Simulink/model/autotrans/";    %Normal directory
%MODEL_NAME = "my_model";                   %Other old model 
OUTPUT_DIR = MODEL_DIRECTORY + "out/";
ERROR_DIR  = MODEL_DIRECTORY + "err/";
RESULT_DIR = MODEL_DIRECTORY + "../";

%Enable/Disable saving traces info
DEBUG = true;

%Set Block and Group names
BLOCK = MODEL_NAME + "/ManeuversGUI";
GROUP = "Passing Maneuver";

%Add path to model in the workspace
addpath(MODEL_DIRECTORY);

%Suppress all warnings
warning('off','all')

%Open the file model
open_system(MODEL_NAME, 'loadonly');

%Boh
set_param(MODEL_NAME, 'MinMaxOverflowLogging', 'UseLocalSettings');
