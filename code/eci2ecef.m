function [ r_ecef ] = eci2ecef( r_eci, dnum )
%UNTITLED2 Summary of this function goes here
%   Reference: Meeus, Jean, Astronomical Algorithms (2nd Ed.). Richmond:
%       Willmann-Bell, Inc., 1998, Ch. 12. - Calculation of GMST
T = (dnum-datenum(2000,1,1,12,0,0))/36525;
theta_g = mod(280.46061837 + 360.98564733629*(T*36525) + 0.000387933*T^2 - T^3/38710000,360);
Q = rotate(theta_g,3);
r_ecef = Q'*r_eci;
end

