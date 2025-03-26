function mass = getUserMass(MyClient)

forcePlateData = pullForcePlateData(MyClient);
mass = forcePlateData(2) + forcePlateData(6);   % Newtons, vertical GRFs
mass = mass/9.81;                               % Convert to kg