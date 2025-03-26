function [vel_spt, acc_spt] = calcTargetSpeed(flag_step, pos_step, vel_step, vel_tm, pos_off, G_p, G_v, del_t_spt, vel_spt, acc_spt)

% Adapted from Song et al. 2020
% PD controller

% Safety values
max_vel = 3;                    % SAFETY: maximum velocity
min_vel = 0.001;                % SAFETY: minimum velocity
max_acc = 0.2;                  % SAFETY: maximum acceleration
min_acc = 0.001;                % SAFETY: minimum acceleration

if ~flag_step
    return; % Return previous values, do not change speed unless there is a step
end

del_vel_spt = G_p*(pos_step - pos_off) + G_v*(vel_step);
vel_spt = vel_tm + del_vel_spt;
acc_spt = abs(del_vel_spt/del_t_spt);

% Implement safety
vel_spt = min(vel_spt, max_vel);
vel_spt = max(vel_spt, min_vel);
acc_spt = min(acc_spt, max_acc);
acc_spt = max(acc_spt, min_acc);
