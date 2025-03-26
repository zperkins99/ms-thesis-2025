function [flag_step, flag_step_ok, pos_step, vel_step, memory, pos_mes, vel_mes,p_step_x_1] = stateEstimator(time, grfs, vel_tm, memory, mass)

% Adapted from Song et al. 2020

grfs_queue_n = 10; % length of sensor queue to filter grf

i = 1;
time_0 = memory(i);                     i = i + 1;      % i == 1
x = memory(i+(0:1))';                   i = i + 2;      % i == 2, 3
P = reshape(memory(i+(0:3)), [2,2]);    i = i + 4;      % i == 4, 5, 6, 7
stance_L_0 = memory(i);                 i = i + 1;      % i == 8
stance_R_0 = memory(i);                 i = i + 1;      % i == 9
len_step = memory(i);                   i = i + 1;      % i == 10
leg_step_1 = memory(i);                 i = i + 1;      % i == 11
leg_step_0 = memory(i);                 i = i + 1;      % i == 12
p_step_y_1 = memory(i);                 i = i + 1;      % i == 13
p_step_y_0 = memory(i);                 i = i + 1;      % i == 14
p_step_x_1 = memory(i);                 i = i + 1;      % i == 15
p_step_x_0 = memory(i);                 i = i + 1;      % i == 16
t_step_1 = memory(i);                   i = i + 1;      % i == 17
t_step_0 = memory(i);                   i = i + 1;      % i == 18
n_step = memory(i);                     i = i + 1;      % i == 19
pos_step = memory(i);                   i = i + 1;      % i == 20
vel_step = memory(i);                   i = i + 1;      % i == 21
vel_tm_mean = memory(i);                i = i + 1;      % i == 22
n_ts = memory(i);                       i = i + 1;      % i == 23
grfs_queue_i = memory(i);               i = i + 1;      % i == 24
grfs_queue_buffer = reshape(memory(i+(0:grfs_queue_n*8-1)), [grfs_queue_n, 8]);      i = i + grfs_queue_n*8;   

del_t = time - time_0;

%=================%
% FILTER GRF DATA %
%=================%
grfs_queue_i = grfs_queue_i + 1;
if grfs_queue_i > grfs_queue_n
    grfs_queue_i = grfs_queue_i - grfs_queue_n;
end
grfs_queue_buffer(grfs_queue_i,:) = grfs;
grfs_filt = mean(grfs_queue_buffer);

%===============================%
% [KALMAN FILTER] PREDICT STATE %
%===============================%
u = (grfs_filt(1) + grfs_filt(5))/mass; % control input a = Fy/m
A = [1 del_t; 0 1];
B = [(del_t^2)/2; del_t];
noise_q2 = 1.3863;
Q = B*B'*noise_q2;

x = A*x + B*u;
P = A*P*A' + Q;

%==================================%
% [KALMAN FILTER] NEW MEASUREMENT? %
%                 i.e. new step?   %        
%==================================%
th_grfz = 0.2*9.81*mass; % vertical GRF exceeding 20 percent of user's mass

fz_l = grfs_filt(2);
mx_l = grfs_filt(3);
my_l = grfs_filt(4);
fz_r = grfs_filt(6);
mx_r = grfs_filt(7);
my_r = grfs_filt(8);

% Update mean values of pos, vel, vel_spt
pos_step = (pos_step*n_ts + x(1))/(n_ts + 1);
vel_step = (vel_step*n_ts + x(2))/(n_ts + 1);
vel_tm_mean = (vel_tm_mean*n_ts + vel_tm)/(n_ts + 1);
n_ts = n_ts + 1;

% Detect new step
flag_step = 0;
if stance_L_0 == 0 && fz_l > th_grfz % left step?
    flag_step = 1;
    p_step_y_0 = p_step_y_1;
    p_step_y_1 = (mx_l/fz_l);
    p_step_x_0 = p_step_x_1;
    p_step_x_1 = -my_l/fz_l;
    leg_step_1 = 0; % 0: L
