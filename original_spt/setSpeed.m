function speed = setSpeed(speed,acceleration)
    %eml.extrinsic('calllib');
    calllib('treadmillremote','TREADMILL_setSpeed', speed, speed, acceleration);
    fprintf('setSpeed %f \n',speed)
end