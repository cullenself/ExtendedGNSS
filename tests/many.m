clear; close all; clc;

addpath('../code');
addpath('../code/helpers');
addpath('../config');

gpsWeek = 1920;
gpsSec = 345680;
EarthCutoff = ceil(atan2d(6371+500,20200+6371));
config;

satdata = retrieveNavigationData(gpsWeek,gpsSec,0,'../NavFiles');

rx.Tsys = 1;
rx.RXNoise = 0;
rx.RXGain = 0;
thresh = 25;

[X,Y] = meshgrid(-400000:1000:400000);
X = X*1000;
Y = Y*1000;
for i = 1:size(X,1)
    for j = 1:size(Y,1)
        rx.r = [X(1,i);Y(j,1);0];
        [ tracked, neededGain(j,i) ] = observe( rx , gpsWeek , gpsSec , satdata , thresh );
        numSats(j,i) = numel(tracked);
    end
end
surf(X./1000,Y./1000,numSats,'LineStyle','none')
xlabel('ECEF x (km)')
ylabel('ECEF y (km)')
title('Number of GPS Satellites Tracked vs Position')
colorbar;