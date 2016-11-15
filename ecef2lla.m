function [lat,lon,alt] = ecef2lla(pVec)
% ecef2lla : Convert from a position vector in the Earth-centered, Earth-fixed
% (ECEF) reference frame to latitude, longitude, and altitude
% (geodetic with respect to the WGS-84 ellipsoid).
%
%
% INPUTS
%
% pVec ---- 3-by-1 position coordinate vector in the ECEF reference frame,
% in meters.
%
% OUTPUTS
%
% lat ----- latitude in radians
%
% lon ----- longitude in radians
%
% alt ----- altitude (height) in meters above the ellipsoid
%
%+--------------------------------------------------------------------+
% References: Misra & Enge 4.A.1
%
%
% Author: Matthew Self
%+====================================================================+
Re = 6378137; % Radius of Earth (m)
f  = 1/298.257223563; % flattening term
maxIter = 1e10; % Since we have to iterate to find the latitude, 
err_tol = 1e-14; % we need breaking conditions

r_d = sqrt(pVec(1)^2 + pVec(2)^2); % distance from Earth's rotational axis
lat_gc = asin(pVec(3)/Re); % geocentric latitude, straight from Cartesian coords
lon = atan2(pVec(2),pVec(1)); % longitude, straight from Cartesian coords

lat = lat_gc; % initial guess for geodedic latitude
for iter = 1:maxIter
    lat_old = lat;
    Ce = real(Re/(sqrt(1-(2*f-f^2)*sin(lat)^2))); % bulging factor
    lat = atan2(pVec(3)+Ce*(2*f-f^2)*real(sin(lat)),r_d); % guess using corrected z position and distance from rot. axis
    if (abs(lat - lat_old) < err_tol) % if the guess stops converging
        break;
    end
end
alt = r_d/cos(lat) - Ce; % height is position minus bulge
end