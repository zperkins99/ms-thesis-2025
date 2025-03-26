function [Vcomm, STOP]  = safety(pid,BackCoP)
    %dt = .001;
    persistent thrown
    persistent curr_speed
    
     if isempty(curr_speed)
         curr_speed = 0;
     end
%         
    if isempty(thrown)
        thrown = 0;
    end
    
    if (thrown == 1)
        Vadd = 0;
        curr_speed = 0;
    
    elseif (BackCoP <= 0.3) %safety condition
        thrown = 1;
        Vadd = 0;
        curr_speed = 0;
        
    else %normal function as PID controller of belt speed
        if abs(pid - curr_speed) <= .002
            Vadd = pid;
        else
            Vadd = curr_speed + .002 * sign(pid - curr_speed);
        end
    end
    
    STOP = thrown;
    %Vcomm = curr_speed + (Vadd * dt);    
    Vcomm = Vadd; %*dt
    curr_speed = Vcomm;
    
end