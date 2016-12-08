function [ r_ecef ] = findSun( dnum )
%UNTITLED3 Summary of this function goes here
%   BEWARE: Degrees everywhere
n = dnum-datenum(2000,1,1,12,0,0);
L = mod(280.460 + 0.9856474 * n,360);
g = mod(357.528 + 0.9856003 * n,360);
long = L + 1.915*sind(g) + 0.02 * sind(2*g);
lat = 0;
R = (1.00014 - 0.01671 * cosd(g) - 0.0014 * cosd(2*g))*149597870700;

r_ecliptic = [R*cosd(lat)*cosd(long);R*cosd(lat)*sind(long);R*sind(lat)];
r_ecef = eci2ecef(r_ecliptic,dnum);
end