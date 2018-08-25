MODEL_DIRECTORY = "~/Simulink/model/autotrans/out/";    %Normal directory
MODEL_NAME="twin_autotrans_disturbed";
%Set Block and Group names
BLOCK = MODEL_NAME + "/ManeuversGUI";
GROUP = "Passing Maneuver";

N=100;

for i=1:N
    t0 = tic;
    
    new_trace
    [t, x, y] = sim(MODEL_NAME);
    wxl = size(y);
    last= wxl(1);
    RES = y(last);
    [TIME, DATA_T] = signalbuilder(BLOCK, 'GET', 'Throttle', GROUP);
    [TIME, DATA_B] = signalbuilder(BLOCK, 'GET', 'Brake', GROUP);

    tf = toc(t0);
    V = [DATA_T DATA_B tf RES];
    dlmwrite('out/result.csv',V,'delimiter',',','-append');
end