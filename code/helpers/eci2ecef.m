function [ r_ecef ] = eci2ecef( r_eci, dnum )
%eci2ecef - Converts an Earth Centered Inertial position at a specific
%instance to an Earth Centered, Earth Fixed position at that same instance.
%
%   Inputs:
%       r_eci: 3x1 position vector (unit blind)
%       dnum: Matlab datenum (UTC)
%
%   Outputs:
%       r_ecef: 3x1 position vector (same units as input)
%
%   Assumptions: Ignoring precession, nutation, polar motion
%
%   Reference: 
%       Meeus, Jean, Astronomical Algorithms (2nd Ed.). Richmond:
%           Willmann-Bell, Inc., 1998, Ch. 12. - Calculation of GMST
%       http://earth-info.nga.mil/GandG/publications/tr8350.2/tr8350.2-a/Appendix.pdf
T = (dnum-datenum(2000,1,1,12,0,0))/36525;
theta_g = mod(280.46061837 + 360.98564733629*(T*36525) + 0.000387933*T^2 - T^3/38710000,360);
Q = rotate(theta_g,3);
r_ecef = Q'*r_eci;
end