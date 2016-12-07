function [gpsWeek, gpsSec] = utc2gps(n)
% utc2gps : Convert UTC time to GPS time expressed in GPS week and GPS
% second of week.
%
%
% INPUTS
%
% n -------------- The UTC time and date expressed as a Matlab datenum. Use
% the Matlab function datenum() to generate n; use datestr()
% to render n in a standard format.
%
%
% OUTPUTS
%
% gpsWeek -------- The unambiguous GPS week number where zero corresponds to
% midnight on the evening of 5 January/morning of 6 January,
% 1980. By unambiguous is meant the full week count since
% the 1980 reference time (no rollover at 1024 weeks).
%
% gpsSec --------- The GPS time of week expressed as GPS seconds from midnight
% on Saturday.
%
%+------------------------------------------------------------------------+
% References: Lecture Notes 9/7
%   Bulletin C 52 - IERS
%
% Author: Matthew Self - mcs3779
%+========================================================================+

if n > datenum(2017,7,1) % Warn of un-updated leap second count
    warning('Leap second correction may be incorrect!!');
end
    
leap = 17; % current leap second count (9/20/2016)
if n > datenum(2017,1,1) % next leap second addition
    leap = leap + 1;
end

n = n - datenum(1980,1,6); % days from epoch
seconds = n*86400 + leap; % seconds from epoch, accounting for leap
gpsWeek = floor(seconds/604800); % convert seconds to week
gpsSec = mod(seconds,604800); % subtract week count from total seconds
end