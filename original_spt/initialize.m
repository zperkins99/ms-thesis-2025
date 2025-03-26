function initialize
    %eml.extrinsic('calllib');
    calllib('treadmillremote','TREADMILL_initialize', '127.0.0.1', '4000'); 
    disp('treadmill connetion initialized')
end