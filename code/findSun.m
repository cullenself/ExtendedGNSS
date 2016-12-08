function [ r_ecef ] = findSun( dnum )
%findSun - provides the position vector of the sun in WGS-84 ECEF
% coordinates as a function of the current date
%
%   Inputs: dnum - Matlab datenum
%
%   Outputs: r_ecef - 3x1 vector (m)
%
%   BEWARE: Degrees everywhere, also: unsure of how to check
%
%   Reference: 
%       Meeus, Jean, Astronomical Algorithms (2nd Ed.). Richmond:
%           Willmann-Bell, Inc., 1998, Ch. 25-26
T = (dnum-datenum(2000,1,1,12,0,0))/36525;
L = 280.46646 + 36000.76983 * T + 0.0003032 * T^2;
M = 357.52911 + 35999.05029 * T + 0.0001537 * T^2;
e = 0.016708634 - 0.000042037 * T - 0.0000001267 * T^2;
C = (1.914602 - 0.004817 * T -0.000014 * T^2) * sind(M) + ...
    (0.019993 - 0.000101 * T) * sind(2*M) + ...
    0.000289 * sind(3*M);
s = L + C;
v = M + C;
R = 149597870700*(1.000001018 * ( 1 - e^2 ))/(1 + e*cosd(v));
omega = 125.04 - 1934.136 * T;
long = s - 0.00569 - 0.00478 * sind(omega);
obliq = 23.0 + (26.0 + (21.448 - T * (46.8150 + T * ...
                           (0.00059 - 0.001813 * T))) / 60) / 60 + ...
                           0.00256 * cosd(omega);

r_ecliptic = R*[cosd(long);sind(long)*cosd(obliq);sind(long)*sind(obliq)];
r_ecef = eci2ecef(r_ecliptic,dnum);
end