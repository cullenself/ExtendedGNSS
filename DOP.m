clear; close all; clc;

addpath('./code');
addpath('./code/helpers');
addpath('./config');

rx.RXNoise = -4.5; % dB-Hz
rx.r = [385000000,0,0]'; % m
rx.u = -rx.r/norm(rx.r); % unit vector representing rx antenna orientation
rx.Tsys = 190; % Kelvin ***double check this number
rx.RXGain = 5; % dB
gpsWeek = 1920;
gpsSec = 345680;
thresh = 30;

satdata = retrieveNavigationData(gpsWeek,gpsSec,0,'./NavFiles');

% Vary the range to find needed gain
for i = 1:1000
    d(i) = ((i-1)*(385000-20000)/1000+20000)*1000;
    rx.r = [d(i);0;0];
    [ tracked, neededGain(i) ] = observe( rx , gpsWeek , gpsSec , satdata, thresh );
    count(i) = numel(tracked);
    if count(i) >= 4
        for n = 1:numel(tracked)
            A(n,1:3) = tracked(n).rel'/norm(tracked(n).rel);
        end
        A(:,4) = -1;
        A = -A;
        D = inv(A'*A);
        GDOP(i) = sqrt(trace(D));
    else
        GDOP(i) = NaN;
    end
        
end
plot((d./1000 - 6371),neededGain);
xlabel('Altitude (km)');
ylabel('Needed Additional Gain (dB)');
title('Extra Gain needed to track 4 satellites');

figure(2)
plot((d./1000 - 6371),GDOP);

figure(3)
plot((d./1000 - 6371),count);