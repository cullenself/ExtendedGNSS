clear; close all; clc;

addpath('../code');
addpath('../code/helpers');
addpath('../config');

gpsWeek = 1920;
gpsSec = 345680;
EarthCutoff = ceil(atan2d(6371+500,20200+6371));
config;

satdata = retrieveNavigationData(gpsWeek,gpsSec,0,'../NavFiles');

sat53 = satdata([satdata.SVID]==31);

[sv.r, sv.v] = satloc(gpsWeek,gpsSec,sat53);
sv.u = -sv.r/norm(sv.r);

for i = 1:1000
    d(i) = ((i-1)*(385000-20000)/1000+20000)*1000;
    sv.rel = sv.r - [d(i);0;0];
    [phi(i), theta(i)] = findRotationAngle(sv, gpsWeek, gpsSec);
    visible(i).power = SatPowerOut(31) + SatDirectivityGain(dirGain,theta(i), phi(i)) + SatGainCF(31) + 20*log10(lambdaGPSL1/(4*pi*norm(sv.rel))); % multiple things need to be checked out, log vs log10, need to make SatPowerOut matrix, SatDGain depends on another angle that I don't know, must make up RXGain, need to cite this formula
    visible(i).cn0 = visible(i).power - 10*log10(190) + 228.6; % RXNoise is negative
end

plot(d,phi);

figure
plot(d,theta);

figure
plot(d,[visible.cn0]);