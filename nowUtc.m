function [n] = nowUtc()
% nowUtc : Return current UTC time as a date number.
%
% OUTPUTS
% 
% n -------------- The UTC time and date expressed as a Matlab datenum.  Use
%                  the Matlab function datestr() to read n in a standard
%                  format.
%
%+------------------------------------------------------------------------------+
% References:
%
%
% Author:  Todd Humphreys
%+==============================================================================+
    
nref = datenum(1970,1,1,0,0,0);
deltaUtcMs = java.lang.System.currentTimeMillis;
n = nref + deltaUtcMs/1000/86400;