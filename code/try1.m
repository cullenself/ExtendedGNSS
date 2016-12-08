clear; clc; close all;
% Constants
navDirectory = '../NavFiles';
EarthCutoff = 13.8; % deg ( need to calculate based on size of Earth and distance )
TXConfig;
navConstants;
rxconfig;

% Read in a certain day
satdata = retrieveNavigationData(gpsWeek,gpsSec,0,navDirectory);
% break out into positions and pointing angles
for i = 1:length(satdata)
    [trans(i).r, trans(i).v] = satloc(gpsWeek,gpsSec,satdata(i));
    trans(i).u = -trans(i).r/norm(trans(i).r);
    trans(i).rel = trans(i).r - antenna.r;
    [trans(i).phi, trans(i).offboreTX] = findRotationAngle(trans(i), gpsWeek, gpsSec); % returns phi in degrees, function of SV position, RX position, and time
%     trans(i).offboreRX = acosd(dot(trans(i).rel,antenna.u)/norm(trans(i).rel)); % in degrees
    if (abs(trans(i).offboreTX) < EarthCutoff || abs(trans(i).offboreTX) > 90 )
        trans(i).blocked = 1;
    else
        trans(i).blocked = 0;
    end
    % Other Assorted Information
    trans(i).SVID = satdata(i).SVID;
end

% trim the list
visible = trans(~[trans.blocked]);
% screen out sats for which no data is available ***
visible = visible(ismember([visible.SVID],validSVIDs));

for i = 1:length(visible)
    % Calculate Second Angle, Phi, use a function because its a fairly involved process
    visible(i).power = SatPowerOut(visible(i).SVID) + SatDirectivityGain(dirGain,visible(i).offboreTX, visible(i).phi) + SatGainCF(visible(i).SVID) + 20*log10(lambdaGPSL1/(4*pi*norm(visible(i).rel))) + RXGain; % multiple things need to be checked out, log vs log10, need to make SatPowerOut matrix, SatDGain depends on another angle that I don't know, must make up RXGain, need to cite this formula
    visible(i).cn0 = visible(i).power - 10*log10(Tsys) + 228.6 + RXNoise; % RXNoise is negative
    if visible(i).cn0 > 25
        visible(i).tracked = 1;
    else
        visible(i).tracked = 0;
    end
end
