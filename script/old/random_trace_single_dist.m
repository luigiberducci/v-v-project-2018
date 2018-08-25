%INJECTION
%Get Time-Data variation of a SIGNAL in a GROUP of a BLOCK
BLOCK = "twin_sldemo_autotrans/ManeuversGUI";
GROUP = "Passing Maneuver";
%SIGNAL= "Throttle";
%[TIME, DATA] = signalbuilder(BLOCK, 'GET', SIGNAL, GROUP)
 
%INJECT A VARIATION FOR A SPECIFIC FIELD OF DATA
%DATA(3)=DATA(3)+10.0;
%APPLY VARIATION
%signalbuilder(BLOCK, 'SET', SIGNAL, GROUP, TIME, DATA);
 
%Default (Gradual acceleration, no brake)
T_MIN = 0;
T_MAX = 50;
 
T_THROTTLE = [T_MIN T_MAX];
D_THROTTLE = [10 50];
T_BRAKE    = [T_MIN T_MAX];
D_BRAKE    = [0 0];
 
%Random Throttle disturbance
n = 1;  %Num of rand
T = T_MIN + rand(1,n) * (T_MAX-T_MIN);   %Instant in which the disturbance occurs
D = 0 + rand(1,n) * (100);   %Disturbance of throttle vary in [0,100] 
DIST_DELAY = 1;        %Delay between peaks of data, by default it is instantanously
 

T_THROTTLE = [T_MIN T   T+DIST_DELAY T_MAX];
D_THROTTLE = [10    10  D            50];
signalbuilder(BLOCK, 'SET', 'Throttle', GROUP, T_THROTTLE, D_THROTTLE);

%Random Brake disturbance
n = 1;  %Num of rand
T = T_MIN + rand(1,n) * (T_MAX-T_MIN);   %Instant in which the disturbance occurs
D = 0 + rand(1,n) * (400-100);   %Disturbance of throttle vary in [100,400] ft-lib, because under 100 the brake is too small
DIST_DELAY = 1;        %Delay between peaks of data, by default it is instantanously
 

T_BRAKE = [ T_MIN T   T+DIST_DELAY T_MAX];
D_BRAKE = [ 0     0   D            0    ];
signalbuilder(BLOCK, 'SET', 'Brake', GROUP, T_BRAKE, D_BRAKE);


