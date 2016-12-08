function [ tracked, neededGain ] = observe( rx , gpsWeek , gpsSec , satdata , thresh )
%observe - calculate the received power and carrier to noise ratios for a
% given antenna, based on Lockheed Martin provided satellite directivity
% patterns.
%
% Inputs:
%   rx - structure with following fields:
%       r - 3x1 position vector (m)
%       u - 3x1 unit vector of antenna orientation
%       Tsys - nominal system temperature
%       RXNoise - inherent noise/loss due to RX processing
%       RXGain - currently a single value, but eventually need to make a
%           parameter lookup.
%   gpsWeek, gpsSec - time of interest
%
% Outputs:
%   tracked - list of SV's that were able to be tracked
%   neededGain - additional gain needed to make position observable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
config;

% break out into positions and pointing angles
for i = 1:length(satdata)
    [trans(i).r, trans(i).v] = satloc(gpsWeek,gpsSec,satdata(i));
    trans(i).u = -trans(i).r/norm(trans(i).r);
    trans(i).rel = trans(i).r - rx.r;
    [trans(i).phi, trans(i).offboreTX] = findRotationAngle(trans(i), gpsWeek, gpsSec); % returns phi in degrees, function of SV position, RX position, and time
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
    visible(i).power = SatPowerOut(visible(i).SVID) + SatDirectivityGain(dirGain,visible(i).offboreTX, visible(i).phi) + SatGainCF(visible(i).SVID) + 20*log10(lambdaGPSL1/(4*pi*norm(visible(i).rel))) + rx.RXGain; % multiple things need to be checked out, log vs log10, need to make SatPowerOut matrix, SatDGain depends on another angle that I don't know, must make up RXGain, need to cite this formula
    visible(i).cn0 = visible(i).power - 10*log10(rx.Tsys) + 228.6 + rx.RXNoise; % RXNoise is negative
    if visible(i).cn0 > thresh
        visible(i).tracked = 1;
    else
        visible(i).tracked = 0;
    end
end
tracked = visible(~~[visible.tracked]);
temp = sort([visible.cn0],'descend');
neededGain = thresh - temp(4);
end