end
if stance_R_0 == 0 && fz_r > th_grfz % right step?
    flag_step = 1;
    p_step_y_0 = p_step_y_1;
    p_step_y_1 = (mx_r/fz_r);
    p_step_x_0 = p_step_x_1;
    p_step_x_1 = -my_r/fz_r;
    leg_step_1 = 1; % 1: R
end

% If new step made
if flag_step
    t_step_0 = t_step_1;
    t_step_1 = time;
    len_step = p_step_y_1 - p_step_y_0;
    leg_step_0 = leg_step_1; 
    n_step = n_step + 1;
    n_ts = 0;
end

% Update Stance data
stance_L_0 = fz_l > th_grfz;
stance_R_0 = fz_r > th_grfz;
p_step_y_0 = p_step_y_0 - vel_tm*del_t;
p_step_y_1 = p_step_y_1 - vel_tm*del_t;

%==============================%
% [KALMAN FILTER] UPDATE STATE %
%             if new step made %        
%==============================%
% Do not update if step is suspicious (i.e. crossover detection)
th_cross = 0.2375*0.8; % Threshold for crossover 80% of half the width of treadmill

if (flag_step && (abs(p_step_x_1) < th_cross)) && (flag_step && ((t_step_1 - t_step_0) < 1.2))
    flag_step_ok = 1;
else
    flag_step_ok = 0;
end

if flag_step_ok
    % Measured output (y_mes)
    pos_mes = (p_step_y_1 + p_step_y_0)/2;
    vel_mes = len_step/(t_step_1 - t_step_0) - vel_tm_mean;
    y_mes = [pos_mes; vel_mes];

    % Update state
    noise_v = [0.0003 0.0005; 0.0005 0.0024]; 
    R = noise_v*noise_v';
    y_est = [pos_step; vel_step]; % Estimated output (y_est)

    K = P/(P + R);                     % K = P*C'/(C*P*C' +R)   % Calculate Kalman gain
    x = x + K*(y_mes - y_est);                                  % Update state
    P = (eye(2) - K)*P;                % P = (eye(2) - K*C)*P   % Update state error
else
    pos_mes = -20;
    vel_mes = -20;
    y_mes = [pos_mes; vel_mes];
end

%==============================%
% SAVE DATA FOR NEXT ITERATION %        
%==============================%

i = 1;
memory(i) = time;                   i = i + 1;      % i == 1
memory (i+(0:1)) = x;               i = i + 2;      % i == 2, 3
memory (i+(0:3)) = P(:);            i = i + 4;      % i == 4, 5, 6, 7
memory(i) = stance_L_0;             i = i + 1;      % i == 8
memory(i) = stance_R_0;             i = i + 1;      % i == 9
memory(i) = len_step;               i = i + 1;      % i == 10
memory(i) = leg_step_1;             i = i + 1;      % i == 11
memory(i) = leg_step_0;             i = i + 1;      % i == 12
memory(i) = p_step_y_1;             i = i + 1;      % i == 13
memory(i) = p_step_y_0;             i = i + 1;      % i == 14
memory(i) = p_step_x_1;             i = i + 1;      % i == 15
memory(i) = p_step_x_0;             i = i + 1;      % i == 16
memory(i) = t_step_1;               i = i + 1;      % i == 17
memory(i) = t_step_0;               i = i + 1;      % i == 18
memory(i) = n_step;                 i = i + 1;      % i == 19
memory(i) = pos_step;               i = i + 1;      % i == 20
memory(i) = vel_step;               i = i + 1;      % i == 21
memory(i) = vel_tm_mean;            i = i + 1;      % i == 22
memory(i) = n_ts;                   i = i + 1;      % i == 23
memory(i) = grfs_queue_i;           i = i + 1;      % i == 24
memory(i+(0:grfs_queue_n*8-1)) = grfs_queue_buffer; i = i + grfs_queue_n*8;



