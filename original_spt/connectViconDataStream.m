function MyClient = connectViconDataStream

% This code relies on AdaptBool.m and dotNET files which must be downloaded
% from Vicon to implement the Vicon DataStream SDK
% https://www.vicon.com/software/datastream-sdk/ 

if ~exist('axisMapping')
  axisMapping = 'ZUp';
end

if ~exist('HostName')
  HostName = 'localhost:801';
end

% Load the SDK
fprintf('Loading SDK...');
addpath('..\dotNET');
dssdkAssembly = which('ViconDataStreamSDK_DotNET.dll');
if dssdkAssembly == ""
  [file, path] = uigetfile('*.dll');
  if isequal(ile, 0)
    fprintf('User canceled');
    return;
  else
    dssdkAssembly = fullfile(path, file);
  end   
end

NET.addAssembly(dssdkAssembly);

% Make a new client
MyClient = ViconDataStreamSDK.DotNET.Client();

% Connect to a server
while ~MyClient.IsConnected().Connected
  MyClient.Connect(HostName);
end

% Enable device data
MyClient.EnableDeviceData();
fprintf('Device Data Enabled: %s\n',AdaptBool(MyClient.IsDeviceDataEnabled().Enabled));

% Set the buffer size
MyClient.SetBufferSize(1)

% Set the streaming mode
MyClient.SetStreamMode(ViconDataStreamSDK.DotNET.StreamMode.ClientPull);

% Set the global up axis
if axisMapping == 'XUp'
  MyClient.SetAxisMapping(ViconDataStreamSDK.DotNET.Direction.Up, ...
                          ViconDataStreamSDK.DotNET.Direction.Forward,      ...
                          ViconDataStreamSDK.DotNET.Direction.Left ); % X-up
elseif axisMapping == 'YUp'
  MyClient.SetAxisMapping( ViconDataStreamSDK.DotNET.Direction.Forward, ...
                          ViconDataStreamSDK.DotNET.Direction.Up,    ...
                          ViconDataStreamSDK.DotNET.Direction.Right );    % Y-up
else
  MyClient.SetAxisMapping(ViconDataStreamSDK.DotNET.Direction.Forward, ...
                          ViconDataStreamSDK.DotNET.Direction.Left,    ...
                          ViconDataStreamSDK.DotNET.Direction.Up );    % Z-up
end

Output_GetAxisMapping = MyClient.GetAxisMapping();