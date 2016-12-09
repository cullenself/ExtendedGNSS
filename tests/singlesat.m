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
sat53.i0 = 0;

[sv.r, sv.v] = satloc(gpsWeek,gpsSec,sat53);
sv.u = -sv.r/norm(sv.r);

for i = 1:1000
    d(i) = ((i-1)*(385000-20000)/1000+20000)*1000;
    sv.rel = sv.r - [10000;0;d(i)];
    [phi(i), theta(i)] = findRotationAngle(sv, gpsWeek, gpsSec);
    if (abs(theta(i)) < EarthCutoff) || (abs(theta(i)) > 90)
        visible(i).power = NaN;
        visible(i).cn0 = 0;
    else
        visible(i).power = SatPowerOut(31) + SatDirectivityGain(dirGain,theta(i), phi(i)) + SatGainCF(31) + 20*log10(lambdaGPSL1/(4*pi*norm(sv.rel))); % multiple things need to be checked out, log vs log10, need to make SatPowerOut matrix, SatDGain depends on another angle that I don't know, must make up RXGain, need to cite this formula
        visible(i).cn0 = visible(i).power - 10*log10(190) + 228.6; % RXNoise is negative
    end
end
figure(1);
plot(d,phi);
figure(2);
plot(d,theta);
figure(3);
plot(d,[visible.cn0]);


clearvars('phi','theta');
[X,Y] = meshgrid(-100000:1000:100000);
X = X*1000;
Y = Y*1000;
sv.r = [20000000;0;0];
sv.u = [-1;0;0];
sv.v = [0;sqrt(3.986004418e14/norm(sv.r));0];
for i = 1:size(X,1)
    for j = 1:size(Y,1)
        sv.rel = sv.r - [X(1,i);Y(j,1);0];
        [phi(j,i), theta(j,i)] = findRotationAngle(sv, gpsWeek, gpsSec);
        if (abs(theta(j,i)) < EarthCutoff) || (abs(theta(j,i)) > 90)
            cn0(j,i) = NaN;
            continue;
        end
        power = SatPowerOut(31) + SatDirectivityGain(dirGain,theta(j,i), phi(j,i)) + SatGainCF(31) + 20*log10(lambdaGPSL1/(4*pi*norm(sv.rel))); % multiple things need to be checked out, log vs log10, need to make SatPowerOut matrix, SatDGain depends on another angle that I don't know, must make up RXGain, need to cite this formula
        cn0(j,i) = power - 10*log10(190) + 228.6; % RXNoise is negative
        if cn0(j,i) > 100
            disp('help');
        end
    end
end
figure(4)
surf(X,Y,cn0);
hold on;
scatter3(sv.r(1),sv.r(2),sv.r(3),500);
scatter3(0,0,0,6378);
figure(5)
surf(X,Y,theta);
hold on;
scatter3(sv.r(1),sv.r(2),sv.r(3),500);
scatter3(0,0,0,6378);