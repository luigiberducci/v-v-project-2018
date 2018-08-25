MODEL_DIRECTORY = "~/Simulink/model/autotrans/out/";    %Normal directory
MODEL_NAME="twin_autotrans_disturbed";

addpath(MODEL_DIRECTORY);

[t, x, y] = sim(MODEL_NAME);
wxl = size(y);
last= wxl(1);
y(last)

