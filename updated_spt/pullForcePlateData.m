function forcePlateData = pullForcePlateData(MyClient)

forcePlateData = [];
scales = [-1, -1, -1, -1, -1, -1, -1, -1]; % Scales for GRF values where [Fy_l Fz_l Mx_l My_l Fy_r Fz_r Mx_r My_r]

% Get a frame
MyClient.GetFrame();

% Get the number of force plates in current Vicon system
ForcePlateCount = MyClient.GetForcePlateCount().ForcePlateCount; % Count should be 2 so long as in SPT system

% Pull 10 samples of data (force, moment, cop)
for ForcePlateIndex = 0:typecast(ForcePlateCount, 'int32') - 1 % We only want devices 1 and 2 (left and right treadmill force plates)
    Output_GetForcePlateSubsamples = MyClient.GetForcePlateSubsamples(typecast(ForcePlateIndex, 'uint32')); % The number of samples per 0.01 seconds (100 Hz is Vicon system sampling rate)
    temp_forcePlateData = [];

    for ForcePlateSubsample = 0:typecast( Output_GetForcePlateSubsamples.ForcePlateSubsamples, 'int32') - 1
        Output_GetGlobalForceVector = MyClient.GetGlobalForceVector(typecast(ForcePlateIndex, 'uint32'), typecast(ForcePlateSubsample, 'uint32'));
        Output_GetGlobalMomentVector = MyClient.GetGlobalMomentVector(typecast(ForcePlateIndex, 'uint32'), typecast(ForcePlateSubsample, 'uint32'));
      
        % Build force plate data temp matrix
%        temp_forcePlateData(ForcePlateSubsample + 1, 1) = Output_GetGlobalForceVector.ForceVector( 1 ); % fx 
        temp_forcePlateData(ForcePlateSubsample + 1, 1) = Output_GetGlobalForceVector.ForceVector( 2 ); % fy
        temp_forcePlateData(ForcePlateSubsample + 1, 2) = Output_GetGlobalForceVector.ForceVector( 3 ); % fz
        temp_forcePlateData(ForcePlateSubsample + 1, 3) = Output_GetGlobalMomentVector.MomentVector( 1 ); % mx
        temp_forcePlateData(ForcePlateSubsample + 1, 4) = Output_GetGlobalMomentVector.MomentVector( 2 ); % my
%         temp_forcePlateData(ForcePlateSubsample + 1, 6) = Output_GetGlobalMomentVector.MomentVector( 3 ); % mz

    end % ForcePlateSubsample  

    forcePlateData = [forcePlateData, temp_forcePlateData];

end % ForcePlateIndex

% Average the subsamples 
forcePlateData = mean(forcePlateData);

% Check if nan
if isnan(forcePlateData)
    forcePlateData = zeros(1,8); % Return zeros
end

% Scale the values
forcePlateData = forcePlateData .* scales;

