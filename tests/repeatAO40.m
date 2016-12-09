clear; close all; clc;

addpath('../code');
addpath('../code/helpers');
addpath('../config');

rx.RXNoise = -4.5; % dB-Hz
rx.r = [60000,0,0]' * 1000; % m
rx.u = -rx.r/norm(rx.r); % unit vector representing rx antenna orientation
rx.Tsys = 190; % Kelvin ***double check this number
rx.RXGain = 4; % dB
gpsWeek = 1920;
gpsSec = 345680;
thresh = 40;

satdata = retrieveNavigationData(gpsWeek,gpsSec,0,'../NavFiles');
gpsSecVec = gpsSec+(1:48*4)*15*60;
for i = 1:(48*4)
    [ tracked, neededGain(i) ] = observe( rx , gpsWeek , gpsSecVec(i), retrieveNavigationData(gpsWeek,gpsSecVec(i),0,'../NavFiles') , thresh );
    numSats(i) = numel(tracked);
end

figure(1);
stairs(gpsSecVec,numSats);
xlabel('GPS Second');
ylabel('Number of Satellites');
title('Satellites Tracked vs Time for AO40 Replication');
print('../Images/ao40actual','-dpng');
mean(numSats)

% Lower the threshold
thresh = 25;

satdata = retrieveNavigationData(gpsWeek,gpsSec,0,'../NavFiles');
gpsSecVec = gpsSec+(1:48*4)*15*60;
for i = 1:(48*4)
    [ tracked, neededGain(i) ] = observe( rx , gpsWeek , gpsSecVec(i), retrieveNavigationData(gpsWeek,gpsSecVec(i),0,'../NavFiles') , thresh );
    numSats(i) = numel(tracked);
end

figure(2)
stairs(gpsSecVec,numSats);
xlabel('GPS Second');
ylabel('Number of Satellites');
title('Satellites Tracked vs Time for Modified AO40 Replication');
print('../Images/ao40better','-dpng');
mean(numSats)