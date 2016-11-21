function [satdata, ionodata] = getephem(fname, ephday, ephtime)
% getephem : Extract satellite ephemeris data from RINEX version 2.1
%            navigation data file.
%
%
% INPUTS
%
% fname ------ Name of a RINEX ephemeris file (including path)
%
% ephday ----- Day of the month of ephtime
%
% ephtime ---- Target time for ephemerides, in seconds of day (e.g., 3600 is
%              0100 hours) rounded to the nearest hour, where time is GPS time.
%              This function will extract ephemerides for the most recent
%              records within promptWindow seconds of ephtime, where
%              promptWindow is a constant defined below.
%
% OUTPUTS
%
% satdata ---- Ephemeris structure array with the following fields:
%
%       SVID - satellite number
%       health - satellite health flag (0 = healthy; otherwise unhealthy)
%       we - week of ephemeris epoch (GPS week, unambiguous)
%       te - time of ephemeris epoch (GPS seconds of week)
%       wc - week of clock epoch (GPS week)
%       tc - time of clock epoch (GPS seconds of week)
%       e - eccentricity (unitless)
%       sqrta - sqrt of orbit semi-major axis (m^1/2)
%       omega0 - argument of perigee (rad.)
%       M0 - mean anomaly at epoch (rad.)
%       L0 - longitude of ascending node at beginning of week (rad.)
%       i0 - inclination angle at epoch (rad.)
%       dOdt - longitude rate (rad / sec.)
%       dn - mean motion difference (rad / sec.)
%       didt - inclination rate (rad / sec.)
%       Cuc - cosine correction to argument of perigee (rad.)
%       Cus - sine correction to argument of perigee (rad.)
%       Crc - cosine correction to orbital radius (m)
%       Crs - sine correction to orbital radius (m)
%       Cic - cosine correction to inclination (rad.)
%       Cis - sine correction to inclination (rad.)
%       af0 - 0th order satellite clock correction (s)
%       af1 - 1st order satellite clock correction (s / s)
%       af2 - 2nd order satellite clock correction (s / s^2)
%       TGD - group delay time for the satellite (s)
%
% ionodata -- Ionospheric data structure array with the following fields:
%
%       alpha0, alpha1, alpha2, alpha3 - power series expansion coefficients
%           for amplitude of ionospheric TEC
%
%       beta0, beta1, beta2, beta3 - power series expansion coefficients for
%            period of ionospheric plasma density cycle
% 
%+------------------------------------------------------------------------------+
% References: See rinex212.pdf for a description of the RINEX 2.1 format.
%
%
% Author: Isaac Miller and Todd Humphreys
%+==============================================================================+

% +/- promptWindow is the time window over which records will be accepted, in
% seconds
promptWindow = 2*3600; 
fid = fopen(fname, 'r');
% Switch on Rinex version
iiPattern = [];
while(isempty(iiPattern))
  data = fgets(fid);
  iiPattern = strfind(data,'RINEX VERSION / TYPE');
end
data = data(1:13);
data = str2num(data);
if (data == 2.1||data==2.11)
  Rinex2p1Script;
else
  error('Only RINEX version 2.11 is supported.');
end

return;

