RXNoise = -4.5; % dB-Hz
antenna.r = [3578600,0,0]'; % km
antenna.u = -antenna.r/norm(antenna.r); % unit vector representing rx antenna orientation
Tsys = 190; % Kelvin ***double check this number
TXPower = 27; % dBW
RXGain = 5; % dB
gpsWeek = 1920;
gpsSec = 345680;