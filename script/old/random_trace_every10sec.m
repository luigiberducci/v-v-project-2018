%parameter
%MODEL_DIRECTORY = "~/Simulink/model/autotrans/out";
%MODEL_DIRECTORY = "~/Simulink/model/autotrans/";
%MODEL_NAME = "my_model";
%MODEL_NAME = "twin_autotrans_disturbed";

%Open the file model
addpath(MODEL_DIRECTORY);
open_system(MODEL_NAME, 'loadonly');

%Set Block and Group names
BLOCK = MODEL_NAME + "/ManeuversGUI";
GROUP = "Passing Maneuver";

%Default (Gradual acceleration, no brake)
T_MIN = 0;
T_MAX = 150;
T_STEP= 10;
 
%Random Throttle disturbance
n = floor(((T_MAX-T_MIN)/T_STEP))+1;  %Num of rand
D = 0 + rand(1,n-1) * (100);      %Disturbance of throttle vary in [0,100] 

T_THROTTLE = T_MIN:T_STEP:T_MAX;    %Inject disturbance every 10 secs
D_THROTTLE = [0 D];
signalbuilder(BLOCK, 'SET', 'Throttle', GROUP, T_THROTTLE, D_THROTTLE);

%Random Brake disturbance
D = 0 + rand(1,n-1) * (400-0);  %Disturbance of brake vary in [0,400] ft-lib, notice that brake <100 is very small
 
T_BRAKE = T_MIN:10:T_MAX;
D_BRAKE = [0 D];

signalbuilder(BLOCK, 'SET', 'Brake', GROUP, T_BRAKE, D_BRAKE);

%Save system
save_system(MODEL_NAME);
