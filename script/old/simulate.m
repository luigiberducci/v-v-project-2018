% 'SUV_and_monitor' is the name of the Simulink model containing the
% System Under Verification (SUV) and the monitor checking the property
global SUV_and_monitor;
 
% 'property_module_name' is the name of the Simulink block containing the
% output of the monitor
global property_module_name;

% 'disturbance_dictionary_file_name' is the name of the file containing the
% disturbance dictionary
global disturbance_dictionary_file_name;

%% VARIABLE DEFINITIONS
disturbance_dictionary_file_name = 'dictionary.txt';
property_module_name             = 'bool';

% CHANGE HERE BELOW:
SUV_and_monitor                  = 'twin_sldemo_autotrans';


set_param(SUV_and_monitor, 'StartFcn', 'simulator_driver_set_params');
paramNameValStruct.SaveFinalState            = 'on';
paramNameValStruct.SaveCompleteFinalSimState = 'on';
paramNameValStruct.FinalStateName            = 'xFinal';
paramNameValStruct.LoadInitialState          = 'off';
paramNameValStruct.InitialState              = 'xInitial';

currentSnapshotTime = 0;
tStart = tic;


% R<time>
% Parameter time is a cell, so it must be converted to string and
% then to double (there is not a direct conversion)
time_slice = currentSnapshotTime + sampling_time * str2num(arg);
paramNameValStruct.StopTime = sprintf('%ld', time_slice);
simOut = sim(SUV_and_monitor, paramNameValStruct);
% store xInitial for next simulation step
xInitial = simOut.get('xFinal');
% store snapshotTime for next run
currentSnapshotTime = simOut.get('xFinal').snapshotTime;
% store bool for error checking
bool = simOut.get(property_module_name);
% LoadInitialState is off only on the first run
paramNameValStruct.LoadInitialState = 'on';

% INJECT DISTURBANCE FOLLOWING INPUT DISTURBANCE DICTIONARY
% 'None' means do nothing
vals = dictionary.get(arg);
%assert(length(vals)>0, '''I%s'' is not a valid disturbance!', arg);
for currindex = 1:length(vals)
    vals_i = vals(currindex);
    if (~strcmpi(vals_i(1), 'NONE'))
        currinput.(char(vals_i(1))) = char(vals_i(2));
    end
end

% Displays time needed too execute the simulation campaign
toc(tStart);


%INJECTION
%Get Time-Data variation of a SIGNAL in a GROUP of a BLOCK
BLOCK = "twin_sldemo_autotrans/ManeuversGUI";
GROUP = "Passing Maneuver";
SIGNAL= "Throttle";
[TIME, DATA] = signalbuilder(BLOCK, 'GET', SIGNAL, GROUP)

%INJECT A VARIATION FOR A SPECIFIC FIELD OF DATA
DATA(3)=DATA(3)+10.0;
%APPLY VARIATION
signalbuilder(BLOCK, 'SET', SIGNAL, GROUP, TIME, DATA);

%Default (Gradual acceleration, no brake)
T_MIN = 0;
T_MAX = 50;

T_THROTTLE = [T_MIN T_MAX];
D_THROTTLE = [10 50];
T_BRAKE    = [T_MIN T_MAX];
D_BRAKE    = [0 0];

%Random Throttle disturbance
%TIME
n = 1;  %Num of rand
T = T_MIN + rand(1,n) * (T_MAX-T_MIN);   %Instant in which the disturbance occurs
D = 0 + rand(1,n) * (100);   %Disturbance of throttle vary in [0,100] 
DIST_DELAY = 1;        %Delay between peaks of data, by default it is instantanously


T_THROTTLE = [T_MIN T   T+DIST_DELAY T_MAX];
D_THROTTLE = [10    10  D            50];
signalbuilder(BLOCK, 'SET', 'Throttle', GROUP, T_THROTTLE, D_THROTTLE);


%How run simulation, get output and plot difference of speeds
>> simOut = sim("twin_autotrans_disturbed", "SaveOutput", "on", "OutputSaveName", "yout")

simOut = 

  Simulink.SimulationOutput:

     sldemo_autotrans_output: [1x1 Simulink.SimulationData.Dataset] 

          SimulationMetadata: [1x1 Simulink.SimulationMetadata] 
                ErrorMessage: [0x0 char] 

>> out = simOut.get("sldemo_autotrans_output")

out = 

Simulink.SimulationData.Dataset 'sldemo_autotrans_output' with 14 elements

                         Name                       BlockPath                                
                         _________________________  ________________________________________ 
    1  [1x1 Signal]      Disturbed EngineRPM        twin_autotrans_disturbed/DistEngine     
    2  [1x1 Signal]      ''                         twin_autotrans_disturbed/DistShiftLogic 
    3  [1x1 Signal]      ImpellerTorque             ..._autotrans_disturbed/DistTransmission
    4  [1x1 Signal]      OutputTorque               ..._autotrans_disturbed/DistTransmission
    5  [1x1 Signal]      Disturbed Speed            twin_autotrans_disturbed/DistVehicle    
    6  [1x1 Signal]      Disturbed TransmissionRPM  twin_autotrans_disturbed/DistVehicle    
    7  [1x1 Signal]      Regular EngineRPM          twin_autotrans_disturbed/Engine         
    8  [1x1 Signal]      BrakeTorque                twin_autotrans_disturbed/ManeuversGUI   
    9  [1x1 Signal]      Throttle                   twin_autotrans_disturbed/ManeuversGUI   
   10  [1x1 Signal]      ''                         twin_autotrans_disturbed/ShiftLogic     
   11  [1x1 Signal]      ImpellerTorque             twin_autotrans_disturbed/Transmission   
   12  [1x1 Signal]      OutputTorque               twin_autotrans_disturbed/Transmission   
   13  [1x1 Signal]      Regular Speed              twin_autotrans_disturbed/Vehicle        
   14  [1x1 Signal]      Regular TransmissionRPM    twin_autotrans_disturbed/Vehicle        

  - Use braces { } to access, modify, or add elements using index.

>> reg = out.get('Regular Speed').Values
  timeseries

  Common Properties:
            Name: 'Regular Speed'
            Time: [751x1 double]
        TimeInfo: [1x1 tsdata.timemetadata]
            Data: [751x1 double]
        DataInfo: [1x1 tsdata.datametadata]

  More properties, Methods

>> dist = out.get('Disturbed Speed').Values
  timeseries

  Common Properties:
            Name: 'Disturbed Speed'
            Time: [751x1 double]
        TimeInfo: [1x1 tsdata.timemetadata]
            Data: [751x1 double]
        DataInfo: [1x1 tsdata.datametadata]

  More properties, Methods

>> plot(reg-dist)
