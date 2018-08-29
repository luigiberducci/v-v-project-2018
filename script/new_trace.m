% new_trace(): void
% PRE:  MODEL_NAME, BLOCK, GROUP variables already defined in the workspace
% POST: disturbance trace (model's input as throttle,brake signals) updated randomly

%Signal parameters
TIME_MIN        = 0;    %Time period [TIME_MIN, TIME_MAX]
TIME_MAX        = 150;  
NUM_TICKS       = 10;   %Number of instants where inject disturbance
TIME_STEP       = (TIME_MAX-TIME_MIN)/NUM_TICKS;
THROTTLE_MIN    = 0;    %Throttle vary in [0,100]
THROTTLE_MAX    = 100;
BRAKE_MIN       = 0;    %BrakeTorque vary in [0,5650]
BRAKE_MAX       = 5650;

%Create Throttle and Brake domains
SIZE_DOM        = 10;
BRAKE_STEP      = floor( (BRAKE_MAX-BRAKE_MIN) / (SIZE_DOM-1) ); %The minus one is because we consider 0 value in domain
BRAKE_DOM       = BRAKE_MIN:BRAKE_STEP:BRAKE_MAX;
THROTTLE_STEP   = floor( (THROTTLE_MAX-THROTTLE_MIN)/ (SIZE_DOM-1) );
THROTTLE_DOM    = THROTTLE_MIN:THROTTLE_STEP:THROTTLE_MAX;

%Create signals
n  = NUM_TICKS;  %Number of values to generate
DT = ceil( 0 + rand(1,n) * SIZE_DOM );
DB = ceil( 0 + rand(1,n) * SIZE_DOM );

TIME_VECTOR = TIME_MIN : TIME_STEP : TIME_MAX;      %Create time vector 
D_THROTTLE  = [ 0 THROTTLE_DOM(DT) ];               %Create Throttle vector, it starts from 0 because the vehicle is stopped
D_BRAKE     = [ 0 BRAKE_DOM(DB) ];                  %Create Brake vector, it starts from 0 because the vehicle is stopped

%Set signals in the model
signalbuilder(BLOCK, 'SET', 'Throttle', GROUP, TIME_VECTOR, D_THROTTLE);
signalbuilder(BLOCK, 'SET', 'Brake',    GROUP, TIME_VECTOR, D_BRAKE);

%Save system
save_system(MODEL_NAME);
