function  closeTreadmill
    %eml.extrinsic('calllib')
    calllib('treadmillremote','TREADMILL_close')
    disp('treadmill connection closed')
end
