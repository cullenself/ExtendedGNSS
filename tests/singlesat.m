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
    sv.rel = sv.r - [0;0;d(i)];
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
plot(d./1000-6378,phi);
xlabel('Height above North Pole (km)');
ylabel('Phi (deg)');
title('Phi vs Height for SVID 31 at GPS Time: 1920:345680');
print('../images/phivsheight','-dpng');
figure(2);
plot(d./1000-6378,theta);
xlabel('Height above North Pole (km)');
ylabel('Theta (deg)');
title('Theta vs Height for SVID 31 at GPS Time: 1920:345680');
print('../images/thetavsheight','-dpng');
figure(3);
plot(d./1000-6378,[visible.cn0]);
xlabel('Height above North Pole (km)');
ylabel('Unbiased C/N0 (db-Hz)');
title('C/N0 vs Height for SVID 31 at GPS Time: 1920:345680');
print('../images/cn0vsheight','-dpng');

clearvars('phi','theta');
[X,Y] = meshgrid(-100000:1000:100000);
X = X*1000;
Y = Y*1000;
for i = 1:size(X,1)
    for j = 1:size(Y,1)
        sv.rel = sv.r - [X(1,i);Y(j,1);0];
        [phi(j,i), theta(j,i)] = findRotationAngle(sv, gpsWeek, gpsSec);
        if (abs(theta(j,i)) < EarthCutoff) || (abs(theta(j,i)) >= 90)
            cn0(j,i) = NaN;
            continue;
        end
        power = SatPowerOut(31) + SatDirectivityGain(dirGain,theta(j,i), phi(j,i)) + SatGainCF(31) + 20*log10(lambdaGPSL1/(4*pi*norm(sv.rel)));
        cn0(j,i) = power - 10*log10(190) + 228.6;
    end
end
figure(4)
surfc(X./1000,Y./1000,cn0);
hold on;
scatter3(sv.r(1)/1000,sv.r(2)/1000,0,1);
scatter3(0,0,0,10);
xlabel('ECEF x (km)');
ylabel('ECEF y (km)');
zlabel('Unbiased C/N0 Ratio (db-Hz)');
title('Unbiased C/N0 Map for SVID 31 at GPS Time: 1920:345680');

sv.r = [20000000;0;0];
sv.u = [-1;0;0];
sv.v = [0;sqrt(3.986004418e14/norm(sv.r));1];
clearvars('phi','theta');
[X,Y] = meshgrid(-100000:1000:100000);
X = X*1000;
Y = Y*1000;
for i = 1:size(X,1)
    for j = 1:size(Y,1)
        sv.rel = sv.r - [X(1,i);Y(j,1);0];
        [phi(j,i), theta(j,i)] = findRotationAngle(sv, gpsWeek, gpsSec);
        if (abs(theta(j,i)) < EarthCutoff) || (abs(theta(j,i)) >= 90)
            cn0(j,i) = NaN;
            continue;
        end
        power = SatPowerOut(31) + SatDirectivityGain(dirGain,theta(j,i), phi(j,i)) + SatGainCF(31) + 20*log10(lambdaGPSL1/(4*pi*norm(sv.rel)));
        cn0(j,i) = power - 10*log10(190) + 228.6;
    end
end
figure(5)
surfc(X./1000,Y./1000,cn0);
hold on;
scatter3(sv.r(1)/1000,sv.r(2)/1000,1);
scatter3(0,0,0,10);
xlabel('ECEF x (km)');
ylabel('ECEF y (km)');
zlabel('Unbiased C/N0 Ratio (db-Hz)');
title('Unbiased C/N0 Map for Ideal Satellite on ECEF x-axis');