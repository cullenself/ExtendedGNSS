function [n] = gps2utc(gpsWeek,gpsSec)
% gps2utc : Convert GPS time expressed in GPS week and GPS second of week to
% UTC.
%
%
% INPUTS
%
% gpsWeek -------- The unambiguous GPS week number where zero corresponds to
% midnight on the evening of 5 January/morning of 6 January,
% 1980. By unambiguous is meant the full week count since
% the 1980 reference time (no rollover at 1024 weeks).
%
% gpsSec --------- The GPS time of week expressed as GPS seconds from midnight
% on Saturday.
%
%
% OUTPUTS
%
% n -------------- The UTC time and date expressed as a Matlab datenum. Use
% the Matlab function datestr() to read n in a standard
% format.
%
%+-----------------------------------------------------------------------+
% References: Lecture Notes 9/7
%   Bulletin C 52 - IERS
%
% Author: Matthew Self - mcs3779
%+=======================================================================+
[gpsWeek_warning, gpsSec_warning] = utc2gps(datenum(2017,7,1)); % first possible date for function to be out of date
[gpsWeek_leap, gpsSec_leap] = utc2gps(datenum(2017,1,1)); % next leap second

seconds_gps = gpsSec + 604800*gpsWeek; % total gps seconds

if seconds_gps > [gpsWeek_warning, gpsSec_warning]*[604800; 1] % Warn of un-updated leap second count
    warning('Leap second correction may be incorrect!!');
end
    
leap = 17; % current leap second count (9/20/2016)
if seconds_gps > [gpsWeek_leap, gpsSec_leap]*[604800; 1] % next leap second addition
    leap = leap + 1;
end

seconds = seconds_gps - leap; % seconds from epoch
days = seconds/86400; % fractional day count
n = days + datenum(datetime(1980,1,6)); % add GPS epoch

end