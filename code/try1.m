% Constants
navDirectory = '../NavFiles';
RXNoise = -4.5; % dB-Hz
TXPower = 27; % dBW
EarthCutoff = 13.8; % deg ( need to calculate based on size of Earth and distance )
TXConfig;
navConstants;
rxconfig;
% Receiver Position
antenna.r = [35786000,0,0]';
antenna.u = -antenna.r/norm(antenna.r);
% Times
gpsWeek = 1920;
gpsSec = 345680;

% Read in a certain day
satdata = retrieveNavigationData(gpsWeek,gpsSec,0,navDirectory);
% break out into positions and pointing angles
for i = 1:length(satdata)
    [trans(i).r, trans(i).v] = satloc(gpsWeek,gpsSec,satdata(i));
    trans(i).u = -trans(i).r/norm(trans(i).r);
    trans(i).rel = trans(i).r - antenna.r;
    trans(i).offboreTX = acosd(dot(-trans(i).rel,trans(i).u)/(norm(trans(i).rel)*norm(trans(i).u))); % in degrees ( ***need fix this sign ambiguity*** )
    trans(i).offboreRX = acosd(dot(trans(i).rel,antenna.u)/(norm(trans(i).rel)*norm(antenna.u))); % in degrees
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
    visible(i).phi = findRotationAngle(visible(i), gpsWeek, gpsSec); % returns phi in degrees, function of SV position, RX position, and time
    visible(i).power = SatPowerOut(visible(i).SVID) + SatDirectivityGain(dirGain,visible(i).offboreTX, visible(i).phi) + SatGainCF(visible(i).SVID) + 20*log10(lambdaGPSL1/(4*pi*norm(visible(i).rel))) + RXGain; % multiple things need to be checked out, log vs log10, need to make SatPowerOut matrix, SatDGain depends on another angle that I don't know, must make up RXGain, need to cite this formula
    visible(i).cn0 = visible(i).power - 10*log10(Tsys) + 228.6 + RXNoise; % RXNoise is negative
    if visible(i).cn0 > 25
        visible(i).tracked = 1;
    else
        visible(i).tracked = 0;
    end
end
