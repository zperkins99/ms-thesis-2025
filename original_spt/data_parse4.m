function [BackCoP, Hip, run_med, new_s, mp] = data_parse4(vec,t)
    offset = .02295; %Right plate offset from origin
    BackCoP = 1;
    Hip = 1;
    L = .85; %leg length
    persistent I
    if isempty(I)
        I=0;
    end
    persistent new_stride
    if isempty(new_stride)
       new_stride = 0; 
    end
    y0 = 1;
    rf = 600;
    persistent curr_struct
    if isempty(curr_struct)
        curr_struct = struct('slide', y0*ones(rf,1),'run_med',y0,...
        'last_state',1,'maxFz',200,'mp_vec',y0*ones(3,1),'stride',y0,...
        'len',0,'stime', zeros(3,1)); 
    end

      %manually demux the collected signals
    LON = vec(1);
    LMx = vec(2);
    LFy = vec(3);
    LFz = vec(4);
    RON = vec(5);
    RMx = vec(6);
    RFy = vec(7);
    RFz = vec(8);

    persistent minFz
    if isempty(minFz)
        minFz = 600;
    end


    if (LON==1 && RON ==1) %double support
        minFz = 600;
        LCoP = LMx / LFz;
        RCoP = (RMx / RFz) + offset;
        if (RCoP < LCoP) % Right is back leg
            BackCoP = RCoP;
            Hip = BackCoP - L*(RFy / sqrt(RFy^2 + max(RFz,minFz)^2));

            BackFz = RFz;
        else % Left is back leg
            BackCoP = LCoP;
            Hip = BackCoP - (L*LFy / sqrt(LFy^2 + max(LFz,minFz)^2));

            BackFz = LFz;
        end

        %grow current stride
        curr_struct.last_state = 2;
        curr_struct.stride(curr_struct.len + 1) = Hip;
        curr_struct.len = curr_struct.len + 1;

        %sliding median
        curr_struct.slide = circshift(curr_struct.slide,1);
        curr_struct.slide(rf) = Hip;
        curr_struct.run_med = median(curr_struct.slide);
        new_stride = 0;
        if BackFz > curr_struct.maxFz
            curr_struct.maxFz = BackFz; 
        end

    elseif LON==1 % Left single support
        BackCoP = LMx / LFz;
        Hip = BackCoP - L*(LFy / sqrt(LFy^2 + max(LFz,minFz)^2));
        BackFz = LFz;

        if curr_struct.last_state == 2 %new stride detected
            %update mp_vec
            curr_struct.mp_vec = circshift(curr_struct.mp_vec',1)';
            curr_struct.mp_vec(3) = curr_struct.stride(ceil(curr_struct.len / 2));

            %rest stride
            curr_struct.stride = Hip; %holds hip data for the current stride
            curr_struct.len = 1;
            curr_struct.maxFz = BackFz;
            curr_struct.stime = circshift(curr_struct.stime',1)';
            curr_struct.stime(3) = t;
            dt = curr_struct.stime(3) - curr_struct.stime(2);
            I = I + dt * (curr_struct.mp_vec(3) - y0);

            %sliding median
            curr_struct.slide = circshift(curr_struct.slide,1);
            curr_struct.slide(rf) = Hip;
            curr_struct.run_med = median(curr_struct.slide);
            curr_struct.maxFz = BackFz;
            new_stride = 1;
        else
            %grow current stride
            curr_struct.stride(curr_struct.len + 1) = Hip;
            curr_struct.len = curr_struct.len + 1;

            %sliding median
            curr_struct.slide = circshift(curr_struct.slide,1);
            curr_struct.slide(rf) = Hip;
            curr_struct.run_med = median(curr_struct.slide);
            curr_struct.maxFz = BackFz;
            new_stride = 0;
            if BackFz > curr_struct.maxFz
               curr_struct.maxFz = BackFz; 
            end
        end

        curr_struct.last_state = 1;
    elseif (RON == 1) % Right Single support
        BackCoP = (RMx / RFz) + offset;
        Hip = BackCoP - L*(RFy / sqrt(RFy^2 + max(RFz,minFz)^2));

        BackFz = RFz;

        if curr_struct.last_state == 2 %new stride detected
            %update mp_vec
            curr_struct.mp_vec = circshift(curr_struct.mp_vec',1)';
            curr_struct.mp_vec(3) = curr_struct.stride(ceil(curr_struct.len / 2));

            %reset stride
            curr_struct.stride = Hip; %holds hip data for the current stride
            curr_struct.len = 1;
            curr_struct.maxFz = BackFz;
            curr_struct.stime = circshift(curr_struct.stime',1)';
            curr_struct.stime(3) = t;

            dt = curr_struct.stime(3) - curr_struct.stime(2);
            I = I + dt * (curr_struct.mp_vec(3) - y0);

            %sliding median
            curr_struct.slide = circshift(curr_struct.slide,1);
            curr_struct.slide(rf) = Hip;
            curr_struct.run_med = median(curr_struct.slide);
            curr_struct.maxFz = BackFz;
            new_stride = 1;
        else
            %grow current stride
            curr_struct.stride(curr_struct.len + 1) = Hip;
            curr_struct.len = curr_struct.len + 1;

            %sliding median
            curr_struct.slide = circshift(curr_struct.slide,1);
            curr_struct.slide(rf) = Hip;
            curr_struct.run_med = median(curr_struct.slide);
            curr_struct.maxFz = BackFz;
            new_stride = 0;
            if BackFz > curr_struct.maxFz
               curr_struct.maxFz = BackFz; 
            end
        end

        curr_struct.last_state = 1;
    else % float
        %reset stride
         minFz = 600;
         curr_struct.stride = Hip; %holds hip data for the current stride
         curr_struct.len = 1;
         curr_struct.stime = circshift(curr_struct.stime',1)';
         curr_struct.stime(3) = t;

         dt = curr_struct.stime(3) - curr_struct.stime(2);
         I = I + dt * (curr_struct.mp_vec(3) - y0);

         %sliding median (set based on assuming person stays at median of last stride)
         curr_struct.slide = circshift(curr_struct.slide,1);
         curr_struct.slide(rf) = curr_struct.mp_vec(3);
         %curr_struct.run_med = curr_struct.mp_vec(3);

         curr_struct.run_med  =  curr_struct.run_med;
         curr_struct.slide = circshift(curr_struct.slide,1);
         curr_struct.slide(rf) = curr_struct.run_med;

         new_stride = 1;
         curr_struct.last_state = 2;
    end
    minFz = .8 * curr_struct.maxFz;
  %manual  triggered PID    
    V = diff(curr_struct.mp_vec) ./ diff(curr_struct.stime); %velocity of last two strides
    Pcurr = curr_struct.mp_vec(3) - y0; %most recent position error
    Icurr = I; %integral error
    Dcurr = V(2);% most recent velocity  (of error)

    mp = curr_struct.mp_vec(3);
    run_med = curr_struct.run_med;
    new_s = new_stride;
end