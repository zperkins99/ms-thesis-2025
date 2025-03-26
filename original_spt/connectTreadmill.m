function connectTreadmill
    calllib('treadmill_remote','TREADMILL_initialize', '127.0.0.1', '4000'); % 4000 and 127.0.0.1 identify the listening port (see treadmill control panel)
    disp('Treadmill connected')
end