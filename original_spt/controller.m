%% THIS CODE RUNS THE SELF-PACED TREADMILL
% Type controller into the command window or click run to execute

% FOR SAFETY: Someone must always be watching the user and be ready to hit the emergency STOP on the treadmill control panel - this will override 
% self-paced control and the treadmill will stop immediately

% If the treadmill is stopped manually (as opposed to using the back safety mechanism) the program must be stopped manually by clicking Stop 
% or typing Ctrl + C. Connections must then be closed from the command window by typing into the command window:
% closeTreadmill;
% closeViconDataStream(MyClient);
% It is recommended that the back safety mechanism be leveraged to stop the treadmill - users can simply hold onto the hand rails and 
% allow themselves to drift toward the back of the treadmill to trigger the STOP
    
clearvars
close all

%======================%        % Giganet box and electrical isolator must be on
% CONNECT TO VICON SDK %        % Vicon Nexus must be open and live
%======================%        % Set Vicon system to SPT
MyClient = connectViconDataStream;

%=====================%         % Participant must be standing on treadmill
% GET PARICIPANT MASS %
%=====================%
mass = getUserMass(MyClient);

%======================%        % Loads a C libary for treadmill remote
% CONNECT TO TREADMILL %        % Treadmill control panel must be open and ready for remote connection
%======================%
if ~libisloaded('treadmill_remote')
    loadTreadmillLibrary;
end
connectTreadmill;

%======================%
% INITIALIZE VARIABLES %
%======================%
time_0 = 0;                                 % Initial time (s)
time_step = 0.01;                           % Time step (s)
precontrol_duration = 1000;                 % Pre-control duration (time steps at ~100 Hz), 3000 = 30s, due to latency the length is a bit longer per "second"
real_time_loop = 1;                         % Program runs so long as real_time_loop == 1
phase = 0;                                  % Phase: Precontol (0), Self-paced control (1), program starts in precontrol, shifts to self-paced control
spt_display = 1;                            % Used to display start of Self-Paced Treadmill Control

zi = zeros(3, 8);                           % Initial state for filter function in getGRF
vel_tm = 0;                                 % Initial treadmill velocity for trackTreadmillSpeed
P = [0.0005, 0.0006, 0.0006, 0.0017];       % Initial P matrix for Kalman filter in stateEstimator
vel_spt = 1.25;                             % Initial target velocity (m/s)
acc_spt = 0.2;                              % Initial target acceleration (m/s^2)
G_p = 0.1;                                  % Position gain for control in calcTargetSpeed (from Song et al. = 0.1)
G_v = 0.25;                                 % Velocity gain for control in calcTargetSpeed (from Song et al. = 0.25)
pos_off = -0.15;                            % Reference position - Note the reference position in the HAL is best set at -0.15 when asking user to walk in center of treadmill
del_t_spt = 0.5;                            % Sets the target acceleration s.t. the target velocity is reached in del_t_spt seconds (s), used in calcTargetSpeed
memory = [0 0 0 P(1) P(2) P(3) P(4) 0 ...   % Initial values for memory used in stateEstimator
    0 .7 0 1 .35 -.35 .12 .12 0 -.5 0 ...
    0 0 0 0 0 zeros(1,80)]; 
back_safety_thr = -0.5;                    % Safety threshold for falling off back of treadmill, triggered by hip position (COM) NOT back foot

data_save = [zeros(7000,11)];              % Data storage matrix set for 7000 (70s of data) with 11 variables to store (can be modified)
ds = 1;                                    % Data Save index

%=============%
% SPT PROGRAM %
%=============%

% Start pre-control phase
disp('***** STARTING PRE-CONTROL PHASE *****')
setTreadmillSpeed(vel_spt, acc_spt);
time_start = tic;

% Enter real-time loop
while real_time_loop
    % Get current time
    time = toc(time_start);
    data_save(ds,1) = time;

    % Track treadmill speed
    [vel_tm, time_0] = trackTreadmillSpeed(time, vel_spt, acc_spt, vel_tm, time_0);
    data_save (ds,2) = vel_tm;

    % Get GRF data from Vicon DataStream server
    [grfs, zi] = getGRF(MyClient, zi);

    % State estimation using Kalman filter
    [flag_step, flag_step_ok, pos_step, vel_step, memory, pos_mes, vel_mes,p_step_x_1] = stateEstimator(time, grfs, vel_tm, memory, mass);
    data_save(ds, 3:8) = [flag_step, flag_step_ok, pos_step, vel_step, pos_mes, vel_mes];
    data_save(ds, 11) = p_step_x_1;

    % Calculate target speed for self-paced control
    [vel_spt, acc_spt] = calcTargetSpeed(flag_step, pos_step, vel_step, vel_tm, pos_off, G_p, G_v, del_t_spt, vel_spt, acc_spt);
    data_save(ds, 9:10) = [vel_spt, acc_spt];

    if phase
        if spt_display
            disp('***** STARTING SELF-PACED TREADMILL CONTROL *****')
            spt_display = 0;
        end
        % Safety for back of treadmill
        if (pos_step < back_safety_thr)
            disp('Back safety triggered')
            real_time_loop = 0; % Exit loop
        end
        setTreadmillSpeed(vel_spt, acc_spt);

    elseif ~phase 
        % Display Pre-Control Phase count down (seconds)
        if ~rem(precontrol_duration,100)
            disp(precontrol_duration/100)
        end
        % Switch to Self-Paced Treadmill Control
        if precontrol_duration == 1
            phase = 1;
        end
        precontrol_duration = precontrol_duration - 1;

    end
    % pause(time_step)
    ds = ds + 1;
    if ds == 7000
        disp("***** DATA COLLECTION FINISHED *****")
    end
end
        
%============%          % Disconnect from treadmill and Vicon SDK
% DISCONNECT %
%============% 
pause(0.01)                % Allows time for program to stop treadmill
setTreadmillSpeed(0, 0.5); % Safely stops treadmill when real-time loop is exited via back_safety_thr
closeTreadmill;
closeViconDataStream(MyClient);
