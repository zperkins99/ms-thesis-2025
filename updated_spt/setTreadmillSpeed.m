function speed = setTreadmillSpeed(speed, acceleration)
    calllib('treadmill_remote','TREADMILL_setSpeed', speed, speed, acceleration);
end