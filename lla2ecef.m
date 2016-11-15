function [pVec] = lla2ecef(lat,lon,alt)
% lla2ecef : Convert from latitude, longitude, and altitude (geodetic with
% respect to the WGS-84 ellipsoid) to a position vector in the
% Earth-centered, Earth-fixed (ECEF) reference frame.
%
%
% INPUTS
%
% lat ----- latitude in radians
%
% lon ----- longitude in radians
%
% alt ----- altitude (height) in meters above the ellipsoid
%
%
% OUTPUTS
%
% pVec ---- 3-by-1 position coordinate vector in the ECEF reference frame,
% in meters.

%
%+--------------------------------------------------------------------+
% References: Misra & Enge 4.A.1
%
%
% Author: Matthew Self
%+====================================================================+
Re = 6378137; % Radius of Earth (m)
f  = 1/298.257223563; % flattening

assert(abs(lat) <= pi/2,'Latitude must range from -pi/2 to pi/2!');
assert(abs(lon) <= pi,'Longitude must range from -pi to pi!');

% The radius is effectively Re*(some correction) + altitude, then changed
% from spherical coordinates to Cartesian.
gs_pos_x = ((Re/(sqrt(1-(2*f-f^2)*sin(lat)^2)))+alt)*cos(lat)*cos(lon);
gs_pos_y = ((Re/(sqrt(1-(2*f-f^2)*sin(lat)^2)))+alt)*cos(lat)*sin(lon);
gs_pos_z = (((Re*(1-f)^2)/sqrt(1-(2*f-f^2)*sin(lat)^2))+alt)*sin(lat);
pVec = [gs_pos_x gs_pos_y gs_pos_z];