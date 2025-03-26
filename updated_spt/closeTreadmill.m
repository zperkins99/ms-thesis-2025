function  closeTreadmill
    calllib('treadmill_remote','TREADMILL_close')
    unloadlibrary('treadmill_remote')
    disp('Treadmill connection closed')
end
