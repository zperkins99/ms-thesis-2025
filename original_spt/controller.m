%% THIS CODE RUNS THE SELF-PACED TREADMILL
% Written by HAL senior design team (Spring 2017)
% With modifications by ZP for implementation (Fall 2024, Spring 2025)

if ~libisloaded('treadmillremote')
    loadTreadmillLib;
end

initialize; % Conenct to treadmill

pc = 1; % Initialize for pre-control phase

a = 2; % Acceleration for control phase

MAX = 3.5; MIN = 0; % Max and min allowable velocities
len = 1; speed = [0];
rm = [0]; V = [0]; t = [0]; % Data for plotting
curr_speed = 0; last = 0;


if pc
    v0 = 1.25; a0 = 0.1; % Initial velocity/acceleration for pre-control phase
    disp('********  START PRE-CONTROL PHASE  ************')

    setSpeed(v0,a0);

    for i = 1:20
        disp(21-i)
        pause(1)
    end
end
disp('********  START CONTROLLER  ************')

go = 1; tic
while go
    try % Between writes
        load('C:\Program Files (x86)\Bertec\Treadmill\stream002.mat'); % Read the data most recently written by dSPACE
        %Vpid = stream002.Y(2).Data(end); %command velocity from PID controller
        %STOP = stream002.Y(1).Data(end); %emergency stop switch

        % ZP Updates to match new median_zp.lay stream002 from dSPACE ControlDesk log file
        Vpid = stream002.Y(8).Data(end);
        STOP = stream002.Y(7).Data(end);
        
        %rm(len) = stream002.Y(3).Data(end); %running median

        % ZP Updates to match median_zp.lay stream002 from dSPACE ControlDesk log file
        rm(len) = stream002.Y(9).Data(end);
        
        if STOP %emergency stop switch was tripped
            Vcomm = 0;
            V(len) = 0;
            go = 0; % exit the while loop
        else
            Vcomm = Vpid ;
            V(len) = Vpid ;
        end
        
        %if Vcomm ~= last
        speed(len) = setSpeed(min(max(Vcomm,MIN),MAX),a);
            %last = Vcomm;
        t(len) = toc;
        %end
 
        %curr_speed = min(max(Vcomm,MIN),MAX);
        len = len + 1 ;
        fclose('all'); % Not sure this is necessary but making sure stream002 is closed so it can be written again
        pause(.002);
 
    catch % File being written by dSPACE 
    
    end % Try
    
end % While

closeTreadmill;