function [vel_tm, time_0] = trackTreadmillSpeed(time, vel_spt, acc_spt, vel_tm, time_0)

% Adapted from Song et al. 2020

del_t = time - time_0;
del_vel = vel_spt - vel_tm;
if del_vel > 0 
    del_vel = min(del_vel, acc_spt*del_t);
else
    del_vel = max(del_vel, -acc_spt*del_t);
end
vel_tm = vel_tm + del_vel;
time_0 = time;
